/**
 *
 * @author Ram vilas
 * @since 07/2025
 * @description  CreditReferralCaseTriggerHandler is the handler class for Credit referral Cases Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public class CreditReferralCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CreditReferralCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Case caseRecord = (Case) record;
    return caseRecord.RecordTypeId == RTCase.creditReferral;
  }
  /**
   * @description onBeforeInsert to handle before update trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());

    CreditReferralCaseActions.ownerAssignment(records);
    CreditReferralCaseActions.escalateFraudCase(
      records,
      (Map<Id, Case>) oldMap
    );
  }
  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap Map<Id, SObject>
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());

    CreditReferralCaseActions.invalidUserForFraudCase(
      records,
      (Map<Id, Case>) oldMap
    );
    CreditReferralCaseActions.invalidOutcomeToUpdateOwner(
      records,
      (Map<Id, Case>) oldMap
    );
    CreditReferralCaseActions.ownerUpdateToFruadCases(
      records,
      (Map<Id, Case>) oldMap
    );
    CreditReferralCaseActions.escalateFraudCase(
      records,
      (Map<Id, Case>) oldMap
    );
  }

  /**
   * @description onAfterInsert to handle After insert trigger actions.
   */
  public override void onAfterInsert() {
    Logger.debug('On_After_Insert started: ' + System.now());
    CreditReferralCaseActions.escalateRLA(records, null);
  }

  /**
   * @description onAfterUpdate to handle After update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_After_Update started: ' + System.now());
    CreditReferralCaseActions.escalateRLA(records, (Map<Id, Case>) oldMap);
  }
}
