/**
 * @author Mani
 * @since 12/2024
 * @description This acts as a tigger handler for profile update case types and orchestrates the business process and automations
 */
public with sharing class ProfileUpdateCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ProfileUpdateCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of KYC QA Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.profileUpdate;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    ProfileUpdateCaseActions.setOwnerToIDOpsQueue(records);
    ProfileUpdateCaseActions.setDocumentCountryCode(
      records,
      new Map<Id, Case>()
    );
    Logger.saveLog();
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());
    ProfileUpdateCaseActions.validateStagingProgress(
      records,
      (Map<Id, Case>) oldMap
    );
    ProfileUpdateCaseActions.setDocumentCountryCode(
      records,
      (Map<Id, Case>) oldMap
    );
    Logger.saveLog();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_After_Update started: ' + System.now());
    ProfileUpdateCaseActions.legalNameNotifications(
      records,
      (Map<Id, Case>) oldMap
    );
    ProfileUpdateCaseActions.sendLegalNameUpdateToOCV(
      records,
      (Map<Id, Case>) oldMap
    );
    Logger.debug('On_After_Update finished: ' + System.now());
    Logger.saveLog();
  }
}
