/**
 * @description Handler for Account Closure  and Case Group Case Trigger which extends Lib_TriggerHandler framework.
 * @author Kopal Goswami
 * @since 11/2024
 */
public with sharing class AccountClosureCaseTriggerHandler extends Lib_TriggerHandler {
  //appliable case record types to this handler
  public static final Set<Id> ACCNT_CLOSURE_CASE_RT_IDS = new Set<Id>{
    RTCase.accountClosure,
    RTCase.caseGroup
  };

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public AccountClosureCaseTriggerHandler() {
    super();
  }

  //Validate the record relevance to this handler based on record type

  public override Boolean isValidRecord(SObject records) {
    return ACCNT_CLOSURE_CASE_RT_IDS.contains(((Case) records).RecordTypeId);
  }

  public override void onBeforeInsert() {
    AccountClosureCaseActions.assignParentCaseToChildCase(records);
    AccountClosureCaseActions.validateDuplicateCaseGroupPerAccount(
      records,
      null
    );
    AccountClosureCaseActions.populateCaseSubject(records, null);
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    AccountClosureCaseActions.setQueueOwnerToEscalatedCases(
      records,
      (Map<Id, Case>) oldMap
    );
    AccountClosureCaseActions.populateCaseSubject(
      records,
      (Map<Id, Case>) oldMap
    );
    AccountClosureCaseActions.validateDuplicateCaseGroupPerAccount(
      records,
      (Map<Id, Case>) oldMap
    );
    AccountClosureCaseActions.validateCaseGroupClosure(
      records,
      (Map<Id, Case>) oldMap
    );
  }

  public override void onAfterInsert() {
    AccountClosureCaseActions.handleButtonVisibiltyFlag(records, null);
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    AccountClosureCaseActions.updateChildCaseField(
      records,
      (Map<Id, Case>) oldMap
    );
    AccountClosureCaseActions.handleButtonVisibiltyFlag(
      records,
      (Map<Id, Case>) oldMap
    );
  }

  public override void onAfterDelete() {
    AccountClosureCaseActions.handleButtonVisibiltyFlag(records, null);
  }
}
