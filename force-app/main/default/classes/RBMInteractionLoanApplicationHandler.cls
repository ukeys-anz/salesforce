/**
 * @description       : This handler class for Associated_Loan_Application__c junction object,
 *                      used within the context of RBM Broker Interaction functionality.
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 05-19-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/

public with sharing class RBMInteractionLoanApplicationHandler extends Lib_TriggerHandler {
  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    RBMInteractionLoanApplicationActions.calculateInteractionRelatedLoanApplications(
      records
    );
    RBMInteractionLoanApplicationActions.validateApplicationRecords(records);
  }
}
