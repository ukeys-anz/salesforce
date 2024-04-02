/**
 * @author Tan Phan
 * @since 11/2023
 * @description handler class for AccountAccountRelationTrigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class AccountAccountRelationTriggerHandler extends Lib_TriggerHandler {
  /** @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    CCRMAccountAccountRelationActions.setExternalId(records);
  }

  /**
   * @description onAfterUpdate to handle After update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CCRMAccountAccountRelationActions.checkRelationshipStatus(records);
  }
}
