/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2023
 * @description handler class for ContactToContactTrigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class ContactToContactTriggerHandler extends Lib_TriggerHandler {
  /** @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    CCRMContactToContactActions.setExternalId(records);
  }

  /**
   * @description onAfterUpdate to handle After update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CCRMContactToContactActions.checkRelationshipEndDate(
      records,
      (Map<Id, FinServ__ContactContactRelation__c>) oldMap
    );
  }
}
