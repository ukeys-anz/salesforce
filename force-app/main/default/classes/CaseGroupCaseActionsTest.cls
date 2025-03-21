/**
 * @author Kopal Goswami
 * @since 11/2024
 * @description CaseGroupCaseActionsTest is the test class to cover tests for {@link CaseGroupCaseActions.cls}
 */

@isTest
public with sharing class CaseGroupCaseActionsTest {
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
  private static void testCascadeParentFieldChangesToChildCasesPostive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryRelatedChildCasesPerParent',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );

    List<Case> childCases = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);

    Assert.isTrue(ChildCases[0].Status == 'Open', 'Child Case status is Open');
    Test.startTest();
    CaseGroupCaseActions.cascadeParentFieldChangesToChildCases(
      mockParentCaseRecord('Escalated', null)
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
  private static void testUpdateChildCaseFieldCircumstancePositive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryRelatedChildCasesPerParent',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );

    List<Case> childCases = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);

    Assert.isNull(
      ChildCases[0].Circumstance__c,
      'Child Case circumstance should be Null'
    );
    Test.startTest();
    CaseGroupCaseActions.cascadeParentFieldChangesToChildCases(
      mockParentCaseRecord('Escalated', 'Deceased Estate')
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
  private static void testValidateDuplicateParentCasePerAccountPositive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryExistingParentCasesWithIssueType',
      mockParentCaseRecord('Open', null)
    );
    List<Case> currentParentRecord = mockParentCaseRecord('Open', null);

    Test.startTest();
    CaseGroupCaseActions.validateDuplicateParentCasePerAccount(
      currentParentRecord
    );
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].hasErrors(),
      'Error should have been set: ' +
      CaseGroupCaseActions.DUPLICATE_CASEGROUP_ERROR
    );

    Assert.isTrue(
      currentParentRecord[0].getErrors()[0]
        .getMessage()
        .contains(CaseGroupCaseActions.DUPLICATE_CASEGROUP_ERROR),
      'Error message should be: ' +
      CaseGroupCaseActions.DUPLICATE_CASEGROUP_ERROR
    );
  }

  @isTest
  private static void testValidateDuplicateCaseGroupPerAccountNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryExistingParentCasesWithIssueType',
      new List<Case>()
    );
    List<Case> currentParentRecord = mockParentCaseRecord('Open', null);

    Test.startTest();
    CaseGroupCaseActions.validateDuplicateParentCasePerAccount(
      currentParentRecord
    );
    Test.stopTest();

    Assert.isFalse(
      currentParentRecord[0].hasErrors(),
      'Error should not have been set: ' +
      CaseGroupCaseActions.DUPLICATE_CASEGROUP_ERROR
    );
  }

  @isTest
  private static void testPopulateParentCaseSubjectPositive() {
    registerMocks();
    accountClosureRepoMock.mock('queryAccountName', mockQueryAccountName());
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    CaseGroupCaseActions.populateParentCaseSubject(currentParentRecord);
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].Subject ==
      'Account Closure Case Group - Sample Name',
      'Subject of the case is updated to Account Closure Case Group - Sample Name'
    );
  }

  @isTest
  private static void testAssignEscalatedCasesToQueuePositive() {
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    CaseGroupCaseActions.assignEscalatedCasesToQueue(currentParentRecord);
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].OwnerId == QueryQueue.accountClosureQueue.Id,
      'OwnerId of the case is updated to accountClosureQueue'
    );
  }

  @isTest
  private static void testValidateParentClosureIfChildCasesOpenPositive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotClosedChildCases',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );
    List<Case> currentParentRecord = mockParentCaseRecord('Closed', null);

    Test.startTest();
    CaseGroupCaseActions.validateParentClosureIfChildCasesOpen(
      currentParentRecord
    );
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].hasErrors(),
      'Error should have been set: ' +
      CaseGroupCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE
    );

    Assert.isTrue(
      currentParentRecord[0].getErrors()[0]
        .getMessage()
        .contains(CaseGroupCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE),
      'Error message should be: ' +
      CaseGroupCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE
    );
  }

  @isTest
  private static void testValidateParentClosureIfChildCasesOpenNegative() {
    registerMocks();
    accountClosureRepoMock.mock('queryNotClosedChildCases', new List<Case>());
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    CaseGroupCaseActions.validateParentClosureIfChildCasesOpen(
      currentParentRecord
    );
    Test.stopTest();

    Assert.isFalse(
      currentParentRecord[0].hasErrors(),
      'Error should have been set: ' +
      CaseGroupCaseActions.CASEGROUP_CLOSURE_ERROR_MESSAGE
    );
  }

  @isTest
  private static void testPrepareAccountIdAndTypeCaseMapPositive() {
    Test.startTest();
    Map<String, Case> accountIdAndTypeCaseMap = CaseGroupCaseActions.prepareAccountIdAndTypeCaseMap(
      mockParentCaseRecord('Escalated', null)
    );
    Test.stopTest();
    Assert.isTrue(
      accountIdAndTypeCaseMap.containsKey(
        FAKER_ACCOUNT_ID + GetHelpConstants.ACCOUNT_CLOSURE
      ),
      'Map with key accountid and case issue type is formed'
    );
  }

  private static List<Case> mockQueryChildCaseRecords(Id parentId) {
    List<Case> childcases = new List<Case>();

    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = 'Open';
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.ParentId = parentId;
    caseRecord.RecordTypeId = RTCase.accountClosure;
    caseRecord.Sub_Status__c = 'Success';

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
}
