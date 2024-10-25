/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Commercial Bill external query test class
 */
@isTest
private class CommercialBillExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "compositeAccountNumber": "4017192605-OL72362139602-0",' +
      '       "accountNumber": "OL72362139602",' +
      '       "status": "ACTIVE"' +
      '     }' +
      '   ]' +
      ' }';

    CommercialBillExternalQuery query = new CommercialBillExternalQuery();
    Test.startTest();
    query.calloutResponse = query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is null');
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = '4011643101-7234567890121234',
        FinServ__FinancialAccountNumber__c = '7234567890121234',
        Product_Type__c = 'CAP-CIS:PCA'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }
  @isTest
  static void createCommercialBillTest() {
    registerMocks();

    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createCommercialBillContext();
    CommercialBillExternalQuery query = new CommercialBillExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);
    query.calloutResponse = new CommercialBillExternalQuery.CommercialBillCalloutResponse();
    ((CommercialBillExternalQuery.CommercialBillCalloutResponse) query.calloutResponse)
      .accounts = new List<CommercialBillExternalQuery.CommercialBillModel>();
    CommercialBillExternalQuery.CommercialBillModel cBModel = new CommercialBillExternalQuery.CommercialBillModel();
    cBModel.compositeAccountNumber = '4017192605-OL72362139602-4';
    cBModel.accountNumber = 'OL72362139602';
    ((CommercialBillExternalQuery.CommercialBillCalloutResponse) query.calloutResponse)
      .accounts.add(cBModel);
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = query.createExternalRecords(
      query.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Assert.areEqual(
      'OL72362139602',
      result.externalRecords[0].get('AccountNumber'),
      'Number mismatch'
    );
  }
  /**
   * @description Create commercial bill Repayment context for API
   * @name createCBRepaymentDetailContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createCommercialBillContext() {
    Test.setMock(HttpCalloutMock.class, new CreateCommercialBillTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CommercialBill'
    );
    return context;
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class CreateCommercialBillTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_cbResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
