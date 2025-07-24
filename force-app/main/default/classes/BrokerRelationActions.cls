/**
 * @description       : Broker_Relation__c related trigger actions class
 * @author            : Grace Anusha | Salesforce
 * @group             :
 * @last modified on  : 02-14-2025
 * @last modified by  : Grace Anusha | Salesforce
 * @runTests BrokerRelationActionsTest
 **/

public class BrokerRelationActions {
  private static final BrokerRelationRepository BROKER_RELATION_REPOSITORY = (BrokerRelationRepository) Lib_InstanceProvider.forType(
    BrokerRelationRepository.class
  );
  private static final BrokerSettingsRepository BROKER_SETTINGS_REPOSITORY = (BrokerSettingsRepository) Lib_InstanceProvider.forType(
    BrokerSettingsRepository.class
  );
  private static final Set<SObjectField> BROKER_RELATION_RBM_FIELDS = new Set<SObjectField>{
    Broker_Relation__c.Primary_RBM__c,
    Broker_Relation__c.Secondary_RBM__c
  };
  public static final Set<SObjectField> EXT_ID_CONSTITUENT_FIELDS = new Set<SObjectField>{
    Broker_Relation__c.Name,
    Broker_Relation__c.Segment__c,
    Broker_Relation__c.State__c
  };

  /**
   * @description updates external id field with format Name-Segment-State
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param records contains new value
   **/
  public static void populateExternalId(List<Broker_Relation__c> records) {
    for (Broker_Relation__c brokerRelation : records) {
      brokerRelation.External_Id__c = String.format(
        '{0}-{1}-{2}',
        new List<Object>{
          brokerRelation.Name.replace(' ', '_'),
          brokerRelation.Segment__c,
          brokerRelation.State__c
        }
      );
    }
  }

  /**
   * @description updates external id field with format Name-Segment-State upon modification of broker set
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void populateExternalIdOnFilteredBrokerSet(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    List<Broker_Relation__c> brokerRelationsWithChangedExIds = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(EXT_ID_CONSTITUENT_FIELDS)
      .toList();
    populateExternalId(brokerRelationsWithChangedExIds);
  }

  /**
   * @description displays error when aggregator is changed
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void restrictAggregatorChange(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    List<Broker_Relation__c> changedBrokerSets = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Broker_Relation__c.Aggregator__c)
      .toList();
    Set<Id> changedBrokerSetIds = ListUtil.getIds(
      changedBrokerSets,
      Broker_Relation__c.Id
    );
    List<Broker_Relation__c> brokerSetsWithRelatedInfo = BROKER_RELATION_REPOSITORY.getBrokerSetWithBrokerAndOfficeGroup(
      changedBrokerSetIds
    );
    Map<Id, Broker_Relation__c> brokerSetsWithRelatedInfoById = (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
      brokerSetsWithRelatedInfo,
      Broker_Relation__c.Id
    );
    showErrorAggregatorChange(brokerSetsWithRelatedInfoById, changedBrokerSets);
  }

  /**
   * @description displays error when broker set is changed on office group
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void restrictBrokerSetChangeOnOfficeGroup(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    List<Broker_Relation__c> changedOfficeGroups = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Broker_Relation__c.Associated_Broker_Set__c)
      .toList();
    Set<Id> changedOfficeGroupIds = ListUtil.getIds(
      changedOfficeGroups,
      Broker_Relation__c.Id
    );
    List<Broker_Relation__c> officeGroupsWithBrokers = BROKER_RELATION_REPOSITORY.getBrokerMapOfficeGroup(
      changedOfficeGroupIds
    );
    Map<Id, Broker_Relation__c> officeGroupsWithBrokersById = (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
      officeGroupsWithBrokers,
      Broker_Relation__c.Id
    );
    showErrorIfOfficeGroupHasBrokers(
      officeGroupsWithBrokersById,
      changedOfficeGroups,
      System.Label.ErrorMsg_OfficeGroup_Change_BrokerSets_Has_Brokers
    );
  }

  /**
   * @description Blocks deactivation of office group when brokers are present in it
   * @author  Grace Anusha | Salesforce | 14-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void blockDeactivationOfficeGroup(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    List<Broker_Relation__c> changedOfficeGroups = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(Broker_Relation__c.IsActive__c, false)
      .toList();
    Set<Id> changedOfficeGroupIds = ListUtil.getIds(
      changedOfficeGroups,
      Broker_Relation__c.Id
    );
    List<Broker_Relation__c> changedOfficeGroupsWithBrokers = BROKER_RELATION_REPOSITORY.getBrokerMapOfficeGroup(
      changedOfficeGroupIds
    );
    Map<Id, Broker_Relation__c> changedOfficeGroupsWithBrokersById = (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
      changedOfficeGroupsWithBrokers,
      Broker_Relation__c.Id
    );
    showErrorIfOfficeGroupHasBrokers(
      changedOfficeGroupsWithBrokersById,
      changedOfficeGroups,
      System.Label.ErrorMsg_OfficeGroup_Deactication_Has_Brokers
    );
  }

  /**
   * @description Displays error when aggregator is changed on Broker Set
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param brokerRelationMap contains new broker set value with broker and office group
   * @param records contains new value
   **/
  @TestVisible
  private static void showErrorAggregatorChange(
    Map<Id, Broker_Relation__c> brokerRelationMap,
    List<Broker_Relation__c> records
  ) {
    for (Broker_Relation__c record : records) {
      if (!brokerRelationMap.containsKey(record.Id)) {
        continue;
      }

      if ((!brokerRelationMap.get(record.Id).Broker_Set_Brokers__r.isEmpty())) {
        record.Aggregator__c.addError(
          System.Label.ErrorMsg_BrokerSet_Change_Agg_Has_Brokers
        );
      }
      if ((!brokerRelationMap.get(record.Id).Office_Groups__r.isEmpty())) {
        record.Aggregator__c.addError(
          System.Label.ErrorMsg_BrokerSet_Change_Agg_Has_OG
        );
      }
    }
  }

