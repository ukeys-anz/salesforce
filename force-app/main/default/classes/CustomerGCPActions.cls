/**
 * @description       : description Service layer for GCP event related actions for customer event
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 08-05-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class CustomerGCPActions {
  public static final String GCP_EVENT_ADD = 'add';
  public static final String GCP_EVENT_UPDATE = 'update';

  /**
   * @description Method used for calling the common CloudEventController method for publishing cloud event
   * @author Madhuri Edke | 07-16-2024
   * @param cloudEventModels
   **/
  public static void publishGCPEventForLoanApps(
    List<BrokerCloudEventModel> cloudEventModels
  ) {
    List<SObject> successPublishedEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    logSuccessEvents(successPublishedEvents);
  }

  /**
   * @description Creating Cloud Event Model structure which is subsequently passed into the publishing method from the caller method
   * @param records Account record
   * @param triggerContext Trigger Context
   * @return List<BrokerCloudEventModel>
   **/
  public static List<BrokerCloudEventModel> createCloudEventModels(
    List<Account> records,
    String triggerContext
  ) {
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();
    for (Account eachRecord : records) {
      BrokerCloudEventModel eventModel = generateRLACEModel(
        eachRecord,
        triggerContext
      );
      cloudEventModels.add(eventModel);
    }
    return cloudEventModels;
  }

  /**
   * @description Generate customer related Cloud Event Model
   * @param record Account record
   * @param eventType GCP event type
   * @return BrokerCloudEventModel
   */
  @TestVisible
  private static BrokerCloudEventModel generateRLACEModel(
    Account record,
    String eventType
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    BrokerCloudEventModel.MasterNode masterNodeObj = CustomerDataCEBuilder.buildAccountNode(
      record
    );
    masterNodes.add(masterNodeObj);
    return new CustomerDataCloudEventModel(record, masterNodes, eventType);
  }

  /**
   * @description Log publish success events
   * @param successEvents List of success events
   */
  @TestVisible
  private static void logSuccessEvents(List<SObject> successEvents) {
    if (successEvents.isEmpty()) {
      return;
    }
    Logger.info(
      'Customer Published' + successEvents.size() + 'Account Cloud Events'
    );
    Logger.saveLog();
  }
}
