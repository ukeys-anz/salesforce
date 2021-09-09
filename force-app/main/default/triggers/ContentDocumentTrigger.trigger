trigger ContentDocumentTrigger on ContentDocument(before delete) {
  ContentDocumentTriggerHandler handler = new ContentDocumentTriggerHandler();
}
