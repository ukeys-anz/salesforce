/**
 * @author Batya Aisman Sufrin
 * @since 03/2024
 * @description FalseCustomerProfileCaseTriggerHandler is the handler class for False Customer Profile Case Trigger.
 */
public with sharing class FalseCustomerProfileCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public FalseCustomerProfileCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of False Customer Profile Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.falseCustomerProfile;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseSubject(
      records
    );
    CommonCaseTriggerActions.populateContactLookupForANZPlus(
      records,
      new Map<Id, Case>()
    );
    CommonCaseTriggerActions.maskTaxNumbers(records, new Map<Id, Case>());
    CommonCaseTriggerActions.setBusinessHours(records);
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnCOB(
      records,
      new Map<Id, Case>()
    );
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnAccount(
      records,
      new Map<Id, Case>()
    );
    Logger.debug('On_Before_Insert finished: ' + System.now()).save();
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseSubject(
      records
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
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnCOB(
      records,
      (Map<Id, Case>) oldMap
    );
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnAccount(
      records,
      (Map<Id, Case>) oldMap
    );
    Logger.debug('On_Before_Update finished: ' + System.now()).save();
  }
}
