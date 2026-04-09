/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormProductTriggerHandler is the handler class for AFP Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class CommercialAppFormProductTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CommercialAppFormProductTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CommercialAppFormProductActions.checkStageOnInsert(records);

    //populate close date on AFP
    CommercialAppFormProductActions.populateCloseDate(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialAppFormProductActions.checkSkipStage(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    //map stage with source system status
    CommercialAppFormProductActions.mapStageWithSourceSystemStatus(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    CommercialAppFormProductActions.populateCloseDateForAmbitOnStageChange(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    //populate last updated stage date
    CommercialAppFormProductActions.populateStageUpdatedDate(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
  }
  /**
   * @description onAfterInsert to handle after update trigger actions.
   */
  public override void onAfterInsert() {
    CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      (List<ApplicationFormProduct>) records,
      null,
      'add'
    );
    CommercialAppFormProductActions.setFieldsOnRelatedOpportunity(
      records,
      null
    );
    CommercialAppFormProductActions.createAppFormShareRecords(records);
    CommercialBrokerAppFormProdActions.createOptyAndOptyProductRecords(records);
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      (List<ApplicationFormProduct>) records,
      (Map<Id, ApplicationFormProduct>) oldMap,
      'add'
    );
    CommercialAppFormProductActions.setFieldsOnRelatedOpportunity(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    CommercialAppFormProductActions.updateApprovedAmountOnOpp(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    CommercialAppFormProductActions.calculateEstimatedRevenueOnOpp(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    CommercialAppFormProductActions.updateStageOnOpportunity(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    CommercialAppFormProductActions.syncSettlementDateAndAmountToOppProduct(
      (List<ApplicationFormProduct>) records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
    CommercialAppFormProductActions.setPotentialDuplicateFlag(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
  }
}
