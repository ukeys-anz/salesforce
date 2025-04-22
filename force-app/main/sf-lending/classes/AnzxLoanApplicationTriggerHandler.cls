/**
 * @author @ramvilas
 * @since April 2025
 * @description creates `ResidentialLoanApplication` of loan application record type
 * @group handler
 * @runTests AnzxLoanApplicationTriggerHandlerTest
 */
public with sharing class AnzxLoanApplicationTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public AnzxLoanApplicationTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of RLA records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    ResidentialLoanApplication loanRecord = (ResidentialLoanApplication) record;
    return loanRecord.RecordTypeId == RTResidentialLoanApplication.anzxHomeLoan;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    //Assign home loan applications queue as owner
    AnzxLoanApplicationActions.assignHomeLoanAppQueue(records);
    AnzxLoanApplicationActions.setSunsetTimestamp(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    AnzxLoanApplicationActions.setSunsetTimestamp(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );

    CommonResidentialLoanApplicationActions.updateApplicationProgressToBlank(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );
  }
}
