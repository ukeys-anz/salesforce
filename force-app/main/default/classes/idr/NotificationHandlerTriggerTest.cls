/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  To test NotificationTriggerHandler
 */

@isTest
public class NotificationHandlerTriggerTest {
  /**
   * @description Test data setup required for this test class
   */
  @testSetup
  static void setup() {
    IDR_Notification_Hours__c nHours = new IDR_Notification_Hours__c();
    nHours.Start_Time__c = System.now().hour() - 1;
    nHours.End_Time__c = System.now().hour() + 2;
    insert nHours;

    // Create Cases
    Case[] newCasesWithStatus = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case testCase = new Case();

      testCase.IDR_Account_Card_Policy_Number__c = '000001234';
      testCase.Description = 'Test decription';
      testCase.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
      testCase.IDR_Customer_Number__c = '1234567890';
      testCase.Status = IDRConstants.OPEN_STATUS;
      testCase.IDR_SwicthOff_3rd_Party_Notification__c = false;
      testCase.IDR_SwitchOff_Customer_Notification__c = false;
      testCase.IDR_3rdParty_Email__c = 'testEmail@email.com';
      testCase.IDR_3rdParty_Name__c = 'testName';
      testCase.IDR_3rdParty_Mobile__c = '035464838276';

      newCasesWithStatus.add(testCase);
    }

    insert newCasesWithStatus;
  }

  /**
   * @description Test Customer Notification based on the flag
   */
  @isTest
  static void testCustomerNotification() {
    List<Case> caseList = [SELECT Id FROM Case];
    test.startTest();
    List<Notification_Handler__c> nhList = [
      SELECT id
      FROM Notification_Handler__c
      WHERE case__c IN :caseList
    ];
    System.assertEquals(
      caseList.size(),
      nhList.size(),
      'Notification handler list size should be as expected.'
    );
    Test.stopTest();
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
      handlerPostExecution.Status__c,
      'Notification handler status should be as expected.'
    );
  }
}
