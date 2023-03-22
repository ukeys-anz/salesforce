/**
 * @author Tan Phan
 * @since 09/2022
 * @description CCRMCustomerProfileUpdateHelper contains helpers related to handling Customer_Profile_Updates__c object.
 * @runTests CCRMCustomerProfileUpdateHelperTest
 */
public with sharing class CCRMCustomerProfileUpdateHelper {
  private static final string PENDING_UPDATE_ERROR = 'Unable to edit this record since it was recently edited and changes are still being processed, please try again later.';
  private static final string DELETE_LAST_CONTACT_ERROR = 'This contact cannot be deleted as at least one contact must be linked to a customer. Please try adding a new contact before deleting this one.';

  private static final Profile ANZ_STANDARD_USER_PROFILE = CommonUtil.getProfileByName(
    Label.CCRM_Profile_Name
  );

  /**
   * @description Check for any changes to given records, and create Customer_Profile_Updates__c records accordingly
   * @name createCustomerProfileUpdates
   * @param records The list of records to check for changes
   * @param oldMap The map which holds the previous values of the records.
   */
  public static void createCustomerProfileUpdates(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    if (records.isEmpty() || !shouldTrackFieldChanges()) {
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
    List<Customer_Profile_Updates__c> customerProfileUpdates = new List<Customer_Profile_Updates__c>();

    for (SObject record : records) {
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
            .getUpdates()
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
   * @description
   * @return Boolean - Whether or not the current changes should be tracked in Customer_Profile_Updates__c
   */
  public static Boolean shouldTrackFieldChanges() {
    return UserInfo.getProfileId() == ANZ_STANDARD_USER_PROFILE.Id;
  }
}
