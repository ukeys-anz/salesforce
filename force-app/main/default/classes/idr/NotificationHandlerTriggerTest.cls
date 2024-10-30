/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  To test NotificationTriggerHandler
 */

@IsTest
public class NotificationHandlerTriggerTest {
  static final Faker FAKER = new Faker('en-AU');
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
      testCase.IDR_3rdParty_Mobile__c = '044838276';
      testCase.ANZx_Customer__c = false;
      testCase.Origin = 'Phone';
      testCase.IDR_NC_Mobile__c = '+6149999999';
    } else if (recordTypeId == GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID) {
      testCase.Description = 'Test Unauthenticated Enquiry change to Non Customer Complaint';
      testCase.Status = IDRConstants.OPEN_STATUS;
      testCase.ANZx_Customer__c = true;
      testCase.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
      testCase.IDR_Product_Category__c = 'Not product related';
    }
    testCase.RecordTypeId = recordTypeId;
    testCase.IDR_NC_Mobile__c = '+61499999999';

    return testCase;
  }

  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      IDR_Account_Card_Policy_Number__c = '000001234',
      Description = 'Test decription',
      IDR_Customer_Number__c = '1234567890',
      Status = IDRConstants.OPEN_STATUS,
      IDR_SwicthOff_3rd_Party_Notification__c = false,
      IDR_SwitchOff_Customer_Notification__c = false,
      IDR_3rdParty_Email__c = 'testEmail@email.com',
      IDR_3rdParty_Name__c = 'testName',
      IDR_3rdParty_Mobile__c = '044838276',
      ANZx_Customer__c = false,
      Origin = 'Phone',
      IDR_NC_Mobile__c = '+6149999999'
    ),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );

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
      WHERE Case__c IN :caseRecord
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
      SELECT Id
      FROM Notification_Handler__c
      WHERE Case__c IN :caseList
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
      WHERE Case__c IN :caseList
    ];

    return IDRConstants.NOTIFICATION_PUBLISH_STATUS ==
      handlerPostExecution.Status__c;
  }

  /**
   * @description Test data setup required for this test class
   */
  @TestSetup
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
  @IsTest
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
      SELECT Id
      FROM Notification_Handler__c
      WHERE Case__c IN :customerComplaintCaseList
    ];
    List<Notification_Handler__c> nhListNonCustomerComplaint = [
      SELECT Id
      FROM Notification_Handler__c
      WHERE Case__c IN :customerNonComplaintCaseList
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
  @IsTest
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
  @IsTest
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
  @IsTest
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

  @IsTest
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
  @IsTest
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

  @IsTest
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

  @IsTest
  static void testMobileNumberFormatting() {
    //Retrieve the case inserted
    Case oCase = caseRecord;

    Test.startTest();
    //create the notification handler record Manually
    Notification_Handler__c handlerRecord = new Notification_Handler__c();
    handlerRecord.Case__c = oCase.Id;
    handlerRecord.Status__c = IDRConstants.NOTIFICATION_PUBLISH_STATUS;

    IDR_Notification_Event__e evt = NotificationTriggerHandler.getNotifcationEvent(
      oCase,
      handlerRecord
    );

    Test.stopTest();

    System.assert(
      String.isNotBlank(evt.AuthorisedMobile__c),
      'Authorised Mobile cannot be blank'
    );
    System.assert(
      evt.AuthorisedMobile__c.startsWith('614'),
      'Authorised Mobile should be formatted'
    );
    System.assert(
      evt.AuthorisedMobile__c.isNumeric(),
      'Authorised Mobile should be a number'
    );
    System.assertEquals(
      evt.AuthorisedMobile__c,
      PhoneUtils.cleanupMobile(oCase.IDR_3rdParty_Mobile__c),
      '3rd party mobile isn\'t cleaned'
    );
    System.assert(
      String.isNotBlank(evt.ComplainantMobile__c),
      'Complaint Mobile Number cannot be blank'
    );
    System.assert(
      evt.ComplainantMobile__c.startsWith('614'),
      'Complaint Mobile should be formatted'
    );
    System.assert(
      evt.ComplainantMobile__c.isNumeric(),
      'Complaint Mobile should be a number'
    );
    System.assertEquals(
      evt.ComplainantMobile__c,
      PhoneUtils.cleanupMobile(oCase.IDR_NC_Mobile__c),
      'NC Mobile isn\'t cleaned'
    );
  }
  @IsTest
  static void testcheckMobileEmailnotNullOnCase() {
    Case csObj = caseRecord;
    Case csObj2 = new Case();
    csObj2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Test.startTest();
    Boolean isValid = NotificationTriggerHandler.checkMobileEmailnotNullOnCase(
      csObj
    );
    Boolean isInvalid = NotificationTriggerHandler.checkMobileEmailnotNullOnCase(
      csObj2
    );
    Test.stopTest();
    System.assertEquals(true, isValid, 'mobile or email is populated');
    System.assertEquals(false, isInvalid, 'mobile or email is not populated');
  }
}