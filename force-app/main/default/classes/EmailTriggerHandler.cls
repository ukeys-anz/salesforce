/**
 * @description EmailTriggerHandler is the handler class for Event Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Shivraj Kadam
 * @since 10/2023
 */

public with sharing class EmailTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public EmailTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    //Added for CC-5645 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Subject');
    TextUtils.maskSObjectDataANZExtended(records, 'TextBody');
    TextUtils.maskSObjectDataANZExtended(records, 'HtmlBody');
  }
  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //Added for CC-5645 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Subject');
    TextUtils.maskSObjectDataANZExtended(records, 'TextBody');
    TextUtils.maskSObjectDataANZExtended(records, 'HtmlBody');
  }
}
