/**
 * @description       : Broker_Relation__c related trigger actions class
 * @author            : Grace Anusha | Salesforce
 * @group             :
 * @last modified on  : 02-14-2025
 * @last modified by  : Grace Anusha | Salesforce
 * @runTests BrokerRelationActionsTest
 **/

public class BrokerRelationActions {
  private static final RetailContactRepository CONTACT_REPOSITORY = (RetailContactRepository) Lib_InstanceProvider.forType(
    RetailContactRepository.class
  );
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
  public static final String SEPERATOR_HYPHEN = '-';
  public static final String SEPERATOR_UNDERSCORE = '_';
  public static final String SEPERATOR_WHITESPACE = ' ';
  /**
   * @description updates external id field with format Name-Segment-State
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param records contains new value
   **/
  public static void populateExternalId(List<Broker_Relation__c> records) {
    for (Broker_Relation__c brokerRelation : records) {
      brokerRelation.External_Id__c =
        brokerRelation.Name.replace(
          SEPERATOR_WHITESPACE,
          SEPERATOR_UNDERSCORE
        ) +
        SEPERATOR_HYPHEN +
        brokerRelation.Segment__c +
        SEPERATOR_HYPHEN +
        brokerRelation.State__c;
    }
  }

  /**
   * @description updates external id field with format Name-Segment-State upon modification of broker set
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void populateExternalIdOnFilteredBS(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    List<Broker_Relation__c> extIdConstituentFieldBSChangeRecords = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(EXT_ID_CONSTITUENT_FIELDS)
      .toList();
    populateExternalId(extIdConstituentFieldBSChangeRecords);
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
    records = ListUtil.filter(records, oldMap)
      .changed(Broker_Relation__c.Aggregator__c)
      .toList();
    Map<Id, Broker_Relation__c> brokerMap = BROKER_RELATION_REPOSITORY.getBrokerMap(
      ListUtil.getIds(records, Broker_Relation__c.Id)
    );
    showError(brokerMap, records);
  }

  /**
   * @description displays error when broker set is changed on office group
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param oldMap contains old value
   * @param records contains new value
   **/
  public static void restrictBrokerSetChangeOnOG(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    records = ListUtil.filter(records, oldMap)
      .changed(Broker_Relation__c.Associated_Broker_Set__c)
      .toList();
    showErrorOfficeGroupHasBrokers(
      BROKER_RELATION_REPOSITORY.getBrokerMapOfficeGroup(
        ListUtil.getIds(records, Broker_Relation__c.Id)
      ),
      records,
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
    records = ListUtil.filter(records, oldMap)
      .changedTo(Broker_Relation__c.IsActive__c, false)
      .toList();
    showErrorOfficeGroupHasBrokers(
      BROKER_RELATION_REPOSITORY.getBrokerMapOfficeGroup(
        ListUtil.getIds(records, Broker_Relation__c.Id)
      ),
      records,
      System.Label.ErrorMsg_OfficeGroup_Deactication_Has_Brokers
    );
  }

  /**
   * @description Displays error when aggregator is changed on Broker Set
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param brokerMap contains new broker relation value
   * @param records contains new value
   **/
  @TestVisible
  private static void showError(
    Map<Id, Broker_Relation__c> brokerMap,
    List<Broker_Relation__c> records
  ) {
    for (Broker_Relation__c record : records) {
      if (
        brokerMap.containsKey(record.Id) &&
        !brokerMap.get(record.Id).Broker_Set_Brokers__r.isEmpty()
      ) {
        record.Aggregator__c.addError(
          System.Label.ErrorMsg_BrokerSet_Change_Agg_Has_Brokers
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
  private static void showErrorOfficeGroupHasBrokers(
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
    records = ListUtil.filter(records, oldMap)
      .changedTo(Broker_Relation__c.IsActive__c, false)
      .toList();
    showErrorBrokerSetHasBrokers(
      BROKER_RELATION_REPOSITORY.getBrokerMap(
        ListUtil.getIds(records, Broker_Relation__c.Id)
      ),
      records
    );
  }

  /**
   * @description displays error if broker set has brokers tagged to it
   * @author  Grace Anusha | Salesforce | 24-03-2025
   * @param brokerMap contains new broker set value
   * @param records contains new value
   **/
  public static void showErrorBrokerSetHasBrokers(
    Map<Id, Broker_Relation__c> brokerMap,
    List<Broker_Relation__c> records
  ) {
    for (Broker_Relation__c brokerSet : records) {
      if (
        brokerMap.containsKey(brokerSet.id) &&
        !brokerMap.get(brokerSet.id).Broker_Set_Brokers__r.isEmpty()
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
  public static void restrictDeactivationRelatedOG(
    Map<Id, Broker_Relation__c> oldMap,
    List<Broker_Relation__c> records
  ) {
    records = ListUtil.filter(records, oldMap)
      .changedTo(Broker_Relation__c.IsActive__c, false)
      .toList();
    showErrorBrokerSetHasOGs(
      BROKER_RELATION_REPOSITORY.getOfficeGroupRelatedToBrokerSet(
        ListUtil.getIds(records, Broker_Relation__c.Id)
      ),
      records
    );
  }

  /**
   * @description displays error if broker set with related office groups is deactivated
   * @author Grace Anusha | Salesforce | 24-03-2025
   * @param officeGroupMap contains Broker Relation triggered value
   * @param records contains new value
   **/
  public static void showErrorBrokerSetHasOGs(
    Map<Id, Broker_Relation__c> officeGroupMap,
    List<Broker_Relation__c> records
  ) {
    for (Broker_Relation__c brokerSet : records) {
      if (
        officeGroupMap.containsKey(brokerSet.id) &&
        !officeGroupMap.get(brokerSet.id).Office_Groups__r.isEmpty()
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
    if (BROKER_SETTINGS_REPOSITORY.get().BypassBrokerRelationEvent__c) {
      return new List<SObject>();
    }
    List<Broker_Relation__c> updatedBrokerSets = ListUtil.filter(
        oldMap.values(),
        newMap
      )
      .anyChanged(BROKER_RELATION_RBM_FIELDS)
      .toList();
    List<SObject> publishedEvents = RetailBrokerRelationEventActions.publishEventForBrokerRelation(
      updatedBrokerSets
    );
    return publishedEvents;
  }
}
