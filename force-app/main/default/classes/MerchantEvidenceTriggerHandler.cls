/**
 * @description       : MerchantEvidenceTriggerHandler
 * @author            : Anun Jain
 * @group             :
 * @last modified on  : 11-04-2025
 * @last modified by  : Ajun Jain
 **/
public with sharing class MerchantEvidenceTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public MerchantEvidenceTriggerHandler() {
    super();
  }

  /**
   * @description Check if a record is relevant to the trigger handler based on certain conditions
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((External_Case_Status__c) record).External_Status__c ==
      'Pending-PreArbOutboundResponse';
  }

  /**
   * @description onAfterInsert to handle before update trigger actions.
   */
  public override void onAfterInsert() {
    MerchantEvidenceActions.createTaskRecords(records);
  }
}
