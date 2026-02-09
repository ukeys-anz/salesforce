/**
 * @description Handler for Disputes Cases
 * @author Vaibhav Joshi
 * @since 07/2025
 */
public with sharing class ImtDisputesCaseTriggerHandler extends Lib_TriggerHandler {
  public static final String IMT_NEW_EXTERNAL_STATUS = 'IMT_New_SF';
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ImtDisputesCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of disputes Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.imtDispute;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    ImtCaseTriggerActions.updateDescription(records);
    Logger.debug('On_Before_Insert finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    Logger.debug('On_After_Insert started: ' + System.now());
    DisputesCaseActions.createExternalCaseStatuses(
      (List<Case>) records,
      IMT_NEW_EXTERNAL_STATUS
    );
    Logger.debug('On_After_Insert finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());
    ImtCaseTriggerActions.updateDescription(records);
    Logger.debug('On_Before_Update finished: ' + System.now());
    Logger.saveLog();
  }
}
