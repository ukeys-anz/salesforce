/**
 * @author Batya Aisman Sufrin
 * @since April 2025
 * @description  FraudCaseTriggerHandler is the handler class for Fraud scope Case Trigger: Fraud, Identity, Recipient/Mule and Scam cases.
 */
public with sharing class FraudXCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public FraudXCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Fraud scope Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Id caseRTId = ((Case) record).RecordTypeId;
    return CheckCaseRecordType.FRAUD_RT_IDS.contains(caseRTId);
  }
  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    FraudXCaseActions.populateFraudXCaseSubject(records, new Map<Id, Case>());
    CommonCaseTriggerActions.populateContactLookupForANZPlus(
      records,
      new Map<Id, Case>()
    );
    CommonCaseTriggerActions.maskTaxNumbers(records, new Map<Id, Case>());
    CommonCaseTriggerActions.setBusinessHours(records);
    Logger.debug('On_Before_Insert finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());
    FraudXCaseActions.populateFraudXCaseSubject(
      records,
      (Map<Id, Case>) oldMap
    );
    CommonCaseTriggerActions.populateContactLookupForANZPlus(
      records,
      (Map<Id, Case>) oldMap
    );
    CommonCaseTriggerActions.maskTaxNumbers(records, (Map<Id, Case>) oldMap);
    CommonCaseTriggerActions.updateCaseDurationTime(
      records,
      (Map<Id, Case>) oldMap
    );
    Logger.debug('On_Before_Update finished: ' + System.now());
    Logger.saveLog();
  }
}
