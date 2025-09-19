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
  private static void testLinkChildCasesWithParent() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryExistingParentCases',
      mockParentCaseRecord('Open', null)
    );
    List<Case> childCaseRecords = mockQueryChildCaseRecords(null);

    Assert.isFalse(
      childCaseRecords[0].ParentId == FAKER_PARENT_CASE_ID,
      'Child Case Parent Id should not be updated'
    );

    Test.startTest();
    AccountClosureCaseActions.linkChildCasesWithParent(childCaseRecords);
    Test.stopTest();

    Assert.isTrue(
      childCaseRecords[0].ParentId == FAKER_PARENT_CASE_ID,
      'Child Case Parent Id should be updated'
    );
  }

  @isTest
  private static void testLinkChildCasesWithoutParent() {
    registerMocks();
    accountClosureRepoMock.mock('queryExistingParentCases', new List<Case>());
    List<Case> childCaseRecords = mockQueryChildCaseRecords(null);

    Assert.isFalse(
      childCaseRecords[0].ParentId == FAKER_PARENT_CASE_ID,
      'Child Case Parent Id should not be updated'
    );

    Test.startTest();
    AccountClosureCaseActions.linkChildCasesWithParent(childCaseRecords);
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
  private static void testPopulateCaseSubjectPositive() {
    registerMocks();
    accountClosureRepoMock.mock('queryAccountName', mockQueryAccountName());
    List<Case> currentParentRecord = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    AccountClosureCaseActions.populateCaseSubject(currentParentRecord);
    Test.stopTest();

    Assert.isTrue(
      currentParentRecord[0].Subject == 'Account Closure - Sample Name',
      'Subject of the case is updated to Account Closure - Sample Name'
    );
  }

  @isTest
  private static void testHandleButtonVisibiltyFlagsPostive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryEligibleChildCasesForClosure',
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );

    accountClosureRepoMock.mock(
      'queryEligibleChildCasesForPrecheck',
      new List<Case>()
    );

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);
    Test.startTest();
    AccountClosureCaseActions.handleButtonVisibiltyFlags(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
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
  private static void testHandleButtonVisibiltyFlagsNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryEligibleChildCasesForClosure',
      new List<Case>()
    );

    accountClosureRepoMock.mock(
      'queryEligibleChildCasesForPrecheck',
      new List<Case>()
    );

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);
    Test.startTest();
    AccountClosureCaseActions.handleButtonVisibiltyFlags(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
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
  private static void testInitiatePrecheckButtonVisibilityPostive() {
    registerMocks();

    List<Case> caseRecordsUpdated = mockParentCaseRecord('Escalated', null);

    Test.startTest();
    AccountClosureCaseActions.initiatePrecheckButtonVisibility(
      mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID)
    );
    Test.stopTest();

    caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Show_Initiate_Account_Closure__c == true,
      'Show intiate pre check should be true on insertion of account closure child case records'
    );
  }

  @isTest
  private static void testCascadeParentFieldsToChildCasesPostive() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryParentCaseDetails',
      mockParentCaseRecord('Closed', null)
    );

    List<Case> childCases = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);

    Assert.isTrue(
      ChildCases[0].Status == 'Escalated',
      'Child Case status is Escalated'
    );
    Test.startTest();
    AccountClosureCaseActions.cascadeParentFieldsToChildCases(childCases);
    Test.stopTest();

    Assert.isTrue(
      childCases[0].Status == 'Closed',
      'Child Case status should be updated to Closed'
    );
  }

  @isTest
  private static void testSetParentCaseStatusAsEscalated() {
    List<Case> caseRecordsUpdated = mockParentCaseRecord(
      CaseGroupCaseConstants.OPEN_STATUS,
      null
    );
    registerMocks();
    accountClosureRepoMock.mock(
      'queryNotEscalatedParentCaseDetails',
      caseRecordsUpdated
    );

    List<Case> childCases = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);
    childCases[0].Sub_Status__c = CaseGroupCaseConstants.FAILED;
    childCases[0].Origin = 'ANZ Plus App';

    Assert.areEqual(
      ChildCases[0].Status,
      CaseGroupCaseConstants.ESCALATED_STATUS,
      'Child Case status is Escalated'
    );

    Test.startTest();
    AccountClosureCaseActions.setParentCaseStatusAsEscalated(childCases);
    Test.stopTest();

    caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.areEqual(
      caseRecordsUpdated[0].Status,
      CaseGroupCaseConstants.ESCALATED_STATUS,
      'Parent Case status should be updated to Escalated'
    );
  }

  @isTest
  private static void testSetAccountDetailsAsEmpty() {
    List<Case> childCases = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);
    List<Case> oldCase = mockQueryChildCaseRecords(FAKER_PARENT_CASE_ID);
    Map<Id, Case> oldChildCase = new Map<Id, Case>();
    oldChildCase.put(oldCase[0].Id, oldCase[0]);
    childCases[0].Status = CaseGroupCaseConstants.WITHDRAWN_STATUS;

    Test.startTest();
    AccountClosureCaseActions.setAccountDetailsAsEmpty(
      childCases,
      oldChildCase
    );
    Test.stopTest();

    Assert.isNull(
      childCases[0].FinServ__FinancialAccount__c,
      'Child Cases should be de-linked'
    );
  }

  private static List<Case> mockQueryChildCaseRecords(Id parentId) {
    List<Case> childcases = new List<Case>();

    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = 'Escalated';
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.ParentId = parentId;
    caseRecord.RecordTypeId = RTCase.accountClosure;
    caseRecord.Sub_Status__c = 'Success';
    caseRecord.FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.getSObjectType()
    );

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
    caseRecord.Type = CaseGroupCaseConstants.ACCOUNT_CLOSURE;
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
