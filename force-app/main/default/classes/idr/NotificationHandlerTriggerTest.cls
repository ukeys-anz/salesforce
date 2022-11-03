/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  To test NotificationTriggerHandler
 */

@isTest
public class NotificationHandlerTriggerTest {
  /**
   * @description createTestCase to create cases with different record types
   * @param recordTypeId Record Type Id
   * @return `Case` will return a Case.
   */
  private static Case createTestCase(Id recordTypeId) {
    Case testCase = new Case();

    if (
      recordTypeId == IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID ||
      recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID
    ) {
      testCase.IDR_Account_Card_Policy_Number__c = '000001234';
      testCase.Description = 'Test decription';
      testCase.IDR_Customer_Number__c = '1234567890';
      testCase.Status = IDRConstants.OPEN_STATUS;
      testCase.IDR_SwicthOff_3rd_Party_Notification__c = false;
      testCase.IDR_SwitchOff_Customer_Notification__c = false;
      testCase.IDR_3rdParty_Email__c = 'testEmail@email.com';
      testCase.IDR_3rdParty_Name__c = 'testName';
      testCase.IDR_3rdParty_Mobile__c = '035464838276';
      testCase.ANZx_Customer__c = false;
      testCase.Origin = 'Phone';
      testCase.IDR_NC_Mobile__c = '+61499999999';
    } else if (recordTypeId == GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID) {
      testCase.Description = 'Test Unauthenticated Enquiry change to Non Customer Complaint';
      testCase.Status = IDRConstants.OPEN_STATUS;
      testCase.ANZx_Customer__c = true;
      testCase.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    }
    testCase.RecordTypeId = recordTypeId;
    testCase.IDR_NC_Mobile__c = '+61499999999';

    return testCase;
  }

  /**
   * @description testPublishedNotificationForDifferentCaseRecordType to test if notification created with different record types
   * @param rtId Record Type Id
   * @return Boolean will return True/False if a notification has been published.
   */
  private static Boolean testPublishedNotificationForDifferentCaseRecordType(
    Id rtId
  ) {
    //Retrieve the case inserted
    List<Case> caseRecord = [
      SELECT Id, RecordTypeId
      FROM Case
      WHERE RecordTypeId = :rtId
    ];

    Notification_Handler__c handlerPostExecution = [
      SELECT Id, Status__c
      FROM Notification_Handler__c
      WHERE case__c IN :caseRecord
      LIMIT 1
    ];

    return IDRConstants.NOTIFICATION_PUBLISH_STATUS ==
      handlerPostExecution.Status__c;
  }

  /**
   * @description testNotificationChangeCaseRecordType to test if notification created with different record types
   * @param oldRTId Old Record Type Id
   * @param newRTId New Record Type Id
   * @return Boolean will return True/False if a a notification has been published.
   */
  private static Boolean testNotificationChangeCaseRecordType(
    Id oldRTId,
    Id newRTId
  ) {
    List<Case> caseList = [
      SELECT Id, RecordTypeId
      FROM Case
      WHERE RecordTypeId = :oldRTId
    ];
    caseList[0].RecordTypeId = newRTId;
    caseList[0].Status = IDRConstants.ESCALATED_STATUS;

    update caseList[0];

    List<Notification_Handler__c> nhList = [
      SELECT id
      FROM Notification_Handler__c
      WHERE case__c IN :caseList
    ];

    return nhList.size() == 1;
  }

  /**
   * @description testPublishedNotificationChangeCaseRecordType to test if notification created when changing a record types
   * @param oldRTId Old Record Type Id
   * @param newRTId New Record Type Id
   * @return Boolean will return True/False if a notification has been published.
   */
  private static Boolean testPublishedNotificationChangeCaseRecordType(
    Id oldRTId,
    Id newRTId
  ) {
    List<Case> caseList = [
      SELECT Id, RecordTypeId
      FROM Case
      WHERE RecordTypeId = :oldRTId
    ];
    caseList[0].RecordTypeId = newRTId;
    caseList[0].Status = IDRConstants.ESCALATED_STATUS;

    update caseList[0];

    Notification_Handler__c handlerPostExecution = [
      SELECT Id, Status__c
      FROM Notification_Handler__c
      WHERE case__c IN :caseList
    ];

    return IDRConstants.NOTIFICATION_PUBLISH_STATUS ==
      handlerPostExecution.Status__c;
  }

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
      Case testCaseNonCustomerComplaint = createTestCase(
        IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
      );
      Case testCaseCustomerComplaint = createTestCase(
        IDRConstants.CUSTOMER_COMPLAINT_RT_ID
      );
      Case unauthCase = createTestCase(
        GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID
      );

