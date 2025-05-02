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
   * @param brokerIdToEventTypeMap Map of broker Id to event type
   * @param oldMap map of old contacts from trigger context
   * @return List of success published events
   */
  public static List<SObject> publishEventForBrokerRelation(
    Map<Id, String> brokerIdToEventTypeMap,
    Map<Id, Contact> oldMap
  ) {
    List<Contact> brokers = CONTACT_REPOSITORY.getContacts(
      brokerIdToEventTypeMap.keySet()
    );
    Map<Id, Broker_Relation__c> brokerSetMapForOldContacts = BROKER_RELATION_REPOSITORY.queryBrokerRelationWithRbmDetails(
      ListUtil.getIds(oldMap.values(), Contact.Broker_Set__c)
    );
    Map<Id, LanIdWrapper> contIdAndOldRbmLanIdMap = createContactAndLanIdMap(
      brokers,
      oldMap,
      brokerSetMapForOldContacts
    );
    BrokerRelationEventWrapper brokerRelationEvent = getBrokerRelationEvent(
      brokers,
      brokerIdToEventTypeMap,
      contIdAndOldRbmLanIdMap
    );
    List<BrokerCloudEventModel> cloudEventModels = createCloudEvents(
      brokerRelationEvent
    );
    List<SObject> successPublishedEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    logSuccessEvents(successPublishedEvents);
    return successPublishedEvents;
  }

  /**
   * @description Publish event for broker relation when triggered from Broker Set
   * @param updatedBrokerSets contains the updated broker set where at least one rbm got changed
   * @return List of success published events
   */
  public static List<SObject> publishEventForBrokerRelation(
    List<Broker_Relation__c> updatedBrokerSets
  ) {
    List<Contact> brokerList = CONTACT_REPOSITORY.getBrokerSetContacts(
      ListUtil.getIds(updatedBrokerSets, Broker_Relation__c.Id)
    );
    Map<Id, User> rbmUserMap = BROKER_RELATION_REPOSITORY.queryRbmUsers(
      ListUtil.getIds(updatedBrokerSets, Broker_Relation__c.Primary_RBM__c),
      ListUtil.getIds(updatedBrokerSets, Broker_Relation__c.Secondary_RBM__c)
    );
    Map<Id, LanIdWrapper> bsIdAndOldRbmLanIdMap = createBsAndLanIdMap(
      brokerList,
      rbmUserMap,
      (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
        updatedBrokerSets,
        Broker_Relation__c.Id
      )
    );
    BrokerRelationEventWrapper brokerRelationEvent = getBrokerRelationEvent(
      brokerList,
      bsIdAndOldRbmLanIdMap
    );
    List<BrokerCloudEventModel> cloudEventModels = RetailBrokerRelationEventActions.createCloudEvents(
      brokerRelationEvent
    );
    List<SObject> successPublishedEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    logSuccessEvents(successPublishedEvents);
    return successPublishedEvents;
  }

  /**
   * @description Create a map of broker Id and it's old rbm lan Ids
   * @param brokerList contact related to updated broker sets
   * @param oldMap map of old contacts from trigger context
   * @param brokerSetMapForOldContacts map of old broker set id and it's detail map
   * @return Map<Id, LanIdWrapper>
   */
  @TestVisible
  private static Map<Id, LanIdWrapper> createContactAndLanIdMap(
    List<Contact> brokerList,
    Map<Id, Contact> oldMap,
    Map<Id, Broker_Relation__c> brokerSetMapForOldContacts
  ) {
    Map<Id, LanIdWrapper> contactIdAndOldRbmLanIdMap = new Map<Id, LanIdWrapper>();
    for (Contact broker : brokerList) {
      LanIdWrapper brokerSetRbmLanIds = new LanIdWrapper();
      Id olderBrokerSetId = oldMap.get(broker.Id).Broker_Set__c;
      brokerSetRbmLanIds.prbmLanId = brokerSetMapForOldContacts.get(
          olderBrokerSetId
        )
        ?.Primary_RBM__r
        ?.Lan_Id__c;
      brokerSetRbmLanIds.srbmLanId = brokerSetMapForOldContacts.get(
          olderBrokerSetId
        )
        ?.Secondary_RBM__r
        ?.Lan_Id__c;
      contactIdAndOldRbmLanIdMap.put(broker.Id, brokerSetRbmLanIds);
    }
    return contactIdAndOldRbmLanIdMap;
  }

  /**
   * @description Create a map of broker set Id and it's old rbm lan ids
   * @param brokerList contact related to updated broker sets
   * @param rbmUserMap user id and user detail map
   * @param oldBrokerSetRecordMap old broker set id and it's detail map
   * @return Map<Id, LanIdWrapper>
   */
  @TestVisible
  private static Map<Id, LanIdWrapper> createBsAndLanIdMap(
    List<Contact> brokerList,
    Map<Id, User> rbmUserMap,
    Map<Id, Broker_Relation__c> oldBrokerSetRecordMap
  ) {
    Map<Id, LanIdWrapper> bsIdAndOldRbmLanIdMap = new Map<Id, LanIdWrapper>();
    for (Contact broker : brokerList) {
      LanIdWrapper brokerSetRbmLanIds = new LanIdWrapper();
      brokerSetRbmLanIds.prbmLanId = rbmUserMap.get(
          oldBrokerSetRecordMap.get(broker.Broker_Set__c)?.Primary_RBM__c
        )
        ?.Lan_Id__c;
      brokerSetRbmLanIds.srbmLanId = rbmUserMap.get(
          oldBrokerSetRecordMap.get(broker.Broker_Set__c)?.Secondary_RBM__c
        )
        ?.Lan_Id__c;
      bsIdAndOldRbmLanIdMap.put(broker.Broker_Set__c, brokerSetRbmLanIds);
    }
    return bsIdAndOldRbmLanIdMap;
  }

  /**
   * @description Generate BrokerRelationEventWrapper instance to pass it for publishing broker relation event triggered from Contact update
   * @param brokers List of broker contact
   * @param brokerIdToEventTypeMap Map of broker Id to event type
   * @param contIdAndOldRbmLanIdMap map of old contacts and it's rbm's lanIds
   * @return BrokerRelationEventWrapper
   */
  @TestVisible
  private static BrokerRelationEventWrapper getBrokerRelationEvent(
    List<Contact> brokers,
    Map<Id, String> brokerIdToEventTypeMap,
    Map<Id, LanIdWrapper> contIdAndOldRbmLanIdMap
  ) {
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsDelete = new List<BrokerCloudEventModel.MasterNode>();
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd = new List<BrokerCloudEventModel.MasterNode>();

    for (Contact broker : brokers) {
      String eventType = brokerIdToEventTypeMap.get(broker.Id);
      LanIdWrapper oldBrokerSet = contIdAndOldRbmLanIdMap.get(broker.Id);
      cloudEventModelsAdd.addAll(
        generateBrokerRelationCEModel(
          broker,
          BROKER_RELATION_EVENT_ADD,
          oldBrokerSet
        )
      );
      if (eventType == BROKER_RELATION_EVENT_DELETE) {
        cloudEventModelsDelete.addAll(
          generateBrokerRelationCEModel(
            broker,
            BROKER_RELATION_EVENT_DELETE,
            oldBrokerSet
          )
        );
      }
    }
    BrokerRelationEventWrapper brokerRelationEvent = new BrokerRelationEventWrapper();
    brokerRelationEvent.cloudEventModelsDelete = cloudEventModelsDelete;
    brokerRelationEvent.cloudEventModelsAdd = cloudEventModelsAdd;
    return brokerRelationEvent;
  }

  /**
   * @description Generate BrokerRelationEventWrapper instance to pass it for publishing broker relation event triggered from Broker Relation update
   * @param brokers List of broker contact
   * @param bsIdAndOldRbmLanIdMap Map of broker set Id to it's old rbm lanIds
   * @return BrokerRelationEventWrapper
   */
  @TestVisible
  private static RetailBrokerRelationEventActions.BrokerRelationEventWrapper getBrokerRelationEvent(
    List<Contact> brokers,
    Map<Id, LanIdWrapper> bsIdAndOldRbmLanIdMap
  ) {
    RetailBrokerRelationEventActions.BrokerRelationEventWrapper brokerRelationEvent = new RetailBrokerRelationEventActions.BrokerRelationEventWrapper();
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsDelete = new List<BrokerCloudEventModel.MasterNode>();
    List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd = new List<BrokerCloudEventModel.MasterNode>();

    for (Contact broker : brokers) {
      RetailBrokerRelationEventActions.LanIdWrapper oldBrokerSetLanIds = bsIdAndOldRbmLanIdMap.get(
        broker.Broker_Set__c
      );
      cloudEventModelsAdd.addAll(
        RetailBrokerRelationEventActions.generateBrokerRelationCEModel(
          broker,
          RetailBrokerRelationEventActions.BROKER_RELATION_EVENT_ADD,
          oldBrokerSetLanIds
        )
      );
      cloudEventModelsDelete.addAll(
        RetailBrokerRelationEventActions.generateBrokerRelationCEModel(
          broker,
          RetailBrokerRelationEventActions.BROKER_RELATION_EVENT_DELETE,
          oldBrokerSetLanIds
        )
      );
    }
    brokerRelationEvent.cloudEventModelsDelete = cloudEventModelsDelete;
    brokerRelationEvent.cloudEventModelsAdd = cloudEventModelsAdd;
    return brokerRelationEvent;
  }

  /**
   * @description To transform broker relation event as List<BrokerCloudEventModel>
   * @param brokerRelationEvent instance of BrokerRelationEventWrapper class
   * @return List<BrokerCloudEventModel>
   */
  @TestVisible
  private static List<BrokerCloudEventModel> createCloudEvents(
    BrokerRelationEventWrapper brokerRelationEvent
  ) {
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();

    cloudEventModels.addAll(
      createEventBatches(
        brokerRelationEvent.cloudEventModelsAdd,
        BROKER_RELATION_EVENT_ADD
      )
    );
    cloudEventModels.addAll(
      createEventBatches(
        brokerRelationEvent.cloudEventModelsDelete,
        BROKER_RELATION_EVENT_DELETE
      )
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
    Integer maxSize = Integer.valueOf(
      System.Label.ANZX_Broker_Relation_event_batch_size
    );
    for (Integer i = 0; i < cloudEventModelsList.size(); i += maxSize) {
      List<Object> eventBatch = ListUtil.subList(
        cloudEventModelsList,
        i,
        maxSize
      );
      cloudEventModels.add(
        new BrokerRelationDataCloudEventModel(
          (List<BrokerCloudEventModel.MasterNode>) eventBatch,
          eventType
        )
      );
    }
    return cloudEventModels;
  }

  /**
   * @description Generate Broker Relation related Cloud Event Model
   * @param broker Contact record
   * @param eventType event type
   * @param oldBrokerSet older broker set record of type LanIdWrapper
   * @return List<BrokerCloudEventModel.MasterNode>
   */
  @TestVisible
  private static List<BrokerCloudEventModel.MasterNode> generateBrokerRelationCEModel(
    Contact broker,
    String eventType,
    LanIdWrapper oldBrokerSet
  ) {
    Set<String> rbmType = returnRbmType(broker, oldBrokerSet, eventType);

    if (rbmType.isEmpty()) {
      return new List<BrokerCloudEventModel.MasterNode>();
    }

    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    if (rbmType.contains('PRBM')) {
      List<BrokerCloudEventModel.MasterNode> primaryRbmMasterNodes = eventType ==
        BROKER_RELATION_EVENT_ADD
        ? buildBrokerRelationAdd(broker, 'PRBM')
        : buildBrokerRelationDelete(broker, 'PRBM', oldBrokerSet);
      masterNodes.addAll(primaryRbmMasterNodes);
    }

    if (rbmType.contains('SRBM')) {
      List<BrokerCloudEventModel.MasterNode> secondaryRbmMasterNodes = eventType ==
        BROKER_RELATION_EVENT_ADD
        ? buildBrokerRelationAdd(broker, 'SRBM')
        : buildBrokerRelationDelete(broker, 'SRBM', oldBrokerSet);
      masterNodes.addAll(secondaryRbmMasterNodes);
    }
    return masterNodes;
  }

  /**
   * @description To decide which rbms are needed to be passed in broker relation event payload
   * @param broker Contact record
   * @param oldBrokerSet older broker set record of type LanIdWrapper
   * @param eventType event type
   * @return Set<String>
   */
  @TestVisible
  private static Set<String> returnRbmType(
    Contact broker,
    LanIdWrapper oldBrokerSet,
    String eventType
  ) {
    Boolean primaryRbmChanged =
      broker?.Broker_Set__r?.Primary_RBM__r?.Lan_Id__c !=
      oldBrokerSet?.prbmLanId;

    Boolean secondaryRbmChanged =
      broker?.Broker_Set__r?.Secondary_RBM__r?.Lan_Id__c !=
      oldBrokerSet?.srbmLanId;

    Boolean secRbmOnContactAvailable =
      broker?.Broker_Set__r?.Secondary_RBM__c != null;

    Boolean secRbmOnBrokerSetAvailable = oldBrokerSet.srbmLanId != null;

    Set<String> rbmType = new Set<String>();
    if (primaryRbmChanged) {
      rbmType.add('PRBM');
    }
    if (
      secondaryRbmChanged &&
      ((secRbmOnContactAvailable && eventType == BROKER_RELATION_EVENT_ADD) ||
      (secRbmOnBrokerSetAvailable && eventType == BROKER_RELATION_EVENT_DELETE))
    ) {
      rbmType.add('SRBM');
    }
    return rbmType;
  }

  /**
   * @description Build the master nodes for broker relation add event
   * @param record the new contact record in trigger context
   * @param rbmType type of event
   * @return List<BrokerCloudEventModel.MasterNode>
   */
  @TestVisible
  private static List<BrokerCloudEventModel.MasterNode> buildBrokerRelationAdd(
    Contact record,
    String rbmType
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    masterNodes.add(
      BrokerRelationDataCEBuilder.buildBrokerRelationAdd(record, rbmType)
    );
    return masterNodes;
  }

  /**
   * @description Build the master nodes for broker relation delete event
   * @param record the new contact record in trigger context
   * @param rbmType type of event
   * @param oldBrokerSet older broker set record of broker contact
   * @return List<BrokerCloudEventModel.MasterNode>
   */
  @TestVisible
  private static List<BrokerCloudEventModel.MasterNode> buildBrokerRelationDelete(
    Contact record,
    String rbmType,
    LanIdWrapper oldBrokerSet
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    masterNodes.add(
      BrokerRelationDataCEBuilder.buildBrokerRelationDelete(
        record,
        rbmType,
        oldBrokerSet
      )
    );
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
      successEvents.size() + ' Broker Relation Cloud Events were published'
    );
    Logger.saveLog();
  }

  /**
   * @description Master Node class for creating and storing MasterNode details
   **/
  public class BrokerRelationEventWrapper {
    /**
     * @description to capture source object external id
     **/
    public List<BrokerCloudEventModel.MasterNode> cloudEventModelsAdd {
      get;
      set;
    }
    /**
     * @description to capture source object name
     **/
    public List<BrokerCloudEventModel.MasterNode> cloudEventModelsDelete {
      get;
      set;
    }
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
}
