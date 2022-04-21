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
   * @description onValidate(oldMap) is called before onAfterUpdate and all the required record updates are handled here
   * @param oldMap old trigger values
   */
  // ABT-25697 - Disable Trigger for Delete Event for Beta
  // public override void onValidate(Map<Id, SObject> oldMap) {
  //   AccountCommonActions.checkForAccountDeletion(records);
  // }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    AccountCommonActions.createEntitlement(records);
    AccountCommonActions.findAndConvertLead(records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    AccountCommonActions.updateEntitlement(records, oldMap);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    AccountCommonActions.revertAccountChanges(records, oldMap);
  }
}
