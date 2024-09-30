/**
 * @author Jason Zhiren Guan
 * @since April 2024
 * @description Test class for Residential Loan Application actions
 */

@IsTest
private class ResidentialLoanAppActionsTest {
  private static final String BROKER_CODE = 'TPMI123456789';
  static Lib_MockProvider rlarRepoMock = Lib_MockProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final String SUNSET_STATUS = 'STATE_UNSPECIFIED';
  private static final String NON_SUNSET_STATUS = 'STATE_CAPTURE';
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

  /**
   * @description
   * Scenarios:
   * 1. insert status = sunset: set timestamp
   * 2. insert status = non sunset: do not set timestamp
   */
  @IsTest
  static void testSetSunsetTimestampForInsert() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToInsert = createResidentialLoanApplications(
      2
    );
    Map<Id, ResidentialLoanApplication> oldLoanAppMap = new Map<Id, ResidentialLoanApplication>();
    // Set new apps attributes
    testLoanAppsToInsert[0].Status = SUNSET_STATUS;
    testLoanAppsToInsert[1].Status = NON_SUNSET_STATUS;

    // Test insert scenarios
    Test.startTest();
    ResidentialLoanApplicationActions.setSunsetTimestamp(
      testLoanAppsToInsert,
      oldLoanAppMap
    );
    Test.stopTest();

