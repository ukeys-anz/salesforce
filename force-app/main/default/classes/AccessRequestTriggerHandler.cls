/**
 * @author Shermal Warnakula
 * @since May 2021
 * @description  AccessRequestTriggerHandler is the handler class for {@link AccessRequestTrigger} which extends {@link Lib_TriggerHandler} the trigger framework used.
 */

public with sharing class AccessRequestTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public AccessRequestTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    AccessRequestCommonActions.logSubmission(records, oldMap);
    AccessRequestCommonActions.checkApprovers(records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    AccessRequestCommonActions.createPARequestRecords(records, oldMap);
    AccessRequestCommonActions.logApprovalDecision(records, oldMap);
  }
}
