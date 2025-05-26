/**
 * @author Jaya Srivastava
 * @since 02/2025
 * @description  LendingCaseTriggerHandler is the handler class for Case Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public class LendingCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public LendingCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Case caseRecord = (Case) record;
    return caseRecord.RecordTypeId == RTCase.lending;
  }
  /**
   * @description onValidateBefore to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    LendingCaseActions.restrictUserFromCreatingLendingCase(records);
    Logger.saveLog();
  }

  /**
   * @description onValidateBefore to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onValidateBefore(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());
    LendingCaseActions.restrictFromUpdatingClosedCase(
      records,
      (Map<Id, Case>) oldMap
    );
    LendingCaseActions.restrictFromUpdatingLendingCase(
      records,
      (Map<Id, Case>) oldMap
    );
    LendingCaseActions.restrictFromChangingOwnerToOtherUser(
      records,
      (Map<Id, Case>) oldMap
    );
    LendingCaseActions.restrictFromAssigningToOtherQueue(
      records,
      (Map<Id, Case>) oldMap
    );
    LendingCaseActions.restrictFromUpdatingStatusIfNotOwner(
      records,
      (Map<Id, Case>) oldMap
    );
    LendingCaseActions.restrictBohCoachFromChangingOwnerIfNotCaseOwner(
      records,
      (Map<Id, Case>) oldMap
    );

    LendingCaseActions.restrictLeadsFromAssigningCaseToOtherUsersOrQueue(
      records,
      (Map<Id, Case>) oldMap
    );
    LendingCaseActions.restrictUserFromUpdatingCaseToClosed(
      records,
      (Map<Id, Case>) oldMap
    );
    Logger.saveLog();
  }
}
