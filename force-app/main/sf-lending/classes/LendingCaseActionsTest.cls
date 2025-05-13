/**
 * @author Jaya Srivastava
 * @since February 2025
 * @description Test class for LendingCaseActions
 */
@IsTest
private class LendingCaseActionsTest {
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );
  private static Lib_MockProvider userMock;
  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkPermission', true)
      .mock('checkAnyRoles', true);
  }

  @IsTest
  static void caseUpdateSuccessful() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    registerMocks();
    Test.startTest();
    LendingCaseActions.restrictUserFromUpdatingLendingCase(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    Assert.areEqual(
      getNewCaseRecords[0].Status,
      'Closed - Approved',
      'Case is Updated'
    );
  }
  @IsTest
  static void caseOwnerUpdateToFromUserToUser() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    getNewCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    getOldCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    LendingCaseActions.restrictUserFromChangingOwnerIfNotQueue(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t assign the lending case directly to someone else. Please assign the case back to the queue for it to be picked up.',
      error.getMessage(),
      'Case cannot be updated'
    );
  }
  @IsTest
  static void caseUpdateFailure() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    registerMocks();
    userMock.mock('checkAnyRoles', false);
    userMock.mock('checkPermission', false);
    Test.startTest();
    LendingCaseActions.restrictUserFromUpdatingLendingCase(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You don\'t have required permissions to perform the action',
      error.getMessage(),
      'Case cannot be updated'
    );
  }
  @IsTest
  static void caseCreationSuccess() {
    List<Case> getCaseRecords = createMockCaseRecordList('Open');
    registerMocks();
    Test.startTest();
    LendingCaseActions.restrictUserFromCreatingLendingCase(getCaseRecords);
    Test.stopTest();
    Assert.areEqual(
      getCaseRecords[0].RecordTypeId,
      RTCase.lending,
      'Case is created'
    );
  }
  @isTest
  static void caseCreationFailure() {
    List<Case> getCaseRecords = createMockCaseRecordList('Open');
    registerMocks();
    userMock.mock('checkPermission', false);
    Test.startTest();
    LendingCaseActions.restrictUserFromCreatingLendingCase(getCaseRecords);
    Test.stopTest();
    List<Database.Error> errors = getCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You don\'t have required permissions to perform the action',
      error.getMessage(),
      'Case cannot be created'
    );
  }
  private static List<Case> createMockCaseRecordList(String status) {
    List<Case> caseRecordsList = new List<Case>();
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CASE_ID;
    caseRecord.Status = status;
    caseRecord.RecordTypeId = RTCase.lending;
    caseRecordsList.add(caseRecord);
    return caseRecordsList;
  }
}
