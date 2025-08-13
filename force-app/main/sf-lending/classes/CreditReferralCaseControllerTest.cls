/**
 *
 * @author Pooja Kirtishahi
 * @since Jul 2025
 * @description Test class for {@link CreditReferralCaseController)
 */

@isTest
public with sharing class CreditReferralCaseControllerTest {
  static Lib_MockProvider caseRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
  static Id loanId = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.SObjectType
  );
  static void registerMocks() {
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
    caseRepoMock = Lib_MockProvider.forType(LendingCaseRepository.class)
      .mock('queryCaseRLAById', getCase);
  }

  @isTest
  static void testEscalateCaseToFraudSuccess() {
    registerMocks();
    dmlMockProvider.mock(
      'doUpdate',
      TestUtil.getMockSaveResult('{"success":true}')
    );
    Test.startTest();
    CreditReferralCaseController.escalateCase(caseId, 'TEST COMMENT', 'CAD');
    Test.stopTest();
    Assert.isNotNull(dmlMockProvider.getHistory('doUpdate'), 'Case is updated');
  }

  @isTest
  static void testEscalateCaseToFraudException() {
    registerMocks();
    dmlMockProvider.mockException(
      'doUpdate',
      new DmlException('Update failed!')
    );
    try {
      Test.startTest();
      CreditReferralCaseController.escalateCase(
        caseId,
        'TEST COMMENT',
        'FRAUD'
      );
      Test.stopTest();
      Assert.fail('Exception should be thrown');
    } catch (exception e) {
      Assert.isTrue(
        e instanceof AuraHandledException,
        'aura handled exception should be thrown'
      );
    }
  }

  /**
   * @description Static method to return Case Record
   */
  static Case getCase {
    get {
      return new Case(
        Id = caseId,
        Address__c = 'Test',
        Loan_Application__c = loanId
      );
    }
  }
}
