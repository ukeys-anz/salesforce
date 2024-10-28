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
  }
  /**
   * @description onAfterInsert to handle after update trigger actions.
   */
  public override void onAfterInsert() {
    CommercialAppFormProductActions.setFieldsOnRelatedOpportunity(
      records,
      null
    );
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialAppFormProductActions.setFieldsOnRelatedOpportunity(
      records,
      (Map<Id, ApplicationFormProduct>) oldMap
    );
  }
}
