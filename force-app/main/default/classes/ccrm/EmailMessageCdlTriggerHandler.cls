/**
 * @author Naman Garg
 * @since 07/2024
 * @description  EmailMessageCdlTriggerHandler is the handler class for Content Document Link Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class EmailMessageCdlTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public EmailMessageCdlTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CDL records linked to email Message
   * @param record record to check if relevant to the execution context
   * @return Boolean returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    ContentDocumentLink cdlrecord = (ContentDocumentLink) record;
    return cdlrecord.LinkedEntityId.getSObjectType() ==
      EmailMessage.sObjectType;
  }

  /**
   * @description onBeforeInsert to manage before insert actions
   */
  public override void onBeforeInsert() {
    CCRMContentDocumentLinkActions.restrictOutlookAttachments(
      (List<ContentDocumentLink>) records
    );
  }
}
