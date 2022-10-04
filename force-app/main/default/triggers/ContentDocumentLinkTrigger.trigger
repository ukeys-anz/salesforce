trigger ContentDocumentLinkTrigger on ContentDocumentLink(
  after insert,
  before delete
) {
  ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
}