  /**
   * @description Displays error when Broker Set is changed on Office Group
   * @author  Grace Anusha | Salesforce | 14-02-2025
   * @param brokerMap contains new broker relation value
   * @param records contains new value
   * @param errorMessageCutomLabel conatins error message
   **/
  @TestVisible
  private static void showErrorIfOfficeGroupHasBrokers(
    Map<Id, Broker_Relation__c> brokerMap,
    List<Broker_Relation__c> records,
    String errorMessageCutomLabel
  ) {
    for (Broker_Relation__c record : records) {
      if (
        brokerMap.containsKey(record.Id) &&
        !brokerMap.get(record.Id).Office_Group_Brokers__r.isEmpty()
      ) {
        record.addError(errorMessageCutomLabel);
      }
    }
  }

  /** @description display error on BS deactivation on conditions
   * @author  Utkarsh Singh | Salesforce | 13-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void restrictDeactivationOfBrokerSet(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    List<Broker_Relation__c> changedBrokerSets = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(Broker_Relation__c.IsActive__c, false)
      .toList();
    Set<Id> changedBrokerSetIds = ListUtil.getIds(
      changedBrokerSets,
      Broker_Relation__c.Id
    );
    List<Broker_Relation__c> brokerSetsWithBrokers = BROKER_RELATION_REPOSITORY.getBrokerMap(
      changedBrokerSetIds
    );
    Map<Id, Broker_Relation__c> brokerSetsWithBrokersById = (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
      brokerSetsWithBrokers,
      Broker_Relation__c.Id
    );
    showErrorIfBrokerSetHasBrokers(
      brokerSetsWithBrokersById,
      changedBrokerSets
    );
  }

  /**
   * @description displays error if broker set has brokers tagged to it
   * @author  Grace Anusha | Salesforce | 24-03-2025
   * @param brokerSetsWithBrokersById contains new broker set value
   * @param brokerRelations contains new value
   **/
  public static void showErrorIfBrokerSetHasBrokers(
    Map<Id, Broker_Relation__c> brokerSetsWithBrokersById,
    List<Broker_Relation__c> brokerRelations
  ) {
    for (Broker_Relation__c brokerSet : brokerRelations) {
      if (
        brokerSetsWithBrokersById.containsKey(brokerSet.id) &&
        !brokerSetsWithBrokersById.get(brokerSet.id)
          .Broker_Set_Brokers__r.isEmpty()
      ) {
        brokerSet.adderror(
          System.Label.Broker_Set_Deactivation_Error_Message_Unlink_Brokers
        );
      }
    }
  }

