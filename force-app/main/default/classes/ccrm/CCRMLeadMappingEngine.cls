/**
 * @author Mairaj Haider
 * @since  5/4/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadMappingEngine is class to handle mapping of account & contact to lead for manual & UNICA leads
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMLeadMappingEngine {
  /**
   * @global declarations.
   */
  private Map<Id, Account> mapAccountsRecordTypeId = null;
  private Map<Id, Account> accountList = new Map<Id, Account>();
  private Map<String, Industry__c> mapIndustries = new Map<String, Industry__c>();
  private List<Lead> leadList = new List<Lead>();
  private Map<string, string> mappedField = new Map<string, string>();

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
    Map<string, string> accountToLeadMapping = new Map<string, string>();
    String query = '';

    //Get accounts by related party Ids
    mapAccountsRecordTypeId = getAccountsByRelatedPartyIds(relatedPartyIds);

    //Get mapping from custom metadata
    List<CCRM_Account_To_Lead_Mapping__mdt> mappingsInCustomMetadata = CCRM_Account_To_Lead_Mapping__mdt.getall()
      .Values();

    //Creates Mapping for different types of accounts using Account_Type__c field withing custom metadata
    for (Lead record : records) {
      String accountType = getAccountType(
        mapAccountsRecordTypeId.get(record.FinServ__RelatedAccount__c)
          .RecordTypeId
      );
      if (String.isNotBlank(accountType)) {
        for (
          CCRM_Account_To_Lead_Mapping__mdt mapping : mappingsInCustomMetadata
        ) {
          if (
            mapping.Account_Field_API_Name__c != null &&
            mapping.Lead_Field_API_Name__c != null &&
            mapping.Account_Type__c == accountType &&
            !accountToLeadMapping.containsKey(mapping.Account_Field_API_Name__c)
          ) {
            accountToLeadMapping.put(
              mapping.Account_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
            query += mapping.Account_Field_API_Name__c + ',';
          }
        }
      }
    }

    //Get accounts data for all the fields defined within custom metadata
    if (!accountToLeadMapping.isEmpty() && String.isNotBlank(query)) {
      query = query.removeEnd(',');
      query =
        'SELECT ' +
        query +
        ' FROM Account WHERE Id IN :relatedPartyIds  ';
      List<Account> account = Database.query(query);
      Map<Id, Account> accountMap = new Map<Id, Account>(account);
      //Map Account fields to Leads
      if (accountMap.size() > 0) {
        leadList = records;
        accountList = accountMap;
        mapAccountFieldsToLead(accountToLeadMapping, true);
      }
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
    Map<string, string> accountToLeadMapping = new Map<string, string>();
    Map<string, string> contactToLeadMapping = new Map<string, string>();
    String accountFields = '';
    String contactFields = '';

    //Get accounts by related party Ids
    //mapAccountsRecordTypeId = getAccountsByRelatedPartyIds(relatedPartyIds);
    Set<String> relatedPartyIds = new Set<String>();

    for (Account account : accountMap.values()) {
      relatedPartyIds.add(account.Id);
    }

    //Get ACCOUNT >> LEAD mapping from custom metadata
    List<CCRM_UNICA_To_Lead_Mapping__mdt> mappingsInCustomMetadata = CCRM_UNICA_To_Lead_Mapping__mdt.getall()
      .Values();

    //Creates Mapping for different types of accounts using Account_Type__c field withing custom metadata
    for (Lead record : records) {
      String fieldName = accountMap.containsKey(record.Customer_ID__c)
        ? record.Customer_ID__c
        : accountMap.containsKey(record.Business_ID__c)
            ? record.Business_ID__c
            : accountMap.containsKey(record.Clg_ID__c) ? record.Clg_ID__c : '';
      String accountType = getAccountType(
        accountMap.get(fieldName).RecordTypeId
      );
      if (String.isNotBlank(accountType)) {
        record.FinServ__RelatedAccount__c = accountMap.get(fieldName).Id;

        //Account fields mapping
        for (
          CCRM_UNICA_To_Lead_Mapping__mdt mapping : mappingsInCustomMetadata
        ) {
          if (
            mapping.Object__c == 'Account' &&
            mapping.Account_or_Contact_Field_API_Name__c != null &&
            mapping.Lead_Field_API_Name__c != null &&
            mapping.Account_Type__c == accountType &&
            !accountToLeadMapping.containsKey(
              mapping.Account_or_Contact_Field_API_Name__c
            )
          ) {
            accountToLeadMapping.put(
              mapping.Account_or_Contact_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
            accountFields += mapping.Account_or_Contact_Field_API_Name__c + ',';
          }

          //Contact fields mapping
          if (
            mapping.Object__c == 'Contact' &&
            mapping.Account_or_Contact_Field_API_Name__c != null &&
            mapping.Lead_Field_API_Name__c != null &&
            mapping.Account_Type__c == accountType &&
            !contactToLeadMapping.containsKey(
              mapping.Account_or_Contact_Field_API_Name__c
            )
          ) {
            contactToLeadMapping.put(
              mapping.Account_or_Contact_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
            contactFields += mapping.Account_or_Contact_Field_API_Name__c + ',';
          }
        }
      }
    }

    if (
      (!accountToLeadMapping.isEmpty() || !contactToLeadMapping.isEmpty()) &&
      (String.isNotBlank(accountFields) || String.isNotBlank(contactFields))
    ) {
      //Get accounts and contact data for all the fields defined within custom metadata
      string query =
        'SELECT ' +
        accountFields +
        ' (SELECT ' +
        contactFields +
        ' Id FROM Contacts order by createddate desc) FROM Account WHERE Id IN :relatedPartyIds';

      List<Account> account = Database.query(query);
      Map<Id, Account> accountFieldsMap = new Map<Id, Account>(account);
      //Map Account fields to Leads
      if (accountMap.size() > 0) {
        prefillManualLeadsFromAccount(records, relatedPartyIds);
        leadList = records;
        accountList = accountFieldsMap;
        mappedField = accountToLeadMapping;
        mapAccountFieldsToLead(accountToLeadMapping, false);
        mapContactFieldsToLead(contactToLeadMapping);
        mapCorrespondingClgAccount(relatedPartyIds);
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
    Set<String> accountIds = new Set<String>();
    Map<String, Account> mapAccountRecord = new Map<String, Account>();
    for (Lead selectLead : records) {
      if (selectLead.Lead_Originator__c == CCRMConstants.ORIGINATOR_UNICA) {
        if (!String.isBlank(selectLead.Customer_ID__c)) {
          accountIds.add(selectLead.Customer_ID__c);
        } else if (!String.isBlank(selectLead.Business_ID__c)) {
          accountIds.add(selectLead.Business_ID__c);
        } else if (!String.isBlank(selectLead.CLG_ID__c)) {
          accountIds.add(selectLead.CLG_ID__c);
        }
      }
    }

    if (Schema.sObjectType.Account.isQueryable()) {
      for (Account accountRecord : [
        SELECT
          Id,
          Source_System_ID__c,
          Source_System_Name__c,
          Name,
          RecordTypeId
        FROM Account
        WHERE
          Source_System_Name__c = 'CAP'
          AND Source_System_ID__c IN :accountIds
      ]) {
        if (!String.isBlank(accountRecord.Source_System_ID__c)) {
          mapAccountRecord.put(
            accountRecord.Source_System_ID__c,
            accountRecord
          );
        }
      }
    }
    return mapAccountRecord;
  }

  /**
   * @description This method map account fields to lead fields using custom metadata
   * @name mapAccountFieldsToLead
   * @param accountToLeadMapping Map of accounts fields to lead fields
   * @param isManual For manual leads
   */
  private void mapAccountFieldsToLead(
    Map<string, string> accountToLeadMapping,
    Boolean isManual
  ) {
    if (isManual) {
      for (Industry__c industry : [
        SELECT Id, Name, Code__c
        FROM Industry__c
        WHERE IsActive__c = TRUE
        WITH SECURITY_ENFORCED
      ]) {
        mapIndustries.put(industry.Code__c, industry);
      }
    }

    for (Lead lead : leadList) {
      for (String fieldName : accountToLeadMapping.keySet()) {
        String leadField = accountToLeadMapping.get(fieldName);
        //Exempt Industry from dynamic mapping.
        //Its mapped manually because its a lookup on Account and picklist on Lead
        if (lead.get(leadField) == null && leadField != 'Industry__c') {
          lead.put(
            leadField,
            accountList.get(lead.FinServ__RelatedAccount__c).get(fieldName)
          );
        }
      }
      if (isManual) {
        setLeadDefaultData(lead, accountList, mapIndustries);
      }
    }
  }

  /**
   * @description This method map CLG account details associated with Business/Customer to lead fields
   * @name mapCorrespondingClgAccount
   * @param relatedPartyIds Set of related party Ids
   */
  private void mapCorrespondingClgAccount(Set<String> relatedPartyIds) {
    Map<Id, FinServ__AccountAccountRelation__c> mapOfAccountToAccountRelations = new Map<Id, FinServ__AccountAccountRelation__c>();
    for (FinServ__AccountAccountRelation__c accToAccRelations : [
      SELECT
        FinServ__Account__c,
        FinServ__Account__r.RecordTypeId,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.Id,
        FinServ__RelatedAccount__r.RecordTypeId,
        FinServ__RelatedAccount__r.Industry
      FROM FinServ__AccountAccountRelation__c
      WHERE FinServ__Account__c = :relatedPartyIds
      WITH SECURITY_ENFORCED
    ]) {
      mapOfAccountToAccountRelations.put(
        accToAccRelations.FinServ__Account__c,
        accToAccRelations
      );
    }

    if (
      mapOfAccountToAccountRelations != null &&
      !mapOfAccountToAccountRelations.isEmpty()
    ) {
      for (Lead lead : leadList) {
        FinServ__AccountAccountRelation__c accRelations = mapOfAccountToAccountRelations.get(
          lead.FinServ__RelatedAccount__c
        );
        String accountType = getAccountType(
          accRelations.FinServ__Account__r.RecordTypeId
        );
        String relatedAccountType = getAccountType(
          accRelations.FinServ__RelatedAccount__r.RecordTypeId
        );
        //Prefill Lead - CLG Name ONLY for:
        //Business and Customer Accounts AND WHEN
        //Related account is ONLY CLG
        if (
          relatedAccountType == 'CLG' &&
          string.isNotBlank(accRelations.FinServ__RelatedAccount__r.Id) &&
          (accountType == 'Business' ||
          accountType == 'Customer')
        ) {
          lead.CLG_Name__c = accRelations.FinServ__RelatedAccount__r.Id;
        } else {
          lead.CLG_Name__c = null;
        }
        //If related CLG account exist for customer account then map Industry from CLG related account
        if (
          relatedAccountType == 'CLG' &&
          accountType == 'Customer' &&
          string.isNotBlank(accRelations.FinServ__RelatedAccount__r.Industry) &&
          mapIndustries.containsKey(
            accRelations.FinServ__RelatedAccount__r.Industry
          )
        ) {
          lead.Industry__c = mapIndustries.get(
              accRelations.FinServ__RelatedAccount__r.Industry
            )
            .Id;
        }
        //If related party is CLG account then set CLG name to related party Id
        if (
          accountType == 'CLG' &&
          String.isNotBlank(lead.FinServ__RelatedAccount__c)
        ) {
          lead.CLG_Name__c = lead.FinServ__RelatedAccount__c;
        }
      }
    }
  }

  /**
   * @description This methods returns Preferred Contact. If no preferred contact exist return recent created contact otherwise return null
   * @name getContactForMapping
   * @return Contact Returns Contact object
   */
  private Contact getContactForMapping() {
    Contact contactForMapping = new Contact();
    for (Lead lead : leadList) {
      List<Contact> contacts = accountList.get(lead.FinServ__RelatedAccount__c)
        .contacts;
      if (contacts.size() == 0) {
        return null;
      }
      for (Contact contact : contacts) {
        if (contact.Is_Preferred_Contact__c) {
          contactForMapping = contact;
          break;
        } else {
          contactForMapping = contacts[0];
        }
      }
    }
    return contactForMapping;
  }

  /**
   * @description This method map contact fields to lead fields using custom metadata
   * @name mapContactFieldsToLead
   * @param contactToLeadMapping Fields for mapping
   */
  private void mapContactFieldsToLead(
    Map<string, string> contactToLeadMapping
  ) {
    for (Lead lead : leadList) {
      Contact contact = getContactForMapping();
      //If no contact exist then assign default first and last name
      if (contact == null) {
        lead.put('FirstName', CCRMConstants.NO_CONTACT_FOUND);
        lead.put('LastName', CCRMConstants.NO_CONTACT_FOUND);
      } else {
        for (String fieldName : contactToLeadMapping.keySet()) {
          String leadField = contactToLeadMapping.get(fieldName);
          if (
            leadField != 'Is_Preferred_Contact__c' &&
            lead.get(leadField) == null
          ) {
            lead.put(leadField, contact.get(fieldName));
          }
        }
      }
    }
  }

  /**
   * @description This method returns accounts by related party Ids
   * @name getAccountsByRelatedPartyIds
   * @param relatedPartyIds List of lead records
   * @return Map<Id, Account> where Key is Account Id.
   */
  private Map<Id, Account> getAccountsByRelatedPartyIds(
    Set<String> relatedPartyIds
  ) {
    List<Account> accountList = [
      SELECT Id, RecordTypeId
      FROM Account
      WHERE Id IN :relatedPartyIds
    ];
    Map<Id, Account> accountMap = new Map<Id, Account>(accountList);
    return accountMap;
  }

  /**
   * @description This method returns account type based on record type id
   * @name getAccountType
   * @param recordTypeId Record type Id
   * @return String Return Account Type - Business/Customer/CLG
   */
  public static String getAccountType(Id recordTypeId) {
    String accountType = '';
    if (recordTypeId == CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID) {
      accountType = CCRMConstants.ACCOUNT_TYPE_BUSINESS;
    } else if (recordTypeId == CCRMConstants.ACCOUNT_PERSON_RT_ID) {
      accountType = CCRMConstants.ACCOUNT_TYPE_CUSTOMER;
    } else if (recordTypeId == CCRMConstants.ACCOUNT_CLG_RT_ID) {
      accountType = CCRMConstants.ACCOUNT_TYPE_CLG;
    }
    return accountType;
  }

  /**
   * @description This method set the default data for Lead
   * @name setLeadDefaultData
   * @param lead Lead
   * @param accounts Map of accounts
   * @param mapIndustries Map of Industries
   */
  private void setLeadDefaultData(
    Lead lead,
    Map<Id, Account> accounts,
    Map<String, Industry__c> mapIndustries
  ) {
    String accountType = getAccountType(
      mapAccountsRecordTypeId.get(lead.FinServ__RelatedAccount__c).RecordTypeId
    );
    lead.New_to_Bank__c = 'No';
    prefillIndustry(accounts, lead, mapIndustries);

    switch on accountType {
      when 'Customer', 'CLG' {
        if (String.isBlank(lead.Company)) {
          lead.Not_Registered__c = true;
        }
      }
      when 'Business' {
        lead.Not_Registered__c = false;
      }
    }
  }

  /**
   * @description This method prefill Industry for lead. Not done through dynamic mapping because Industry is Lookup on lead and picklist on Account
   * @name prefillIndustry
   * @param accounts Map of accounts
   * @param lead Lead
   * @param mapIndustries Map of Industries
   */
  private void prefillIndustry(
    Map<Id, Account> accounts,
    Lead lead,
    Map<String, Industry__c> mapIndustries
  ) {
    string industryId = accounts.get(lead.FinServ__RelatedAccount__c).Industry;
    if (
      string.isNotBlank(industryId) &&
      mapIndustries.containsKey(industryId) &&
      String.isBlank(lead.Industry__c)
    ) {
      lead.Industry__c = mapIndustries.get(industryId).Id;
    }
  }
}
