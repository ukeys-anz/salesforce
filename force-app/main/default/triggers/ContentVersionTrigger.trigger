trigger ContentVersionTrigger on ContentVersion(before insert, before update) {
  ContentVersionTriggerHandler handler = new ContentVersionTriggerHandler();
}
