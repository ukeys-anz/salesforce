/**
 * @author Nilesh Kalal
 * @since 01/2025
 * @description AccountClosureWizardControllerTest is the test class to cover tests for {@link AccountClosureWizardController.cls}
 */
@isTest
public with sharing class AccountClosureWizardControllerTest {
  private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
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
  private static void testCreateCasesForAccounts() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryListOfExistingDummyCases',
      mockListOfCases()
    );
    accountClosureRepoMock.mock(
      'queryListOfInsertedOrUpdatedCases',
      mockListOfCases()
    );

    List<CaseInput> caseInputs = createCaseInputs();
    Test.startTest();

    List<Case> result = AccountClosureWizardController.createCasesForAccounts(
      FAKER_PARENT_CASE_ID,
      caseInputs
    );

    Test.stopTest();
    Assert.isFalse(result == null, 'Expected result to be non-null');
    Assert.isFalse(
      result.isEmpty(),
      'Expected at least one case to be created/updated'
    );
    Assert.isTrue(
      result[0].Status == 'New',
      'Expected case status to be "New"'
    );
  }

  @isTest
  static void testCreateCasesForAccountsWithEmptyInput() {
    registerMocks();
    accountClosureRepoMock.mock(
      'queryListOfExistingDummyCases',
      mockListOfCases()
    );
    accountClosureRepoMock.mock(
      'queryListOfInsertedOrUpdatedCases',
      mockListOfCases()
    );
    List<CaseInput> caseInputs = new List<CaseInput>();

    Test.startTest();

    List<Case> result = AccountClosureWizardController.createCasesForAccounts(
      FAKER_PARENT_CASE_ID,
      caseInputs
    );
    Test.stopTest();
    Assert.isTrue(
      result.isEmpty(),
      'Expected an empty result list for empty CaseInput'
    );
  }

  @isTest
  static void testPrepareFinancialAccountsResponse() {
    List<FinServ__FinancialAccount__c> listOfFinAccounts = mockFinancialAccounts();
    Test.startTest();

    List<FinancialAccountsResponse> response = AccountClosureWizardControllerHelper.prepareFinancialAccountsResponse(
      listOfFinAccounts
    );
    Test.stopTest();
    System.assert(!response.isEmpty(), 'Response should not be empty');
    Assert.isTrue(
      response[0].accountNumber == '111111111',
      'Account Number should be "111111111"'
    );
  }

  private static List<Case> mockListOfCases() {
    List<Case> listOfExistingCases = new List<Case>();
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_PARENT_CASE_ID;
    caseRecord.AccountId = FAKER_ACCOUNT_ID;
    caseRecord.Status = 'New';
    caseRecord.RecordTypeId = RTCase.accountClosure;
    caseRecord.OwnerId = UserInfo.getUserId();
    caseRecord.FinServ__FinancialAccount__c = 'a0FAD000002THXN2A4';
    listOfExistingCases.add(caseRecord);
    return listOfExistingCases;
  }

  private static List<CaseInput> createCaseInputs() {
    List<CaseInput> caseInputs = new List<CaseInput>();
    CaseInput caseInput = new CaseInput();
    caseInput.intendedAccountName = 'hrkeg';
    caseInput.intendedAccountBsb = 'asd';
    caseInput.intendedAccountNumber = '345';
    caseInput.closureReason = 'Bank Initiated Closure - Collections';
    caseInput.accountId = FAKER_ACCOUNT_ID;
    caseInput.accountType = 'Individual';
    caseInput.productName = 'Business One';
    caseInput.financialAccountId = 'a0FAD00000229qr2AA';
    caseInput.productId = '01t2P000000GKT0QAO';
    caseInputs.add(caseInput);

    return caseInputs;
  }

  private static List<FinServ__FinancialAccount__c> mockFinancialAccounts() {
    List<FinServ__FinancialAccount__c> accounts = new List<FinServ__FinancialAccount__c>();
    accounts.add(
      new FinServ__FinancialAccount__c(
        Id = 'a0FAD000002THXN2A4',
        FinServ__FinancialAccountNumber__c = '111111111',
        FinServ__Balance__c = 1.99,
        FinServ__CurrentPostedBalance__c = 1.99,
        BSB__c = '014111',
        FinServ__ProductName__c = '01t2P000000GKT7QAO',
        FinServ__OpenDate__c = Date.newInstance(2016, 9, 21),
        FinServ__CloseDate__c = null,
        FinServ__Status__c = 'Active',
        Marketing_Code__c = 'SAVING01',
        FinServ__Ownership__c = 'Single'
      )
    );
    return accounts;
  }
}
