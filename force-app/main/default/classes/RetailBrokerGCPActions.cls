/**
 * @author Zhiren Jason Guan
 * @since  04/03/2024
 * @description Service layer for GCP event related actions
 * @runTests  RetailBrokerGCPServiceTest
 */

public with sharing class RetailBrokerGCPActions {
  public static final String GCP_EVENT_ADD = 'add';
  public static final String GCP_EVENT_UPDATE = 'update';
  @TestVisible
  private static List<Contact> mockBrokerContacts = new List<Contact>();

  /**
   * @description Publish GCP event for brokers
   * @param brokerIdToEventTypeMap Map of broker Id to GCP event type
   * @return List of success published events
   */
  public static List<SObject> publishGCPEventForBrokers(
    Map<Id, String> brokerIdToEventTypeMap
  ) {
    if (brokerIdToEventTypeMap == null || brokerIdToEventTypeMap.isEmpty()) {
      return new List<SObject>();
    }
    List<Contact> brokers = getBrokerContactsByIds(
      brokerIdToEventTypeMap.keySet()
    );
    List<BrokerDataCloudEventModel> cloudEventModels = new List<BrokerDataCloudEventModel>();
    for (Contact broker : brokers) {
      String eventType = brokerIdToEventTypeMap.get(broker.Id);
      BrokerDataCloudEventModel eventModel = generateBrokerCEModel(
        broker,
        eventType
      );
      cloudEventModels.add(eventModel);
    }
    List<SObject> successPublishedEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    logSuccessEvents(successPublishedEvents);
    return successPublishedEvents;
  }

  /**
   * @description Get broker contacts by Ids
   * @param contactIds Set of contact Ids
   * @return List of contact records
   */
  @TestVisible
  private static List<Contact> getBrokerContactsByIds(Set<Id> contactIds) {
    if (mockBrokerContacts.isEmpty() == false) {
      return mockBrokerContacts;
    }
    return [
      SELECT
        Id,
        Name,
        External_Id__c,
        Broker_Customer_Profile__r.External_Id__c,
        OCV_Event_Version__c,
        Sync_Status__c
      FROM Contact
      WHERE Id IN :contactIds
    ];
  }

  /**
   * @description Generate Broker related Cloud Event Model
   * @param broker Contact record
   * @param eventType GCP event type
   * @return BrokerDataCloudEventModel
   */
  @TestVisible
  private static BrokerDataCloudEventModel generateBrokerCEModel(
    Contact broker,
    String eventType
  ) {
    List<BrokerDataCloudEventModel.MasterNode> masterNodes = eventType ==
      GCP_EVENT_ADD
      ? buildAddContract(broker)
      : buildUpdateContract(broker);
    return new BrokerDataCloudEventModel(broker, masterNodes, eventType);
  }

  /**
   * @description Build the contract for add event
   * @param record the new contact record in trigger context
   * @return list of master objects
   */
  @TestVisible
  private static List<BrokerDataCloudEventModel.MasterNode> buildAddContract(
    Contact record
  ) {
    List<BrokerDataCloudEventModel.MasterNode> masterNodes = new List<BrokerDataCloudEventModel.MasterNode>();
    masterNodes.add(BrokerDataContactCEBuilder.buildAccountNode(record));
    masterNodes.add(BrokerDataContactCEBuilder.buildContactNode(record));
    masterNodes.add(
      BrokerDataContactCEBuilder.buildContactInfoNode(
        record,
        'ContactPointPhone'
      )
    );
    masterNodes.add(
      BrokerDataContactCEBuilder.buildContactInfoNode(
        record,
        'ContactPointEmail'
      )
    );
    masterNodes.add(
      BrokerDataContactCEBuilder.buildContactInfoNode(
        record,
        'ContactPointAddress'
      )
    );
    masterNodes.add(BrokerDataContactCEBuilder.buildBrokerCodeNode(record));
    return masterNodes;
  }

  /**
   * @description Build the contract for update event
   * @param record the new contact record in trigger context
   * @return list of master objects
   */
  @TestVisible
  private static List<BrokerDataCloudEventModel.MasterNode> buildUpdateContract(
    Contact record
  ) {
    List<BrokerDataCloudEventModel.MasterNode> masterNodes = new List<BrokerDataCloudEventModel.MasterNode>();
    masterNodes.add(
      BrokerDataContactCEBuilder.buildContactInfoNode(
        record,
        'ContactPointPhone'
      )
    );
    masterNodes.add(
      BrokerDataContactCEBuilder.buildContactInfoNode(
        record,
        'ContactPointEmail'
      )
    );
    masterNodes.add(
      BrokerDataContactCEBuilder.buildContactInfoNode(
        record,
        'ContactPointAddress'
      )
    );
    masterNodes.add(BrokerDataContactCEBuilder.buildBrokerCodeNode(record));
    masterNodes.add(BrokerDataContactCEBuilder.buildContactNode(record));
    masterNodes.add(BrokerDataContactCEBuilder.buildAccountNode(record));
    return masterNodes;
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
      'Retail Broker Published' + successEvents.size() + ' Contact Cloud Events'
    );
  }
}
