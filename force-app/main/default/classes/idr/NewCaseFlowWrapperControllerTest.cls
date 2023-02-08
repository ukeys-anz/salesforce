/**
 * @author saiero
 * @since 2020
 * @description Test class for {@link NewCaseFlowWrapperController}
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
private with sharing class NewCaseFlowWrapperControllerTest {
  /**
   * @description setup is to prepare test data
   */
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');
    //create test account
    Id recTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAcc = new Account(
      RecordTypeId = recTypeID,
      FirstName = faker.randomString(5),
      LastName = faker.randomString(5),
      OCV_ID__c = '1234567891'
    );
    insert testAcc;

    Case testCase = new Case(
      Origin = 'Phone',
      Type = 'Other',
      Priority = 'Standard',
      Description = faker.randomString(10),
      ANZx_Customer__c = false
    );
    testCase.RecordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID;

    Case testCaseForAEM = new Case(
      Origin = 'ANZ Plus Web',
      Type = 'Other',
      Priority = 'Standard',
      Description = faker.randomString(10),
      ANZx_Customer__c = true
    );
    testCaseForAEM.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;

    Case testCaseFailure = new Case(
      Origin = 'Letter',
      Type = 'Other',
      Priority = 'Standard',
      Description = faker.randomString(10),
      ANZx_Customer__c = false
    );
    testCaseFailure.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    testCaseFailure.IDR_Customer_Number__c = '0123456789';

    List<Case> casesToInsert = new List<Case>{
      testCase,
      testCaseForAEM,
      testCaseFailure
    };
    insert casesToInsert;
  }

  @IsTest
  static void testRecordTypeDevNameFromId() {
    RecordType rt = [
      SELECT DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Customer_Complaint'
    ];
    System.assertEquals(
      'Customer_Complaint',
      NewCaseFlowWrapperController.getCaseRecordTypeDevNameById(rt.Id),
      'Developer name should be Customer_Complaint'
    );
  }

  // Test getting available record type Ids for Case
  @IsTest
  private static void testGetAvailableRecordTypeIdsForSObject() {
    Case c = [SELECT Id, Origin FROM Case WHERE Origin = 'Phone' LIMIT 1];
    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypesChangeRTBtn(
      c.Id
    );
    Test.stopTest();
    System.assertNotEquals(
      0,
      ((List<RecordType>) JSON.deserializeStrict(
          resultString,
          List<RecordType>.class
        ))
        .size(),
      'Record type Ids were returned'
    );
  }

  // Test getting available record type Ids for Unauthenticated Enquiry Case from AEM
  @IsTest
  private static void testGetAvailableRecordTypeIdsForAEMUnauthCases() {
    Case c = [
      SELECT Id, Origin
      FROM Case
      WHERE Origin = 'ANZ Plus Web'
      LIMIT 1
    ];

    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypesChangeRTBtn(
      c.Id
    );
    Test.stopTest();
    System.assertNotEquals(
      0,
      ((List<RecordType>) JSON.deserializeStrict(
          resultString,
          List<RecordType>.class
        ))
        .size(),
      'There should be three recordTypes available for this case'
    );
  }

  // Test getting available record type Ids for Not Unauthenticated Enquiry Case
  // This should run the getCaseRecordTypes method.
  @IsTest
  private static void testGetAvailableRecordTypeIdsForNotUnauthCase() {
    Case c = [SELECT Id, Origin FROM Case WHERE Origin = 'Letter' LIMIT 1];

    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypesChangeRTBtn(
      c.Id
    );
    Test.stopTest();
    System.assertNotEquals(
      0,
      ((List<RecordType>) JSON.deserializeStrict(
          resultString,
          List<RecordType>.class
        ))
        .size(),
      'Record type Ids were returned'
    );
  }
}
