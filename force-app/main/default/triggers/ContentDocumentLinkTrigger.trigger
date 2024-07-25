trigger ContentDocumentLinkTrigger on ContentDocumentLink(
  after insert,
  before delete,
  before insert
) {
  ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
  EmailMessageCdlTriggerHandler emailMessageHandler = new EmailMessageCdlTriggerHandler();
}
