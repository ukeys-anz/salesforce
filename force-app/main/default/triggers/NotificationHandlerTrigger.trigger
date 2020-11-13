trigger NotificationHandlerTrigger on Notification_Handler__c(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  NotificationTriggerHandler handler = new NotificationTriggerHandler();
}
