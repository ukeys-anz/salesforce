/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Other Limits And Liabilities Account external query test class
 */
@isTest
private class CCRMOtherLimitsAndLiabilitiesQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = accId,
          Account_Key__c = '4011643101-523456789',
          FinServ__FinancialAccountNumber__c = '523456789',
          Product_Type__c = 'CAP-CIS:OLL'
        ),
        new Map<String, Object>{ 'Account_Number__c' => '5234-56789' }
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }

  private static Industry__c getIndustryMockedData() {
    return new Industry__c(
      Id = Lib_FakeIdGenerator.getMockId(Industry__c.SobjectType),
      Name = 'PLANT INDUSTRIES',
      Code__c = '011'
    );
  }

  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      '{' +
      '  "accounts": [ ' +
      '    {' +
      '      "accountName": "Stephan Pedersen",' +
      '      "accountNumber": "523456789",' +
      '      "productCode": "OLL",' +
      '      "accountBalance": "50.04",' +
      '      "accountLimit": "2000",' +
      '      "status": "Active" ' +
      '    } ' +
      ' ]' +
      '}';
    CCRMOtherLimitsAndLiabilitiesQuery limitLiabQry = new CCRMOtherLimitsAndLiabilitiesQuery();
    limitLiabQry.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      limitLiabQry.calloutResponse == null,
      'Response is not null'
    );
  }

  @isTest
  static void testCreateFinancialAccounts() {
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createOLLContext();
    CCRMOtherLimitsAndLiabilitiesQuery limitLiabQry = new CCRMOtherLimitsAndLiabilitiesQuery();
    limitLiabQry.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult data = limitLiabQry.execute(
      context
    );

    limitLiabQry.calloutResponse = new CCRMOtherLimitsAndLiabilitiesQuery.CCRMOLLCalloutResponse();
    ((CCRMOtherLimitsAndLiabilitiesQuery.CCRMOLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts = new List<CCRMOtherLimitsAndLiabilitiesQuery.CCRMOtherLimitsAndLiabilitiesModel>();
    CCRMOtherLimitsAndLiabilitiesQuery.CCRMOtherLimitsAndLiabilitiesModel ollModel = new CCRMOtherLimitsAndLiabilitiesQuery.CCRMOtherLimitsAndLiabilitiesModel();
    ollModel.accountBalance = 50.04;
    ollModel.accountLimit = 2000;
    ollModel.accountName = 'Stephan Pedersen';
    ollModel.accountNumber = '523456789';
    ((CCRMOtherLimitsAndLiabilitiesQuery.CCRMOLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts.add(ollModel);
    CCRMExternalObjectQueryBase.ExternalQueryResult result = limitLiabQry.createFinancialAccounts();
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
  }

  @isTest
  static void testFormIndustryCodeAndNameMap() {
    registerMocks();
    Test.startTest();
    Map<String, String> result = new Map<String, String>();
    CCRMOtherLimitsAndLiabilitiesQuery limitLiabQry = new CCRMOtherLimitsAndLiabilitiesQuery();
    Industry__c mockIndustry = getIndustryMockedData();
    faRepoMock.mock('getIndustry', new List<Industry__c>{ mockIndustry });
    limitLiabQry.calloutResponse = new CCRMOtherLimitsAndLiabilitiesQuery.CCRMOLLCalloutResponse();
    ((CCRMOtherLimitsAndLiabilitiesQuery.CCRMOLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts = new List<CCRMOtherLimitsAndLiabilitiesQuery.CCRMOtherLimitsAndLiabilitiesModel>();
    CCRMOtherLimitsAndLiabilitiesQuery.CCRMOtherLimitsAndLiabilitiesModel ollModel = new CCRMOtherLimitsAndLiabilitiesQuery.CCRMOtherLimitsAndLiabilitiesModel();
    ollModel.accountBalance = 50.04;
    ollModel.accountLimit = 2000;
    ollModel.accountName = 'Stephan Pedersen';
    ollModel.anzsicCode = '111';
    ((CCRMOtherLimitsAndLiabilitiesQuery.CCRMOLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts.add(ollModel);
    result = limitLiabQry.formIndustryCodeAndNameMap(
      ((CCRMOtherLimitsAndLiabilitiesQuery.CCRMOLLCalloutResponse) limitLiabQry.calloutResponse)
        .accounts
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.size(),
      'Not able to form Industry code name map'
    );
  }

  @isTest
  static void testOtherLimitLiabilitiesQuery() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    Industry__c mockIndustry = getIndustryMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createOLLContext();
    CCRMOtherLimitsAndLiabilitiesQuery limitLiabQry = new CCRMOtherLimitsAndLiabilitiesQuery();

    faRepoMock.mock('getIndustry', new List<Industry__c>{ mockIndustry });
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = limitLiabQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
    Map<String, Object> firstRecord = result.queryResult[0];
    Assert.areEqual(
      'Stephan Pedersen',
      firstRecord.get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '5234-56789',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
    );
  }
}
