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
  static Lib_MockProvider complaintRepoMock;
  static Lib_MockProvider userInfoRepoMock;

  static void registerMocks() {
    complaintRepoMock = Lib_MockProvider.forType(ComplaintsRepository.class);
    userInfoRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }
  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      IDR_Customer_Number__c = '1234567897',
      IDR_Customer_Identifier__c = 'Customer/Business CAP ID',
      IDR_AFCA_Status__c = '10',
      IDR_Subsequent_Issue__c = '42',
      IDR_Is_Written_Resp_Requested__c = 'No',
      IDR_Is_Written_Resp_Required__c = 'No',
      IDR_Is_Common__c = 'No',
      IDR_Escalation_Reason__c = '21',
      IDR_Complainant_Type__c = '1',
      IDR_Product_Category__c = 'Credit card',
      Type = '19',
      Priority = 'Standard',
      IDR_Complainant_Desired_Outcome__c = 'test',
      Description = 'test'
    ),
    new Map<String, Object>{ 'CaseNumber' => '1234567' }
  );

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
  /**
   * @description Test of getCaseDetailsById for non AEM Complaint.
   */
  @IsTest
  private static void testgetCaseDetailsById() {
    case csObj = caseRecord;
    csObj.Origin = '11';
    csObj.ANZx_Customer__c = false;
    csObj.RecordTypeId = RTCase.customerComplaint;
    registerMocks();
    complaintRepoMock.mock('getCaseDetailsById', (csObj));
    Test.startTest();
    Case caseObj = (Case) JSON.deserialize(
      NewCaseFlowWrapperController.getCaseDetailsById(
        csObj.Id,
        RTCase.nonCustomerComplaint
      ),
      Case.class
    );
    Test.stopTest();
    Assert.isTrue(caseObj != null, 'Case Record should return');
  }
  /**
   * @description Test of getCaseDetailsById for General Inquery CMOS RecordType.
   */
  @IsTest
  private static void testgetCaseDetailsByIdAEMUnauthenticated() {
    case csObj = caseRecord;
    csObj.Origin = 'ANZ Plus Web';
    csObj.ANZx_Customer__c = true;
    csObj.RecordTypeId = RTCase.generalInquiryCmos;
    registerMocks();
    complaintRepoMock.mock('getCaseDetailsById', (csObj));
    Test.startTest();
    Case caseObj = (Case) JSON.deserialize(
      NewCaseFlowWrapperController.getCaseDetailsById(
        csObj.Id,
        RTCase.generalInquiryCmos
      ),
      Case.class
    );
    Test.stopTest();
    Assert.isTrue(
      caseObj.IDR_Product_Category__c == 'Credit card',
      'Case product category should return'
    );
  }
  /**
   * @description Test of getCaseDetailsById for AEM Complaint.
   */
  @IsTest
  private static void testgetCaseDetailsByIdAEMCustomer() {
    case csObj = caseRecord;
    csObj.Origin = 'ANZ Plus Web';
    csObj.ANZx_Customer__c = true;
    csObj.RecordTypeId = RTCase.generalInquiryCmos;
    registerMocks();
    complaintRepoMock.mock('getCaseDetailsById', (csObj));
    Test.startTest();
    Case caseObj = (Case) JSON.deserialize(
      NewCaseFlowWrapperController.getCaseDetailsById(
        csObj.Id,
        RTCase.customerComplaint
      ),
      Case.class
    );
    Test.stopTest();
    Assert.isTrue(
      caseObj.Customer_Notification_Consent__c == 'Yes',
      'Customer Notification consent should be yes'
    );
  }
  /**
   * @description Test of getCaseDetailsById for customer complaint if origin is 11 then IDR_AFCA_Status__c should be 10 .
   */
  @IsTest
  private static void testgetCaseDetailsByIdCustomerNonAEM() {
    Case csObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Origin = '11',
      RecordTypeId = RTCase.customerComplaint,
      ANZx_Customer__c = false
    );
    registerMocks();
    complaintRepoMock.mock('getCaseDetailsById', (csObj));
    Test.startTest();
    Case caseObj = (Case) JSON.deserialize(
      NewCaseFlowWrapperController.getCaseDetailsById(
        csObj.Id,
        RTCase.customerComplaint
      ),
      Case.class
    );
    Test.stopTest();
    Assert.isTrue(
      caseObj.IDR_AFCA_Status__c == '10',
      'AFCA status should not be null'
    );
  }
  /**
   * @description Test of getOCVId.
   */
  @IsTest
  private static void testgetOCVId() {
    Account accObj = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      OCV_ID__c = '9999'
    );
    registerMocks();
    complaintRepoMock.mock('getAccountById', (accObj));
    Test.startTest();
    String ocvId = NewCaseFlowWrapperController.getOCVId(accObj.Id);
    Test.stopTest();
    Assert.isTrue(ocvId == '9999', 'OCV Id shoudl not be null');
  }
  /**
   * @description Test of getCaseRecordTypes.
   */
  @IsTest
  private static void getCaseRecordTypes() {
    registerMocks();
    userInfoRepoMock.mock('checkAnyPermissions', true);
    Assert.isTrue(
      String.isNotBlank(NewCaseFlowWrapperController.getCaseRecordTypes()),
      'RecordTypes should return'
    );
  }
  /**
   * @description Test of getOCVId when OcvId is null.
   */
  @IsTest
  private static void testGetOcvIdNull() {
    registerMocks();
    complaintRepoMock.mock('getAccountById', null);

    Assert.isNull(
      NewCaseFlowWrapperController.getOCVId(
        Lib_FakeIdGenerator.getMockId(Account.SObjectType)
      ),
      'OCV ID should be null'
    );
  }
  /**
   * @description Test of getCaseDetailsById for non customer complaint.
   */
  @IsTest
  private static void testGetAEMComplaintCOnsentObtained() {
    Case csObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Origin = 'ANZ Plus Web',
      RecordTypeId = RTCase.generalInquiryCmos,
      Type = '11',
      ANZx_Customer__c = true
    );
    registerMocks();
    complaintRepoMock.mock('getCaseDetailsById', (csObj));
    Test.startTest();
    Case caseObj = (Case) JSON.deserialize(
      NewCaseFlowWrapperController.getCaseDetailsByCaseRecordAEM(
        csObj,
        RTCase.nonCustomerComplaint
      ),
      Case.class
    );
    Test.stopTest();
    Assert.isTrue(
      caseObj.IDR_NC_Is_Consent_Obtained__c == true,
      'Non Customer Consent should be true'
    );
  }
}
