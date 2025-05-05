/**
 * @author Aman
 * @since 04/2025
 * @description This acts as a tigger handler for Twilio Details.
 */
public with sharing class TwilioDetailHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public TwilioDetailHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns true always as it needs to be implemented on all Twilio details records. Later on we can in extend tis method to incorporate new scopes, if added.
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true
   */
  public override Boolean isValidRecord(SObject record) {
    return true;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    TwilioDetailAction.maskSummary(records, new Map<Id, Twilio_Details__c>());
  }

  /**
   * @description onBeforeInsert to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    TwilioDetailAction.maskSummary(
      records,
      (Map<Id, Twilio_Details__c>) oldMap
    );
  }
}
