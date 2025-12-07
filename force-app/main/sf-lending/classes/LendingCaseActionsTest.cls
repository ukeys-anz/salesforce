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
  private static User currentUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.getSobjectType())
  );
  private static Lib_MockProvider userMock;
  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkPermission', true)
      .mock('checkAnyRoles', true)
      .mock('checkRole', true)
      .mock('getUser', currentUser);
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
    LendingCaseActions.restrictFromUpdatingLendingCase(
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
  static void restrictFromUpdatingClosedCase() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    LendingCaseActions.restrictFromUpdatingClosedCase(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t edit a case that has been closed.',
      error.getMessage(),
      'Case cannot be updated'
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
    LendingCaseActions.restrictFromChangingOwnerToOtherUser(
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
  static void caseOwnerUpdateToFromUserToOtherQueue() {
    List<Case> getNewCaseRecords = createMockCaseRecordList('InProgress');
    getNewCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      Group.getSObjectType()
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    getOldCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    LendingCaseActions.restrictFromAssigningToOtherQueue(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t assign a lending case that you do not have authority to resolve. Please select another case.',
      error.getMessage(),
      'Case cannot be updated'
    );
  }

  @IsTest
  static void restrictCaseStatusUpdateIfUserNotOwner() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    LendingCaseActions.restrictFromUpdatingStatusIfNotOwner(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t edit a case because you are not the owner.',
      error.getMessage(),
      'Case cannot be updated'
    );
  }

  @IsTest
  static void restrictBohCoachFromChangingOwnerIfNotCaseOwner() {
    List<Case> getNewCaseRecords = createMockCaseRecordList('InProgress');
    getNewCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    registerMocks();
    userMock.mock('checkAnyRoles', false);
    Test.startTest();
    LendingCaseActions.restrictBohCoachFromChangingOwnerIfNotCaseOwner(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t assign a case because you are not the owner.',
      error.getMessage(),
      'Case cannot be updated'
    );
  }

  @IsTest
  static void restrictLeadsFromAssigningCaseToOtherUsersOrQueue() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    getNewCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    getOldCaseRecords[0].OwnerId = QueryQueue.get('Lending_Queue').Id;
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    registerMocks();
    Test.startTest();
    LendingCaseActions.restrictLeadsFromAssigningCaseToOtherUsersOrQueue(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t assign a lending case that you do not have authority to resolve. Please select another case.',
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
    LendingCaseActions.restrictFromUpdatingLendingCase(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You don\'t have required permissions to perform the action.',
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
  @IsTest
  static void restrictUserFromUpdatingCaseToClosed() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    registerMocks();
    userMock.mock('checkPermission', false);
    Test.startTest();
    LendingCaseActions.restrictUserFromUpdatingCaseToClosed(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t close the case. Please click \'Approve or Reject\' to complete this request which will automatically close the case.',
      error.getMessage(),
      'Case cannot be updated'
    );
  }

  @isTest
  static void caseCloseSuccess() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      'Closed - Approved'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open');
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    registerMocks();
    Test.startTest();
    LendingCaseActions.restrictUserFromUpdatingCaseToClosed(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(
      0,
      errors.size(),
      'Allow User with required Permission to close the case'
    );

    Assert.areEqual(
      getNewCaseRecords[0].Status,
      'Closed - Approved',
      'Case is closed'
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
      'You don\'t have required permissions to perform the action.',
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
    caseRecord.System_Action__c = false;
    caseRecordsList.add(caseRecord);
    return caseRecordsList;
  }
}
