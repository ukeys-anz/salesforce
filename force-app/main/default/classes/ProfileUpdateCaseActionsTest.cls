@isTest
private class ProfileUpdateCaseActionsTest {
  private static final Faker FAKER = new Faker('AU');
  static Lib_MockProvider profileUpdateCaseRepoMock;
  static Lib_MockProvider handlerMock;

  static void registerMocks() {
    profileUpdateCaseRepoMock = Lib_MockProvider.forType(
      ProfileUpdateCaseRepository.class
    );
    handlerMock = Lib_MockProvider.forType(ProfileStagingHandler.class);
  }

  static Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
  static Case constructCase(String type, String status) {
    return new Case(
      Id = caseId,
      RecordTypeId = RTCase.profileUpdate,
      Type = type,
      Status = status
    );
  }

  @IsTest
  static void setOwnerToIDOpsQueue() {
    Case theCase = constructCase(
      GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
      GetHelpConstants.OPEN_STATUS
    );
    List<Case> lstCases = new List<Case>{ theCase };

    Test.startTest();
    ProfileUpdateCaseActions.setOwnerToIDOpsQueue(lstCases);
    Test.stopTest();

    for (Case oCase : lstCases) {
      Assert.areEqual(
        ProfileUpdateCaseActions.idOpsQueue.Id,
        oCase.OwnerId,
        'Profile Update cases should be assigned to the ID Ops Queue'
      );
    }
  }

  @IsTest
  static void testLegalNameNotifications() {
    registerMocks();

    Case oldCase = constructCase(
      ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
      GetHelpConstants.OPEN_STATUS
    );

    Case theCase = constructCase(
      ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
      GetHelpConstants.CLOSED_STATUS
    );
    theCase.Fraud_Review_Outcome__c = ProfileUpdateCaseActions.PASS;

    profileUpdateCaseRepoMock.mock(
      'getLegalNameCaseForNotification',
      new List<Case>{ theCase }
    );

    Test.startTest();
    ProfileUpdateCaseActions.legalNameNotifications(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    Assert.isFalse(
      profileUpdateCaseRepoMock.getHistories('getLegalNameCaseForNotification')
        .isEmpty(),
      'getLegalNameCaseForNotification should have been called.'
    );
  }

  @IsTest
  static void testSendLegalNameUpdateToOCV() {
    registerMocks();

    Account acct = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    Case oldCase = constructCase(
      ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
      GetHelpConstants.OPEN_STATUS
    );
    Case theCase = constructCase(
      ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
      GetHelpConstants.OPEN_STATUS
    );
    theCase.Fraud_Review_Outcome__c = ProfileUpdateCaseActions.PASS;
    theCase.AccountId = acct.Id;

    profileUpdateCaseRepoMock.mock('getAccounts', new List<Account>{ acct });

    Test.startTest();
    ProfileUpdateCaseActions.sendLegalNameUpdateToOCV(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    Assert.isFalse(
      handlerMock.getHistories('process').isEmpty(),
      'ProfileStagingHandler.process should have been called.'
    );
  }

  @IsTest
  static void testSetDocumentCountryCodeToAU() {
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Map<Id, Case> oldMap = new Map<Id, Case>{
      caseId => new Case(Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME)
    };
    List<Case> cases = new List<Case>{
      new Case(
        Id = caseId,
        Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
        DocumentType__c = 'DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE'
      )
    };
    Test.startTest();
    ProfileUpdateCaseActions.setDocumentCountryCode(cases, oldMap);
    Test.stopTest();
    Assert.areEqual(
      'AUS',
      cases[0].CountryCode__c,
      'Country code should be AUS when document type is updated to an Australian document type'
    );
  }

  @IsTest
  static void testSetDocumentCountryCodeToNonAU() {
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Map<Id, Case> oldMap = new Map<Id, Case>{
      caseId => new Case(
        Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
        CountryCode__c = 'AUS',
        DocumentType__c = 'DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE'
      )
    };
    List<Case> cases = new List<Case>{
      new Case(
        Id = caseId,
        Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME
      )
    };
    Test.startTest();
    ProfileUpdateCaseActions.setDocumentCountryCode(cases, oldMap);
    Test.stopTest();
    Assert.isNull(
      cases[0].CountryCode__c,
      'Country code should be reset when document type is updated to a non-Australian document type'
    );
  }

  @IsTest
  static void testValidateStagingProgress() {
    registerMocks();
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Map<Id, Case> oldMap = new Map<Id, Case>{
      caseId => new Case(
        Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
        Fraud_Review_Outcome__c = ProfileUpdateCaseActions.PASS,
        Status = 'Open'
      )
    };
    List<Case> cases = new List<Case>{
      new Case(
        Id = caseId,
        Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
        Fraud_Review_Outcome__c = ProfileUpdateCaseActions.PASS,
        Status = 'Closed'
      )
    };
    profileUpdateCaseRepoMock.mock(
      'getPendingStagingRecordsByCaseIds',
      new List<Customer_Profile_Updates__c>{
        new Customer_Profile_Updates__c(Case__c = caseId)
      }
    );
    Test.startTest();
    ProfileUpdateCaseActions.validateStagingProgress(cases, oldMap);
    Test.stopTest();
    Assert.isTrue(
      cases[0].hasErrors(),
      'Case should be prevented from closing if there are pending staging records'
    );
  }

  @IsTest
  static void testValidateStagingProgressNoPending() {
    registerMocks();
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Map<Id, Case> oldMap = new Map<Id, Case>{
      caseId => new Case(
        Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
        Fraud_Review_Outcome__c = 'PASS',
        Status = 'Open'
      )
    };
    List<Case> cases = new List<Case>{
      new Case(
        Id = caseId,
        Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
        Fraud_Review_Outcome__c = 'PASS',
        Status = 'Closed'
      )
    };
    profileUpdateCaseRepoMock.mock(
      'getPendingStagingRecordsByCaseIds',
      new List<Customer_Profile_Updates__c>()
    );
    Test.startTest();
    ProfileUpdateCaseActions.validateStagingProgress(cases, oldMap);
    Test.stopTest();
    Assert.isFalse(
      cases[0].hasErrors(),
      'Case should be allowed to be closed if there are no pending staging records'
    );
  }
}
