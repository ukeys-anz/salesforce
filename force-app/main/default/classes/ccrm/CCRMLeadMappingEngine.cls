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
  //CC-1056
  private Map<Id, Schema.RecordTypeInfo> mapOfLeadRecordTypes;
  private List<DCRM_Lead_Conversion_Mapping__mdt> leadToSObjectMappingCustomMetadata;

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
    Map<string, Map<string, string>> accountToLeadMappingWithAccount = new Map<string, Map<string, string>>();
    Map<string, string> accountToLeadMapping = new Map<string, string>();
    String query = '';

    //Get accounts by related party Ids
    mapAccountsRecordTypeId = getAccountsByRelatedPartyIds(relatedPartyIds);
    //CC-1056-On Lead, pre-populate customer-related fields
    if (mapOfLeadRecordTypes == null || mapOfLeadRecordTypes.isEmpty()) {
      mapOfLeadRecordTypes = Lead.sobjectType.getDescribe()
        .getRecordTypeInfosById();
    }

    //Get mapping from custom metadata
    List<CCRM_Account_To_Lead_Mapping__mdt> accountToLeadMappingCustomMetadata = CCRM_Account_To_Lead_Mapping__mdt.getall()
      .Values();

    //Creates Mapping for different types of accounts using Account_Type__c field withing custom metadata
    for (Lead record : records) {
      Map<string, string> accountToLeadMappingClone = new Map<string, string>();
      String accountType = getAccountType(
        mapAccountsRecordTypeId.get(record.FinServ__RelatedAccount__c)
          .RecordTypeId
      );
      if (String.isNotBlank(accountType)) {
        for (
          CCRM_Account_To_Lead_Mapping__mdt mapping : accountToLeadMappingCustomMetadata
        ) {
          if (
            mapping.Account_Field_API_Name__c != null &&
            mapping.Lead_Field_API_Name__c != null &&
            mapping.Account_Type__c == accountType &&
            mapping.Lead_Record_Types__c.containsIgnoreCase(
              mapOfLeadRecordTypes.get(record.RecordTypeId).developername
            ) &&
            mapping.Source_System__c.containsIgnoreCase(
              record.Lead_Originator__c
            )
          ) {
            if (
              !accountToLeadMapping.containsKey(
                mapping.Account_Field_API_Name__c
              )
            ) {
              query += mapping.Account_Field_API_Name__c + ',';
            }
            //Holds mapping of account and leads fields from custom metadata
            accountToLeadMapping.put(
              mapping.Account_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
            //Create clone to create Map based on account types
            accountToLeadMappingClone.put(
              mapping.Account_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
          }
        }
        //Maping with Key: Account Type and Values: Lead and Acount fields
        accountToLeadMappingWithAccount.put(
          accountType,
          accountToLeadMappingClone
        );
      }
    }

    //Get accounts data for all the fields defined within custom metadata
    if (
      !accountToLeadMappingWithAccount.isEmpty() && String.isNotBlank(query)
    ) {
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
        mapAccountFieldsToLead(accountToLeadMappingWithAccount, true);
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
    Map<string, Map<string, string>> accountToLeadMappingWithAccount = new Map<string, Map<string, string>>();
    Map<string, Map<string, string>> contactToLeadMappingWithContact = new Map<string, Map<string, string>>();

    Map<string, string> accountToLeadMapping = new Map<string, string>();
    Map<string, string> contactToLeadMapping = new Map<string, string>();
    String accountFields = '';
    String contactFields = '';

    //CC-1056 Getting all the recordtype developername of lead object.
    mapOfLeadRecordTypes = Lead.sobjectType.getDescribe()
      .getRecordTypeInfosById();

    //Get accounts by related party Ids
    //mapAccountsRecordTypeId = getAccountsByRelatedPartyIds(relatedPartyIds);
    Set<String> relatedPartyIds = getRelatedPartyIds(accountMap);

    //Get ACCOUNT >> LEAD mapping from custom metadata
    List<CCRM_UNICA_To_Lead_Mapping__mdt> unicaToLeadMappingCustomMetadata = CCRM_UNICA_To_Lead_Mapping__mdt.getall()
      .Values();

    //Creates Mapping for different types of accounts using Account_Type__c field withing custom metadata
    for (Lead record : records) {
      Map<string, string> accountToLeadMappingClone = new Map<string, string>();
      Map<string, string> contactToLeadMappingClone = new Map<string, string>();
      String fieldName = accountMap.containsKey(record.Customer_ID__c)
        ? record.Customer_ID__c
        : accountMap.containsKey(record.Business_ID__c)
            ? record.Business_ID__c
            : accountMap.containsKey(record.Clg_ID__c) ? record.Clg_ID__c : '';
      if (String.isBlank(fieldName)) {
        record.addError(Label.ML_Unica_Lead_Source_System_Not_Found_Error);
      }
      String accountType = getAccountType(
        accountMap.get(fieldName).RecordTypeId
      );
      if (String.isNotBlank(accountType)) {
        record.FinServ__RelatedAccount__c = accountMap.get(fieldName).Id;
        //Account fields mapping
        for (
          CCRM_UNICA_To_Lead_Mapping__mdt mapping : unicaToLeadMappingCustomMetadata
        ) {
          if (
            mapping.Object__c == 'Account' &&
            mapping.Account_or_Contact_Field_API_Name__c != null &&
            mapping.Lead_Field_API_Name__c != null &&
            mapping.Account_Type__c == accountType &&
            mapping.Lead_Record_Types__c.containsIgnoreCase(
              mapOfLeadRecordTypes.get(record.RecordTypeId).developername
            )
          ) {
            if (
              !accountToLeadMapping.containsKey(
                mapping.Account_or_Contact_Field_API_Name__c
              )
            ) {
              accountFields +=
                mapping.Account_or_Contact_Field_API_Name__c + ',';
            }
            //Holds mapping of account and leads fields from custom metadata
            accountToLeadMapping.put(
              mapping.Account_or_Contact_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
            //Create clone to create Map - accountToLeadMappingWithAccount based on account types
            accountToLeadMappingClone.put(
              mapping.Account_or_Contact_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
          }

          //Contact fields mapping
          if (
            mapping.Object__c == 'Contact' &&
            mapping.Account_or_Contact_Field_API_Name__c != null &&
            mapping.Lead_Field_API_Name__c != null &&
            mapping.Account_Type__c == accountType &&
            mapping.Lead_Record_Types__c.containsIgnoreCase(
              mapOfLeadRecordTypes.get(record.RecordTypeId).developername
            )
          ) {
            if (
              !contactToLeadMapping.containsKey(
                mapping.Account_or_Contact_Field_API_Name__c
              )
            ) {
              contactFields +=
                mapping.Account_or_Contact_Field_API_Name__c + ',';
            }
            //Holds mapping of contact and leads fields from custom metadata
            contactToLeadMapping.put(
              mapping.Account_or_Contact_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
            //Create clone to create Map - contactToLeadMappingWithContact based on account types
            contactToLeadMappingClone.put(
              mapping.Account_or_Contact_Field_API_Name__c,
              mapping.Lead_Field_API_Name__c
            );
          }
        }
        //Maping with Key: Account Type and Values: Lead and Acount fields
        accountToLeadMappingWithAccount.put(
          accountType,
          accountToLeadMappingClone
        );
        //Maping with Key: Account Type and Values: Lead and Contact fields
        contactToLeadMappingWithContact.put(
          accountType,
          contactToLeadMappingClone
        );
      }
    }

    if (
      (!accountToLeadMappingWithAccount.isEmpty() ||
      !contactToLeadMappingWithContact.isEmpty()) &&
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
        mapAccountFieldsToLead(accountToLeadMappingWithAccount, false);
        mapContactFieldsToLead(contactToLeadMappingWithContact);
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
          Source_System_Name__c = :System.Label.CCRM_Source_System_Name
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
   * @description This method map lead fields to opportunity for
   * opportunity creation when lead is converted
   * @name mapLeadToOpportunityFields
   * @param leadMap The map of Lead records.
   * @param mapofAccountId map of lead id and account id from lead conversion result
   * @return Map<Id, Opportunity> Map of lead and opportunities
   */
  public Map<Id, Opportunity> mapLeadToOpportunityFields(
    Map<Id, Lead> leadMap,
    Map<Id, Id> mapofAccountId
  ) {
    Map<Id, Opportunity> mapOfLeadsWithOpportunities = new Map<Id, Opportunity>();
    String mdLeadFields = '';
    String defaultleadFields = System.Label.Lead_Conversion_Default_Fields;
    String leadQuery = '';
    Set<String> leadRecordTypes = new Set<String>();

    //Get Lead to Opportunity mapping from custom metadata
    if (
      leadToSObjectMappingCustomMetadata == null ||
      leadToSObjectMappingCustomMetadata.isEmpty()
    ) {
      leadToSObjectMappingCustomMetadata = DCRM_Lead_Conversion_Mapping__mdt.getall()
        .Values();
    }
    //Getting all the recordtype developername of lead object.
    if (mapOfLeadRecordTypes == null || mapOfLeadRecordTypes.isEmpty()) {
      mapOfLeadRecordTypes = Lead.sobjectType.getDescribe()
        .getRecordTypeInfosById();
    }
    for (Lead leadRec : leadMap.values()) {
      leadRecordTypes.add(
        mapOfLeadRecordTypes.get(leadRec.RecordTypeId).developername
      );
    }
    for (String leadRecType : leadRecordTypes) {
      for (
        DCRM_Lead_Conversion_Mapping__mdt mdRecord : leadToSObjectMappingCustomMetadata
      ) {
        if (
          mdRecord.Lead_Field__c != null &&
          !defaultleadFields.Contains(mdRecord.Lead_Field__c) &&
          !mdLeadFields.Contains(mdRecord.Lead_Field__c) &&
          mdRecord.Lead_Record_Types__c.contains(leadRecType)
        ) {
          mdLeadFields = mdLeadFields + ', ' + mdRecord.Lead_Field__c;
        }
      }
    }

    Set<Id> leadIds = leadMap.keySet();
    if (Schema.sObjectType.Lead.isQueryable()) {
      leadQuery =
        'Select ' +
        String.escapeSingleQuotes(defaultleadFields) +
        String.escapeSingleQuotes(mdLeadFields) +
        ' From Lead WHERE Id IN :leadIds WITH SECURITY_ENFORCED';
      List<Lead> records = database.query(leadQuery);

      //CC-1099 made the method as generic as per CLD to reusably fetch any conversionRecord from Leads.
      String strTargetObject = MLCRMConstants.SOBJECT_OPPORTUNITY;
      Map<Id, SObject> mapOfLeadsWithSObject = new Map<Id, SObject>();
      mapOfLeadsWithSObject = prefillConversionRecords(
        records,
        strTargetObject,
        mapofAccountId
      );
      if (!mapOfLeadsWithSObject.isEmpty()) {
        for (Id key : mapOfLeadsWithSObject.KeySet()) {
          Opportunity opp = (Opportunity) mapOfLeadsWithSObject.get(key);
          mapOfLeadsWithOpportunities.put(key, opp);
        }
      }
    }
    return mapOfLeadsWithOpportunities;
  }

  /**
   * @description CC-1099 This method prefill data from Account to Leads for UNICA leads
   * @name prefillConversionRecords
   * @param records List of lead records
   * @param strTargetObject Target Object Name
   * @param mapofAccountId map of lead id and account id from lead conversion result
   * @return Map<Id, SObject> Map of lead and opportunities
   */
  public Map<Id, SObject> prefillConversionRecords(
    List<Lead> records,
    String strTargetObject,
    Map<Id, Id> mapofAccountId
  ) {
    Schema.SObjectType oObjectType = Schema.getGlobalDescribe()
      .get(strTargetObject);
    SObject targetObject = oObjectType.newSObject();
    List<SObject> targetObjectList = new List<SObject>();
    Map<Id, SObject> mapOfRecordsWithTargets = new Map<Id, SObject>();
    String contactField = '';
    Map<String, Schema.SObjectField> mapSchema = ((SObject) Type.forName(
          strTargetObject
        )
        .newInstance())
      .getSObjectType()
      .getDescribe()
      .fields.getMap();

    //Get Lead to Opportunity mapping from custom metadata
    if (
      leadToSObjectMappingCustomMetadata == null ||
      leadToSObjectMappingCustomMetadata.isEmpty()
    ) {
      leadToSObjectMappingCustomMetadata = DCRM_Lead_Conversion_Mapping__mdt.getall()
        .Values();
    }

    //Getting all the recordtype developername of lead object.
    if (mapOfLeadRecordTypes == null || mapOfLeadRecordTypes.isEmpty()) {
      mapOfLeadRecordTypes = Lead.sobjectType.getDescribe()
        .getRecordTypeInfosById();
    }

    for (Lead leadRecord : records) {
      targetObject = oObjectType.newSObject();
      //prefill Target Object from CustomMetadata
      for (
        DCRM_Lead_Conversion_Mapping__mdt mapping : leadToSObjectMappingCustomMetadata
      ) {
        if (
          mapping.Target_Object__c == strTargetObject &&
          mapping.Active__c &&
          mapping.Target_Field__c != null &&
          mapping.Lead_Record_Types__c.contains(
            mapOfLeadRecordTypes.get(leadRecord.RecordTypeId).developername
          )
        ) {
          if (
            mapping.Mapping_Type__c == MLCRMConstants.MAPPING_TYPE_FIELD &&
            mapping.Lead_Field__c != null
          ) {
            targetObject.put(
              mapping.Target_Field__c,
              leadRecord.get(mapping.Lead_Field__c)
            );
          } else if (
            mapping.Mapping_Type__c == MLCRMConstants.MAPPING_TYPE_RT &&
            mapping.Target_Value__c != null
          ) {
            targetObject.put(
              mapping.Target_Field__c,
              getRecordTypeId(mapping.Target_Value__c, strTargetObject)
            );
          } else if (
            mapping.Mapping_Type__c == MLCRMConstants.MAPPING_TYPE_FIELD &&
            mapping.Lead_Field__c == null &&
            mapping.Target_Value__c != null
          ) {
            Schema.DisplayType fieldDataType = mapSchema.get(
                mapping.Target_Field__c
              )
              .getDescribe()
              .getType();
            switch on fielddataType {
              when BOOLEAN {
                targetObject.put(
                  mapping.Target_Field__c,
                  Boolean.valueOf(mapping.Target_Value__c)
                );
              }
              when INTEGER {
                targetObject.put(
                  mapping.Target_Field__c,
                  Integer.valueOf(mapping.Target_Value__c)
                );
              }
              when DOUBLE {
                targetObject.put(
                  mapping.Target_Field__c,
                  Double.valueOf(mapping.Target_Value__c)
                );
              }
              when else {
                targetObject.put(
                  mapping.Target_Field__c,
                  mapping.Target_Value__c
                );
              }
            }
          }
        }
      }
      //prefill Target Object with Constants OR conditional
      if (strTargetObject == MLCRMConstants.SOBJECT_OPPORTUNITY) {
        if (String.isBlank(leadRecord.FinServ__RelatedAccount__c)) {
          targetObject.put(
            'AccountId',
            mapofAccountId.containsKey(leadRecord.Id)
              ? mapofAccountId.get(leadRecord.Id)
              : null
          );
        }
        targetObject.put(
          'CampaignId',
          leadRecord.CampaignMembers.isEmpty()
            ? null
            : leadRecord.CampaignMembers[0].CampaignId
        );
        contactField = getContact(leadRecord);
        targetObject.put('Contact__c', contactField);
        targetObject.put('CloseDate', system.today().addDays(90));
      }
      if (targetObject != null) {
        mapOfRecordsWithTargets.put(leadRecord.id, targetObject);
      }
    }
    return mapOfRecordsWithTargets;
  }

  /**
   * @description This method get contact fields from lead fields
   * @name getContact
   * @param record lead record
   * @return String Contact details
   */
  private String getContact(Lead record) {
    String contactField = '';
    if (String.isNotBlank(record.FirstName)) {
      contactField = record.FirstName;
    }
    if (String.isNotBlank(record.LastName)) {
      contactField = contactField + '\n' + record.LastName;
    }
    if (String.isNotBlank(record.Title__c)) {
      contactField = contactField + '\n' + record.Title__c;
    }
    if (String.isNotBlank(record.Email)) {
      contactField = contactField + '\n' + record.Email;
    }
    if (String.isNotBlank(record.Work_Phone__c)) {
      contactField = contactField + '\n' + record.Work_Phone__c;
    }
    if (String.isNotBlank(record.MobilePhone)) {
      contactField = contactField + '\n' + record.MobilePhone;
    }
    if (String.isNotBlank(record.Home_Phone__c)) {
      contactField = contactField + '\n' + record.Home_Phone__c;
    }
    return contactField;
  }
  /**
   * @description This method used to fetch Record Type id of Opportunity by use of Developer Name from the custom metadata
   * @name getOppRecordType
   * @param targetRTDeveloperName RecordType Developer Name
   * @param strTargetObject Object Name
   * @return ID objRecordTypeID id of the record type
   */
  public ID getRecordTypeId(
    String targetRTDeveloperName,
    String strTargetObject
  ) {
    ID objRecordTypeID;
    if (strTargetObject == MLCRMConstants.SOBJECT_OPPORTUNITY) {
      objRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(targetRTDeveloperName)
        .getRecordTypeId();
    }
    return objRecordTypeID;
  }

  /**
   * @description This method map account fields to lead fields using custom metadata
   * @name mapAccountFieldsToLead
   * @param accountToLeadMappingWithAccount Map of accounts fields to lead fields with Key as account type
   * @param isManual For manual leads
   */
  private void mapAccountFieldsToLead(
    Map<string, Map<string, string>> accountToLeadMappingWithAccount,
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
    String strRecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID;
    for (Lead lead : leadList) {
      String accountType = getAccountType(
        mapAccountsRecordTypeId.get(lead.FinServ__RelatedAccount__c)
          .RecordTypeId
      );

      Map<String, String> accountToLeadMapping = accountToLeadMappingWithAccount.get(
        accountType
      );

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
      if (isManual && lead.recordTypeId != strRecordTypeId) {
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
   * @param lead Lead record
   * @return Contact Returns Contact object
   */
  private Contact getContactForMapping(Lead lead) {
    Contact contactForMapping = new Contact();
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

    return contactForMapping;
  }

  /**
   * @description This method map contact fields to lead fields using custom metadata
   * @name mapContactFieldsToLead
   * @param contactToLeadMappingWithContact Fields for mapping
   */
  private void mapContactFieldsToLead(
    Map<string, Map<string, string>> contactToLeadMappingWithContact
  ) {
    for (Lead lead : leadList) {
      Contact contact = getContactForMapping(lead);
      //If no contact exist then assign default first and last name
      if (contact == null) {
        lead.put('FirstName', CCRMConstants.NO_CONTACT_FOUND);
        lead.put('LastName', CCRMConstants.NO_CONTACT_FOUND);
      } else {
        String accountType = getAccountType(
          mapAccountsRecordTypeId.get(lead.FinServ__RelatedAccount__c)
            .RecordTypeId
        );

        Map<String, String> contactToLeadMapping = contactToLeadMappingWithContact.get(
          accountType
        );

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
          lead.Registered_Company__c = 'No';
        }
      }
      when 'Business' {
        lead.Registered_Company__c = 'Yes';
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

  /**
   * @description This method returns set of AccountIds
   * @name getRelatedPartyIds
   * @param accountMap map of system id with account
   * @return Set<String> relatedPartyIds
   */
  public static Set<String> getRelatedPartyIds(
    Map<String, Account> accountMap
  ) {
    Set<String> relatedPartyIds = new Set<String>();
    for (Account account : accountMap.values()) {
      relatedPartyIds.add(account.Id);
    }
    return relatedPartyIds;
  }
}
