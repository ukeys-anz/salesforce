@isTest
private class ResidentialLoanApplicationHelperTest {
  static Lib_MockProvider rlaRepoMock;
  static Lib_MockProvider brokerCodeRepoMock;
  static Lib_MockProvider caseRepoMock;
  private static final String BROKER_CODE = 'TPMI123456789';
  static Lib_MockProvider brokerCodeMergeRepoMock;
  private static final Id COACH_NUDGE_RT_ID = RTTask.coachNudge;

  private static final Id FAKER_CONTACT_ID = Lib_FakeIdGenerator.getMockId(
    Contact.getSObjectType()
  );
  private static final Id FAKER_RLA_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );

  static void registerMocks() {
    rlaRepoMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock(
        'queryRelatedProperties',
        new List<LoanApplicationProperty>{ relatedProperty }
      );
    brokerCodeRepoMock = Lib_MockProvider.forType(BrokerCodeRepository.class);
    brokerCodeMergeRepoMock = Lib_MockProvider.forType(
      RetailContactMergeRepository.class
    );
    caseRepoMock = Lib_MockProvider.forType(LendingCaseRepository.class);
  }

  static Id rlaIds = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.SObjectType
  );
  static Id lapIds = Lib_FakeIdGenerator.getMockId(
    LoanApplicationProperty.SObjectType
  );

  static List<SOPAsset> sopAssets {
    get {
      List<SOPAsset> assets = new List<SOPAsset>();
      SOPAsset asset = new SOPAsset();
      asset.type = 'ASSET_TYPE_PROPERTY';
      asset.propertyId = lapIds;
      assets.add(asset);
      SOPAsset asset1 = new SOPAsset();
      asset1.type = 'Anothertype';
      assets.add(asset1);

      return assets;
    }
  }

  static LoanApplicationProperty relatedProperty {
    get {
      return new LoanApplicationProperty(
        Id = Lib_FakeIdGenerator.getMockId(LoanApplicationProperty.SObjectType),
        Property_ID__c = lapIds,
        PropertyValue = 5000000.01,
        LoanApplicationId = rlaIds,
        Name = '639 collins st docklands vic 3000'
      );
    }
  }

  @isTest
  static void testGetPropertyIdMap() {
    Map<String, SOPAsset> assetMap = ResidentialLoanApplicationHelper.getPropertyIdMap(
      sopAssets
    );
    System.assertEquals(
      1,
      assetMap.size(),
      'only the property asset should be in the map'
    );
  }

  @isTest
  static void testUpdateTheAssets() {
    List<SOPAsset> updatedAssets = ResidentialLoanApplicationHelper.updateTheAssets(
      new List<LoanApplicationProperty>{ relatedProperty },
      sopAssets
    );
    System.assertEquals(
      2,
      updatedAssets.size(),
      'the asset size should not change'
    );
    System.assertEquals(
      5000000.01,
      updatedAssets[0].propertyValue,
      'the property asset should have value now'
    );
  }

  @isTest
  static void testOverwritePropertyAssetData() {
    registerMocks();

    Test.startTest();
    List<SOPAsset> assets = ResidentialLoanApplicationHelper.overwritePropertyAssetData(
      rlaIds,
      sopAssets
    );
    Test.stopTest();

    System.assertEquals(
      '639 collins st docklands vic 3000',
      assets[0].propertyAddress,
      'address should be from related property record'
    );
    System.assertNotEquals(
      '639 collins st docklands vic 3000',
      assets[1].propertyAddress,
      'address should not be from related property record'
    );
  }
  @IsTest
  static void testProcessEmptyAssistedBroker() {
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationHelper.processAssistedBrokerPopulation(
      new List<ResidentialLoanApplication>(),
      ResidentialLoanApplicationActions.ACCREDITATION_RETAIL
    );
    Test.stopTest();
    Assert.isTrue(results.isEmpty(), 'Results should be empty without input');
  }

  @IsTest
  static void testProcessAssistedBroker() {
    registerMocks();
    caseRepoMock.mock(
      'queryRelatedCreditReferralCases',
      createMockCaseRelatedToRla()
    );
    brokerCodeMergeRepoMock.mock('getBrokerIdentifiers', createBrokerCodes(10));
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationHelper.processAssistedBrokerPopulation(
      loanApps,
      ResidentialLoanApplicationActions.ACCREDITATION_RETAIL
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      loanApps.size(),
      'Results should be the same size as input'
    );
    Assert.areEqual(
      results[0].Assisted_Broker__c,
      FAKER_CONTACT_ID,
      'Assisted Broker should be populated with Broker_Name__c value'
    );
  }

  /**
   * @description Test case for createBrokerIdentifierMap method.
   */
  @IsTest
  static void testCreateBrokerIdentifierMap() {
    List<ResidentialLoanApplication> newRecord = createResidentialLoanApplications(
      1
    );

    newRecord[0].Assisted_Broker_TPMI_SAO__c = 'Broker-TPMISAO-1';
    Test.startTest();
    Map<String, String> brokerIdentifierMap = ResidentialLoanApplicationHelper.createBrokerIdentifierMap(
      new List<ResidentialLoanApplication>{ newRecord[0] },
      'Retail'
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      brokerIdentifierMap.size(),
      'One broker identifier should be mapped'
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
    List<ResidentialLoanApplication> loanApplications = ResidentialLoanApplicationHelper.getUnblockedApplication(
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
  static void testPrepareTaskWithFieldsUpdatePositive() {
    List<Task> masterTaskList = createMockTaskRelatedToRla();
    String oldStatus = masterTaskList[0].Status;

    Test.startTest();
    List<Task> taskRecordsToBeUpdated = ResidentialLoanApplicationHelper.prepareTaskWithFieldsUpdate(
      masterTaskList
    );

    Test.stopTest();

    Assert.areEqual(
      'Not Started',
      oldStatus,
      'The task record status should be Not Started'
    );
    Assert.areEqual(
      'Expired',
      taskRecordsToBeUpdated[0].Status,
      'The task record status should have status as Expired'
    );
  }

  @isTest
  static void testPrepareTaskWithFieldsUpdateNegative() {
    List<Task> masterTaskList = new List<Task>();
    Test.startTest();
    List<Task> taskRecordsToBeUpdated = ResidentialLoanApplicationHelper.prepareTaskWithFieldsUpdate(
      masterTaskList
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      taskRecordsToBeUpdated.isEmpty(),
      'Task records should not be returned'
    );
  }

  @isTest
  static void testGetCancelledRlaRecordsPostChatterPositive() {
    List<Id> rlaRecordIdList = new List<Id>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_CANCELLED',
      2
    );
    newRlaRecords[1].Status = 'STATE_REFERRED';
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE',
      2
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0),
      oldRlaRecordsList.get(1).Id => oldRlaRecordsList.get(1)
    };

    Test.startTest();
    Set<Id> rlaRecordIds = ResidentialLoanApplicationHelper.getCancelledRlaRecordsPostChatter(
      newRlaRecords,
      oldRlaRecords
    );
    rlaRecordIdList.addAll(rlaRecordIds);

    Test.stopTest();

    Assert.areEqual(1, rlaRecordIds.size(), 'List has one record');
    Assert.areEqual(
      newRlaRecords[0].Id,
      rlaRecordIdList[0],
      'List of cancelled records'
    );
  }

  @isTest
  static void testGetCancelledRlaRecordsPostChatterNegative() {
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_UNSPECIFIED',
      1
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE',
      1
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    Set<Id> rlaRecordIds = ResidentialLoanApplicationHelper.getCancelledRlaRecordsPostChatter(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();

    Assert.areEqual(
      true,
      rlaRecordIds.isEmpty(),
      'Residential Loan Application records should not be returned'
    );
  }

  @isTest
  static void testPrepareCaseWithFieldsUpdatePositive() {
    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      'STATE_CANCELLED',
      1
    );
    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };
    List<Case> masterCaseList = createMockCaseRelatedToRla();

    Test.startTest();
    List<Case> caseRecordsToBeUpdated = ResidentialLoanApplicationHelper.prepareCaseWithFieldsUpdate(
      masterCaseList,
      newRlaRecords
    );

    Test.stopTest();

    Assert.areEqual(
      'Closed - Cancelled',
      caseRecordsToBeUpdated[0].Status,
      'The Case record status should have status as Expired'
    );
  }

  @isTest
  static void testPrepareCaseWithFieldsUpdatePositiveExpired() {
    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      'STATE_CANCELLED',
      1
    );
    newRlaRecordsList.get(0)
      .Cancellation_Reason__c = 'Credit Assessment Expired';
    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };
    List<Case> masterCaseList = createMockCaseRelatedToRla();

    Test.startTest();
    List<Case> caseRecordsToBeUpdated = ResidentialLoanApplicationHelper.prepareCaseWithFieldsUpdate(
      masterCaseList,
      newRlaRecords
    );

    Test.stopTest();

    Assert.areEqual(
      'Closed - Expired',
      caseRecordsToBeUpdated[0].Status,
      'The Case record status should have status as Expired'
    );
  }

  @isTest
  static void testPrepareCaseWithFieldsUpdateNegative() {
    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      'STATE_CANCELLED',
      1
    );
    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };
    List<Case> masterCaseList = new List<Case>();
    Test.startTest();
    List<Case> caseRecordsToBeUpdated = ResidentialLoanApplicationHelper.prepareCaseWithFieldsUpdate(
      masterCaseList,
      newRlaRecords
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      caseRecordsToBeUpdated.isEmpty(),
      'Case records should not be returned'
    );
  }

  @IsTest
  static void testGetLoanApplicationValidity() {
    Loan_Application_Validity__mdt loanApplicationValidityMDT = new Loan_Application_Validity__mdt(
      DeveloperName = 'RLS STATE SUBMITTED',
      MasterLabel = 'RLS_STATE_SUBMITTED',
      Years__c = 1,
      Months__c = 6,
      Days__c = 60
    );
    Date expectedDate = Date.today().addYears(1).addMonths(6).addDays(60);
    Assert.areEqual(
      expectedDate,
      ResidentialLoanApplicationHelper.getLoanApplicationValidity(
        loanApplicationValidityMDT
      ),
      'Date should be returned after years, months and days have been added to today\'s date'
    );
  }

  static List<Case> createMockCaseRelatedToRla() {
    List<Case> strCaselist = new List<Case>();

    Case creditRefCase = TestDataFactory.createCase('Credit_Referral');
    creditRefCase.Loan_Application__c = FAKER_RLA_ID;
    strCaselist.add(creditRefCase);
    return strCaselist;
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

  static List<ResidentialLoanApplication> createMockRlaRecord(
    String status,
    Integer noOfRecords
  ) {
    List<ResidentialLoanApplication> rlaRecordsList = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < noOfRecords; i++) {
      ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication();
      rlaRecord.Id = FAKER_RLA_ID;
      rlaRecord.Status = status;
      rlaRecordsList.add(rlaRecord);
    }
    return rlaRecordsList;
  }

  static List<Task> createMockTaskRelatedToRla() {
    List<Task> strTasklist = new List<Task>();

    Task coachNudgeTask = TestDataFactory.createTaskRecord(
      RTTask.coachNudge,
      null,
      FAKER_RLA_ID,
      Lib_FakeIdGenerator.getMockId(Group.SObjectType),
      false
    );
    strTasklist.add(coachNudgeTask);
    return strTasklist;
  }

  static Contact createTestContact() {
    Contact testContact = new Contact();
    testContact.Id = FAKER_CONTACT_ID;
    testContact.FirstName = 'Broker01';
    testContact.LastName = 'ANZX-6197';
    testContact.Email = 'contactbroker@anzx.abc';
    testContact.MobilePhone = '123456789';
    testContact.RetailTPMISAO__c = BROKER_CODE;
    testContact.OCV_ID__c = 'OCV123456789';
    return testContact;
  }
}
