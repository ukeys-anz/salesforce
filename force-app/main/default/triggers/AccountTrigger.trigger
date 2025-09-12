trigger AccountTrigger on Account(
  before insert,
  before update,
  after insert,
  after update
) {
  BusinessAccountTriggerHandler businessAccountHandler = new BusinessAccountTriggerHandler();
  IndividualAccountTriggerHandler individualAccountHandler = new IndividualAccountTriggerHandler();
  AccountTriggerHandler handler = new AccountTriggerHandler();
  IDRAccountTriggerHandler idrHandler = new IDRAccountTriggerHandler();
}
