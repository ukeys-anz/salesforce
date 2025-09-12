/**
 * @author CMOS
 * @since 08/2025
 * @description Test class for {@link IDRCasePriorityUpdateQueueable}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
public with sharing class IDRCasePriorityUpdateQueueableTest {
  static Lib_MockProvider caseRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    caseRepoMock = Lib_MockProvider.forType(IDRCaseActionsRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  /**
   * @description Test positive scenario when Account record is updated with ExtraCare flag. Case Priority should be updated to 'Customer experiencing vulnerability'
   */
  @isTest
  static void testExecuteCaseUpdateVulnerable() {
    registerMocks();
    Account acc = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_ONGOING
    );
    Case cs = IDRTestDataFactory.getCaseWithAccount(
      IDRConstants.CASE_PRIORITY_STANDARD,
      acc
    );
    caseRepoMock.mock('queryRelatedCases', new List<Case>{ cs });
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + cs.Id + '","errors":[]}'
        )
      }
    );
    Test.startTest();
    IDRCasePriorityUpdateQueueable q = new IDRCasePriorityUpdateQueueable(
      new Set<Id>{ acc.Id }
    );
    q.execute(null);
    Test.stopTest();
    List<Case> lUpdatedCases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_VULNERABLE,
      lUpdatedCases[0].Priority,
      'Case record priority field is not updated to ' +
      IDRConstants.CASE_PRIORITY_VULNERABLE
    );
  }

  /**
   * @description Test positive scenario when Account record is updated with ExtraCare flag. Case Priority should be updated to IDRConstants.CASE_PRIORITY_STANDARD.
   */
  @isTest
  static void testExecuteCaseUpdateStandard() {
    registerMocks();
    Account acc = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    Case cs = IDRTestDataFactory.getCaseWithAccount(
      IDRConstants.CASE_PRIORITY_VULNERABLE,
      acc
    );
    caseRepoMock.mock('queryRelatedCases', new List<Case>{ cs });
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + cs.Id + '","errors":[]}'
        )
      }
    );
    Test.startTest();
    IDRCasePriorityUpdateQueueable q = new IDRCasePriorityUpdateQueueable(
      new Set<Id>{ acc.Id }
    );
    q.execute(null);
    Test.stopTest();
    List<Case> lUpdatedCases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_STANDARD,
      lUpdatedCases[0].Priority,
      'Case record priority field is not updated to ' +
      IDRConstants.CASE_PRIORITY_STANDARD
    );
  }

  /**
   * @description Test negative scenario when Account record is updated with ExtraCare flag but Case update failed with validation error
   */
  @isTest
  static void testExecuteCaseUpdateError() {
    registerMocks();
    Account acc = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    Case cs = IDRTestDataFactory.getCaseWithAccount(
      IDRConstants.CASE_PRIORITY_STANDARD,
      acc
    );
    caseRepoMock.mock('queryRelatedCases', new List<Case>{ cs });
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{ TestUtil.getMockSaveResult('{}') }
    );

    Test.startTest();
    IDRCasePriorityUpdateQueueable q = new IDRCasePriorityUpdateQueueable(
      new Set<Id>{ acc.Id }
    );
    q.execute(null);
    Test.stopTest();
    List<Case> lUpdatedCases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(0, lUpdatedCases.size(), 'No records should be updated');
  }

  /**
   * @description Test positive scenario of updateComplaintsPriority method when Account record is updated with ExtraCare flag.
   */
  @isTest
  static void testupdateComplaintsPriorityPositive() {
    Account acc = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    Case cs = IDRTestDataFactory.getCaseWithAccount(
      IDRConstants.CASE_PRIORITY_VULNERABLE,
      acc
    );
    List<Case> cases;
    Test.startTest();
    cases = new IDRCasePriorityUpdateQueueable(new Set<Id>{ acc.Id })
      .updateComplaintsPriority(new List<Case>{ cs });
    Test.stopTest();
    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_STANDARD,
      cases[0].Priority,
      'Case record priority field is not updated to ' +
      IDRConstants.CASE_PRIORITY_STANDARD
    );
  }

  /**
   * @description Test negative scenario of updateComplaintsPriority method when Account record is updated with ExtraCare flag.
   */
  @isTest
  static void testupdateComplaintsPriorityNegative() {
    Account acc = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    Case cs = IDRTestDataFactory.getCaseWithAccount(
      IDRConstants.CASE_PRIORITY_STANDARD,
      acc
    );
    List<Case> cases;
    Test.startTest();
    cases = new IDRCasePriorityUpdateQueueable(new Set<Id>{ acc.Id })
      .updateComplaintsPriority(new List<Case>{ cs });
    Test.stopTest();
    Assert.areEqual(0, cases.size(), 'Expected No case record to be updated');
  }
}
