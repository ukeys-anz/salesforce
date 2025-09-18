/**
 * @description handles events on `ResidentialLoanApplication` of RLS record Type
 * @group handler
 * @runTests RLSResidentialLoanAppTriggerHandlerTest
 */
public with sharing class RLSResidentialLoanAppTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public RLSResidentialLoanAppTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of RLA records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    ResidentialLoanApplication loanRecord = (ResidentialLoanApplication) record;
    return loanRecord.RecordTypeId ==
      RTResidentialLoanApplication.rlsResidentialLoanApplication;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions
   */
  public override void onBeforeInsert() {
    ResidentialLoanApplicationActions.populateRetailLoanAssistedBroker(
      records,
      new Map<Id, ResidentialLoanApplication>()
    );
    ResidentialLoanApplicationActions.updateApplicationSyncStatus(records);
    ResidentialLoanApplicationActions.setResidentialLoanApplicationValidity(
      records
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    ResidentialLoanApplicationActions.populateRetailLoanAssistedBroker(
      records,
      (Map<Id, ResidentialLoanApplication>) oldMap
    );
    ResidentialLoanApplicationActions.setResidentialLoanApplicationValidity(
      ListUtil.filter(records, oldMap)
        .changed(ResidentialLoanApplication.Status)
        .toList()
    );
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions
   */
  @TestVisible
  public override void onAfterInsert() {
    ResidentialLoanApplicationActions.publishSyncEvents(
      records,
      ApplicationEventActions.APPLICATION_EVENT_ADD
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    ResidentialLoanApplicationActions.publishSyncEvents(
      records,
      ApplicationEventActions.APPLICATION_EVENT_UPDATE
    );
  }
}
