@isTest
private class ProfileUpdateCaseActionsTest {
  private static final Faker FAKER = new Faker('AU');
  static Lib_MockProvider profileUpdateCaseRepoMock;

  static void registerMocks() {
    profileUpdateCaseRepoMock = Lib_MockProvider.forType(
      ProfileUpdateCaseRepository.class
    );
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
}
