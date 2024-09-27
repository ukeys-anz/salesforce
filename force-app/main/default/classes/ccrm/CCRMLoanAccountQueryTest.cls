/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Loan Account external query test class
 */
@isTest
private class CCRMLoanAccountQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c createMockData(
    String accountKey,
    String accountNum,
    String accountNumFormat
  ) {
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = accId,
          Account_Key__c = accountKey,
          FinServ__FinancialAccountNumber__c = accountNum,
          Product_Type__c = 'CAP-CIS:ILS'
        ),
        new Map<String, Object>{ 'Account_Number__c' => accountNumFormat }
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }

  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "accountName": "Buck Hattie",' +
      '       "accountNumber": "503456793",' +
      '       "productCode": "ILS",' +
      '       "accountBalance": "5000000.47",' +
      '       "status": "Active"' +
      '     }' +
      '   ]' +
      ' }';

    CCRMLoanAccountQuery loanAcct = new CCRMLoanAccountQuery();
    loanAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(loanAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateFinancialAccounts() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = createMockData(
      '4011643101-503456793',
      '503456793',
      '5034-56793'
    );
    DataSource.QueryContext context = TestDataFactory.createLoanAccountSummaryContext();
    CCRMLoanAccountQuery query = new CCRMLoanAccountQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);
    query.calloutResponse = new CCRMLoanAccountQuery.LoanAccountCalloutResponse();
    ((CCRMLoanAccountQuery.LoanAccountCalloutResponse) query.calloutResponse)
      .accounts = new List<CCRMLoanAccountQuery.CCRMLoanAccountModel>();
    CCRMLoanAccountQuery.CCRMLoanAccountModel loanModel = new CCRMLoanAccountQuery.CCRMLoanAccountModel();
    loanModel.accountName = 'Buck Hattie';
    loanModel.accountNumber = '503456793';
    ((CCRMLoanAccountQuery.LoanAccountCalloutResponse) query.calloutResponse)
      .accounts.add(loanModel);
    CCRMExternalObjectQueryBase.ExternalQueryResult result = query.createFinancialAccounts();
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
  }

  @isTest
  static void createLoanAccountsSummaryTest() {
    registerMocks();
    Test.startTest();

    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = createMockData(
      '4011643101-503456793',
      '503456793',
      '5034-56793'
    );

    DataSource.QueryContext context = TestDataFactory.createLoanAccountSummaryContext();
    CCRMLoanAccountQuery loanAcct = new CCRMLoanAccountQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = loanAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
    Assert.areEqual(
      'Buck Hattie',
      result.queryResult[0].get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '5034-56793',
      result.queryResult[0].get('AccountNumber'),
      'Account number mismatch'
    );
  }

  @isTest
  static void createLoanAccountsDetailTest() {
    registerMocks();
    Test.startTest();

    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = createMockData(
      '4011643101-391102388',
      '391102388',
      '3911-02388'
    );

    DataSource.QueryContext context = TestDataFactory.createLoanAccountDetailContext();
    CCRMLoanAccountQuery loanAcct = new CCRMLoanAccountQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithAcctNum',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = loanAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
    Assert.areEqual(
      'REDDY',
      result.queryResult[0].get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '3911-02388',
      result.queryResult[0].get('AccountNumber'),
      'Account number mismatch'
    );
  }
  @isTest
  static void retrieveIndustryCodeAndDescriptionTest() {
    registerMocks();
    Test.startTest();
    Id newIndustryID = Lib_FakeIdGenerator.getMockId(
      Schema.Industry__c.getSObjectType()
    );
    Industry__c industry = new Industry__c(
      Id = newIndustryID,
      Code__c = '0111',
      Name = 'PLANT NURSERIES'
    );
    faRepoMock.mock(
      'getIndustryCodeAndDescription',
      new List<Industry__c>{ industry }
    );
    CCRMLoanAccountQuery financiaBase = new CCRMLoanAccountQuery();
    String industryValue = financiaBase.retrieveIndustryCodeAndDescription(
      '0111'
    );
    Test.stopTest();
    Assert.areEqual(
      '0111 - PLANT NURSERIES',
      industryValue,
      'retrieveIndustryCodeAndDescription is not working properly'
    );
  }
  @isTest
  static void getFinancialAccountsWhenParentIdIsNotBlankForMLUserTest() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    System.runAs(mlUser) {
      Test.startTest();
      FinServ__FinancialAccountRole__c mockFar = createMockData(
        '4011643101-503456793',
        '503456793',
        '5034-56793'
      );
      DataSource.QueryContext context = TestDataFactory.createLoanAccountSummaryContext();
      CCRMLoanAccountQuery query = new CCRMLoanAccountQuery();
      query.populateData(new List<FinServ__FinancialAccountRole__c>{ mockFar });
      query.execute(context);
      query.calloutResponse = new CCRMLoanAccountQuery.LoanAccountCalloutResponse();
      ((CCRMLoanAccountQuery.LoanAccountCalloutResponse) query.calloutResponse)
        .accounts = new List<CCRMLoanAccountQuery.CCRMLoanAccountModel>();
      CCRMLoanAccountQuery.CCRMLoanAccountModel loanModel = new CCRMLoanAccountQuery.CCRMLoanAccountModel();
      loanModel.accountName = 'Buck Hattie';
      loanModel.accountNumber = '503456793';

      ((CCRMLoanAccountQuery.LoanAccountCalloutResponse) query.calloutResponse)
        .accounts.add(loanModel);
      CCRMExternalObjectQueryBase.ExternalQueryResult result = query.createFinancialAccounts();
      Test.stopTest();
      Assert.areEqual(
        1,
        result.queryResult.size(),
        'Size of accounts is not 1'
      );
    }
  }
}
