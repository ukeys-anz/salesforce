/**
 * @author Naman Garg
 * @since  14 May 2025
 * @group CCRM (Commercial CRM)
 * @description CommercialLeadMappingEngine is class to handle mapping of account & contact to lead for manual & UNICA leads
 */
public with sharing class CommercialLeadMappingEngine {
  @TestVisible
  private Map<Id, Account> mapAccountsRecordTypeId = null;
  @TestVisible
  private Map<Id, Account> accountsMap = new Map<Id, Account>();
  @TestVisible
  private Map<String, Industry__c> mapIndustries = new Map<String, Industry__c>();
  @TestVisible
  private List<Lead> leadList = new List<Lead>();
  private Map<string, string> mappedField = new Map<string, string>();

  private static final String INDUSTRY_FIELD = 'Industry__c';
  private static final String IS_PREFERRED_CONTACT_FIELD = 'Is_Preferred_Contact__c';
  private static final String FIRSTNAME_FIELD = 'FirstName';
  private static final String LASTNAME_FIELD = 'LastName';
  private static final String BUSINESS_ACCOUNT = 'Business';
  private static final String CUSTOMER_ACCOUNT = 'Customer';
  private static final String CLG_ACCOUNT = 'CLG';
  private static final String ACCOUNT_OBJECT = 'Account';
  private static final String CONTACT_OBJECT = 'Contact';
  private static final String ORIGINATOR_UNICA = 'Unica';
  private static final String NO_CONTACT_FOUND = 'No Contact Found';
  private static final String COMMERCIAL_CONTACT_INFO = 'Check for Commercial Contacts on profile';

  private static final Map<Id, String> ACCOUNT_TYPE_MAP = new Map<Id, String>{
    RTAccount.businessAccount => BUSINESS_ACCOUNT,
    RTAccount.personAccount => CUSTOMER_ACCOUNT,
    RTAccount.clgAccount => CLG_ACCOUNT
  };
  private static final Set<SObjectField> ELIGIBLE_FIELD_SET = new Set<SObjectField>{
    Lead.Customer_ID__c,
    Lead.Business_ID__c,
    Lead.CLG_ID__c
  };

  private static final LeadActionsRepository LEAD_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );

  private static final UserInfoRepository USER_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private static final CommercialLeadMappingEngineHelper LEAD_MAPPING_HELPER = (CommercialLeadMappingEngineHelper) Lib_InstanceProvider.forType(
    CommercialLeadMappingEngineHelper.class
  );

  /**
   * @description This method prefill data from Account to Leads for Manual Leads
   * @name prefillManualLeadsFromAccount
   * @param records List of lead records
   * @param relatedPartyIds Set of related party Ids
   */
  public void prefillManualLeadsFromAccount(
    List<Lead> records,
    Set<String> relatedPartyIds
  ) {
    PrefillManualLeadWrapper prefillManualLeadWrap = new PrefillManualLeadWrapper();

    mapAccountsRecordTypeId = LEAD_REPOSITORY.getAccountsByRelatedPartyIds(
      relatedPartyIds
    );

    prefillManualLeadWrap = LEAD_MAPPING_HELPER.formAccountToLeadMappingMap(
      records,
      mapAccountsRecordTypeId
    );

    List<Account> account = queryAccounts(
      prefillManualLeadWrap,
      relatedPartyIds
    );

    if (account.isEmpty()) {
      return;
    }

    leadList = records;
    accountsMap = new Map<Id, Account>(account);

    List<Industry__c> industryList = LEAD_REPOSITORY.getIndustries();

    mapIndustries = (Map<String, Industry__c>) ListUtil.mapBy(
      industryList,
      Industry__c.Code__c
    );

    mapAccountFieldsToLead(
      prefillManualLeadWrap.accountToLeadMappingWithAccount
    );

    List<Lead> filteredLeadList = ListUtil.filter(leadList)
      .equals(Lead.RecordTypeId, RTLead.commercialLead)
      .toList();

    setLeadDefaultData(filteredLeadList);

    prefillIndustry(filteredLeadList);
  }

  /**
   * @description queryAccounts this is used to form account query
   * @name queryAccounts
   * @param prefillManualLeadWrap prefill manual lead Wrapper
   * @param relatedPartyIds Set of related party Ids
   * @return List<Account> account List
   */
  @TestVisible
  private List<Account> queryAccounts(
    PrefillManualLeadWrapper prefillManualLeadWrap,
    Set<String> relatedPartyIds
  ) {
    if (
      prefillManualLeadWrap.accountToLeadMappingWithAccount.isEmpty() ||
      String.isBlank(prefillManualLeadWrap.query)
    ) {
      return new List<Account>();
    }
    prefillManualLeadWrap.query = prefillManualLeadWrap.query.removeEnd(',');
    prefillManualLeadWrap.query =
      'SELECT ' +
      prefillManualLeadWrap.query +
      ' FROM Account WHERE Id IN :relatedPartyIds  ';

    return LEAD_REPOSITORY.getAccounts(
      prefillManualLeadWrap.query,
      relatedPartyIds
    );
  }

  /**
   * @description This method map account fields to lead fields using custom metadata
   * @name mapAccountFieldsToLead
   * @param accountToLeadMappingWithAccount Map of accounts fields to lead fields with Key as account type
   */
  @TestVisible
  private void mapAccountFieldsToLead(
    Map<String, Map<String, String>> accountToLeadMappingWithAccount
  ) {
    for (Lead lead : leadList) {
      Id accountRecordTypeId = mapAccountsRecordTypeId.get(
          lead.FinServ__RelatedAccount__c
        )
        ?.RecordTypeId;
      String accountType = ACCOUNT_TYPE_MAP.get(accountRecordTypeId);
      Map<String, String> accountToLeadMapping = accountToLeadMappingWithAccount.get(
        accountType
      );

      for (String fieldName : accountToLeadMapping.keySet()) {
        String leadField = accountToLeadMapping.get(fieldName);
        //Exempt Industry from dynamic mapping.
        //Its mapped manually because its a lookup on Account and picklist on Lead
        if (lead.get(leadField) != null || leadField == INDUSTRY_FIELD) {
          continue;
        }
        lead.put(
          leadField,
          accountsMap.get(lead.FinServ__RelatedAccount__c).get(fieldName)
        );
      }
    }
  }

  /**
   * @description This method set the default data for Lead
   * @name setLeadDefaultData
   * @param filteredLeadList filtered leads of commmercial recordType
   */
  @TestVisible
  private void setLeadDefaultData(List<Lead> filteredLeadList) {
    for (Lead lead : filteredLeadList) {
      Id accountRecordTypeId = mapAccountsRecordTypeId.get(
          lead.FinServ__RelatedAccount__c
        )
        ?.RecordTypeId;
      String accountType = ACCOUNT_TYPE_MAP.get(accountRecordTypeId);

      lead.New_to_Bank__c = 'No';
      switch on accountType {
        when 'Customer', 'CLG' {
          if (String.isBlank(lead.Company)) {
            lead.Registered_Company__c = 'No';
          }
        }
        when 'Business' {
          lead.Registered_Company__c = 'Yes';
        }
      }
    }
  }

  /**
   * @description This method prefill Industry for lead. Not done through dynamic mapping because Industry is Lookup on lead and picklist on Account
   * @name prefillIndustry
   * @param filteredLeadList filtered leads of commmercial recordType
   */
  @TestVisible
  private void prefillIndustry(List<Lead> filteredLeadList) {
    for (Lead lead : filteredLeadList) {
      if (String.isNotBlank(lead.Industry__c)) {
        continue;
      }
      lead.Industry__c = accountsMap.get(lead.FinServ__RelatedAccount__c)
        ?.Industry__c;
    }
  }

  /**
   * @description This method prefill data from Account to Leads for UNICA leads
   * @name prefillUnicaLeads
   * @param records List of lead records
   * @param accountMap Map of account
   */
  public void prefillUnicaLeads(
    List<Lead> records,
    Map<String, Account> accountMap
  ) {
    PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new PrefillUnicaLeadWrapper();

    Set<String> relatedPartyIds = ListUtil.getStrings(
      accountMap.values(),
      Account.Id
    );

    prefillUnicaLeadWrap = LEAD_MAPPING_HELPER.formAccountContactToLeadMappingMap(
      records,
      accountMap
    );

    prefillManualLeadsFromAccount(records, relatedPartyIds);

    List<FinServ__AccountAccountRelation__c> accountToAccountRelationsList = LEAD_REPOSITORY.getAccountAccountRelationsRecords(
      relatedPartyIds
    );

    Map<Id, FinServ__AccountAccountRelation__c> mapOfAccountToAccountRelations = (Map<Id, FinServ__AccountAccountRelation__c>) ListUtil.mapBy(
      accountToAccountRelationsList,
      FinServ__AccountAccountRelation__c.FinServ__Account__c
    );

    mapCorrespondingClgAccount(mapOfAccountToAccountRelations);

    List<Account> account = queryAccountAndRelatedContacts(
      prefillUnicaLeadWrap,
      relatedPartyIds
    );

    if (accountMap.isEmpty()) {
      return;
    }

    leadList = records;
    accountsMap = new Map<Id, Account>(account);
    mappedField = prefillUnicaLeadWrap.accountToLeadMapping;

    mapAccountFieldsToLead(
      prefillUnicaLeadWrap.accountToLeadMappingWithAccount
    );

    Map<Id, Contact> accIdToContactMap = getContactForMapping(leadList);

    mapContactFieldsToLead(
      prefillUnicaLeadWrap.contactToLeadMappingWithContact,
      accIdToContactMap
    );
  }

  /**
   * @description This method map CLG account details associated with Business/Customer to lead fields
   * @name mapCorrespondingClgAccount
   * @param mapOfAccountToAccountRelations Map of Account-Account Relations
   */
  @TestVisible
  private void mapCorrespondingClgAccount(
    Map<Id, FinServ__AccountAccountRelation__c> mapOfAccountToAccountRelations
  ) {
    String accountType = '';
    String relatedAccountType = '';
    FinServ__AccountAccountRelation__c aarRecord = new FinServ__AccountAccountRelation__c();

    if (
      mapOfAccountToAccountRelations.isEmpty() ||
      mapOfAccountToAccountRelations == null
    ) {
      return;
    }

    for (Lead lead : leadList) {
      if (
        !mapOfAccountToAccountRelations.containsKey(
          lead.FinServ__RelatedAccount__c
        )
      ) {
        continue;
      }

      aarRecord = mapOfAccountToAccountRelations.get(
        lead.FinServ__RelatedAccount__c
      );
      accountType = ACCOUNT_TYPE_MAP.get(
        aarRecord.FinServ__Account__r.RecordTypeId
      );
      relatedAccountType = ACCOUNT_TYPE_MAP.get(
        aarRecord.FinServ__RelatedAccount__r.RecordTypeId
      );

      if (relatedAccountType != CLG_ACCOUNT) {
        lead.CLG_Name__c = null;
        continue;
      }
      switch on accountType {
        when 'CLG' {
          lead.CLG_Name__c = lead.FinServ__RelatedAccount__c ??
            lead.CLG_Name__c;
        }
        when 'Business' {
          lead.CLG_Name__c = aarRecord.FinServ__RelatedAccount__r.Id;
        }
        when 'Customer' {
          lead.CLG_Name__c = aarRecord.FinServ__RelatedAccount__r.Id;
          lead.Industry__c = mapIndustries.get(
              aarRecord.FinServ__RelatedAccount__r.Industry
            )
            ?.Id ?? null;
        }
      }
    }
  }

  /**
   * @description this is used to query account and related contact
   * @name queryAccountAndRelatedContacts
   * @param prefillUnicaLeadWrap prefill manual lead Wrapper
   * @param relatedPartyIds Set of related party Ids
   * @return List<Account> Account and related contacts
   */
  @TestVisible
  private List<Account> queryAccountAndRelatedContacts(
    PrefillUnicaLeadWrapper prefillUnicaLeadWrap,
    Set<String> relatedPartyIds
  ) {
    if (
      prefillUnicaLeadWrap.accountToLeadMappingWithAccount.isEmpty() &&
      prefillUnicaLeadWrap.contactToLeadMappingWithContact.isEmpty()
    ) {
      return null;
    }
    if (
      (String.isBlank(prefillUnicaLeadWrap.accountFields) &&
      String.isBlank(prefillUnicaLeadWrap.contactFields))
    ) {
      return null;
    }

    String queryRecords =
      'SELECT ' +
      prefillUnicaLeadWrap.accountFields +
      ' (SELECT ' +
      prefillUnicaLeadWrap.contactFields +
      ' Id FROM Contacts ORDER BY createddate DESC) FROM Account WHERE Id IN :relatedPartyIds';

    return LEAD_REPOSITORY.getAccountsAndRelatedContacts(
      queryRecords,
      relatedPartyIds
    );
  }

  /**
   * @description This methods returns Preferred Contact. If no preferred contact exist return recent created contact otherwise return null
   * @name getContactForMapping
   * @param leadList List of lead records
   * @return Map<Id, Contact> Returns Map of Account Id to Contact map
   */
  @TestVisible
  private Map<Id, Contact> getContactForMapping(List<Lead> leadList) {
    Map<Id, Contact> accIdToContactMap = new Map<Id, Contact>();
    List<Contact> contactList = new List<Contact>();
    for (Lead lead : leadList) {
      contactList = accountsMap.get(lead.FinServ__RelatedAccount__c).contacts;
      if (contactList.size() == 0) {
        accIdToContactMap.put(lead.FinServ__RelatedAccount__c, null);
        continue;
      }
      accIdToContactMap.put(lead.FinServ__RelatedAccount__c, contactList[0]);
    }
    return accIdToContactMap;
  }

  /**
   * @description This method map contact fields to lead fields using custom metadata
   * @name mapContactFieldsToLead
   * @param contactToLeadMappingWithContact account type and Contact to lead mapping
   * @param accIdToContactMap Account Id to Contact map
   */
  @TestVisible
  private void mapContactFieldsToLead(
    Map<String, Map<String, String>> contactToLeadMappingWithContact,
    Map<Id, Contact> accIdToContactMap
  ) {
    String leadField;
    String accountType;
    Contact contactRec = new Contact();
    Map<String, String> contactToLeadMapping = new Map<String, String>();

    for (Lead lead : leadList) {
      accountType = ACCOUNT_TYPE_MAP.get(
        mapAccountsRecordTypeId.get(lead.FinServ__RelatedAccount__c)
          .RecordTypeId
      );
      contactToLeadMapping = contactToLeadMappingWithContact.get(accountType);
      contactRec = accIdToContactMap.get(lead.FinServ__RelatedAccount__c);
      if (
        contactRec == null &&
        lead.FirstName == null &&
        lead.LastName == null
      ) {
        lead.put(FIRSTNAME_FIELD, NO_CONTACT_FOUND);
        lead.put(LASTNAME_FIELD, NO_CONTACT_FOUND);
        continue;
      }
      if (
        contactRec != null &&
        contactToLeadMapping.isEmpty() &&
        lead.FirstName == null &&
        lead.LastName == null
      ) {
        lead.put(FIRSTNAME_FIELD, COMMERCIAL_CONTACT_INFO);
        lead.put(LASTNAME_FIELD, COMMERCIAL_CONTACT_INFO);
        continue;
      }
      for (String fieldName : contactToLeadMapping.keySet()) {
        leadField = contactToLeadMapping.get(fieldName);
        if (
          leadField == IS_PREFERRED_CONTACT_FIELD ||
          lead.get(leadField) != null
        ) {
          continue;
        }
        lead.put(leadField, contactRec.get(fieldName));
      }
    }
  }

  /**
   * @description This method returns related party by Source System ID passed from UNICA lead
   * @name getAccountsBySourceSystemId
   * @param records List of lead records
   * @return Map<String, Account> where Key is Source_System_ID__c.
   */
  public Map<String, Account> getAccountsBySourceSystemId(List<Lead> records) {
    List<Lead> filteredLeadList = ListUtil.filter(records)
      .anyNotNull(ELIGIBLE_FIELD_SET)
      .equals(Lead.Lead_Originator__c, ORIGINATOR_UNICA)
      .toList();

    Set<String> accountIds = getSourceSystemIds(filteredLeadList);

    List<Account> accList = LEAD_REPOSITORY.getRelatedAccounts(accountIds);

    Map<String, Account> mapAccountRecord = (Map<String, Account>) ListUtil.mapBy(
      accList,
      Account.Source_System_ID__c
    );

    return mapAccountRecord;
  }

  /**
   * @description This method returns related party by Source System ID passed from UNICA lead
   * @name getSourceSystemIds
   * @param filteredLeadList List of filtered lead records
   * @return Set<String> set of Source_System_ID__c.
   */
  @TestVisible
  private static Set<String> getSourceSystemIds(List<Lead> filteredLeadList) {
    Set<String> accountIds = new Set<String>();
    for (Lead selectLead : filteredLeadList) {
      accountIds.add(
        selectLead.Customer_ID__c ?? selectLead.Business_ID__c ??
          selectLead.CLG_ID__c
      );
    }
    return accountIds;
  }

  /**
   * @author Naman Garg
   * @since  May 2025
   * @description PrefillManualLeadWrapper is wrapper class
   */
  public class PrefillManualLeadWrapper {
    public String query = '';
    public Map<string, string> accountToLeadMapping = new Map<string, string>();
    public Map<string, string> accountToLeadMappingClone = new Map<string, string>();
    public Map<string, Map<string, string>> accountToLeadMappingWithAccount = new Map<string, Map<string, string>>();
  }

  /**
   * @author Naman Garg
   * @since  May 2025
   * @description PrefillUnicaLeadWrapper is wrapper class
   */
  public class PrefillUnicaLeadWrapper {
    public String accountFields = '';
    public String contactFields = '';
    public Map<string, string> accountToLeadMapping = new Map<string, string>();
    public Map<string, string> contactToLeadMapping = new Map<string, string>();
    public Map<string, string> accountToLeadMappingClone = new Map<string, string>();
    public Map<string, string> contactToLeadMappingClone = new Map<string, string>();
    public Map<string, Map<string, string>> accountToLeadMappingWithAccount = new Map<string, Map<string, string>>();
    public Map<string, Map<string, string>> contactToLeadMappingWithContact = new Map<string, Map<string, string>>();
  }
}
