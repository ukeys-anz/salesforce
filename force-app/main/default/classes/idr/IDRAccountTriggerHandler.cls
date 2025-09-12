/**
 * @author CMOS
 * @since Aug 2025
 * @description  IDRAccountTriggerHandler is the handler class for Account Trigger.
 */
public with sharing class IDRAccountTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public IDRAccountTriggerHandler() {
    super();
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    IDRAccountActions.checkEligibilityForCasePriorityUpdate(records, oldMap);
  }
}
