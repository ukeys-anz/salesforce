/**
 * @author David Dawson
 * @since 08/2020
 * @description  AccountTriggerHandler is the handler class for Account Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class AccountTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public AccountTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onBeforeInsert() {
    CCRMAccountActions.setControllingPost(records, null);
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    AccountCommonActions.createEntitlement(records);
    AccountCommonActions.findAndConvertLead(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    AccountCommonActions.revertAccountChanges(records, oldMap);
    CCRMAccountActions.setControllingPost(records, (Map<Id, Account>) oldMap);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    AccountCommonActions.updateEntitlement(records, oldMap);
  }
}
