/**
 * @author Lance Shi
 * @since  01/2023
 * @description Class to publish Cloud Events when a record is inserted or updated.
 * Test Class - CaseTriggerHandlerTest
 */
public without sharing class CloudEventController {
  @TestVisible
  private static List<Cloud_Event__e> cloudEvents;

  /**
   * @description create and publish Cloud Events
   * @param cloudEventModels List of CloudEventModel
   * @return List<sObject> List of events are published successful
   */
  public static List<sObject> publishCloudEvents(
    List<CloudEventModel> cloudEventModels
  ) {
    if (cloudEventModels.size() == 0) {
      return new List<sObject>();
    }
    createCloudEvents(cloudEventModels);
    return PlatformEventUtils.publishEvents(cloudEvents);
  }

  /**
   * @description create Cloud Event
   * @param cloudEventModels List of CloudEventModel
   */
  private static void createCloudEvents(
    List<CloudEventModel> cloudEventModels
  ) {
    cloudEvents = new List<Cloud_Event__e>();
    for (CloudEventModel ceModel : cloudEventModels) {
      //Logic to create and publish Platform Events
      String payload = JSON.serialize(ceModel, true);
      Cloud_Event__e cloudEvent = new Cloud_Event__e(Data_1__c = payload);
      cloudEvents.add(cloudEvent);
    }
  }
}
