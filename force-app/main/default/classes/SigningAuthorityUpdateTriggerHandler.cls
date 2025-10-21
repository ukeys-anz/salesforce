/**
 * @author Sanskriti Routray
 * @since 09/2025
 * @description  SigningAuthorityUpdateTriggerHandler is the handler class for Case Trigger for Case Management- Signing Auth uplift which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class SigningAuthorityUpdateTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public SigningAuthorityUpdateTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Case caesRecord = (Case) record;
    return caesRecord.RecordTypeId == RTCase.signAuth;
  }

  /**
   * @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    SigningAuthorityUpdateActions.setSubject(records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> eligibleRecords = ListUtil.filter(records)
      .changed(Case.FinServ__FinancialAccount__c)
      .toList();
    SigningAuthorityUpdateActions.dereferenceFA(
      records,
      (Map<Id, Case>) oldMap
    );
    SigningAuthorityUpdateActions.caseEscalationUpdate(
      records,
      (Map<Id, Case>) oldMap
    );
    SigningAuthorityUpdateActions.completeMilestone(
      records,
      (Map<Id, Case>) oldMap
    );
    SigningAuthorityUpdateActions.setSubject(eligibleRecords);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    SigningAuthorityUpdateActions.chatterPostOnSuccessfulUpdate(
      records,
      (Map<Id, Case>) oldMap
    );
  }
}
