/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description LoanApplicantGroupTriggerHandler is the handler class for Loan Applicant Group Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class LoanApplicantGroupTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LoanApplicantGroupTriggerHandler
   */
  public LoanApplicantGroupTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    LoanApplicantGroupHelper.copySOPId(records);
  }
}
