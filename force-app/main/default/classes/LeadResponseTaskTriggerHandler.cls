/**
 * @author Ashwin Mohan
 * @since 04 July
 * @description Trigger handler class for Lead Response related tasks
 */
public with sharing class LeadResponseTaskTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LeadResponseTaskTriggerHandler
   */
  public LeadResponseTaskTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of lead response task records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Task taskRecord = (Task) record;
    return taskRecord.RecordTypeId == RTTask.leadResponse;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    TextUtils.maskSObjectDataANZExtended(records, 'Subject');
    TextUtils.maskSObjectDataANZExtended(records, 'Description');
    LeadResponseTaskActions.validateLeadABNACN(records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    TextUtils.maskSObjectDataANZExtended(records, 'Subject');
    TextUtils.maskSObjectDataANZExtended(records, 'Description');
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    LeadResponseTaskActions.updateLeadsBasisLogResponse(records);
  }

  /**
   * @description onBeforeDelete to handle before delete trigger actions.
   */
  public override void onBeforeDelete() {
    LeadResponseTaskActions.preventDelete(records);
  }
}
