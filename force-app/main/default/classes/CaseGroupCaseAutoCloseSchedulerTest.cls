/**
 * @author Shivam Swaraj
 * @since 07/2025
 * @description  test class for CaseGroupCaseAutoCloseScheduler
 */
@isTest
public with sharing class CaseGroupCaseAutoCloseSchedulerTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider accRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    accRepoMock = Lib_MockProvider.forType(AccountClosureRepository.class);
  }
  @isTest
  public static void testCaseGroupCaseAutoClosePositive() {
    registerMocks();
    Id parentCaseRecordId = Lib_FakeIdGenerator.getMockId(
      Case.getSObjectType()
    );
    Id parentCaseId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType());
    accRepoMock.mock(
      'queryCaseGroupCasesToClose',
      createMockAccountClosureCaseRecord(parentCaseRecordId, 'Closed')
    );
    accRepoMock.mock(
      'queryCaseGroupCasesWithChild',
      createMockCaseGroupRecord(parentCaseId, 'Escalated', new List<Case>())
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
    Id parentCaseRecordId = Lib_FakeIdGenerator.getMockId(
      Case.getSObjectType()
    );
    accRepoMock.mock(
      'queryCaseGroupCasesToClose',
      createMockAccountClosureCaseRecord(parentCaseRecordId, 'Closed')
    );
    accRepoMock.mock(
      'queryCaseGroupCasesWithChild',
      createMockCaseGroupRecord(
        parentCaseRecordId,
        'Escalated',
        createMockAccountClosureCaseRecord(parentCaseRecordId, 'Escalated')
      )
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
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord.AccountId = Lib_FakeIdGenerator.getMockId(
      Account.getSObjectType()
    );
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

  private static List<Case> createMockCaseGroupRecord(
    Id parentId,
    String caseStatus,
    List<Case> childCases
  ) {
    List<Case> parentCases = new List<Case>();
    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        Id = parentId,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Status = caseStatus,
        OwnerId = UserInfo.getUserId(),
        RecordTypeId = RTCase.caseGroup,
        FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.getSObjectType()
        )
      ),
      new Map<String, Object>{ 'Cases' => childCases }
    );
    parentCases.add(caseRecord);
    return parentCases;
  }
}
