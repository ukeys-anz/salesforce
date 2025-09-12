/**
 * @author CMOS
 * @since 08/2025
 * @description Test class for {@link IDRAccountActions}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
public with sharing class IDRAccountActionsTest {
  static Lib_MockProvider caseRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    caseRepoMock = Lib_MockProvider.forType(IDRCaseActionsRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  /**
   * @description Test positive scenario when Account record is updated and AccountActions is invoked..
   */
  @isTest
  static void testcheckEligibilityForCasePriorityUpdate() {
    registerMocks();
    Account oldAccountRecord1 = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    Account newAccountRecord1 = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_ONGOING
    );
    newAccountRecord1.Id = oldAccountRecord1.Id;

    Account oldAccountRecord2 = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_ONGOING
    );
    Account newAccountRecord2 = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    newAccountRecord2.Id = oldAccountRecord2.Id;

    Case cs1 = IDRTestDataFactory.getCaseWithAccount(
      IDRConstants.CASE_PRIORITY_STANDARD,
      newAccountRecord1
    );
    Case cs2 = IDRTestDataFactory.getCaseWithAccount(
      IDRConstants.CASE_PRIORITY_VULNERABLE,
      newAccountRecord2
    );

    caseRepoMock.mock('queryRelatedCases', new List<Case>{ cs1, cs2 });
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + cs1.Id + '","errors":[]}'
        ),
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + cs2.Id + '","errors":[]}'
        )
      }
    );

    Test.startTest();
    IDRAccountActions.checkEligibilityForCasePriorityUpdate(
      new List<Account>{ newAccountRecord1, newAccountRecord2 },
      new Map<Id, Account>{
        oldAccountRecord1.Id => oldAccountRecord1,
        oldAccountRecord2.Id => oldAccountRecord2
      }
    );
    Test.stopTest();
    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_VULNERABLE,
      ((List<Case>) dmlRepoMock.getHistory('doUpdate').getParam('records'))[0]
        .Priority,
      'Expected Case Priority to be updated to ' +
      IDRConstants.CASE_PRIORITY_VULNERABLE
    );
    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_STANDARD,
      ((List<Case>) dmlRepoMock.getHistory('doUpdate').getParam('records'))[1]
        .Priority,
      'Expected Case Priority to be updated to ' +
      IDRConstants.CASE_PRIORITY_STANDARD
    );
  }

  /**
   * @description Test negative scenario when Account record is updated but there are no records to pass to Queueable job.
   */
  @isTest
  static void testZeroFilteredRecords() {
    registerMocks();
    Account oldAccountRecord1 = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    Account newAccountRecord1 = IDRTestDataFactory.getECFAccount(
      IDRConstants.TIME_PERIOD_NOT_REQUIRED
    );
    newAccountRecord1.Id = oldAccountRecord1.Id;
    Test.startTest();
    IDRAccountActions.checkEligibilityForCasePriorityUpdate(
      new List<Account>{ newAccountRecord1 },
      new Map<Id, Account>{ oldAccountRecord1.Id => oldAccountRecord1 }
    );
    Assert.areEqual(
      0,
      Limits.getQueueableJobs(),
      'No Queueable jobs were run since the filtered criteria was not met'
    );
    Test.stopTest();
  }
}
