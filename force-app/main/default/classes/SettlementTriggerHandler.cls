/**
 * @author Peter Charalambous
 * @since Wed Nov 01 2023
 * @description trigger handler for Settlements
 */
public with sharing class SettlementTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public SettlementTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    //Assign settlements queue as owner
    SettlementActions.assignSettlementQueue(records);
    //Populate requested loan amount
    SettlementActions.populateRequestedAmount(records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions
   */
  public override void onAfterInsert() {
    //Create Action Plan
    SettlementActions.createActionPlans(records, null);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    //Create Action Plan
    SettlementActions.createActionPlans(
      records,
      (Map<Id, Settlement__c>) oldMap
    );
  }
}
