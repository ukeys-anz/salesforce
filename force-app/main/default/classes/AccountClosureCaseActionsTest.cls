/**
 * @author Kopal Goswami
 * @since 12/2024
 * @description AccountClosureCaseActionsTest is the test class to cover tests for {@link AccountClosureCaseActions.cls}
 */

@isTest
public with sharing class AccountClosureCaseActionsTest {
  private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  static Lib_MockProvider accountClosureRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    accountClosureRepoMock = Lib_MockProvider.forType(
      AccountClosureRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  private static void testAssignParentCaseToChildCaseWithExistingRecord() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedCaseGroups',
      mockParentCaseRecord('Open', null)
    );
    List<Case> childCaseRecords = mockQueryChildCaseRecords(null);

    Assert.isFalse(
      childCaseRecords[0].ParentId == FAKER_PARENT_CASE_ID,
      'Child Case Parent Id should not be updated'
    );

    Test.startTest();
    AccountClosureCaseActions.assignParentCaseToChildCase(childCaseRecords);
    Test.stopTest();

    Assert.isTrue(
      childCaseRecords[0].ParentId == FAKER_PARENT_CASE_ID,
      'Child Case Parent Id should be updated'
    );
  }

  @isTest
  private static void testAssignParentCaseToChildCaseWithoutExistingRecords() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedCaseGroups',
      mockExistingRecordsAsBlank()
    );
    List<Case> childCaseRecords = mockQueryChildCaseRecords(null);

    Assert.isFalse(
      childCaseRecords[0].ParentId == FAKER_PARENT_CASE_ID,
      'Child Case Parent Id should not be updated'
    );

    Test.startTest();
    AccountClosureCaseActions.assignParentCaseToChildCase(childCaseRecords);
    Test.stopTest();

    List<Case> caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    Assert.isTrue(
      childCaseRecords[0].ParentId == caseRecordsUpdated[0].Id,
      'Child Case Parent Id should be updated'
    );
  }

  @isTest
  private static void testAssignParentCaseToChildCaseWithExistingRecordNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedCaseGroups',
      mockParentCaseRecord('Open', null)
    );

    Test.startTest();
    AccountClosureCaseActions.assignParentCaseToChildCase(
      mockQueryChildCaseRecords(null)
    );
    Test.stopTest();

    Assert.isNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should not have been invoked'
    );
  }

  @isTest
  private static void testUpdateChildCaseFieldStatusPostive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryChildCaseRecords',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );

    List<Case> childCases = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);

    Assert.isTrue(ChildCases[0].Status == 'Open', 'Child Case status is Open');
    Test.startTest();
    AccountClosureCaseActions.updateChildCaseField(
      mockParentCaseRecord('Escalated', null),
      new Map<Id, Case>(mockParentCaseRecord('Open', null))
    );
    Test.stopTest();

    List<Case> caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Status == 'Escalated',
      'Child Case status should be updated to Escalated'
    );
  }

  @isTest
  private static void testUpdateChildCaseFieldStatusNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryChildCaseRecords',
      mockExistingRecordsAsBlank()
    );

    Test.startTest();
    AccountClosureCaseActions.updateChildCaseField(
      mockParentCaseRecord('Escalated', null),
      new Map<Id, Case>(mockParentCaseRecord('Open', null))
    );
    Test.stopTest();

    Assert.isNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should not have been invoked'
    );
  }

  @isTest
  private static void testupdateChildCaseFieldCircumstancePostive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryChildCaseRecords',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );

    List<Case> childCases = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);

    Assert.isNull(
      ChildCases[0].Circumstance__c,
      'Child Case circumstance should be Null'
    );
    Test.startTest();
    AccountClosureCaseActions.updateChildCaseField(
      mockParentCaseRecord('Escalated', 'Deceased Estate'),
      new Map<Id, Case>(mockParentCaseRecord('Open', null))
    );
    Test.stopTest();

    List<Case> caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Circumstance__c == 'Deceased Estate',
      'Child Case status should be updated to Deceased Estate'
    );
  }

  @isTest
  private static void testSetQueueOwnerToEscalatedCasesPositive() {
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);
    Map<Id, Case> olMap = new Map<Id, Case>(mockParentCaseRecord('Open', null));

    Test.startTest();
    AccountClosureCaseActions.setQueueOwnerToEscalatedCases(
      currentParentRecord,
      olMap
    );
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].OwnerId ==
      AccountClosureCaseActionsHelper.accountClosureQueue.Id,
      'OwnerId of the case is updated to accountClosureQueue'
    );
  }

  @isTest
  private static void testSetQueueOwnerToEscalatedCasesNegative() {
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);
    Map<Id, Case> olMap = new Map<Id, Case>(
      mockParentCaseRecord('Escalated', null)
    );

    Test.startTest();
    AccountClosureCaseActions.setQueueOwnerToEscalatedCases(
      currentParentRecord,
      olMap
    );
    Test.stopTest();

    Assert.isFalse(
      currentParentRecord[0].OwnerId ==
      AccountClosureCaseActionsHelper.accountClosureQueue.Id,
      'OwnerId of the case is not updated to accountClosureQueue as no updated records are found'
    );
  }

  @isTest
  private static void testPopulateCaseSubjectPositive() {
    registerMocks();
    accountClosureRepoMock.mock('queryAccountName', mockQueryAccountName());
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    AccountClosureCaseActions.populateCaseSubject(currentParentRecord, null);
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].Subject == 'Case Group - Sample Name',
      'Subject of the case is updated to Case Group - Sample Name'
    );
  }

  @isTest
  private static void testPopulateCaseSubjectNegative() {
    registerMocks();
    accountClosureRepoMock.mock('queryAccountName', mockQueryAccountName());
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    AccountClosureCaseActions.populateCaseSubject(
      currentParentRecord,
      new Map<Id, case>(mockParentCaseRecord('Escalated', null))
    );
    Test.stopTest();

    Assert.isFalse(
      currentParentRecord[0].Subject == 'Case Group - Sample Name',
      'Subject of the case is not updated to Case Group - Sample Name as their is no change in the Account'
    );
  }

  @isTest
  private static void testValidateDuplicateCaseGroupPerAccountPositive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedCaseGroups',
      mockParentCaseRecord('Open', null)
    );
    List<Case> currentParentRecord = mockParentCaseRecord('Open', null);

    Test.startTest();
    AccountClosureCaseActions.validateDuplicateCaseGroupPerAccount(
      currentParentRecord,
      null
    );
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].hasErrors(),
      'Error should have been set: ' +
      AccountClosureCaseActions.DUPLICATE_CASEGROUP_ERROR
    );

    Assert.isTrue(
      currentParentRecord[0].getErrors()[0]
        .getMessage()
        .contains(AccountClosureCaseActions.DUPLICATE_CASEGROUP_ERROR),
      'Error message should be: ' +
      AccountClosureCaseActions.DUPLICATE_CASEGROUP_ERROR
    );
  }

  @isTest
  private static void testValidateDuplicateCaseGroupPerAccountNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedCaseGroups',
      mockExistingRecordsAsBlank()
    );
    List<Case> currentParentRecord = mockParentCaseRecord('Open', null);

    Test.startTest();
    AccountClosureCaseActions.validateDuplicateCaseGroupPerAccount(
      currentParentRecord,
      null
    );
    Test.stopTest();

    Assert.isFalse(
      currentParentRecord[0].hasErrors(),
      'Error should have been set: ' +
      AccountClosureCaseActions.DUPLICATE_CASEGROUP_ERROR
    );
  }

  @isTest
  private static void testHandleButtonVisibiltyFlagPostive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryChildCasesForClosure',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );

    accountClosureRepoMock.mock(
      'queryEligibleChildCaseRecords',
      mockExistingRecordsAsBlank()
    );

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);
    Test.startTest();
    AccountClosureCaseActions.handleButtonVisibiltyFlag(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID),
      null
    );
    Test.stopTest();

    caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Account_Closure__c == true,
      'Show Account Closure flag should be true as the child case has sub status as Success'
    );

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Initiate_Account_Closure__c == false,
      'Show Initiate Account closure should be false as their is no child case with sub status as failed'
    );
  }

  @isTest
  private static void testHandleButtonVisibiltyFlagNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryChildCasesForClosure',
      mockExistingRecordsAsBlank()
    );

    accountClosureRepoMock.mock(
      'queryEligibleChildCaseRecords',
      mockExistingRecordsAsBlank()
    );

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);
    Test.startTest();
    AccountClosureCaseActions.handleButtonVisibiltyFlag(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID),
      null
    );
    Test.stopTest();

    caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Account_Closure__c == false,
      'Show Account Closure flag should be false as their is no eligible child case is found'
    );

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Initiate_Account_Closure__c == false,
      'Show Initiate Account closure should be false as their is no child case with sub status as failed'
    );
  }

  @isTest
  private static void testValidateCaseGroupClosurePositive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedAccountClosureCases',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );
    List<Case> currentParentRecord = mockParentCaseRecord('Closed', null);

    Test.startTest();
    AccountClosureCaseActions.validateCaseGroupClosure(
      currentParentRecord,
      new Map<Id, Case>(mockParentCaseRecord('Open', null))
    );
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].hasErrors(),
      'Error should have been set: ' +
      AccountClosureCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE
    );

    Assert.isTrue(
      currentParentRecord[0].getErrors()[0]
        .getMessage()
        .contains(AccountClosureCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE),
      'Error message should be: ' +
      AccountClosureCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE
    );
  }

  @isTest
  private static void testValidateCaseGroupClosureNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedAccountClosureCases',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    AccountClosureCaseActions.validateCaseGroupClosure(
      currentParentRecord,
      new Map<Id, Case>(mockParentCaseRecord('Open', null))
    );
    Test.stopTest();

    Assert.isFalse(
      currentParentRecord[0].hasErrors(),
      'Error should have been set: ' +
      AccountClosureCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE
    );
  }

  private static List<Case> mockQueryChildCaseRecords(Id parentId) {
    List<Case> childcases = new List<Case>();

    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = GetHelpConstants.OPEN_STATUS;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.ParentId = parentId;
    caseRecord.RecordTypeId = RTCase.accountClosure;
    caseRecord.Sub_Status__c = GetHelpConstants.SUCCESS;

    childcases.add(caseRecord);
    return childcases;
  }

  private static List<Case> mockParentCaseRecord(
    String statusValue,
    String circumstanceValue
  ) {
    List<Case> parentCases = new List<Case>();
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_PARENT_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = statusValue;
    caseRecord.RecordTypeId = RTCase.caseGroup;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.Type = GetHelpConstants.ACCOUNT_CLOSURE;
    caseRecord.Circumstance__c = circumstanceValue;

    parentCases.add(caseRecord);
    return parentCases;
  }

  private static List<Account> mockQueryAccountName() {
    List<Account> accountRecords = new List<Account>();
    Account acc = new Account();
    acc.Id = FAKER_ACCOUNT_ID;
    acc.Name = 'Sample Name';
    accountRecords.add(acc);
    return accountRecords;
  }

  private static List<Case> mockExistingRecordsAsBlank() {
    List<Case> caserecords = new List<Case>();
    return caserecords;
  }
}
