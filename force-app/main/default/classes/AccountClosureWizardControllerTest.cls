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
  static Lib_MockProvider financialAccountControllerMock;

  static void registerMocks() {
    accountClosureRepoMock = Lib_MockProvider.forType(
      AccountClosureRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    financialAccountControllerMock = Lib_MockProvider.forType(
      FinancialAccountController.class
    );
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

    // Call the method under test
    List<Case> result = AccountClosureWizardController.createCasesForAccounts(
      FAKER_PARENT_CASE_ID,
      caseInputs
    );

    Test.stopTest();

    // Assertions
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

  // Test method for createCasesForAccounts with Empty CaseInput List (Negative Scenario)
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
    List<CaseInput> caseInputs = new List<CaseInput>(); // Empty CaseInput List

    Test.startTest();

    // Call the method under test
    List<Case> result = AccountClosureWizardController.createCasesForAccounts(
      FAKER_PARENT_CASE_ID,
      caseInputs
    );

    Test.stopTest();

    // Assertions
    Assert.isTrue(
      result.isEmpty(),
      'Expected an empty result list for empty CaseInput'
    );
  }

  @isTest
  static void testGetFilteredFinancialAccounts() {
    String ocvId = 'ocv12345';
    List<String> accountNumbers = new List<String>{ '000000000', '111111111' };

    Test.startTest();

    // Call the method under test
    List<FinancialAccountsResponse> response = AccountClosureWizardController.getFilteredFinancialAccounts(
      ocvId,
      accountNumbers
    );

    Test.stopTest();
  }

  @isTest
  static void testPrepareFinancialAccountsResponse() {
    registerMocks();
    financialAccountControllerMock.mock(
      'getFinancialAccountFabric',
      mockGetFinancialAccountFabric()
    );
    accountClosureRepoMock.mock('fetchChildCases', mockListOfCases());
    accountClosureRepoMock.mock(
      'fetchFinancialAccounts',
      mockFetchFinancialAccounts()
    );

    List<FinServ__FinancialAccount__c> fabricAccounts = mockGetFinancialAccountFabric();
    Map<Id, FinServ__FinancialAccount__c> dbAccounts = mockFetchFinancialAccounts();

    Test.startTest();

    // Call the method under test
    List<FinancialAccountsResponse> response = AccountClosureWizardControllerHelper.prepareFinancialAccountsResponse(
      fabricAccounts,
      dbAccounts
    );
    System.debug('response ' + response);
    Test.stopTest();
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

  // Helper method to create a mock CaseInput
  private static List<CaseInput> createCaseInputs() {
    List<CaseInput> caseInputs = new List<CaseInput>();

    // Assuming CaseInput has a constructor or setters for these fields
    CaseInput caseInput = new CaseInput();
    caseInput.intendedAccountName = 'hrkeg';
    caseInput.intendedAccountBsb = 'asd';
    caseInput.intendedAccountNumber = '345';
    caseInput.closureReason = 'Bank Initiated Closure - Collections';
    caseInput.accountId = FAKER_ACCOUNT_ID;
    caseInput.accountType = 'Individual';
    caseInput.productName = 'Business One';
    caseInput.finiancialAccountId = 'a0FAD00000229qr2AA';
    caseInput.productId = '01t2P000000GKT0QAO';

    // Add to the list
    caseInputs.add(caseInput);

    return caseInputs;
  }

  private static List<FinServ__FinancialAccount__c> mockGetFinancialAccountFabric() {
    List<FinServ__FinancialAccount__c> accounts = new List<FinServ__FinancialAccount__c>();

    // Mocking the first account as per expected data
    accounts.add(
      new FinServ__FinancialAccount__c(
        Id = 'a0FAD000002THXN2A4',
        FinServ__FinancialAccountNumber__c = '111111111',
        FinServ__Balance__c = 1.99,
        FinServ__CurrentPostedBalance__c = 1.99,
        BSB__c = '014111',
        FinServ__OpenDate__c = Date.newInstance(2016, 9, 21),
        FinServ__CloseDate__c = null,
        FinServ__Status__c = 'Active',
        Marketing_Code__c = 'SAVING01',
        FinServ__Ownership__c = 'Single'
      )
    );

    return accounts;
  }

  // Mock fetchFinancialAccounts method
  private static Map<Id, FinServ__FinancialAccount__c> mockFetchFinancialAccounts() {
    Map<Id, FinServ__FinancialAccount__c> accountMap = new Map<Id, FinServ__FinancialAccount__c>();

    // Mock data based on your expected output
    accountMap.put(
      'a0FAD000002THXN2A4',
      new FinServ__FinancialAccount__c(
        Id = 'a0FAD000002THXN2A4',
        FinServ__FinancialAccountNumber__c = '000000000',
        FinServ__ProductName__c = '01t2P000000GKT0QAO', // Product Id
        FinServ__Balance__c = 18.9912,
        FinServ__Ownership__c = 'Individual',
        Marketing_Code__c = 'TRANSACT01',
        FinServ__Status__c = 'Active',
        RecordTypeId = '0125m0000004HmBAAU' // Example RecordTypeId
      )
    );
    return accountMap;
  }
}
