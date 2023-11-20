/**
 * @author Tan Phan
 * @since 09/2022
 * @description CCRMCustomerProfileUpdateHelper contains helpers related to handling Customer_Profile_Updates__c object.
 * @runTests CCRMCustomerProfileUpdateHelperTest
 */
public with sharing class CCRMCustomerProfileUpdateHelper {
  private static final string PENDING_UPDATE_ERROR = 'Unable to edit this record since it was recently edited and changes are still being processed, please try again later.';
  private static final string DELETE_LAST_CONTACT_ERROR = 'This contact cannot be deleted as at least one contact must be linked to a customer. Please try adding a new contact before deleting this one.';
  private static final String KYC_EDIT_ERROR = 'You are not allowed to edit the KYC fields for active customer.';
  private static final Profile CURRENT_USER_PROFILE = MLCRMCommonUtils.getProfileById(
    UserInfo.getProfileId()
  );
  public static final Boolean IS_MLUSER = (CURRENT_USER_PROFILE?.Name ==
  Label.MLCRM_Profile_Name);
  private static Map<String, Set<String>> mapObjectField;

  /**
   * @description Check for any changes to given records, and create Customer_Profile_Updates__c records accordingly
   * @name createCustomerProfileUpdates
   * @param records The list of records to check for changes
   * @param oldMap The map which holds the previous values of the records.
   * @param isProspect true if we are passing prospect account records & False if we are passing Active account records.
   */
  public static void createCustomerProfileUpdates(
    List<SObject> records,
    Map<Id, SObject> oldMap,
    Boolean isProspect
  ) {
    if (records.isEmpty()) {
      return;
    }
    Schema.DescribeSObjectResult objectInfo = records[0]
      .getSObjectType()
      .getDescribe();
    String accountLookupField = CCRMCustomerProfileUpdateConfig.MAPPING_CONFIGS.get(
        objectInfo.Name
      )
      .accountLookupField;
    Set<Id> customersWithPendingUpdate = getCustomersWithPendingUpdates(
      records,
      accountLookupField
    );
    List<SObject> recordsApplicableForStaging = MLCRMCustomerProfileUpdateHelper.getRecordsApplicableForStaging(
      records,
      oldMap,
      isProspect
    );

    if (objectInfo.Name == CCRMConstants.SOBJECT_ACCOUNT) {
      CCRMCustomerProfileUpdateConfig.controllingPostMap = getUpdatedCPIDs(
        records,
        oldMap
      );
      CCRMCustomerProfileUpdateConfig.industryMap = getIndustry(
        records,
        oldMap
      );
    }

    List<Customer_Profile_Updates__c> customerProfileUpdates = new List<Customer_Profile_Updates__c>();

    for (SObject record : recordsApplicableForStaging) {
      if (
        customersWithPendingUpdate.contains((Id) record.get(accountLookupField))
      ) {
        record.addError(PENDING_UPDATE_ERROR);
      } else {
        customerProfileUpdates.addAll(
          new CCRMCustomerProfileUpdateConfig.TrackingRequest(
              record,
              oldMap?.get(record.Id)
            )
            .getUpdates(isProspect, IS_MLUSER)
        );
      }
    }

    CCRMCustomerProfileUpdateSystemActions.saveAndPublishUpdates(
      customerProfileUpdates
    );
    if (oldMap == null) {
      CCRMCustomerProfileUpdateSystemActions.deleteRecords(
        new Map<Id, SObject>(records).keySet()
      );
    }
  }

  /**
   * @description Delete a prospect contact by creating customer profile update record/event, make sure that the last contact cannot be deleted.
   * @name deleteProspectContact
   * @param recordId Id of the contact to delete
   */
  @AuraEnabled
  public static void deleteProspectContact(Id recordId) {
    Contact con = [
      SELECT Id, AccountId, Occurrence_Number__c
      FROM Contact
      WHERE Id = :recordId
      WITH SECURITY_ENFORCED
    ];

    Set<Id> customersWithPendingUpdate = getCustomersWithPendingUpdates(
      new List<Contact>{ con },
      'AccountId'
    );
    if (customersWithPendingUpdate.contains(con.AccountId)) {
      throw new AuraHandledException(PENDING_UPDATE_ERROR);
    }

    Integer siblingContactsCount = [
      SELECT COUNT()
      FROM Contact
      WHERE AccountId = :con.AccountId
      WITH SECURITY_ENFORCED
    ];
    if (siblingContactsCount == 1) {
      throw new AuraHandledException(DELETE_LAST_CONTACT_ERROR);
    }

    CCRMCustomerProfileUpdateSystemActions.saveAndPublishUpdates(
      new List<Customer_Profile_Updates__c>{
        new Customer_Profile_Updates__c(
          Action__c = 'Delete',
          Name = SObjectType.Contact.Label +
            CCRMCustomerProfileUpdateConfig.NAME_SUFFIX,
          TriggeredFrom__c = SObjectType.Contact.Name,
          Occurrence_Number__c = con.Occurrence_Number__c,
          Customer_Name__c = con.AccountId,
          UserLanId__c = CCRMCustomerProfileUpdateConfig.CURRENT_USER.Lan_Id__c,
          Status__c = 'Pending'
        )
      }
    );
  }

  /**
   * @description check the linked accounts of provided records for updates that are still in "Pending" status
   * @name getCustomersWithPendingUpdates
   * @param records The list of records to check
   * @param accountLookupApiName The API name of account lookup field on the records
   * @return Set<Id> ID of the accounts with pending updates
   */
  private static Set<Id> getCustomersWithPendingUpdates(
    List<SObject> records,
    String accountLookupApiName
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (SObject record : records) {
      accountIds.add((Id) record.get(accountLookupApiName));
    }

    Set<Id> customersWithPendingUpdates = new Set<Id>();

    for (Customer_Profile_Updates__c cpu : [
      SELECT Id, Customer_Name__c
      FROM Customer_Profile_Updates__c
      WHERE
        Customer_Name__c IN :accountIds
        AND Status__c = 'Pending'
        AND TriggeredFrom__c = :records[0].getSObjectType().getDescribe().Name
      WITH SECURITY_ENFORCED
    ]) {
      customersWithPendingUpdates.add(cpu.Customer_Name__c);
    }
    return customersWithPendingUpdates;
  }

  /**
   * @description doesProfileAllowCustStaging
   * @return Boolean - Whether user profile allowed the current changes to be tracked in Customer_Profile_Updates__c
   */
  public static Boolean doesProfileAllowCustStaging() {
    return (MLCRMCommonUtils.getAllowedProfileIdsSet(
        new Set<String>{ Label.CCRM_Profile_Name, Label.MLCRM_Profile_Name },
        false
      )
      .contains(UserInfo.getProfileId()));
  }

  /**
   * @description This method will used to populate Map
   * @name populateObjectFieldMap
   * @param objFieldMap hold Object as Key and its Non-KYC fields
   * @param objName name of Object
   * @param objField name of Field
   * @return Map<String, Set<String>> the map of Object and its corresponding Non-KYC fields.
   */
  public static Map<String, Set<String>> populateObjectFieldMap(
    Map<String, Set<String>> objFieldMap,
    String objName,
    String objField
  ) {
    if (objFieldMap.containsKey(objName)) {
      objFieldMap.get(objName).add(objField);
    } else {
      objFieldMap.put(objName, new Set<String>{ objField });
    }
    return objFieldMap;
  }

  /**
   * @description This method is to form a Map of Object and its corresponding KYC fields.
   * @name formObjectFieldsMap
   * @param record Sobject record to check the obejct name
   * @return Map<String, Set<String>> - the map of Object and its corresponding KYC fields.
   */
  public static Map<String, Set<String>> formObjectFieldsMap(Sobject record) {
    Schema.DescribeSObjectResult objectInfo = record.getSObjectType()
      .getDescribe();
    if (mapObjectField == null) {
      mapObjectField = new Map<String, Set<String>>();
      for (DCRM_Customer_Management_Non_KYC_Fields__mdt custIdenIter : [
        SELECT
          Id,
          DeveloperName,
          Object_Name__c,
          Field_Name__c,
          Profile_Name__c,
          RecordType_Name__c
        FROM DCRM_Customer_Management_Non_KYC_Fields__mdt
        WHERE Object_Name__c = :objectInfo.name
      ]) {
        Set<String> profileNameSet = new Set<String>();
        profileNameSet.addAll(custIdenIter.Profile_Name__c.split(';'));
        if (profileNameSet.contains(CURRENT_USER_PROFILE.Name)) {
          mapObjectField = populateObjectFieldMap(
            mapObjectField,
            custIdenIter.Object_Name__c +
            '-' +
            custIdenIter.RecordType_Name__c,
            custIdenIter.Field_Name__c
          );
        }
      }
    }
    return mapObjectField;
  }

  /**
   * @description isFormula checks if a field is Formula
   * @param fieldName Name of the field to be check if it's updateable
   * @param objectApiName name of the object
   * @return Boolean Is the field Formula
   */
  public static Boolean isFormula(String fieldName, String objectApiName) {
    SobjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
    SobjectField objectField = objectType.getDescribe()
      .fields.getMap()
      .get(fieldName);
    return objectField.getDescribe().isCalculated();
  }

  /**
   * @description Restrict edit of certain fields for active/inactive Customer
   * @name restrictEdit
   * @param records from the trigger
   * @param oldMap Map of old records
   */
  public static void restrictEdit(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    if (!records.isEmpty()) {
      //allowedFieldsToUpdateInCustomMetadata - It will store the Object name and the set of Non-KYC fields which user is allow to edit.
      Map<String, Set<String>> allowedFieldsToUpdateInCustomMetadata = formObjectFieldsMap(
        records[0]
      );

      //allowedFieldsToUpdateInFieldSets - It will store the set of Non-KYC fields that are there in fieldSets of the respective object.
      Set<String> allowedFieldsToUpdateInFieldSets = MLCRMCustomerProfileUpdateHelper.getFieldsinFieldSets(
        records[0].getSObjectType().getDescribe().name
      );
      Schema.DescribeSObjectResult objectInfo = records[0]
        .getSObjectType()
        .getDescribe();
      Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = objectInfo
        .sobjectType.getDescribe()
        .getRecordTypeInfosById();
      Set<String> fieldPopulated;
      for (Sobject record : records) {
        fieldPopulated = new Set<String>();

        //fieldPopulated - It will store the set of Field API Name for which value are previously present on the record
        //and also for which the value are currently present after made a change.
        fieldPopulated.addAll(record.getPopulatedFieldsAsMap().keySet());
        fieldPopulated.addAll(
          oldMap.get((Id) record.get('Id')).getPopulatedFieldsAsMap().keySet()
        );
        String recordTypeName = recordTypeInfoMap
          .get((Id) record.get('RecordTypeId'))
          .getDeveloperName();

        //It will check that particular field value changes & if that field is present in FieldSet
        //and not there in objectFieldsMap which means it is a KYC Field then it will throw error.

        //It won't throw error in below cases:
        //If field is present in both FieldSet & objectFieldsMap then it is a Non-KYC field.
        //If field is present in neither in FieldSet nor in objectFieldsMap then it is a System Field.
        for (String populatedfieldName : fieldPopulated) {
          if (
            allowedFieldsToUpdateInFieldSets.contains(populatedfieldName) &&
            allowedFieldsToUpdateInCustomMetadata.containsKey(
              objectInfo.name +
              '-' +
              recordTypeName
            ) &&
            !allowedFieldsToupdateInCustomMetadata.get(
                objectInfo.name +
                '-' +
                recordTypeName
              )
              .contains(populatedfieldName) &&
            String.valueOf(record.get(populatedfieldName)) !=
            String.valueOf(
              oldMap.get((Id) record.get('Id')).get(populatedfieldName)
            )
          ) {
            record.addError(populatedfieldName, KYC_EDIT_ERROR);
          }
        }
      }
    }
  }
  /**
   * @description Get Controlling post records if CP ID changes
   * @name getUpdatedCPIDs
   * @param records from the trigger
   * @param oldMap Map of old records
   * @return Map<Id, SObject> map of Controlling Post Id and its corresponding record
   */
  public static Map<Id, SObject> getUpdatedCPIDs(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    Set<Id> cpIdsSet = new Set<Id>();
    Map<Id, SObject> cpIdMap = new Map<Id, SObject>();
    for (SObject recordItr : records) {
      if (
        ((Id) recordItr.get('RecordTypeId') ==
        CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID ||
        (Id) recordItr.get('RecordTypeId') ==
        CCRMConstants.ACCOUNT_PERSON_RT_ID) &&
        (((Id) recordItr.get(CCRMConstants.ACC_CPID)) !=
        ((Id) (oldMap.get(recordItr.Id).get(CCRMConstants.ACC_CPID))))
      ) {
        cpIdsSet.add((Id) recordItr.get(CCRMConstants.ACC_CPID));
        cpIdsSet.add((Id) oldMap.get(recordItr.Id).get(CCRMConstants.ACC_CPID));
      }
    }
    if (!cpIdsSet.isEmpty()) {
      cpIdMap = new Map<Id, Controlling_Post__c>(
        [
          SELECT Id, CPID__c, Name
          FROM Controlling_Post__c
          WHERE Id IN :cpIdsSet
        ]
      );
    }
    return cpIdMap;
  }

  /**
   * @description Get Industry record if changes
   * @name getIndustry
   * @param records from the trigger
   * @param oldMap Map of old records
   * @return Map<Id, SObject> map of map of Industry Id and its corresponding record
   */
  public static Map<Id, SObject> getIndustry(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    Set<Id> indIdsSet = new Set<Id>();
    Map<Id, SObject> indIdMap = new Map<Id, SObject>();
    for (SObject recordItr : records) {
      if (
        ((Id) recordItr.get('RecordTypeId') ==
        CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID) &&
        (((Id) recordItr.get(CCRMConstants.ACC_IND)) !=
        ((Id) (oldMap.get(recordItr.Id).get(CCRMConstants.ACC_IND))))
      ) {
        indIdsSet.add((Id) recordItr.get(CCRMConstants.ACC_IND));
        indIdsSet.add((Id) oldMap.get(recordItr.Id).get(CCRMConstants.ACC_IND));
      }
    }
    if (!indIdsSet.isEmpty()) {
      indIdMap = new Map<Id, Industry__c>(
        [SELECT Id, Code__c, Name FROM Industry__c WHERE Id IN :indIdsSet]
      );
    }
    return indIdMap;
  }
}
