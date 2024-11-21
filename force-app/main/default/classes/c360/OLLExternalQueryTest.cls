/**
 * @author Ayushi Gupta
 * @since  09/2024
 * @group Platform
 * @description OLL external query test class
 */
@isTest
private class OLLExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
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
    OtherLimitsAndLiabilitiesExternalQuery limitLiabQry = new OtherLimitsAndLiabilitiesExternalQuery();
    limitLiabQry.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      limitLiabQry.calloutResponse == null,
      'Response is not null'
    );
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    Test.startTest();
    OtherLimitsAndLiabilitiesExternalQuery limitLiabQry = new OtherLimitsAndLiabilitiesExternalQuery();
    limitLiabQry.parseResponse('');
    Test.stopTest();
    Assert.isTrue(limitLiabQry.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createOLLQueryContext();
    OtherLimitsAndLiabilitiesExternalQuery limitLiabQry = new OtherLimitsAndLiabilitiesExternalQuery();
    limitLiabQry.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    limitLiabQry.execute(context);

    limitLiabQry.calloutResponse = new OtherLimitsAndLiabilitiesExternalQuery.OLLCalloutResponse();
    ((OtherLimitsAndLiabilitiesExternalQuery.OLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts = new List<OtherLimitsAndLiabilitiesExternalQuery.OtherLimitsAndLiabilitiesModel>();
    OtherLimitsAndLiabilitiesExternalQuery.OtherLimitsAndLiabilitiesModel ollModel = new OtherLimitsAndLiabilitiesExternalQuery.OtherLimitsAndLiabilitiesModel();
    ollModel.accountBalance = 50.04;
    ollModel.accountLimit = 2000;
    ollModel.accountName = 'Stephan Pedersen';
    ollModel.accountNumber = '523456789';
    ((OtherLimitsAndLiabilitiesExternalQuery.OLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts.add(ollModel);
    ((FinancialAccountQueryBase.FinancialAccountCalloutResponse) limitLiabQry.calloutResponse)
      .customerId = 'CAP-CIS_4011643101';
    ExternalObjectQueryBase.ExternalQueryResult result = limitLiabQry.createExternalRecords(
      limitLiabQry.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
  }

  @isTest
  static void testFormIndustryCodeAndNameMap() {
    registerMocks();
    Test.startTest();
    Map<String, String> industryCodeNameMap = new Map<String, String>();
    Industry__c mockIndustry = getIndustryMockedData();
    faRepoMock.mock('getIndustry', new List<Industry__c>{ mockIndustry });
    OtherLimitsAndLiabilitiesExternalQuery limitLiabQry = new OtherLimitsAndLiabilitiesExternalQuery();
    limitLiabQry.calloutResponse = new OtherLimitsAndLiabilitiesExternalQuery.OLLCalloutResponse();
    ((OtherLimitsAndLiabilitiesExternalQuery.OLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts = new List<OtherLimitsAndLiabilitiesExternalQuery.OtherLimitsAndLiabilitiesModel>();
    OtherLimitsAndLiabilitiesExternalQuery.OtherLimitsAndLiabilitiesModel ollModel = new OtherLimitsAndLiabilitiesExternalQuery.OtherLimitsAndLiabilitiesModel();
    ollModel.accountBalance = 50.04;
    ollModel.accountLimit = 2000;
    ollModel.accountName = 'Stephan Pedersen';
    ollModel.anzsicCode = '111';
    ((OtherLimitsAndLiabilitiesExternalQuery.OLLCalloutResponse) limitLiabQry.calloutResponse)
      .accounts.add(ollModel);
    industryCodeNameMap = limitLiabQry.formIndustryCodeAndNameMap(
      ((OtherLimitsAndLiabilitiesExternalQuery.OLLCalloutResponse) limitLiabQry.calloutResponse)
        .accounts
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      industryCodeNameMap.size(),
      'Not able to form Industry code name map'
    );
  }

  //Integration test
  @isTest
  static void testOtherLimitLiabilitiesQuery() {
    registerMocks();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    Industry__c mockIndustry = getIndustryMockedData();
    DataSource.QueryContext context = createOLLQueryContext();
    OtherLimitsAndLiabilitiesExternalQuery limitLiabQry = new OtherLimitsAndLiabilitiesExternalQuery();

    faRepoMock.mock('getIndustry', new List<Industry__c>{ mockIndustry });
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = limitLiabQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
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

  /**
   * @description create OLL Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createOLLQueryContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new OtherLimitsAndLiabilitiesTestMock()
    );
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'OtherLimitsAndLiabilities'
    );
    return context;
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class OtherLimitsAndLiabilitiesTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_OLLResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'other-limit-liablity');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
