/**
 * @author ramvilas
 * @since May 2025
 * @description Test class for {@link HomeLoanHistoryController)
 */

@isTest
public inherited sharing class HomeLoanHistoryControllerTest {
  static Lib_MockProvider caseRepoMock;
  static Lib_MockProvider homeLoanAPIRepoMock;
  static void registerMocks() {
    caseRepoMock = Lib_MockProvider.forType(LendingCaseRepository.class);
    homeLoanAPIRepoMock = Lib_MockProvider.forType(
      HomeLoanHistoryAPIRepository.class
    );
  }

  static LoanAccountChangesModel homeLoanAPIResp = LoanAccountChangesModel.parse(
    Service.getStaticResource('mock_listOfLoanAccountChanges')
  );

  @isTest
  static void testGetListOfLoanAccountChangesSuccess() {
    String ocvId = '11111231';
    String loanAccNumber = '1234';
    registerMocks();
    homeLoanAPIRepoMock.mock('getListOfLoanAccountChanges', homeLoanAPIResp);
    caseRepoMock.mock('queryCaseByChangeName', new List<Case>{ getCase });
    Test.startTest();
    LoanAccountChangesViewModel response = HomeLoanHistoryController.getListOfLoanAccountChanges(
      ocvId,
      loanAccNumber
    );

    Test.stopTest();
    Assert.isNotNull(response, 'Status code of the response should be 200');

    Assert.areEqual(
      'NCC - Update Property Use',
      response.accountHistoryList[0].changeRequest,
      'Status code of the response should be 200'
    );
  }

  @isTest
  static void testGetListOfLoanAccountChangesException() {
    String ocvId = '11111231';
    String loanAccNumber = '1234';
    registerMocks();
    homeLoanAPIRepoMock.mockException(
      'getListOfLoanAccountChanges',
      new CalloutException('Error calling out')
    );
    Test.startTest();
    try {
      LoanAccountChangesViewModel response = HomeLoanHistoryController.getListOfLoanAccountChanges(
        ocvId,
        loanAccNumber
      );
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'An AuraHandledException should be thrown.'
      );
    }
    Test.stopTest();
  }

  static Case getCase {
    get {
      Id lendingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('Lending')
        .getRecordTypeId();
      Case caseRecord = new Case();
      caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
      caseRecord.Type = 'Manage Home Loans';
      caseRecord.Sub_Type__c = 'NCC - Update Property Use';
      caseRecord.RecordTypeId = lendingRecordTypeId;
      caseRecord.Status = 'Closed - Approved';
      caseRecord.Loan_Account_Change_Number__c = 'accounts_391450876_changes_aa15100e-ce05-4c2e-bbc4-b9d1031da112';
      return caseRecord;
    }
  }
}
