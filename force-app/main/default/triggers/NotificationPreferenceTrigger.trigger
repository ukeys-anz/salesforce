trigger NotificationPreferenceTrigger on IDR_Notification_Preference__c (before insert) {
	IDRNotificationPreferenceTriggerHandler triggerHandler = new IDRNotificationPreferenceTriggerHandler();
}