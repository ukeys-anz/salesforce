/**
 * @author Nilesh Kalal
 * @since 01/2025
 * @description AccountClosureWizardControllerTest is the test class to cover tests for {@link AccountClosureWizardController.cls}
 */
@isTest
public with sharing class AccountClosureWizardControllerTest {
  private static User thisUser = [
    SELECT Id
    FROM User
    WHERE Id = :UserInfo.getUserId()
  ];
  @testSetup
  static void setup() {
    System.runAs(thisUser) {
      TestUtil.addAccountsGoalsPs();
    }
  }
  private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
  private static final Id FAKER_FIN_ACC_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  static Lib_MockProvider accountClosureRepoMock;
  static Lib_MockProvider finAccRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    accountClosureRepoMock = Lib_MockProvider.forType(
      AccountClosureRepository.class
    );
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  private static void testCreateChildCasesForFinAccounts() {
    registerMocks();
    accountClosureRepoMock.mock(
      'getUnusedChildCasesByParentId',
      mockListOfCases()
    );
    accountClosureRepoMock.mock(
      'getInsertedOrUpdatedCaseDetails',
      mockListOfCases()
    );

    List<CaseInputWrapper> caseInputs = createCaseInputs();
    Test.startTest();

    List<Case> result = AccountClosureWizardController.createChildCasesForFinAccounts(
      FAKER_PARENT_CASE_ID,
      caseInputs
    );

    Test.stopTest();
    Assert.isFalse(result == null, 'Expected result to be non-null');
    Assert.isFalse(result.isEmpty(), 'Expected case to be updated');
    Assert.isTrue(
      result[0].Status == 'New',
      'Expected case status to be "New"'
    );
  }

  @isTest
  static void tesCreateChildCasesForFinAccountsWithEmptyInput() {
    registerMocks();
    accountClosureRepoMock.mock(
      'getUnusedChildCasesByParentId',
      mockListOfCases()
    );
    accountClosureRepoMock.mock(
      'getInsertedOrUpdatedCaseDetails',
      mockListOfCases()
    );
    List<CaseInputWrapper> caseInputs = new List<CaseInputWrapper>();

    Test.startTest();

    List<Case> result = AccountClosureWizardController.createChildCasesForFinAccounts(
      FAKER_PARENT_CASE_ID,
      caseInputs
    );
    Test.stopTest();
    Assert.isTrue(
      result.isEmpty(),
      'Expected an empty result list for empty CaseInputWrapper'
    );
  }
  @isTest
  public static void testGetFilteredFinancialAccountsPositive() {
    System.runAs(thisUser) {
      registerMocks();
      finAccRepoMock.mock('getFinAccountList', mockFinancialAccounts());

      finAccRepoMock.mock(
        'fetchFinancialAccountUIConfigInfo',
        mockfinAccountUiConfig()
      );

      accountClosureRepoMock.mock(
        'getCasesByFinancialAccountIds',
        new List<Case>()
      );

      accountClosureRepoMock.mock(
        'fetchFilteredFinancialAccountsDetails',
        mockFinancialAccounts()
      );

      Test.startTest();
      List<FinServ__FinancialAccount__c> response = AccountClosureWizardController.getFilteredFinancialAccounts(
        '12345'
      );
      Test.stopTest();

      Assert.areEqual(
        response[0].Id,
        FAKER_FIN_ACC_ID,
        'Financial account id should be same'
      );
    }
  }

  @isTest
  public static void testGetFinancialAccountIdsFromFabricResponseNegative() {
    System.runAs(thisUser) {
      registerMocks();
      finAccRepoMock.mock(
        'getFinAccountList',
        new List<FinServ__FinancialAccount__c>()
      );

      finAccRepoMock.mock(
        'fetchFinancialAccountUIConfigInfo',
        mockfinAccountUiConfig()
      );

      Test.startTest();
      Map<String, Object> groupedFinAccounts = FinancialAccountController.getFinancialAccountFabric(
        '12345',
        new List<String>()
      );
      Set<Id> finAccountId = AccountClosureWizardController.getFinancialAccountIdsFromFabricResponse(
        groupedFinAccounts
      );
      Test.stopTest();

      Assert.areEqual(
        finAccountId.size(),
        0,
        'Financial account record Id should not be stored from the grouped financial accounts'
      );
    }
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

  private static List<CaseInputWrapper> createCaseInputs() {
    List<CaseInputWrapper> caseInputs = new List<CaseInputWrapper>();
    CaseInputWrapper caseInput = new CaseInputWrapper();
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
        Id = FAKER_FIN_ACC_ID,
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

  private static List<FinancialAccountUIConfiguration__mdt> mockfinAccountUiConfig() {
    List<FinancialAccountUIConfiguration__mdt> mockMetaData = new List<FinancialAccountUIConfiguration__mdt>();
    FinancialAccountUIConfiguration__mdt dummyRecord1 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'HOMELOAN1',
      Account_Type__c = 'Loan',
      Balance_Title__c = 'Loan Balance',
      Section_Header_Title__c = 'Loan',
      Sort_Order__c = 1,
      Ownership_Type__c = 'Single',
      Show_Goals__c = false
    );
    mockMetaData.add(dummyRecord1);

    FinancialAccountUIConfiguration__mdt dummyRecord2 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'SAVING01',
      Account_Type__c = 'Savings',
      Balance_Title__c = 'Total Saved',
      Section_Header_Title__c = 'Savings',
      Sort_Order__c = 2,
      Ownership_Type__c = 'Single',
      Show_Goals__c = true
    );
    mockMetaData.add(dummyRecord2);

    return mockMetaData;
  }
}
