/**
 * @author Peter Charalambous
 * @since Tue Apr 16 2024
 * @description trigger handler for Settlement Account object
 */
public with sharing class SettlementAccountTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public SettlementAccountTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    SettlementAccountActions.populateCustomerName(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    SettlementAccountActions.populateCustomerName(records);
  }
}
