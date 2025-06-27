/**
 * @author       : Prahlad Bhadani
 * @since        : April 2025
 * @description  : BOHLeadTriggerHandler is the handler class for BoH Lead Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class BOHLeadTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name BOHLeadTriggerHandler
   */
  public BOHLeadTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of BoH Lending Lead records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Lead leadRecord = (Lead) record;
    return leadRecord.RecordTypeId == RTLead.anzxLead;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    TextUtils.maskSObjectData(records, 'Description'); //CC-4053 Redaction
    // Method will check if lead is BOH Lead
    BOHLeadActions.getInstance().setBOHLeadFlag(records);
    BOHLeadActions.populateExistingCustomer(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    TextUtils.maskSObjectData(records, 'Description'); //CC-4053 Redaction
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    LeadActionsHelper.checkAndCreateCallbackTask(records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions
   * @name onAfterUpdate
   * @param oldMap
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    BOHLeadActions.convertBohLeads((Map<Id, Lead>) oldMap, records);
  }
}
