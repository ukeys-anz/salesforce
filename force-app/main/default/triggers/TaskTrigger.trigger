trigger TaskTrigger on Task(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  TaskTriggerHandler handler = new TaskTriggerHandler();
}