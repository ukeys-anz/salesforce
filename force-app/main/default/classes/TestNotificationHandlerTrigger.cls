@isTest
public class TestNotificationHandlerTrigger {

    @testSetup static void setup() {
        // Create Case
        Case testCase = new Case();
        
        testCase.IDR_Account_Card_Policy_Number__c = '000001234';
        testCase.Description = 'Test decription';
        testCase.RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID;
        testCase.Status = IDRConstants.OPEN_STATUS;

        insert testCase;

    }

    @isTest
    static void testManualNotification() {
        Case c = [Select Id From Case Limit 1];
        Test.startTest();
        Notification_Handler__c handlerRecord = new Notification_Handler__c();
        handlerRecord.Case__c = c.Id;
        handlerRecord.Status__c= IDRConstants.NOTIFICATION_PUBLISH_STATUS;
        handlerRecord.Case_Status__c = IDRConstants.OPEN_STATUS;
        insert handlerRecord;
        Test.stopTest();
        System.assertEquals(1, NotificationTriggerHandler.idrNotifications.size());
    }




}