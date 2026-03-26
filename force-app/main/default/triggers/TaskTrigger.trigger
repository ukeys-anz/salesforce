trigger TaskTrigger on Task(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  TaskTriggerHandler handler = new TaskTriggerHandler();
  SettlementTaskTriggerHandler settlementHandler = new SettlementTaskTriggerHandler();
  CustomerNudgeTaskTriggerHandler customerNudgeHandler = new CustomerNudgeTaskTriggerHandler();
  IDRTaskTriggerHandler triggerHandler = new IDRTaskTriggerHandler();
  LeadResponseTaskTriggerHandler leadResponseHandler = new LeadResponseTaskTriggerHandler();
  MobileLendingTaskTriggerHandler mlTaskHandler = new MobileLendingTaskTriggerHandler();
}
