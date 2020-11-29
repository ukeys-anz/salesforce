trigger NotificationPreferenceTrigger on IDR_Notification_Preference__c (before insert) {
	NotificationPreferenceTriggerHandler triggerHandler = new NotificationPreferenceTriggerHandler();
}