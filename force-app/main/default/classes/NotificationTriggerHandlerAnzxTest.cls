/**
 * @author Lance Shi
 * @since 11/2021
 * @description  To test NotificationTriggerHandler for anzx complaint cases
 */

@isTest
public class NotificationTriggerHandlerAnzxTest {
  /**
   * @description Test data setup required for this test class
   */
  @testSetup
  static void setup() {
    IDR_Notification_Hours__c nHours = new IDR_Notification_Hours__c();
    nHours.Start_Time__c = System.now().hour() - 1;
    nHours.End_Time__c = System.now().hour() + 2;
    insert nHours;

    Account personAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId(),
      FirstName = 'TestFirst',
      LastName = 'TestLast',
      OCV_ID__c = 'PERSONOCV879879',
      ANZx_Customer__c = true
    );
    insert personAcc;

    Case testCase = new Case();
    testCase.AccountId = personAcc.Id;
    testCase.IDR_Account_Card_Policy_Number__c = '000001234';
    testCase.Description = 'Test decription';
    testCase.RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID;
    testCase.Customer_Notification_Consent__c = 'Yes';
    testCase.IDR_Customer_Number__c = '1234567890';
    testCase.Status = GetHelpConstants.OPEN_STATUS;

    insert testCase;
  }

  /**
   * @description Test Customer Notification based on the flag
   */
  @isTest
  static void testAnzxNotification() {
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
    Case c = [
      SELECT
        Id,
        IDR_3rdParty_Email__c,
        IDR_3rdParty_Name__c,
        IDR_3rdParty_Mobile__c,
        IDR_Customer_Number__c,
        IDR_NC_Email__c,
        IDR_NC_Is_Consent_Obtained__c,
        CaseNumber__c,
        Customer_Notification_Consent__c,
        Account.Source_System_ID__c,
        Account.PersonMobilePhone,
        Account.PersonContact.FirstName,
        IDR_Customer_Identifier__c,
        CaseNumber,
        IDR_NC_First_Name__c,
        IDR_NC_Mobile__c,
        RecordTypeId,
        IDR_SwicthOff_3rd_Party_Notification__c,
        IDR_SwitchOff_Customer_Notification__c,
        IDR_3rdParty_Relationship_To_Complainant__c
      FROM Case
      LIMIT 1
    ];

    Test.startTest();
    //create the notification handler record Manually
    Notification_Handler__c handlerRecord = new Notification_Handler__c();
    handlerRecord.Case__c = c.Id;
    handlerRecord.Status__c = IDRConstants.NOTIFICATION_PUBLISH_STATUS;
    insert handlerRecord;

    IDR_Notification_Event__e evt = NotificationTriggerHandler.getNotifcationEvent(
      c,
      handlerRecord
    );

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

    System.assertEquals(
      null,
      evt.CAP_CIS_ID__c,
      'Event CAP_CIS_ID__c should be null.'
    );
    System.assertEquals(
      c.Id,
      evt.Case_ID__c,
      'Event Case_ID__c should be as expected.'
    );
    System.assertEquals(
      true,
      evt.SMSFlag__c,
      'Event SMSFlag__c should be as expected.'
    );
    System.assertEquals(
      c.Account.PersonMobilePhone,
      evt.ComplainantMobile__c,
      'Event Complainant Mobile Number should be as expected.'
    );
  }
}
