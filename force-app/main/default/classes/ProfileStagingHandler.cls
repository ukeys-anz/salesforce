/**
 * @author Tan Phan
 * @since 06/2024
 * @description Handles the processing of profile staging records Customer_Profile_Updates__c
 *  - This class provides methods to capture changes to records.
 *  - Insert `Customer_Profile_Updates__c` records.
 *  - Publish `Customer_Profile_Update_Event__e` events based on the provided configuration.
 */
public virtual with sharing class ProfileStagingHandler {
  private static final ProfileStagingRepository REPOSITORY = (ProfileStagingRepository) Lib_InstanceProvider.forType(
    ProfileStagingRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Processes the given records based on the provided configuration
   * 	* Capture changes to records.
   * 	* Insert Customer_Profile_Updates__c records.
   * 	* Publish Customer_Profile_Update_Event__e events.
   * @param config The configuration for processing the records.
   * @param records The list of records to be processed.
   * @param oldMap The map of old records.
   */
  public virtual void process(
    ProfileStagingConfig config,
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    List<Customer_Profile_Updates__c> updates = generateUpdates(
      config,
      records,
      oldMap
    );
    DML.doInsert(updates);
    List<Customer_Profile_Update_Event__e> events = generateEvents(updates);
    DML.doPublish(events);
  }

  /**
   * @description Captures profile updates based on the provided configuration, records, and old map.
   * @param config The ProfileStagingConfig object containing the configuration for capturing updates.
   * @param records The list of SObject records to capture updates from.
   * @param oldMap The map of old SObject records, where the key is the record Id and the value is the old record.
   * @return `List<Customer_Profile_Updates__c>` Representing the captured updates.
   */
  @TestVisible
  protected virtual List<Customer_Profile_Updates__c> generateUpdates(
    ProfileStagingConfig config,
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    List<Customer_Profile_Updates__c> updates = new List<Customer_Profile_Updates__c>();
    for (SObject record : records) {
      SObject oldRecord = oldMap?.get(record.Id);
      Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c(
        Action__c = oldRecord == null ? 'Add' : 'Update',
        Status__c = 'Pending',
        UserLanId__c = USER_INFO.getUser().Lan_Id__c
      );
      if (config.process(cpu, record, oldRecord)) {
        updates.add(cpu);
      }
    }
    return updates;
  }

  /**
   * @description Builds a list of Customer_Profile_Update_Event__e objects based on the given list of Customer_Profile_Updates__c records.
   * @param records The list of Customer_Profile_Updates__c records to process.
   * @return A list of Customer_Profile_Update_Event__e objects.
   */
  @TestVisible
  protected virtual List<Customer_Profile_Update_Event__e> generateEvents(
    List<Customer_Profile_Updates__c> records
  ) {
    records = REPOSITORY.queryCustomerProfileUpdates(records);
    List<Customer_Profile_Update_Event__e> events = new List<Customer_Profile_Update_Event__e>();
    for (Customer_Profile_Updates__c record : records) {
      Customer_Profile_Update_Event__e event = new Customer_Profile_Update_Event__e(
        Customer_Profile_Update_Identifier__c = record.Id,
        RecordType_Name__c = record.Customer_Name__r?.RecordType?.DeveloperName
      );
      events.add(event);
    }
    return events;
  }
}
