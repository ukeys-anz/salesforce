/**
 * @author Saurabh Chauhan
 * @since  05/03/2025
 * @description Service layer for GCP event related actions for broker relation event
 * @runTests  RetailBrokerRelationEventActionsTest
 */
public with sharing class RetailBrokerRelationEventActions {
  public static final String BROKER_RELATION_EVENT_ADD = 'add';
  public static final String BROKER_RELATION_EVENT_DELETE = 'delete';

  private static final RetailContactRepository CONTACT_REPOSITORY = (RetailContactRepository) Lib_InstanceProvider.forType(
    RetailContactRepository.class
  );
  private static final BrokerRelationRepository BROKER_RELATION_REPOSITORY = (BrokerRelationRepository) Lib_InstanceProvider.forType(
    BrokerRelationRepository.class
  );
  /**
   * @description Publish event for broker relation when triggered from Contact
   * @param updatedBrokers broker record Ids eligible for Broker Relation event
   * @param oldMap map of old contacts from trigger context
   * @return List of success published events
   */
  public static List<SObject> publishBrokerRelationEventFromContact(
    Set<Id> updatedBrokers,
    Map<Id, Contact> oldMap
  ) {
    List<Contact> brokers = CONTACT_REPOSITORY.getContacts(updatedBrokers);
    Set<Id> oldBrokerSetIds = null;

    if (oldMap != null) {
      List<Contact> oldContacts = new List<Contact>(oldMap.values());
      oldBrokerSetIds = ListUtil.getIds(oldContacts, Contact.Broker_Set__c);
    }

    List<Broker_Relation__c> brokerRelationsWithRBMInfo = BROKER_RELATION_REPOSITORY.queryBrokerRelationWithRbmDetails(
      oldBrokerSetIds
    );
    Map<Id, Broker_Relation__c> brokerSetMapForOldContacts = (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
      brokerRelationsWithRBMInfo,
      Broker_Relation__c.Id
    );
    List<PayloadInputWrapper> payloadInputList = getPayloadInputListForContacts(
      brokers,
      oldMap,
      brokerSetMapForOldContacts
    );
    List<SObject> successPublishedEvents = publishEvents(payloadInputList);
    return successPublishedEvents;
  }

  /**
   * @description Publish event for broker relation when triggered from Broker Set
   * @param oldBrokerSetRecords contains old broker set records where, at least one rbm got changed
   * @return List of success published events
   */
  public static List<SObject> publishBrokerRelationEventFromBrokerSet(
    List<Broker_Relation__c> oldBrokerSetRecords
  ) {
    Map<Id, Broker_Relation__c> brokerSetMap = (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
      oldBrokerSetRecords,
      Broker_Relation__c.Id
    );
    List<Contact> brokerList = CONTACT_REPOSITORY.getBrokerSetContacts(
      brokerSetMap.keySet()
    );
    Set<Id> oldPrimaryRbms = ListUtil.getIds(
      oldBrokerSetRecords,
      Broker_Relation__c.Primary_RBM__c
    );
    Set<Id> oldSecondaryRbms = ListUtil.getIds(
      oldBrokerSetRecords,
      Broker_Relation__c.Secondary_RBM__c
    );
    List<User> rbUsers = BROKER_RELATION_REPOSITORY.queryRbmUsers(
      oldPrimaryRbms,
      oldSecondaryRbms
    );
    Map<Id, User> rbmUserMap = (Map<Id, User>) ListUtil.mapBy(rbUsers, User.Id);
    List<PayloadInputWrapper> payloadInputList = getPayloadInputListForBrokerSet(
      brokerList,
      rbmUserMap,
      brokerSetMap
    );
    List<SObject> successPublishedEvents = publishEvents(payloadInputList);
    return successPublishedEvents;
  }

  /**
   * @description Publish broker relation events
   * @param payloadInputList list of input wrapper needed to build payload for add and delete event
   * @return List of success published events
   */
  @TestVisible
  private static List<SObject> publishEvents(
    List<PayloadInputWrapper> payloadInputList
  ) {
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd = generateAddEventModel(
      payloadInputList
    );
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsDelete = generateDeleteEventModel(
      payloadInputList
    );
    List<BrokerCloudEventModel> cloudEventModels = createCloudEvents(
      cloudEventModelsAdd,
      cloudEventModelsDelete
    );
    List<SObject> successPublishedEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    logSuccessEvents(successPublishedEvents);
    return successPublishedEvents;
  }

  /**
   * @description Create a list of PayloadInputWrapper
   * @param brokerList contact related to updated broker sets
   * @param oldMap map of old contacts from trigger context
   * @param brokerSetMapForOldContacts map of old broker set id and it's detail map
   * @return List<PayloadInputWrapper>
   */
  @TestVisible
  private static List<PayloadInputWrapper> getPayloadInputListForContacts(
    List<Contact> brokerList,
    Map<Id, Contact> oldMap,
    Map<Id, Broker_Relation__c> brokerSetMapForOldContacts
  ) {
    List<PayloadInputWrapper> inputWrapperList = new List<PayloadInputWrapper>();
    for (Contact broker : brokerList) {
      LanIdWrapper oldRbmLanIds = new LanIdWrapper();
      Id olderBrokerSetId = null;
      olderBrokerSetId =oldMap?.oldMap.get(broker.Id)?.Broker_Set__c;

      oldRbmLanIds.prbmLanId = brokerSetMapForOldContacts.get(olderBrokerSetId)
        ?.Primary_RBM__r
        ?.Lan_Id__c;
      oldRbmLanIds.srbmLanId = brokerSetMapForOldContacts.get(olderBrokerSetId)
        ?.Secondary_RBM__r
        ?.Lan_Id__c;

      PayloadInputWrapper inputWrapper = new PayloadInputWrapper();
      inputWrapper.oldBrokerSet = oldRbmLanIds;
      inputWrapper.broker = broker;
      inputWrapper.rbmType = returnRbmType(broker, oldRbmLanIds);
      inputWrapperList.add(inputWrapper);
    }
    return inputWrapperList;
  }

  /**
   * @description Create a list of PayloadInputWrapper
   * @param brokerList contact related to updated broker sets
   * @param rbmUserMap user id and user detail map
   * @param oldBrokerSetRecordMap old broker set id and it's detail map
   * @return List<PayloadInputWrapper>
   */
  @TestVisible
  private static List<PayloadInputWrapper> getPayloadInputListForBrokerSet(
    List<Contact> brokerList,
    Map<Id, User> rbmUserMap,
    Map<Id, Broker_Relation__c> oldBrokerSetRecordMap
  ) {
    List<PayloadInputWrapper> inputWrapperList = new List<PayloadInputWrapper>();
    for (Contact broker : brokerList) {
      LanIdWrapper oldRbmLanIds = new LanIdWrapper();
      oldRbmLanIds.prbmLanId = rbmUserMap.get(
          oldBrokerSetRecordMap.get(broker.Broker_Set__c)?.Primary_RBM__c
        )
        ?.Lan_Id__c;
      oldRbmLanIds.srbmLanId = rbmUserMap.get(
          oldBrokerSetRecordMap.get(broker.Broker_Set__c)?.Secondary_RBM__c
        )
        ?.Lan_Id__c;

      PayloadInputWrapper inputWrapper = new PayloadInputWrapper();
      inputWrapper.oldBrokerSet = oldRbmLanIds;
      inputWrapper.rbmType = returnRbmType(broker, oldRbmLanIds);
      inputWrapper.broker = broker;
      inputWrapperList.add(inputWrapper);
    }
    return inputWrapperList;
  }

  /**
   * @description Generate Broker Relation related Cloud Event Model for Add event
   * @param payloadInputList List of payload input wrapper
   * @return List<BrokerCloudEventModel.MasterNode>
   */
  @TestVisible
  private static List<BrokerCloudEventModel.MasterNode> generateAddEventModel(
    List<PayloadInputWrapper> payloadInputList
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    for (PayloadInputWrapper inputWrapper : payloadInputList) {
      if (inputWrapper.rbmType.contains('PRBM' + BROKER_RELATION_EVENT_ADD)) {
        masterNodes.add(
          BrokerRelationDataCEBuilder.buildBrokerRelationAddEvent(
            inputWrapper.broker,
            'PRBM'
          )
        );
      }
      if (inputWrapper.rbmType.contains('SRBM' + BROKER_RELATION_EVENT_ADD)) {
        masterNodes.add(
          BrokerRelationDataCEBuilder.buildBrokerRelationAddEvent(
            inputWrapper.broker,
            'SRBM'
          )
        );
      }
    }
    return masterNodes;
  }

  /**
   * @description Generate Broker Relation related Cloud Event Model for Delete event
   * @param payloadInputList List of payload input wrapper
   * @return List<BrokerCloudEventModel.MasterNode>
   */
  @TestVisible
  private static List<BrokerCloudEventModel.MasterNode> generateDeleteEventModel(
    List<PayloadInputWrapper> payloadInputList
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    for (PayloadInputWrapper inputWrapper : payloadInputList) {
      if (
        inputWrapper.rbmType.contains('PRBM' + BROKER_RELATION_EVENT_DELETE)
      ) {
        masterNodes.add(
          BrokerRelationDataCEBuilder.buildBrokerRelationDeleteEvent(
            inputWrapper.broker,
            'PRBM',
            inputWrapper.oldBrokerSet
          )
        );
      }
      if (
        inputWrapper.rbmType.contains('SRBM' + BROKER_RELATION_EVENT_DELETE)
      ) {
        masterNodes.add(
          BrokerRelationDataCEBuilder.buildBrokerRelationDeleteEvent(
            inputWrapper.broker,
            'SRBM',
            inputWrapper.oldBrokerSet
          )
        );
      }
    }
    return masterNodes;
  }

  /**
   * @description To decide which rbms are needed to be passed in broker relation event payload
   * @param broker Contact record
   * @param oldBrokerSet older broker set record of type LanIdWrapper
   * @return Set<String>
   */
  @TestVisible
  private static Set<String> returnRbmType(
    Contact broker,
    LanIdWrapper oldBrokerSet
  ) {
    Set<String> rbmType = new Set<String>();

    if (
      broker.Broker_Set__r.Primary_RBM__r.Lan_Id__c != oldBrokerSet.prbmLanId
    ) {
      rbmType.add('PRBM' + BROKER_RELATION_EVENT_ADD);
    }

    if (oldBrokerSet.prbmLanId != null && !rbmType.isEmpty()) {
      rbmType.add('PRBM' + BROKER_RELATION_EVENT_DELETE);
    }

    if (
      broker.Broker_Set__r?.Secondary_RBM__r?.Lan_Id__c ==
      oldBrokerSet.srbmLanId
    ) {
      return rbmType;
    }

    if (broker.Broker_Set__r?.Secondary_RBM__c != null) {
      rbmType.add('SRBM' + BROKER_RELATION_EVENT_ADD);
    }

    if (oldBrokerSet?.srbmLanId != null) {
      rbmType.add('SRBM' + BROKER_RELATION_EVENT_DELETE);
    }

    return rbmType;
  }

  /**
   * @description To transform broker relation event as List<BrokerCloudEventModel>
   * @param cloudEventModelsAdd Add event payload for Broker Relation event
   * @param cloudEventModelsDelete Delete event payload for Broker Relation event
   * @return List<BrokerCloudEventModel>
   */
  @TestVisible
  private static List<BrokerCloudEventModel> createCloudEvents(
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd,
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsDelete
  ) {
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();

    cloudEventModels.addAll(
      createEventBatches(cloudEventModelsAdd, BROKER_RELATION_EVENT_ADD)
    );
    cloudEventModels.addAll(
      createEventBatches(cloudEventModelsDelete, BROKER_RELATION_EVENT_DELETE)
    );

    return cloudEventModels;
  }

  /**
   * @description To create batches of 100 records, so that no more than 100 records are passed as a part of one event of broker relation
   * @param cloudEventModelsList List<BrokerCloudEventModel.MasterNode>
   * @param eventType type of broker relation event
   * @return List<BrokerCloudEventModel>
   */
  @TestVisible
  private static List<BrokerCloudEventModel> createEventBatches(
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsList,
    String eventType
  ) {
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();
    final Integer eventBatchSize = Integer.valueOf(
      System.Label.ANZX_Broker_Relation_event_batch_size
    );
    final Integer numOfEvents = cloudEventModelsList.size();

    // process all cloud events in chunks of size = 'eventBatchSize'.
    for (Integer i = 0; i < numOfEvents; i += eventBatchSize) {
      // increments by 'eventBatchSize'
      List<Object> anEventBatch = ListUtil.subList(
        cloudEventModelsList,
        i,
        eventBatchSize
      );
      // prepare a list of batches, each with a maximum of "eventBatchSize" events.
      cloudEventModels.add(
        new BrokerRelationDataCloudEventModel(
          (List<BrokerCloudEventModel.MasterNode>) anEventBatch,
          eventType
        )
      );
    }
    return cloudEventModels;
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
      successEvents.size() + ' Broker Relation Cloud Events were published'
    );
    Logger.saveLog();
  }

  /**
   * @description Wrapper class to hold details of old broker set
   **/
  public class LanIdWrapper {
    /**
     * @description to capture primary rbm lan id
     **/
    public String prbmLanId { get; set; }
    /**
     * @description to capture secondary rbm lan id
     **/
    public String srbmLanId { get; set; }
  }

  /**
   * @description Wrapper class to get inputs needed to generate event payload
   **/
  public class PayloadInputWrapper {
    /**
     * @description to capture broker details
     **/
    public Contact broker { get; set; }
    /**
     * @description to capture old rbm lan ids
     **/
    public LanIdWrapper oldBrokerSet { get; set; }
    /**
     * @description to capture changed RBMs
     **/
    public Set<String> rbmType { get; set; }
  }
}