  /** @description display error on BS deactivation on conditions
   * @author  Utkarsh Singh | Salesforce | 13-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void restrictDeactivationRelatedOfficeGroup(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    List<Broker_Relation__c> changedBrokerSets = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(Broker_Relation__c.IsActive__c, false)
      .toList();
    Set<Id> changedBrokerSetIds = ListUtil.getIds(
      changedBrokerSets,
      Broker_Relation__c.Id
    );
    List<Broker_Relation__c> changedBrokerSetsWithRelatedOGs = BROKER_RELATION_REPOSITORY.getOfficeGroupRelatedToBrokerSet(
      changedBrokerSetIds
    );
    Map<Id, Broker_Relation__c> changedBrokerSetsWithRelatedOGsById = (Map<Id, Broker_Relation__c>) ListUtil.mapBy(
      changedBrokerSetsWithRelatedOGs,
      Broker_Relation__c.Id
    );
    showErrorIfBrokerSetHasOfficeGroups(
      changedBrokerSetsWithRelatedOGsById,
      changedBrokerSets
    );
  }

  /**
   * @description displays error if broker set with related office groups is deactivated
   * @author Grace Anusha | Salesforce | 24-03-2025
   * @param changedBrokerSetsWithRelatedOGsById contains Broker Relation triggered value
   * @param brokerRelations contains new value
   **/
  public static void showErrorIfBrokerSetHasOfficeGroups(
    Map<Id, Broker_Relation__c> changedBrokerSetsWithRelatedOGsById,
    List<Broker_Relation__c> brokerRelations
  ) {
    for (Broker_Relation__c brokerSet : brokerRelations) {
      if (
        changedBrokerSetsWithRelatedOGsById.containsKey(brokerSet.id) &&
        !changedBrokerSetsWithRelatedOGsById.get(brokerSet.id)
          .Office_Groups__r.isEmpty()
      ) {
        brokerSet.adderror(
          System.Label.Broker_Set_Deactivation_Error_Message_Unlink_Office_Group
        );
      }
    }
  }

  /**
   * @description Generate and dispatch Broker Relation related GCP cloud events
   * It trusts the CloudEventController.publishCloudEvents to complete the publish job
   * @param oldMap map of old broker relations from trigger context
   * @param newMap map of new broker relations from trigger context
   * @return List of success published events
   */
  public static List<SObject> publishBrokerRelationEvents(
    Map<Id, Broker_Relation__c> oldMap,
    Map<Id, Broker_Relation__c> newMap
  ) {
    List<SObject> publishedEvents = new List<SObject>();
    try {
      if (BROKER_SETTINGS_REPOSITORY.get().BypassBrokerRelationEvent__c) {
        return publishedEvents;
      }
      List<Broker_Relation__c> updatedBrokerSets = ListUtil.filter(
          oldMap.values(),
          newMap
        )
        .anyChanged(BROKER_RELATION_RBM_FIELDS)
        .toList();
      publishedEvents = RetailBrokerRelationEventActions.publishBrokerRelationEventFromBrokerSet(
        updatedBrokerSets
      );
    } catch (Exception e) {
      Logger.error(
          'Encountered error when publishing Broker Relation event. RBM info in Broker Org was not updated.',
          e
        )
        .save();
    }
    return publishedEvents;
  }
}
