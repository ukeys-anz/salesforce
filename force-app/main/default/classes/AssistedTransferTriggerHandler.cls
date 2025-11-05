/**
 * @author Hrushikesh
 * @since 10/2025
 * @description  AssistedTransferTriggerHandler is the handler class for Case Trigger for Case Management- Assisted Transfer which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class AssistedTransferTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public AssistedTransferTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Case caesRecord = (Case) record;
    return caesRecord.RecordTypeId == RTCase.assistedTransfer;
  }

  /**
   * @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    CommonCaseTriggerActions.orchestrateANZPlusAction(
      records,
      new Map<Id, Case>()
    );
    AssistedTransferActions.updateEntitlementOnCase(records);
    AssistedTransferActions.markSLAStatus(records, null);
    AssistedTransferActions.setSubject(records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommonCaseTriggerActions.orchestrateANZPlusAction(
      records,
      (Map<Id, Case>) oldMap
    );

    CommonCaseTriggerActions.updateCaseDurationTime(
      records,
      (Map<Id, Case>) oldMap
    );
    AssistedTransferActions.updateOwnerOnSubStatusChange(
      records,
      (Map<Id, Case>) oldMap
    );
    AssistedTransferActions.completeMilestone(records, (Map<Id, Case>) oldMap);
    AssistedTransferActions.markSLAStatus(records, (Map<Id, Case>) oldMap);
  }
}
