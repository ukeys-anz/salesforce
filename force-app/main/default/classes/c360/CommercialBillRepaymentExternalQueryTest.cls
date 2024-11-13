/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of CommercialBillRepaymentExternalQuery
 */
@isTest
private class CommercialBillRepaymentExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "repayments": [' +
      '     {' +
      '       "compositeAccountRepaymentId": "4017192605-OL72362139602-0",' +
      '       "scheduledBillReductionAmount": "25000.000",' +
      '   	  "scheduledStartDate": "2019-01-23T00:00:00",' +
      '   	  "scheduledEndDate": "2019-01-23T00:00:00"' +
      '     }' +
      '   ]' +
      ' }';
    Test.startTest();
    CommercialBillRepaymentExternalQuery query = new CommercialBillRepaymentExternalQuery();
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
  static void testCreateFinancialAccounts() {
    registerMocks();

    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createCBRepaymentDetailContext();
    CommercialBillRepaymentExternalQuery query = new CommercialBillRepaymentExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);

    query.calloutResponse = new CommercialBillRepaymentExternalQuery.RepaymentDetailCalloutResponse();
    ((CommercialBillRepaymentExternalQuery.RepaymentDetailCalloutResponse) query.calloutResponse)
      .repayments = new List<CommercialBillRepaymentExternalQuery.RepaymentDetailModel>();
    CommercialBillRepaymentExternalQuery.RepaymentDetailModel repayModel = new CommercialBillRepaymentExternalQuery.RepaymentDetailModel();
    repayModel.compositeAccountRepaymentId = '4017192605-OL72362139602-4';
    repayModel.scheduledBillReductionAmount = 25000.000;
    ((CommercialBillRepaymentExternalQuery.RepaymentDetailCalloutResponse) query.calloutResponse)
      .repayments.add(repayModel);
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
  }

  /**
   * @description Create commercial bill Repayment context for API
   * @name createCBRepaymentDetailContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createCBRepaymentDetailContext() {
    Test.setMock(HttpCalloutMock.class, new CreateCBRepaymentDetailTestMock());
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CommercialBillRepaymentDetail'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CreateCBRepaymentDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_cbRepayment');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
