/**
 * @author Tan Phan
 * @since 09/2022
 * @description Contains helper actions for {@link CCRMCustomerProfileUpdateHelper} that need to run in system mode (without sharing)
 *  "without sharing" is needed since the running user does not have "create" permission on Customer_Profile_Updates__c, Customer_Profile_Update_Event__e
 *  and "delete" permission on Contact/ContactPointEmail/ContactPointAddress
 * @runTests CCRMCustomerProfileUpdateHelperTest
 */
public without sharing class CCRMCustomerProfileUpdateSystemActions {
  /**
   * @description insert Customer_Profile_Updates__c records and publish Customer_Profile_Update_Event__e events
   * @name saveAndPublishUpdates
   * @param records The record to insert and publish events
   */
  public static void saveAndPublishUpdates(
    List<Customer_Profile_Updates__c> records
  ) {
    if (records.isEmpty()) {
      return;
    }
    List<Database.SaveResult> results = Database.insert(records, false);
    Logger.error(
      'CCRMCustomerProfileUpdateHelper.createCustomerProfileUpdates error',
      results
    );
    Logger.saveLog();

    Set<Id> successIds = new Set<Id>();
    for (Database.SaveResult sr : results) {
      if (sr.success) {
        successIds.add(sr.Id);
      }
    }
    publishEvents(successIds);
  }

  /**
   * @description publish Customer_Profile_Update_Event__e platform event when prospect customer is updated by bankers
   * @param recordIds The list of customer profile updates record ID
   */
  private static void publishEvents(Set<Id> recordIds) {
    if (recordIds.isEmpty()) {
      return;
    }
    List<Customer_Profile_Update_Event__e> events = new List<Customer_Profile_Update_Event__e>();
    for (Id recordId : recordIds) {
      events.add(
        new Customer_Profile_Update_Event__e(
          Customer_Profile_Update_Identifier__c = recordId
        )
      );
    }

    PlatformEventUtils.publishEvents(events);
  }

  /**
   * @description Delete prospect related records once a customer update event has been raised
   * @param recordIds the record IDs to delete
   */
  @future
  public static void deleteRecords(Set<Id> recordIds) {
    if (recordIds.isEmpty()) {
      return;
    }
    List<Database.DeleteResult> results = Database.delete(
      new List<Id>(recordIds),
      false
    );
    Logger.error(
      'CCRMCustomerProfileUpdateHelper.deleteRecords error',
      results
    );
    Logger.saveLog();
  }
}
