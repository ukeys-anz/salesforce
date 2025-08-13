/**
 * @description       : This handler class for Associated_Loan_Application__c junction object,
 *                      used within the context of RBM Broker Interaction functionality.
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 06-04-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/

public with sharing class RBMAssociatedLoanApplicationHandler extends Lib_TriggerHandler {
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of
   * Associated_Loan_Application records. Since it is a junction Object with 2 master detail fields, and no
   * record Type, We are utilizing one of the master detail field as a filter for passing the validated Records.
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Associated_Loan_Application__c loanApplication = (Associated_Loan_Application__c) record;

    return loanApplication.Interaction__c != null;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    RBMAssociatedLoanApplicationActions.calculateInteractionRelatedLoanApplications(
      records
    );
    RBMAssociatedLoanApplicationActions.setApplicationUniqueKeys(records);
  }
}
