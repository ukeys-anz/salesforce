/**
 * @author Jason Zhiren Guan
 * @since April 2024
 * @description Test class for Residential Loan Application actions
 */

@IsTest
private class ResidentialLoanAppActionsTest {
  private static final String BROKER_CODE = 'TPMI123456789';
  private static final Id FAKER_RLA_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider rlaRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    rlaRepoMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock('queryRelatedCreditReferralCases', createMockCaseRelatedToRla());
  }

  @IsTest
  static void testPopulateAssistedBroker() {
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.populateRetailLoanAssistedBroker(
      new List<ResidentialLoanApplication>(),
      new Map<Id, ResidentialLoanApplication>()
    );
    Test.stopTest();
    Assert.isTrue(results.isEmpty(), 'Results should be empty without input');
  }

  @IsTest
  static void testGetRecordsForAssistedBrokerOnInsert() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.getRecordsToUpdateAssistedBroker(
      loanApps,
      new Map<Id, ResidentialLoanApplication>()
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      loanApps.size(),
      'Results should be the same size as input'
    );
  }

  @IsTest
  static void testGetRecordsForAssistedBrokerOnUpdate() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Map<Id, ResidentialLoanApplication> loanAppMap = convertRecordsToOldMap(
      loanApps
    );
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.getRecordsToUpdateAssistedBroker(
      loanApps,
      loanAppMap
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      loanApps.size(),
      'Results should be the same size as input'
    );
  }

  @IsTest
  static void testProcessEmptyAssistedBroker() {
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.processAssistedBrokerPopulation(
      new List<ResidentialLoanApplication>(),
      ResidentialLoanApplicationActions.ACCREDITATION_RETAIL
    );
    Test.stopTest();
    Assert.isTrue(results.isEmpty(), 'Results should be empty without input');
  }

  @IsTest
  static void testProcessAssistedBroker() {
    ResidentialLoanApplicationActions.mockBrokerCodes = createBrokerCodes(10);
    Id testContactId = ResidentialLoanApplicationActions.mockBrokerCodes[0]
      .Broker_Name__c;
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.processAssistedBrokerPopulation(
      loanApps,
      ResidentialLoanApplicationActions.ACCREDITATION_RETAIL
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      loanApps.size(),
      'Results should be the same size as input'
    );
    for (ResidentialLoanApplication loanApp : results) {
      Assert.areEqual(
        loanApp.Assisted_Broker__c,
        testContactId,
        'Assisted Broker should be populated with Broker_Name__c value'
      );
    }
  }

  @IsTest
  static void testGetBrokerCodesByTPMISAO() {
    List<String> brokerIdentifiers = new List<String>{ 'EXT-1234_Retail' };
    Test.startTest();
    List<Broker_Code__c> brokerCodes = ResidentialLoanApplicationActions.getBrokerCodesByTPMISAO(
      brokerIdentifiers
    );
    Assert.isTrue(
      brokerCodes.isEmpty(),
      'Broker Codes should be empty without DML in unit tests'
    );
    ResidentialLoanApplicationActions.mockBrokerCodes = createBrokerCodes(10);
    brokerCodes = ResidentialLoanApplicationActions.getBrokerCodesByTPMISAO(
      brokerIdentifiers
    );
    Test.stopTest();
    Assert.areEqual(brokerCodes.size(), 10, 'Broker Codes should be populated');
  }

  static List<ResidentialLoanApplication> createResidentialLoanApplications(
    Integer count
  ) {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < count; i++) {
      ResidentialLoanApplication loanApp = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i + 1)
      );
      loanApp.Id = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      loanApp.Assisted_Broker_TPMI_SAO__c = BROKER_CODE;
      loanApps.add(loanApp);
    }
    return loanApps;
  }

  static List<Broker_Code__c> createBrokerCodes(Integer count) {
    Contact testContact = createTestContact();
    List<Broker_Code__c> brokerCodes = new List<Broker_Code__c>();
    for (Integer i = 0; i < count; i++) {
      Broker_Code__c brokerCode = new Broker_Code__c();
      brokerCode.Id = Lib_FakeIdGenerator.getMockId(Broker_Code__c.SObjectType);
      brokerCode.Accreditation_Type__c = 'Retail';
      brokerCode.Broker_Name__c = testContact.Id;
      brokerCode.External_Id__c =
        BROKER_CODE +
        '_' +
        ResidentialLoanApplicationActions.ACCREDITATION_RETAIL;
      brokerCodes.add(brokerCode);
    }
    return brokerCodes;
  }

  static Contact createTestContact() {
    Contact testContact = new Contact();
    testContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    testContact.FirstName = 'Broker01';
    testContact.LastName = 'ANZX-6197';
    testContact.Email = 'contactbroker@anzx.abc';
    testContact.MobilePhone = '123456789';
    testContact.RetailTPMISAO__c = BROKER_CODE;
    testContact.OCV_ID__c = 'OCV123456789';
    return testContact;
  }

  static Map<Id, ResidentialLoanApplication> convertRecordsToOldMap(
    List<ResidentialLoanApplication> loanApps
  ) {
    List<ResidentialLoanApplication> oldLoanApps = loanApps.deepClone(true);
    for (ResidentialLoanApplication loanApp : oldLoanApps) {
      loanApp.Assisted_Broker_TPMI_SAO__c =
        loanApp.Assisted_Broker_TPMI_SAO__c + '_Old';
    }
    return new Map<Id, ResidentialLoanApplication>(oldLoanApps);
  }

  @isTest
  private static void testProcessCancelledRLARecords() {
    registerMocks();

    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      GetHelpConstants.RLA_STATUS_CANCELLED
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };

    List<Case> caseRecordBeforeUpdate = createMockCaseRelatedToRla();
    System.assertEquals(
      'Open',
      caseRecordBeforeUpdate[0].Status,
      'The Case record status should be created with "Open" status'
    );

    Test.startTest();
    ResidentialLoanApplicationActions.cancelRelatedCreditReferralCases(
      newRlaRecords,
      oldRlaRecords
    );
    Test.stopTest();

    List<Case> caseRecordAfterUpdate = (List<Case>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    System.assertEquals(
      GetHelpConstants.CLOSED_CANCELLED_STATUS,
      caseRecordAfterUpdate[0].Status,
      'The Case record status should update to Closed Cancelled'
    );
  }

  @isTest
  private static void testprepareCaseWithFieldsUpdatePositive() {
    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };
    List<Case> masterCaseList = createMockCaseRelatedToRla();
    List<Case> caseRecordsToBeUpdated = new List<Case>();
    System.assertEquals(
      'Open',
      masterCaseList[0].Status,
      'The Case record status should be Open'
    );

    Test.startTest();
    caseRecordsToBeUpdated = ResidentialLoanApplicationActions.prepareCaseWithFieldsUpdate(
      masterCaseList,
      newRlaRecords
    );

    Test.stopTest();

    System.assertEquals(
      GetHelpConstants.CLOSED_CANCELLED_STATUS,
      caseRecordsToBeUpdated[0].Status,
      'The Case record status should have status as Expired'
    );
  }

  @isTest
  private static void testprepareCaseWithFieldsUpdatePositiveExpired() {
    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    newRlaRecordsList.get(0)
      .Cancellation_Reason__c = GetHelpConstants.RLA_CANCELLATION_REASON_CREDIT_ASSESMENT_EXPIRED;
    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };
    List<Case> masterCaseList = createMockCaseRelatedToRla();
    List<Case> caseRecordsToBeUpdated = new List<Case>();
    System.assertEquals(
      'Open',
      masterCaseList[0].Status,
      'The Case record status should be Open'
    );

    Test.startTest();
    caseRecordsToBeUpdated = ResidentialLoanApplicationActions.prepareCaseWithFieldsUpdate(
      masterCaseList,
      newRlaRecords
    );

    Test.stopTest();

    System.assertEquals(
      GetHelpConstants.CLOSED_EXPIRED_STATUS,
      caseRecordsToBeUpdated[0].Status,
      'The Case record status should have status as Expired'
    );
  }

  @isTest
  private static void testprepareCaseWithFieldsUpdateNegative() {
    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };
    List<Case> masterCaseList = new List<Case>();
    List<Case> caseRecordsToBeUpdated = ResidentialLoanApplicationActions.prepareCaseWithFieldsUpdate(
      masterCaseList,
      newRlaRecords
    );
    System.assertEquals(
      true,
      caseRecordsToBeUpdated.isEmpty(),
      'Case records should not be returned'
    );
  }

  private static List<ResidentialLoanApplication> createMockRlaRecord(
    String status
  ) {
    List<ResidentialLoanApplication> rlaRecordsList = new List<ResidentialLoanApplication>();
    ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication();
    rlaRecord.Id = FAKER_RLA_ID;
    rlaRecord.Status = status;

    rlaRecordsList.add(rlaRecord);
    return rlaRecordsList;
  }

  private static List<Case> createMockCaseRelatedToRla() {
    List<Case> strCaselist = new List<Case>();

    Case creditRefCase = TestDataFactory.createCase('Credit_Referral');
    creditRefCase.Loan_Application__c = FAKER_RLA_ID;
    strCaselist.add(creditRefCase);
    return strCaselist;
  }

  @isTest
  private static void testfilterRlaAndReturnCancelledStatusRecordsPositive() {
    Set<Id> rlaRecordIds = new Set<Id>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecordIds = ResidentialLoanApplicationActions.filterRlaAndReturnCancelledStatusRecords(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();

    System.assertEquals(
      true,
      !rlaRecordIds.isEmpty(),
      'Residential Loan Application records should be returned'
    );
  }

  @isTest
  private static void testfilterRlaAndReturnCancelledStatusRecordsNegative() {
    Set<Id> rlaRecordIds = new Set<Id>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_UNSPECIFIED'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecordIds = ResidentialLoanApplicationActions.filterRlaAndReturnCancelledStatusRecords(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();

    System.assertEquals(
      true,
      rlaRecordIds.isEmpty(),
      'Residential Loan Application records should not be returned'
    );
  }

  @isTest
  static void testCancelResidentialLoanApplicationSuccess() {
    registerMocks();
    Database.SaveResult res = TestUtil.getMockSaveResult('{"success":true}');
    dmlRepoMock.mock('doUpdate', res);

    Test.setMock(HttpCalloutMock.class, new MockCancelLoanAppCallout());
    Map<String, String> rlaObject = new Map<String, String>{
      'requestId' => '1234',
      'ocvId' => '12345',
      'Cancellation_Reason__c' => 'Credit Assessment expired',
      'Other_Cancellation_Reason__c' => 'test',
      'recordId' => Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      )
    };

    Test.startTest();
    String checkResult = ResidentialLoanApplicationActions.cancelResidentialLoanApplication(
      rlaObject
    );
    Test.stopTest();

    ResidentialLoanApplication rla = (ResidentialLoanApplication) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');

    Assert.areEqual(
      'success',
      checkResult,
      'Residential Loan Application should be cancelled'
    );
    Assert.areEqual(
      rla.Cancellation_Reason__c,
      'Credit Assessment expired',
      'Residential Loan Application should be updated with cancellation reason as Credit Assessment expired'
    );
  }

  @isTest
  static void testCancelResidentialLoanApplicationFailure() {
    Test.setMock(HttpCalloutMock.class, new MockCancelLoanAppCalloutFailure());
    Map<String, String> rlaObject = new Map<String, String>{
      'requestId' => '1234',
      'ocvId' => '12345',
      'Cancellation_Reason__c' => 'Credit Assessment expired',
      'Other_Cancellation_Reason__c' => 'test',
      'recordId' => Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      )
    };
    BOHService s = new BOHService();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + rlaObject.get('ocvId'),
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    HttpCalloutResponse response = s.cancelResidentialLoanApp(
      rlaObject.get('requestId'),
      rlaObject.get('ocvId')
    );
    Test.stopTest();
    System.debug(response);
    Assert.areEqual(response.statusCode, 500, 'Status Code should be 500');
  }

  /**
   * @description Mock cancel loan success api callout
   */
  public class MockCancelLoanAppCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  /**
   * @description Mock cancel loan failure api callout
   */
  public class MockCancelLoanAppCalloutFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}
