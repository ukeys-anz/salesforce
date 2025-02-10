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
}
