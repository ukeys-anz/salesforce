/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormTriggerHandler is the handler class for AF Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class CommercialAppFormTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CommercialAppFormTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    CommercialAppFormActions.setTotalAmountOnOpp(records, null);
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialAppFormActions.setTotalAmountOnOpp(
      records,
      (Map<Id, ApplicationForm>) oldMap
    );
  }
}
