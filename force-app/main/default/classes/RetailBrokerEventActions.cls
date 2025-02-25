/**
 * @author Zhiren Jason Guan
 * @since  04/03/2024
 * @description Service layer for GCP event related actions for broker event
 * @runTests  RetailBrokerEventActionsTest
 */

public with sharing class RetailBrokerEventActions {
  public static final String BROKER_EVENT_ADD = 'add';
  public static final String BROKER_EVENT_UPDATE = 'update';
  private static final RetailBrokerRepository RETAIL_BROKER_REPOSITORY = (RetailBrokerRepository) Lib_InstanceProvider.forType(
    RetailBrokerRepository.class
  );

  /**
   * @description Publish event for brokers
   * @param brokerIdToEventTypeMap Map of broker Id to event type
   * @return List of success published events
   */
  public static List<SObject> publishEventForBrokers(
    Map<Id, String> brokerIdToEventTypeMap
  ) {
    if (brokerIdToEventTypeMap == null || brokerIdToEventTypeMap.isEmpty()) {
      return new List<SObject>();
    }
    List<Contact> brokers = RETAIL_BROKER_REPOSITORY.getBrokerContactsByIds(
      brokerIdToEventTypeMap.keySet()
    );
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();
    for (Contact broker : brokers) {
      String eventType = brokerIdToEventTypeMap.get(broker.Id);
      BrokerCloudEventModel eventModel = generateBrokerCEModel(
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
   * @description Generate Broker related Cloud Event Model
   * @param broker Contact record
   * @param eventType event type
   * @return BrokerCloudEventModel
   */
  @TestVisible
  private static BrokerCloudEventModel generateBrokerCEModel(
    Contact broker,
    String eventType
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = eventType ==
      BROKER_EVENT_ADD
      ? buildAddContact(broker)
      : buildUpdateContact(broker);
    return new BrokerDataCloudEventModel(broker, masterNodes, eventType);
  }

  /**
   * @description Build the contract for add event
   * @param record the new contact record in trigger context
   * @return list of master objects
   */
  @TestVisible
  private static List<BrokerCloudEventModel.MasterNode> buildAddContact(
    Contact record
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    masterNodes.add(BrokerCloudEventBuilder.buildAccountNode(record));
    masterNodes.add(BrokerCloudEventBuilder.buildContactNode(record));
    masterNodes.add(
      BrokerCloudEventBuilder.buildContactInfoNode(record, 'ContactPointPhone')
    );
    masterNodes.add(
      BrokerCloudEventBuilder.buildContactInfoNode(record, 'ContactPointEmail')
    );
    masterNodes.add(
      BrokerCloudEventBuilder.buildContactInfoNode(
        record,
        'ContactPointAddress'
      )
    );
    masterNodes.add(BrokerCloudEventBuilder.buildBrokerCodeNode(record));
    return masterNodes;
  }

  /**
   * @description Build the contract for update event
   * @param record the new contact record in trigger context
   * @return list of master objects
   */
  @TestVisible
  private static List<BrokerCloudEventModel.MasterNode> buildUpdateContact(
    Contact record
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    masterNodes.add(
      BrokerCloudEventBuilder.buildContactInfoNode(record, 'ContactPointPhone')
    );
    masterNodes.add(
      BrokerCloudEventBuilder.buildContactInfoNode(record, 'ContactPointEmail')
    );
    masterNodes.add(
      BrokerCloudEventBuilder.buildContactInfoNode(
        record,
        'ContactPointAddress'
      )
    );
    masterNodes.add(BrokerCloudEventBuilder.buildBrokerCodeNode(record));
    masterNodes.add(BrokerCloudEventBuilder.buildContactNode(record));
    masterNodes.add(BrokerCloudEventBuilder.buildAccountNode(record));
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
