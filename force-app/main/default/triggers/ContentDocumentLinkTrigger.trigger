trigger ContentDocumentLinkTrigger on ContentDocumentLink(after insert) {
  ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
}
