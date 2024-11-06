/**
 * @author Batya Aisman Sufrin
 * @since 06/2024
 * @description  AutoKYCQACaseTriggerHandler is the handler class for KYC QA Case Trigger.
 */
public with sharing class AutoKYCQACaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public AutoKYCQACaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of KYC QA Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.kycQa;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    //validations
    AutoKYCQACaseActions.validateCobExist(records);
    AutoKYCQACaseActions.validateDuplicateKYCQACasePerAccount(records);
    AutoKYCQACaseActions.validateDuplicateKYCQACasePerCOBApp(records);

    //populate fields
    List<Case> validCases = ListUtil.filter(records).noError().toList();
    AutoKYCQACaseActions.populateAutoKYCQAChecks(validCases);
    AutoKYCQACaseActions.populateClosedNoDefectDefaults(
      validCases,
      new Map<Id, Case>()
    );
    Logger.debug('On_Before_Insert finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());
    //validations
    AutoKYCQACaseActions.validateOwnerChange(records, (Map<Id, Case>) oldMap);

    //populate fields
    List<Case> validCases = ListUtil.filter(records).noError().toList();
    AutoKYCQACaseActions.populateClosedNoDefectDefaults(
      validCases,
      (Map<Id, Case>) oldMap
    );
    AutoKYCQACaseActions.updateTestedDate(validCases);

    if (Label.CustomerRestraintEnabled.equalsIgnoreCase('true')) {
      AutoKYCQACaseActions.setRetraintStatus(
        validCases,
        (Map<Id, Case>) oldMap
      );
      AutoKYCQACaseActions.setUnrestraintStatus(
        validCases,
        (Map<Id, Case>) oldMap
      );
    }

    Logger.debug('On_Before_Update finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_After_Update started: ' + System.now());
    AutoKYCQACaseActions.downgrade(records, (Map<Id, Case>) oldMap);
    AutoKYCQACaseActions.upgrade(records, (Map<Id, Case>) oldMap);
    Logger.debug('On_After_Update finished: ' + System.now());
    Logger.saveLog();
  }
}
