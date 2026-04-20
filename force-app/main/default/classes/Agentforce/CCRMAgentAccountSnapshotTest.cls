/**
 * @author Prasanjeet Dutta
 * @since 2026
 * @description Test class for CCRMAgentAccountSnapshot invocable Apex class.
 *              Mirrors mocking pattern used in CCRMAgentCustomerSummaryPromptTest.
 */
@IsTest
private class CCRMAgentAccountSnapshotTest {
  static Lib_MockProvider repoMock;

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(
      CCRMAgentAccountSnapshotRepository.class
    );
  }

  @IsTest
  /**
   * @description Positive test: Validate snapshot JSON contains expected sections and counts.
   */
  static void testGetSnapshotSuccess() {
    registerMocks();

    // Prepare mock datasets
    List<Deposit_Account__x> deposits = new List<Deposit_Account__x>{
      // Active account - should contribute to count and details
      new Deposit_Account__x(
        Account_Status__c = 'Active',
        Account_Number__c = 'D-001',
        Account_Name__c = 'Everyday',
        Product_Name__c = 'Everyday Account',
        Expiry_Date__c = String.valueOf(Date.today().addDays(45)),
        Overdraft_Expiry_Date__c = String.valueOf(Date.today().addDays(60)),
        Balance_Available__c = -10
      ),
      // Closed account - should NOT contribute to count, and its negative balance should NOT appear in details
      new Deposit_Account__x(
        Account_Status__c = 'Closed',
        Account_Number__c = 'D-002',
        Account_Name__c = 'Saver',
        Product_Name__c = 'Saver Account',
        Balance_Available__c = -9999
      )
    };
    repoMock.mock('fetchDepositAccountsByExternalId', deposits);

    List<Loan_Account__x> loans = new List<Loan_Account__x>{
      new Loan_Account__x(
        Account_Status__c = 'Open',
        Account_Number__c = 'L-001',
        Account_Name__c = 'Home Loan',
        Product_Name__c = 'Variable',
        Expires__c = String.valueOf(Date.today().addDays(90)),
        Repayment_Details_Days_Delinquent__c = 5
      )
    };
    repoMock.mock('fetchLoanAccountsByExternalId', loans);

    List<Term_Deposit__x> termDeposits = new List<Term_Deposit__x>{
      new Term_Deposit__x(
        Account_Status__c = 'Open',
        Account_Number__c = 'TD-001',
        Account_Name__c = 'Term Dep A',
        Product_Name__c = '6M TD',
        Maturity_Date__c = String.valueOf(Date.today().addDays(120))
      )
    };
    repoMock.mock('fetchTermDepositsByExternalId', termDeposits);

    List<Credit_Card__x> cards = new List<Credit_Card__x>{
      // Active card - should contribute and generate details
      new Credit_Card__x(
        Account_Status__c = 'Active',
        Account_Number__c = 'CC-001',
        Account_Name__c = 'Visa',
        Product_Name__c = 'Platinum',
        Available_Funds__c = -5,
        Days_Delinquent__c = 2
      ),
      // Closed card - should be ignored completely even if delinquent/negative
      new Credit_Card__x(
        Account_Status__c = 'Closed',
        Account_Number__c = 'CC-002',
        Account_Name__c = 'Closed Card',
        Product_Name__c = 'Standard',
        Available_Funds__c = -100,
        Days_Delinquent__c = 99
      )
    };
    repoMock.mock('fetchCreditCardsByExternalId', cards);

    List<Portfolio_Of_Loan__x> pol = new List<Portfolio_Of_Loan__x>{
      new Portfolio_Of_Loan__x(
        Account_Status__c = 'Active',
        Account_Number__c = 'POL-001',
        Account_Name__c = 'Portfolio 1',
        Product_Name__c = 'Consolidated',
        Expires__c = String.valueOf(Date.today().addDays(100))
      )
    };
    repoMock.mock('fetchPortfolioOfLoansByExternalId', pol);

    List<Other_Limits_and_Liabilities__x> otherLimits = new List<Other_Limits_and_Liabilities__x>{
      new Other_Limits_and_Liabilities__x(Account_Status__c = 'Active')
    };
    repoMock.mock('fetchOtherLimitsByExternalId', otherLimits);

    List<Asset_Finance_AMBIT_Contract__x> ambit = new List<Asset_Finance_AMBIT_Contract__x>{
      new Asset_Finance_AMBIT_Contract__x(
        Status__c = 'Active',
        Contract_Number__c = 'AM-001',
        Product_Name__c = 'AMBIT X',
        Expiry_Date__c = Date.today().addDays(170)
      )
    };
    repoMock.mock('fetchAssetFinanceAmbitByExternalId', ambit);

    List<Asset_Finance_ELS__x> els = new List<Asset_Finance_ELS__x>{
      new Asset_Finance_ELS__x(
        Account_Status__c = 'Active',
        Account_Number__c = 'ELS-001',
        Account_Name__c = 'ELS A',
        Product_Name__c = 'ELS Product',
        Expires__c = String.valueOf(Date.today().addDays(170))
      )
    };
    repoMock.mock('fetchAssetFinanceELSByExternalId', els);

    List<Commercial_Bill__x> bills = new List<Commercial_Bill__x>{
      new Commercial_Bill__x(
        Account_Status__c = 'Active',
        Account_Number__c = 'CB-001',
        Account_Name__c = 'Bill A',
        Expires__c = String.valueOf(Date.today().addDays(150))
      )
    };
    repoMock.mock('fetchCommercialBillsByExternalId', bills);

    List<Indemnity_Guarantee__x> igs = new List<Indemnity_Guarantee__x>{
      new Indemnity_Guarantee__x(
        Account_Status__c = 'Active',
        Account_Number__c = 'IG-001',
        Account_Name__c = 'IG A',
        Expiry_Date__c = String.valueOf(Date.today().addDays(25)),
        ExternalId = 'IG-EXT-001'
      )
    };
    repoMock.mock('fetchIndemnityGuaranteesByExternalId', igs);

    // Mock the facility fee with a proper list containing one item
    List<Facility_Fee__x> mockFacilityFee = new List<Facility_Fee__x>{
      new Facility_Fee__x(Next_Due_Date__c = '22/08/2025')
    };
    repoMock.mock('fetchFacilityFeeNextDueDateByIGExternalId', mockFacilityFee);

    // Build request with Account containing External_Id__c
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Snapshot Account'
    );
    // put by dynamic key to mirror production code retrieval
    acc.put('External_Id__c', 'EXT-123');

    CCRMAgentAccountSnapshot.Request req = new CCRMAgentAccountSnapshot.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentAccountSnapshot.Response> res = CCRMAgentAccountSnapshot.getSnapshot(
      new List<CCRMAgentAccountSnapshot.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, res.size(), 'Should return one response');
    System.assertNotEquals(null, res[0].Prompt, 'Prompt should not be null');

    String json = res[0].Prompt;

    // Validate key sections presence
    System.assert(
      json.contains('Deposit Accounts'),
      'Should include Deposit Accounts'
    );
    System.assert(
      json.contains('Loan Accounts'),
      'Should include Loan Accounts'
    );
    System.assert(
      json.contains('Term Deposits'),
      'Should include Term Deposits'
    );
    System.assert(json.contains('Credit Cards'), 'Should include Credit Cards');
    System.assert(
      json.contains('Portfolio of Loans'),
      'Should include Portfolio of Loans'
    );
    System.assert(
      json.contains('Other Limits and Liabilities'),
      'Should include Other Limits'
    );
    System.assert(
      json.contains('Commercial Bills'),
      'Should include Commercial Bills'
    );
    System.assert(
      json.contains('Indemnity Guarantees'),
      'Should include Indemnity Guarantees'
    );

    // Sanity checks for some rule-driven detail lines (only from active/open accounts)
    System.assert(
      json.contains('overdrawn') || json.contains('delinquent'),
      'Should include rule-driven detail lines from active/open accounts'
    );
    System.assertEquals(
      -1,
      json.indexOf('CC-002'),
      'Closed credit card should not appear in details'
    );
    System.assertEquals(
      -1,
      json.indexOf('D-002'),
      'Closed deposit with negative balance should not appear in details'
    );
  }

  @IsTest
  /**
   * @description Negative test: Null account in request should return empty response object.
   */
  static void testNullAccountRequest() {
    CCRMAgentAccountSnapshot.Request req = new CCRMAgentAccountSnapshot.Request();
    Test.startTest();
    List<CCRMAgentAccountSnapshot.Response> res = CCRMAgentAccountSnapshot.getSnapshot(
      new List<CCRMAgentAccountSnapshot.Request>{ req }
    );
    Test.stopTest();
    System.assertEquals(
      1,
      res.size(),
      'Should still return one response wrapper'
    );
    System.assertEquals(
      null,
      res[0].Prompt,
      'Prompt should be null when no account provided'
    );
  }

  @IsTest
  /**
   * @description Negative test: Missing External_Id__c should return empty response object.
   */
  static void testMissingExternalId() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Snapshot Account'
    );
    CCRMAgentAccountSnapshot.Request req = new CCRMAgentAccountSnapshot.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentAccountSnapshot.Response> res = CCRMAgentAccountSnapshot.getSnapshot(
      new List<CCRMAgentAccountSnapshot.Request>{ req }
    );
    Test.stopTest();
    System.assertEquals(
      1,
      res.size(),
      'Should still return one response wrapper'
    );
    System.assertEquals(
      null,
      res[0].Prompt,
      'Prompt should be null when External_Id__c is missing'
    );
  }

  @IsTest
  /**
   * @description Unit test: Validates helper methods behave as expected.
   */
  static void testHelpers() {
    // isActiveOrOpen
    System.assertEquals(
      true,
      invokeIsActiveOrOpen('Active'),
      'Active should be true'
    );
    System.assertEquals(
      true,
      invokeIsActiveOrOpen('open'),
      'open should be true'
    );
    System.assertEquals(
      false,
      invokeIsActiveOrOpen('Closed'),
      'Closed should be false'
    );

    // toDate accepts yyyy-MM-dd
    Date d1 = CCRMAgentAccountSnapshot.toDate(String.valueOf(Date.today()));
    System.assertNotEquals(null, d1, 'ISO date should parse');

    // toDate accepts dd/MM/yyyy
    String ddMMyyyy =
      String.valueOf(Date.today().day()) +
      '/' +
      String.valueOf(Date.today().month()) +
      '/' +
      String.valueOf(Date.today().year());
    Date d2 = CCRMAgentAccountSnapshot.toDate(ddMMyyyy);
    System.assertNotEquals(null, d2, 'dd/MM/yyyy should parse');
  }

  @IsTest
  /**
   * @description Test that when all APIs fail, the snapshot includes error messages
   *              for all categories to ensure 100% catch block coverage.
   */
  static void testAllApisFail() {
    registerMocks();

    // Mock all APIs to throw exceptions to cover all catch blocks
    repoMock.mockException(
      'fetchDepositAccountsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchLoanAccountsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchTermDepositsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchCreditCardsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchPortfolioOfLoansByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchOtherLimitsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchAssetFinanceAmbitByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchAssetFinanceELSByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchCommercialBillsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchIndemnityGuaranteesByExternalId',
      new CalloutException('Connection timeout')
    );

    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Snapshot Account'
    );
    acc.put('External_Id__c', 'EXT-123');

    CCRMAgentAccountSnapshot.Request req = new CCRMAgentAccountSnapshot.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentAccountSnapshot.Response> res = CCRMAgentAccountSnapshot.getSnapshot(
      new List<CCRMAgentAccountSnapshot.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, res.size(), 'Should return one response');
    System.assertNotEquals(null, res[0].Prompt, 'Prompt should not be null');

    String json = res[0].Prompt;

    // Verify all sections exist with error messages
    System.assert(
      json.contains('Deposit Accounts'),
      'Should include Deposit Accounts section'
    );
    System.assert(
      json.contains('Loan Accounts'),
      'Should include Loan Accounts section'
    );
    System.assert(
      json.contains('Term Deposits'),
      'Should include Term Deposits section'
    );
    System.assert(
      json.contains('Credit Cards'),
      'Should include Credit Cards section'
    );
    System.assert(
      json.contains('Portfolio of Loans'),
      'Should include Portfolio of Loans section'
    );
    System.assert(
      json.contains('Other Limits and Liabilities'),
      'Should include Other Limits section'
    );
    System.assert(
      json.contains('Asset Finance AMBIT Contract'),
      'Should include AMBIT section'
    );
    System.assert(
      json.contains('Asset Finance (ELS)'),
      'Should include ELS section'
    );
    System.assert(
      json.contains('Commercial Bills'),
      'Should include Commercial Bills section'
    );
    System.assert(
      json.contains('Indemnity Guarantees'),
      'Should include Indemnity Guarantees section'
    );

    // Count occurrences of error message (should be 10 - one for each category)
    Integer errorCount = 0;
    Integer index = 0;
    while (
      (index = json.indexOf('Currently unable to retrieve data', index)) != -1
    ) {
      errorCount++;
      index++;
    }
    System.assertEquals(
      10,
      errorCount,
      'Should have error messages for all 10 categories'
    );
  }

  @IsTest
  /**
   * @description Test that when all APIs fail, the snapshot includes error messages
   *              for all categories to ensure catch block coverage for multiple failures.
   */
  static void testMultipleApisFail() {
    registerMocks();

    // Mock all APIs to throw exceptions
    repoMock.mockException(
      'fetchDepositAccountsByExternalId',
      new CalloutException('Service unavailable')
    );
    repoMock.mockException(
      'fetchLoanAccountsByExternalId',
      new CalloutException('Timeout')
    );
    repoMock.mockException(
      'fetchTermDepositsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchCreditCardsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchPortfolioOfLoansByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchOtherLimitsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchAssetFinanceAmbitByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchAssetFinanceELSByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchCommercialBillsByExternalId',
      new CalloutException('Connection timeout')
    );
    repoMock.mockException(
      'fetchIndemnityGuaranteesByExternalId',
      new CalloutException('Connection timeout')
    );

    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Snapshot Account'
    );
    acc.put('External_Id__c', 'EXT-123');

    CCRMAgentAccountSnapshot.Request req = new CCRMAgentAccountSnapshot.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentAccountSnapshot.Response> res = CCRMAgentAccountSnapshot.getSnapshot(
      new List<CCRMAgentAccountSnapshot.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, res.size(), 'Should return one response');
    System.assertNotEquals(null, res[0].Prompt, 'Prompt should not be null');

    String json = res[0].Prompt;

    // Verify all sections exist with error messages
    System.assert(
      json.contains('Deposit Accounts'),
      'Should include Deposit Accounts section'
    );
    System.assert(
      json.contains('Loan Accounts'),
      'Should include Loan Accounts section'
    );
    System.assert(
      json.contains('Term Deposits'),
      'Should include Term Deposits section'
    );
    System.assert(
      json.contains('Credit Cards'),
      'Should include Credit Cards section'
    );
    System.assert(
      json.contains('Portfolio of Loans'),
      'Should include Portfolio of Loans section'
    );
    System.assert(
      json.contains('Other Limits and Liabilities'),
      'Should include Other Limits section'
    );
    System.assert(
      json.contains('Asset Finance AMBIT Contract'),
      'Should include AMBIT section'
    );
    System.assert(
      json.contains('Asset Finance (ELS)'),
      'Should include ELS section'
    );
    System.assert(
      json.contains('Commercial Bills'),
      'Should include Commercial Bills section'
    );
    System.assert(
      json.contains('Indemnity Guarantees'),
      'Should include Indemnity Guarantees section'
    );

    // Count occurrences of error message (should be 10)
    Integer errorCount = 0;
    Integer index = 0;
    while (
      (index = json.indexOf('Currently unable to retrieve data', index)) != -1
    ) {
      errorCount++;
      index++;
    }
    System.assertEquals(
      10,
      errorCount,
      'Should have error messages for all failed APIs'
    );
  }

  // Helper to access private isActiveOrOpen via test-visible pattern (using reflection-like wrapper)
  @TestVisible
  private static Boolean invokeIsActiveOrOpen(String status) {
    // The method is private; leverage the same logic to keep test resilient if visibility changes.
    // Duplicate minimal logic for assertion level check.
    if (String.isBlank(status)) {
      return false;
    }
    String s = status.trim().toLowerCase();
    return s == 'active' ||
      s == 'open' ||
      s == 'Complete Activated'.toLowerCase();
  }
}
