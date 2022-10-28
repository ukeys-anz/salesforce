/**
 * @author Qing Wang
 * @since 07/2022
 * @description  ExternalCaseStatusTriggerHandler is the handler class for ExternalCaseStatus Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class ExternalCaseStatusTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ExternalCaseStatusTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    ExternalCaseStatusActions.updateCaseStatusFromLatestExternalStatus(records);
  }
}
