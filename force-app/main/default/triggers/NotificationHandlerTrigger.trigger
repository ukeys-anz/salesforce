trigger NotificationHandlerTrigger on Notification_Handler__c(
  before insert,
  before update,
  after insert,
  after update
) {
  NotificationTriggerHandler handler = new NotificationTriggerHandler();
}
  