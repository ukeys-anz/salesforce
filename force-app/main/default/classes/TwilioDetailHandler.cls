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