    // Assert
    Assert.isTrue(
      testLoanAppsToInsert[0].SunsetTimestamp__c.isSameDay(Date.today()),
      'Application Sunset Timestamp should be set as current date time'
    );
    Assert.isNull(
      testLoanAppsToInsert[1].SunsetTimestamp__c,
      'Application Sunset Timestamp should not be set'
    );
  }

  /**
   * @description
   * Scenarios:
   * 1. update from non sunset to non sunset: do not set timestamp
   * 2. update from sunset to sunset: keep the timestamp no change
   * 3. update from non sunset to sunset: set timestamp
   * 4. update from sunset to non sunset: clear timestamp
   */
  @IsTest
  static void testSetSunsetTimestampForUpdate() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToUpdate = createResidentialLoanApplications(
      4
    );
    List<ResidentialLoanApplication> oldLoanApps = testLoanAppsToUpdate.deepClone(
      true
    );
    Map<Id, ResidentialLoanApplication> oldLoanAppMap = new Map<Id, ResidentialLoanApplication>(
      oldLoanApps
    );

    // Set new apps attributes
    testLoanAppsToUpdate[0].Status = NON_SUNSET_STATUS;
    testLoanAppsToUpdate[1].Status = SUNSET_STATUS;
    testLoanAppsToUpdate[2].Status = SUNSET_STATUS;
    testLoanAppsToUpdate[3].Status = NON_SUNSET_STATUS;
    testLoanAppsToUpdate[3].SunsetTimestamp__c = System.now();

    // Set old apps attributes
    oldLoanApps[0].Status = NON_SUNSET_STATUS;
    oldLoanApps[1].Status = SUNSET_STATUS;
    oldLoanApps[2].Status = NON_SUNSET_STATUS;
    oldLoanApps[3].Status = SUNSET_STATUS;

    Test.startTest();
    // Test update scenarios
    ResidentialLoanApplicationActions.setSunsetTimestamp(
      testLoanAppsToUpdate,
      oldLoanAppMap
    );
    Test.stopTest();

    // Assert
    Assert.areEqual(
      testLoanAppsToUpdate[0].SunsetTimestamp__c,
      oldLoanApps[0].SunsetTimestamp__c,
      'Application Sunset Timestamp should not be set'
    );
    Assert.areEqual(
      testLoanAppsToUpdate[1].SunsetTimestamp__c,
      oldLoanApps[1].SunsetTimestamp__c,
      'Application Sunset Timestamp should remain the same'
    );
    Assert.isTrue(
      testLoanAppsToUpdate[2].SunsetTimestamp__c.isSameDay(Date.today()),
      'Application Sunset Timestamp should be set as current date time'
    );
    Assert.isNull(
      testLoanAppsToUpdate[3].SunsetTimestamp__c,
      'Application Sunset Timestamp should be cleared'
    );
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

  /**
   * @description Method for testing updateApplicationSyncStatus
   * @author Deepro De | 06-03-2024
   **/
  @isTest
  static void testUpdateApplicationSyncStatus() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      2
    );
    loanApps[1].Sync_Status__c = 'Blocked';
    Test.startTest();
    ResidentialLoanApplicationActions.updateApplicationSyncStatus(loanApps);
    Test.stopTest();
    Assert.areEqual(
      'Blocked',
      loanApps[1].Sync_Status__c,
      'Expected Residential Loan Application Sync Status to be Blocked'
    );

    Assert.areEqual(
      'Broker Org',
      loanApps[0].Sync_Status__c,
      'Expected Residential Loan Application Sync Status to be Broker Org'
    );
  }

  /**
   * @description Method for testing publishSyncEvents
   * @author Deepro De | 06-03-2024
   **/
  @isTest
  static void testPublishSyncEvents() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    for (ResidentialLoanApplication eachLoanApp : loanApps) {
      eachLoanApp.Sync_Status__c = 'Broker Org';
    }
    rlarRepoMock.mock('queryLoanApplications', loanApps);
    Test.startTest();
    ResidentialLoanApplicationActions.mockBrokerSettings = new BrokerSettings__c(
      BypassApplicationSyncEvents__c = false
    );
    List<SObject> cloudEvents = ResidentialLoanApplicationActions.publishSyncEvents(
      loanApps,
      ApplicationEventActions.APPLICATION_EVENT_ADD
    );
    Test.stopTest();
    Assert.areEqual(
      10,
      cloudEvents.size(),
      '10 Cloud Events should be published'
    );
    Assert.isFalse(
      rlarRepoMock.getHistories('queryLoanApplications').isEmpty(),
      'queryLoanApplications should have been called at least once'
    );
    List<Id> loanApplicationIds = (List<Id>) rlarRepoMock.getHistory(
        'queryLoanApplications'
      )
      .getParam('loanIds');
    Assert.isFalse(
      loanApplicationIds.isEmpty(),
      'loanApplicationIds should have been passed on to the queryLoanApplications method'
    );
  }

  /**
   * @description Method for testing filterLoanAppsBasedOnSyncStatus
   * @author Deepro De | 06-03-2024
   **/
  @isTest
  static void testFilterLoanAppsBasedOnSyncStatus() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      3
    );
    loanApps[0].Sync_Status__c = 'Broker Org';
    loanApps[1].Sync_Status__c = 'Broker Org';
    loanApps[2].Sync_Status__c = 'Blocked';
    Test.startTest();
    List<Id> loanAppList = ResidentialLoanApplicationActions.filterLoanAppsBasedOnSyncStatus(
      loanApps
    );
    Test.stopTest();
    Assert.areEqual(
      2,
      loanAppList.size(),
      'Expected size of loanAppList should be 2'
    );
  }

  /**
   * @description Method for testing getUnblockedApplication
   * @author Deepro De | 16-07-2024
   **/
  @isTest
  static void testGetUnblockedApplication() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    loanApps[0].Sync_Status__c = 'Blocked';
    Test.startTest();
    List<ResidentialLoanApplication> loanApplications = ResidentialLoanApplicationActions.getUnblockedApplication(
      loanApps
    );
    Test.stopTest();
    Assert.areEqual(
      9,
      loanApplications.size(),
      'Expected size of loanAppList should be 9'
    );
  }
  @isTest
  private static void testProcessCancelledRLARecords() {
    registerMocks();

    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      BOHConstants.rlaStateCancelledStatus
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
      BOHConstants.caseClosedCancelledStatus,
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
      BOHConstants.caseClosedCancelledStatus,
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
      .Cancellation_Reason__c = BOHConstants.rlaReasonCreditAssessmentExpired;
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
      BOHConstants.caseClosedExpiredStatus,
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
