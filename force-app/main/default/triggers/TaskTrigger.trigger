trigger TaskTrigger on Task(before insert) {
  TaskTriggerHandler handler = new TaskTriggerHandler();
}
