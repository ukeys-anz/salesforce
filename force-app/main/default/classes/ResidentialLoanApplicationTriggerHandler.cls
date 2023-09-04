/**
 * @author cruzb
 * @since July 2023
 * @description creates `ResidentialLoanApplication`
 * @group handler
 */
public with sharing class ResidentialLoanApplicationTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public ResidentialLoanApplicationTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    //Assign home loan applications queue as owner
    ResidentialLoanApplicationActions.assignHomeLoanAppQueue(records);
  }
}
