/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  To test NotificationTriggerHandler
 */

@isTest
public class TestNotificationHandlerTrigger {
  /**
   * @description Test data setup required for this test class
   */
  @testSetup
  static void setup() {
    IDR_Notification_Hours__c nHours = new IDR_Notification_Hours__c();
    nHours.Start_Time__c = System.now().hour() - 1;
    nHours.End_Time__c = System.now().hour() + 2;
    insert nHours;

    // Create Case
    Case testCase = new Case();

    testCase.IDR_Account_Card_Policy_Number__c = '000001234';
    testCase.Description = 'Test decription';
    testCase.RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID;
    testCase.IDR_Customer_Number__c = '1234567890';
    testCase.Status = IDRConstants.OPEN_STATUS;

    insert testCase;
  }

  /**
   * @description Test data setup required for this test class
   */

  @isTest
  static void testManualNotification() {
    //Retrieve the case inserted
    Case c = [SELECT Id FROM Case LIMIT 1];

    Test.startTest();
    //create the notification handler record Manually
    Notification_Handler__c handlerRecord = new Notification_Handler__c();
    handlerRecord.Case__c = c.Id;
    handlerRecord.Status__c = IDRConstants.NOTIFICATION_PUBLISH_STATUS;
    handlerRecord.Case_Status__c = IDRConstants.OPEN_STATUS;
    insert handlerRecord;

    Test.stopTest();

    Notification_Handler__c handlerPostExecution = [
      SELECT Id, Status__c
      FROM Notification_Handler__c
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    //verify that notification is published successfully
    System.assertEquals(
      IDRConstants.NOTIFICATION_PUBLISH_STATUS,
      handlerPostExecution.Status__c
    );
  }
}
