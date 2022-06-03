trigger AccountTrigger on Account(after insert, after update, before update) {
  AccountTriggerHandler handler = new AccountTriggerHandler();
}
