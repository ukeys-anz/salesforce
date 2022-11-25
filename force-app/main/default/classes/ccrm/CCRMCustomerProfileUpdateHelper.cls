/**
 * @author Tan Phan
 * @since 09/2022
 * @description CCRMCustomerProfileUpdateHelper contains helpers related to handling Customer_Profile_Updates__c object.
 * @runTests CCRMCustomerProfileUpdateHelperTest
 */
public with sharing class CCRMCustomerProfileUpdateHelper {
  private static final string PENDING_UPDATE_ERROR = 'Unable to edit this record since it was recently edited and changes are still being processed, please try again later.';
  private static final string DELETE_LAST_CONTACT_ERROR = 'This contact cannot be deleted as at least one contact must be linked to a customer. Please try adding a new contact before deleting this one.';
  private static final Map<Object, Set<String>> UI_EXCLUSION_FIELDS = new Map<Object, Set<String>>{
    'ContactPointAddress' => new Set<String>{ 'Global_Address_Key__c' }
  };
  private static final Map<Object, List<Set<String>>> FIELD_GROUPS = new Map<Object, List<Set<String>>>{
    'ContactPointAddress' => new List<Set<String>>{
      new Set<String>{ 'Street', 'City', 'State', 'Country', 'PostalCode' }
    }
  };

  private static final User CURRENT_USER = [
    SELECT Lan_Id__c
    FROM User
    WHERE Id = :UserInfo.getUserId()
  ];

  private static final Profile ANZ_STANDARD_USER_PROFILE = CommonUtil.getProfileByName(
    Label.CCRM_Profile_Name
  );

  /**
   * @description Check for any changes to given records, and create Customer_Profile_Updates__c records accordingly
   * @name createCustomerProfileUpdates
   * @param records The list of records to check for changes
   * @param oldMap The map which holds the previous values of the records.
   * @param accountLookupApiName The API name of account lookup field on the records
   * @param occurrenceNumberApiName The API name of contact and email address fields on the records
   */
  public static void createCustomerProfileUpdates(
    List<SObject> records,
    Map<Id, SObject> oldMap,
    String accountLookupApiName,
    String occurrenceNumberApiName
  ) {
    if (records.isEmpty() || !shouldTrackFieldChanges()) {
      return;
    }
    Set<Id> customersWithPendingUpdate = getCustomersWithPendingUpdates(
      records,
      accountLookupApiName
    );
    List<Customer_Profile_Updates__c> customerProfileUpdates = new List<Customer_Profile_Updates__c>();
    Schema.DescribeSObjectResult objectInfo = records[0]
      .getSObjectType()
      .getDescribe();

    for (SObject record : records) {
      Id customerId = (Id) record.get(accountLookupApiName);
      if (customersWithPendingUpdate.contains(customerId)) {
        record.addError(PENDING_UPDATE_ERROR);
        continue;
      }
      Customer_Profile_Updates__c cpu = new ExtractionRequest(
          record,
          oldMap?.get(record.Id)
        )
        .extractChangeData();

      if (cpu != null) {
        cpu.Action__c = oldMap == null ? 'Add' : 'Update';
        cpu.Object_Name__c = objectInfo.Label;
        cpu.TriggeredFrom__c = objectInfo.Name;
        cpu.Customer_Name__c = (Id) record.get(accountLookupApiName);
        cpu.UserLanId__c = CURRENT_USER.Lan_Id__c;
        cpu.Status__c = 'Pending';
        if (
          occurrenceNumberApiName != null &&
          record.get(occurrenceNumberApiName) != null
        ) {
          cpu.Occurrence_Number__c = integer.valueof(
            record.get(occurrenceNumberApiName)
          );
        }
        customerProfileUpdates.add(cpu);
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
          Object_Name__c = SObjectType.Contact.Name,
          TriggeredFrom__c = SObjectType.Contact.Label,
          Occurrence_Number__c = con.Occurrence_Number__c,
          Customer_Name__c = con.AccountId,
          UserLanId__c = CURRENT_USER.Lan_Id__c,
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
   * @description Encapsulate logics to extract changes to a record
   */
  class ExtractionRequest {
    SObject record;
    SObject oldRecord;
    Schema.DescribeSObjectResult objectInfo;
    Map<String, SObjectField> fieldMap;
    Set<String> uiExclusionFIelds;
    List<Set<String>> fieldGroups;
    Map<String, Object> oldValues;
    Map<String, Object> newValues;
    Map<String, Object> oldBackEndValues;
    Map<String, Object> newBackEndValues;

    ExtractionRequest(SObject record, SObject oldRecord) {
      this.record = record;
      this.oldRecord = oldRecord;
      this.oldValues = new Map<String, Object>();
      this.newValues = new Map<String, Object>();
      this.oldBackEndValues = new Map<String, Object>();
      this.newBackEndValues = new Map<String, Object>();
      this.objectInfo = this.record.getSObjectType().getDescribe();
      this.fieldMap = this.objectInfo.fields.getMap();
      this.uiExclusionFields = UI_EXCLUSION_FIELDS.containsKey(
          this.objectInfo.Name
        )
        ? UI_EXCLUSION_FIELDS.get(this.objectInfo.Name)
        : new Set<String>();
      this.fieldGroups = FIELD_GROUPS.containsKey(this.objectInfo.Name)
        ? FIELD_GROUPS.get(this.objectInfo.Name)
        : new List<Set<String>>();
    }

    /**
     * @description Extract the front-end and back-end old/new values of a field and put them in respective variables
     * @name extractField
     * @param field The field to extract values
     */
    void extractField(String field) {
      Schema.DescribeFieldResult fieldInfo = fieldMap.get(field).getDescribe();
      if (!this.uiExclusionFields.contains(field)) {
        //on updated records we want to log the null values, but not on new records
        if (
          this.oldRecord != null ||
          (this.record.get(field) != null &&
          this.record.get(field) != false)
        ) {
          this.newValues.put(fieldInfo.label, this.record.get(field));
        }
        if (this.oldRecord != null) {
          this.oldValues.put(fieldInfo.label, this.oldRecord.get(field));
        }
      }
      if (
        this.oldRecord != null ||
        this.record.get(field) != null &&
        this.record.get(field) != false
      ) {
        this.newBackEndValues.put(field, record.get(field));
      }
      if (this.oldRecord != null) {
        this.oldBackEndValues.put(field, oldRecord.get(field));
        this.record.put(field, this.oldRecord.get(field));
      }
    }

    /**
     * @description check whether a field is part of a field group that needs to be processed together
     * @name extractFieldGroup
     * @param field The field to check
     */
    void extractFieldGroup(String field) {
      for (Set<String> fieldGroup : this.fieldGroups) {
        if (!fieldGroup.contains(field)) {
          continue;
        }
        for (String groupMember : fieldGroup) {
          if (groupMember != field) {
            this.extractField(groupMember);
          }
        }
      }
    }

    /**
     * @description Check for any changes to a record, and create a Customer_Profile_Updates__c record accordingly, then revert any changes made to the record
     * @name extractChangeData
     * @return Customer_Profile_Updates__c - record to contain old and new values of the record. null if no changes detected.
     */
    Customer_Profile_Updates__c extractChangeData() {
      for (String field : this.fieldMap.keySet()) {
        Schema.DescribeFieldResult fieldInfo = fieldMap.get(field)
          .getDescribe();
        if (this.newBackEndValues.containsKey(fieldInfo.localname)) {
          continue;
        }
        if (this.oldRecord == null && fieldInfo.isCreateable()) {
          this.extractField(fieldInfo.localname);
        } else if (
          this.oldRecord != null &&
          this.oldRecord.get(field) != this.record.get(field) &&
          fieldInfo.isUpdateable()
        ) {
          this.extractField(fieldInfo.localname);
          this.extractFieldGroup(fieldInfo.localname);
        }
      }
      return newBackEndValues.isEmpty()
        ? null
        : new Customer_Profile_Updates__c(
            OldValue__c = oldValues.isEmpty()
              ? null
              : JSON.serializePretty(oldValues),
            NewValue__c = JSON.serializePretty(newValues),
            AsIsValue__c = oldBackEndValues.isEmpty()
              ? null
              : JSON.serialize(oldBackEndValues),
            ToBeValue__c = JSON.serialize(newBackEndValues)
          );
    }
  }

  /**
   * @description
   * @return Boolean - Whether or not the current changes should be tracked in Customer_Profile_Updates__c
   */
  public static Boolean shouldTrackFieldChanges() {
    return UserInfo.getProfileId() == ANZ_STANDARD_USER_PROFILE.Id;
  }
}