      newCasesWithStatus.add(testCaseNonCustomerComplaint);
      newCasesWithStatus.add(testCaseCustomerComplaint);
      newCasesWithStatus.add(unauthCase);
    }

    insert newCasesWithStatus;
  }

  /**
   * @description Test Customer/ Non Customer Notification based on the flag
   */
  @isTest
  static void testCustomerNotificationComplaint() {
    List<Case> customerComplaintCaseList = [
      SELECT Id, RecordTypeId
      FROM Case
      WHERE RecordTypeId = :IDRConstants.CUSTOMER_COMPLAINT_RT_ID
    ];
    List<Case> customerNonComplaintCaseList = [
      SELECT Id, RecordTypeId
      FROM Case
      WHERE RecordTypeId = :IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
    ];
    Test.startTest();
    List<Notification_Handler__c> nhListCustomerComplaint = [
      SELECT id
      FROM Notification_Handler__c
      WHERE case__c IN :customerComplaintCaseList
    ];
    List<Notification_Handler__c> nhListNonCustomerComplaint = [
      SELECT id
      FROM Notification_Handler__c
      WHERE case__c IN :customerNonComplaintCaseList
    ];

    System.assertEquals(
      customerComplaintCaseList.size(),
      nhListCustomerComplaint.size(),
      'Notification handler list size should be as expected | Customer Complaints'
    );

    System.assertEquals(
      customerNonComplaintCaseList.size(),
      nhListNonCustomerComplaint.size(),
      'Notification handler list size should be as expected | Non Customer Complaints'
    );
    Test.stopTest();
  }

  /**
   * @description Test the notification for customer complaint
   */
  @isTest
  static void testManualNotificationCustomerComplaint() {
    Test.startTest();
    System.assert(
      testPublishedNotificationForDifferentCaseRecordType(
        IDRConstants.CUSTOMER_COMPLAINT_RT_ID
      ),
      'Notification handler status should be as expected | Customer Complaint'
    );
    Test.stopTest();
  }

  /**
   * @description Test the notification for non customer complaint
   */
  @isTest
  static void testManualNotificationNonCustomerComplaint() {
    Test.startTest();
    System.assert(
      testPublishedNotificationForDifferentCaseRecordType(
        IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
      ),
      'Notification handler status should be as expected | Non Customer Complaint'
    );
    Test.stopTest();
  }

  /**
   * @description Test Notification when unauthenticated enquiry Case changed to non customer complaint.
   */
  @isTest
  static void testNotificationUnauthToNonCustomerComplaint() {
    Test.startTest();
    System.assert(
      testNotificationChangeCaseRecordType(
        GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID,
        GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID
      ),
      'Notification handler list size should be as expected.'
    );
    Test.stopTest();
  }

  /**
   * @description Test if notification published successfully when an unauthenticated enquiry case changed to non customer complaint.
   */

  @isTest
  static void testManualNotificationUnauthToNonCustomerComplaint() {
    Test.startTest();
    System.assert(
      testPublishedNotificationChangeCaseRecordType(
        GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID,
        GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID
      ),
      'Notification handler status should be as expected.'
    );
    Test.stopTest();
  }

  /**
   * @description Test Notification when unauthenticated enquiry Case changed to anz plus complaint.
   */
  @isTest
  static void testNotificationUnauthToANZPlusComplaint() {
    Test.startTest();
    System.assert(
      testNotificationChangeCaseRecordType(
        GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID,
        GetHelpConstants.COMPLAINT_RT_ID
      ),
      'Notification handler list size should be as expected.'
    );
    Test.stopTest();
  }

  /**
   * @description Test if notification published successfully when an unauthenticated enquiry case changed to non customer complaint.
   */

  @isTest
  static void testManualNotificationUnauthToANZPlusComplaint() {
    Test.startTest();
    System.assert(
      testPublishedNotificationChangeCaseRecordType(
        GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID,
        GetHelpConstants.COMPLAINT_RT_ID
      ),
      'Notification handler status should be as expected.'
    );
    Test.stopTest();
  }
}
