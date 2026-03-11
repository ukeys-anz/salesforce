/**
 * @author Tan Phan
 * @since 06/2024
 * @description Handles the processing of profile staging records Customer_Profile_Updates__c
 *  - This class provides methods to capture changes to records.
 *  - Insert `Customer_Profile_Updates__c` records.
 *  - The `publishEvents` method retrieves the list of `Customer_Profile_Updates__c` records based on the provided record IDs and publishes events accordingly.
 *    It generates `Customer_Profile_Update_Event__e` platform events and `Cloud_Event__e` events based on the event configuration.
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
   * @description Represents the base Customer_Profile_Updates__c record.
   */
  @TestVisible
  public Customer_Profile_Updates__c templateCpu {
    get {
      return templateCpu ??
        new Customer_Profile_Updates__c(
          UserLanId__c = USER_INFO.getUser().Lan_Id__c,
          Status__c = 'Pending'
        );
    }
    private set;
  }

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
    this.process(updates);
  }

  /**
   * @description Processes the list of customer profile updates.
   * @param updates The list of customer profile updates to process.
   */
  public virtual void process(List<Customer_Profile_Updates__c> updates) {
    DML.doInsert(updates);

    Set<Id> recordIds = new Map<Id, SObject>(updates).keySet();
    publishEvents(recordIds);
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
      Customer_Profile_Updates__c cpu = this.templateCpu;
      cpu.Action__c = oldRecord == null ? 'Add' : 'Update';
      if (config.process(cpu, record, oldRecord)) {
        updates.add(cpu);
      }
    }
    return updates;
  }

  /**
   * @description Retrieves the list of Customer_Profile_Updates__c records and publish events accordingly.
   * @param recordIds The set of Customer_Profile_Updates__c record Ids
   */
  public virtual void publishEvents(Set<Id> recordIds) {
    List<Customer_Profile_Updates__c> records = REPOSITORY.queryCustomerProfileUpdates(
      recordIds
    );

    List<Customer_Profile_Update_Event__e> pEvents = new List<Customer_Profile_Update_Event__e>();
    List<Cloud_Event__e> cEvents = new List<Cloud_Event__e>();

    for (Customer_Profile_Updates__c record : records) {
      ProfileStagingEventConfig__mdt eventConfig = getEventConfig(record);
      if (eventConfig == null) {
        pEvents.add(generatePlatformEvent(record));
        continue;
      }

      cEvents.add(generateCloudEvent(record, eventConfig));

      if (eventConfig.PublishOldEvent__c == false) {
        continue;
      }
      pEvents.add(generatePlatformEvent(record));
    }

    List<sObject> events = new List<sObject>();
    events.addAll(pEvents);
    events.addAll(cEvents);
    DML.doPublish(events);
  }

  /**
   * @description Retrieves the event configuration for the given Customer_Profile_Updates__c record.
   * @param record The Customer_Profile_Updates__c record to retrieve the event configuration for.
   * @return The event configuration for the given record, or null if no configuration is found
   */
  protected virtual ProfileStagingEventConfig__mdt getEventConfig(
    Customer_Profile_Updates__c record
  ) {
    return REPOSITORY.getEventConfig(record.TriggeredFrom__c);
  }

  @TestVisible
  /**
   * @description Generates a Customer_Profile_Update_Event__e platform event based on the given Customer_Profile_Updates__c record.
   * @param record The Customer_Profile_Updates__c record to generate the platform event from.
   * @return A Customer_Profile_Update_Event__e platform event instance.
   */
  private virtual Customer_Profile_Update_Event__e generatePlatformEvent(
    Customer_Profile_Updates__c record
  ) {
    return new Customer_Profile_Update_Event__e(
      Customer_Profile_Update_Identifier__c = record.Id,
      RecordType_Name__c = record.Customer_Name__r?.RecordType?.DeveloperName
    );
  }

  /**
   * @description Generates a Cloud_Event__e event based on the given Customer_Profile_Updates__c record and event configuration.
   * @param record The Customer_Profile_Updates__c record to generate the cloud event from.
   * @param eventConfig The event configuration metadata to use for generating the cloud event.
   * @return A Cloud_Event__e event instance.
   */
  @TestVisible
  private virtual Cloud_Event__e generateCloudEvent(
    Customer_Profile_Updates__c record,
    ProfileStagingEventConfig__mdt eventConfig
  ) {
    CloudEventModel model = new ProfileStagingCloudEventModel(
      record,
      eventConfig
    );
    return new Cloud_Event__e(Data_1__c = JSON.serializePretty(model, true));
  }
}
