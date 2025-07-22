/**
 * @author Shivam Swaraj
 * @since 07/2025
 * @description  test class for CaseGroupCaseAutoCloseScheduler
 */
@isTest
public with sharing class CaseGroupCaseAutoCloseSchedulerTest {
  private static final String FAKER_PARENT_CASE_ID = (String) Lib_FakeIdGenerator.getMockId(
    Case.SObjectType
  );
  private static final String FAKER_CHILD_CASE_ID = (String) Lib_FakeIdGenerator.getMockId(
    Case.SObjectType
  );
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider accRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    accRepoMock = Lib_MockProvider.forType(AccountClosureRepository.class);
  }
  @isTest
  public static void testCaseGroupCaseAutoClosePositive() {
    registerMocks();
    Id parentCaseId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType());
    accRepoMock.mock(
      'queryCaseGroupCasesToClose',
      createMockAccountClosureCaseRecord(FAKER_PARENT_CASE_ID, 'Closed')
    );
    accRepoMock.mock(
      'queryNotClosedAccountClosureCases',
      createMockAccountClosureCaseRecord(parentCaseId, 'Escalated')
    );

    Test.startTest();
    CaseGroupCaseAutoCloseScheduler caseGroupSch = new CaseGroupCaseAutoCloseScheduler();
    caseGroupSch.execute(null);
    Test.stopTest();
    List<Case> closedCases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isTrue(
      closedCases[0].Status == CaseGroupCaseConstants.CLOSED_STATUS,
      'Status should be closed'
    );
  }

  @isTest
  public static void testCaseGroupCaseAutoCloseNegative() {
    registerMocks();
    accRepoMock.mock(
      'queryCaseGroupCasesToClose',
      createMockAccountClosureCaseRecord(FAKER_PARENT_CASE_ID, 'Escalated')
    );
    accRepoMock.mock(
      'queryNotClosedAccountClosureCases',
      createMockAccountClosureCaseRecord(FAKER_PARENT_CASE_ID, 'Escalated')
    );
    Test.startTest();
    CaseGroupCaseAutoCloseScheduler caseGroupSch = new CaseGroupCaseAutoCloseScheduler();
    caseGroupSch.execute(null);
    Test.stopTest();
    List<Case> notClosedCases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isTrue(
      notclosedCases.isEmpty(),
      'Status should be not be changed to closed'
    );
  }

  private static List<Case> createMockAccountClosureCaseRecord(
    Id parentId,
    String caseStatus
  ) {
    List<Case> childcases = new List<Case>();

    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = caseStatus;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.ParentId = parentId;
    caseRecord.RecordTypeId = RTCase.accountClosure;
    caseRecord.FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.getSObjectType()
    );
    childcases.add(caseRecord);
    return childcases;
  }
}
