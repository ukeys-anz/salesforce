/**
 * @author Deepro De
 * @since August 2024
 * @description trigger handler for Loan Applicant object
 */
public with sharing class LoanApplicantTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public LoanApplicantTriggerHandler() {
    super();
  }
  /**
   * @description onAfterInsert to handle after insert trigger actions
   */
  public override void onAfterInsert() {
    LoanApplicantActions.accountSyncStatusUpdate(Trigger.newMap.keySet());
  }
}
