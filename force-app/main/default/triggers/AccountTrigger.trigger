trigger AccountTrigger on Account(after insert, after update) {
  AccountTriggerHandler handler = new AccountTriggerHandler();
}
