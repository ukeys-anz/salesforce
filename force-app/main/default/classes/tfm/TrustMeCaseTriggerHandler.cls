/**
 * @author Shivraj Kadam
 * @since 02/2025
 * @description  TrustMeCaseTriggerHandler is the handler class for TrustMe QA Case Trigger.
 */
public with sharing class TrustMeCaseTriggerHandler extends Lib_TriggerHandler {
   /**
   * @description Constructor to initialise Trigger Handler library
   */
  public TrustMeCaseTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of KYC QA Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.trustMeQA;
  }
  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> validCases = ListUtil.filter(records).noError().toList();
    TrustMeCaseActions.updateTestedDate(validCases);
  }
}