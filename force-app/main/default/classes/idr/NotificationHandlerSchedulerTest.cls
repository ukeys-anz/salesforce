/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  To test NotificationHandlerBatch and NotificationHandlerScheduler
 */
@isTest
public with sharing class NotificationHandlerSchedulerTest {
  /**
   * @description Test data setup required for this test class
   */
  @testSetup
  static void setup() {
    //Create Custom Setting
    IDR_Notification_Hours__c nHours = new IDR_Notification_Hours__c();
    nHours.Start_Time__c = System.now().hour() - 2;
    nHours.End_Time__c = System.now().hour() - 1;
    insert nHours;

    // Create Case

    List<Case> caseList = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case testCase = new Case();

      testCase.IDR_Account_Card_Policy_Number__c = '000001234';
      testCase.Description = 'Test decription';
      testCase.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
      testCase.IDR_Customer_Number__c = '1234567890';
      testCase.Status = IDRConstants.ESCALATED_STATUS;
      testCase.IDR_Escalated_to__c = '1';
      testCase.IDR_Escalation_Reason__c = '1';
      testCase.IDR_SwicthOff_3rd_Party_Notification__c = false;
      testCase.IDR_SwitchOff_Customer_Notification__c = false;

      caseList.add(testCase);
    }

    insert caseList;
  }

  /**
   * @description Test the whether all the scheduled notification are picked up and processed by batch successfully.
   */
  @isTest
  static void testScheduledNotification() {
    Notification_Handler__c handler = [
      SELECT Id, Status__c
      FROM Notification_Handler__c
      LIMIT 1
    ];

    System.assertEquals(
      IDRConstants.NOTIFICATION_PENDING_PUBLISH_STATUS,
      handler.Status__c
    );

    Test.startTest();
    SchedulableContext sc = null;
    NotificationHandlerScheduler schedule = new NotificationHandlerScheduler();
    schedule.execute(sc);

    Test.stopTest();
    Notification_Handler__c handlerPostExecution = [
      SELECT Id, Status__c
      FROM Notification_Handler__c
      LIMIT 1
    ];

    System.assertEquals(
      IDRConstants.NOTIFICATION_PUBLISH_STATUS,
      handlerPostExecution.Status__c
    );
  }
}
