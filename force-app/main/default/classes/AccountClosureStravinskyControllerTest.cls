/**
 * @author Kopal Goswami
 * @since Jan 2025
 * @description Test class for AccountClosureStravinskyController
 */
@isTest
public with sharing class AccountClosureStravinskyControllerTest {
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
  private static void testGetPackageClosureAuraSuccess() {
    registerMocks();
    accountClosureRepoMock.mock('queryCaseDetails', mockQueryCaseDetails());

    Test.startTest();
    GenesisPackageClosureModel response = AccountClosureStravinskyController.getPackageClosureAura(
      FAKER_CHILD_CASE_ID
    );
    Test.stopTest();

    Assert.areEqual(
      null,
      response.errorinfo,
      'No ErrorInfo Present in Response'
    );
  }

  @isTest
  private static void testUpdateCaseStatusSuccess() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryCaseToUpdateStatusAsClosed',
      mockQueryCaseToUpdateStatusAsClosed()
    );
    List<Id> records = new List<Id>{ FAKER_CHILD_CASE_ID };

    List<Case> childCaseRecords = mockQueryCaseToUpdateStatusAsClosed();

    Assert.isTrue(
      childCaseRecords[0].Status == 'Escalated',
      'Child case status is Escalated'
    );

    Test.startTest();
    AccountClosureStravinskyController.updateCaseStatus(records);
    Test.stopTest();

    List<Case> caseRecordsUpdated = (List<Case>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.isTrue(
      caseRecordsUpdated[0].Status == 'Closed',
      'Child case status is Updated to Closed'
    );
  }

  @isTest
  private static void testUpdateCaseStatusNegative() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryCaseToUpdateStatusAsClosed',
      mockQueryCaseToUpdateStatusAsClosed()
    );

    List<Id> records = new List<Id>();

    Test.startTest();
    AccountClosureStravinskyController.updateCaseStatus(records);
    Test.stopTest();

    Assert.isNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should not have been invoked'
    );
  }

  @isTest
  private static void testSetStatusToClosedSuccess() {
    List<Case> caseRecords = mockQueryCaseToUpdateStatusAsClosed();

    Assert.isTrue(
      caseRecords[0].Status == 'Escalated',
      'Child case status is Escalated'
    );

    Test.startTest();
    AccountClosureStravinskyController.setStatusToClosed(caseRecords);
    Test.stopTest();

    Assert.isTrue(
      caseRecords[0].Status == 'Closed',
      'Child case status is set to Closed'
    );
  }

  @isTest
  private static void testSetStatusToClosedNegative() {
    List<Case> caseRecords = mockQueryCaseToUpdateStatusAsClosed();
    List<Case> records = new List<Case>();
    Test.startTest();
    AccountClosureStravinskyController.setStatusToClosed(records);
    Test.stopTest();

    Assert.isFalse(
      caseRecords[0].Status == 'Closed',
      'Child case status is set to Closed'
    );
  }

  private static List<Case> mockQueryCaseToUpdateStatusAsClosed() {
    List<Case> childcases = new List<Case>();
    childcases.add(mockQueryCaseDetails());
    return childcases;
  }

  private static Case mockQueryCaseDetails() {
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CHILD_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = GetHelpConstants.ESCALATED_STATUS;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.ParentId = FAKER_PARENT_CASE_ID;
    caseRecord.RecordTypeId = RTCase.accountClosure;
    caseRecord.Sub_Status__c = GetHelpConstants.SUCCESS;
    caseRecord.FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.getSObjectType()
    );
    caseRecord.ProductId = Lib_FakeIdGenerator.getMockId(
      Product2.getSObjectType()
    );

    return caseRecord;
  }
}
