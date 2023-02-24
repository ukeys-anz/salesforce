/**
 * @author saiero
 * @since 2020
 * @description Test class for {@link NewCaseFlowWrapperController}
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
private with sharing class NewCaseFlowWrapperControllerTest {
  private static final String PRODUCTCATEGORY = 'Not product related';
  private static final String PHONE_ORIGIN = 'Phone';
  private static final String WEB_ORIGIN = 'ANZ Plus Web';
  private static final String LETTER_ORIGIN = 'Letter';
  private static final String CASE_TYPE = 'Other';
  private static final String CASE_PRIORITY = 'Standard';

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
      OCV_ID__c = faker.randomString(10)
    );
    insert testAcc;

    Case testCase = new Case(
      Origin = PHONE_ORIGIN,
      Type = CASE_TYPE,
      Priority = CASE_PRIORITY,
      Description = faker.randomString(10),
      ANZx_Customer__c = false
    );
    testCase.RecordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID;

    Case testCaseForAEM = new Case(
      Origin = WEB_ORIGIN,
      Type = CASE_TYPE,
      Priority = CASE_PRIORITY,
      IDR_NC_Is_Consent_Obtained__c = false,
      IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
      IDR_Product_Category__c = PRODUCTCATEGORY,
      Description = faker.randomString(10),
      ANZx_Customer__c = true
    );
    testCaseForAEM.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;

    Case testCaseFailure = new Case(
      Origin = LETTER_ORIGIN,
      Type = CASE_TYPE,
      Priority = CASE_PRIORITY,
      Description = faker.randomString(10),
      ANZx_Customer__c = false
    );
    testCaseFailure.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    testCaseFailure.IDR_Customer_Number__c = faker.randomString(10);

    List<Case> casesToInsert = new List<Case>{
      testCase,
      testCaseForAEM,
      testCaseFailure
    };
    insert casesToInsert;
  }

  @IsTest
  static void testRecordTypeDevNameFromId() {
    RecordType customerComplaintRT = [
      SELECT DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Customer_Complaint'
    ];
    System.assertEquals(
      'Customer_Complaint',
      NewCaseFlowWrapperController.getCaseRecordTypeDevNameById(
        customerComplaintRT.Id
      ),
      'Developer name should be Customer_Complaint'
    );
  }

  // Test getting available record type Ids for Case
  @IsTest
  private static void testGetAvailableRecordTypeIdsForSObject() {
    Case caseTest = [
      SELECT Id, Origin
      FROM Case
      WHERE Origin = :PHONE_ORIGIN
      LIMIT 1
    ];
    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypesChangeRTBtn(
      caseTest.Id
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
    Case aemUnauthCase = [
      SELECT Id, Origin
      FROM Case
      WHERE Origin = :WEB_ORIGIN
      LIMIT 1
    ];

    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypesChangeRTBtn(
      aemUnauthCase.Id
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
    Case aemLetterCase = [
      SELECT Id, Origin
      FROM Case
      WHERE Origin = :LETTER_ORIGIN
      LIMIT 1
    ];

    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypesChangeRTBtn(
      aemLetterCase.Id
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
