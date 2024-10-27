/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description CommercialBillFeeQuery external query test class
 */
@isTest
private class CommercialBillFeeExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }

  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      ' {' +
      '   "fees": [' +
      '     {' +
      '       "compositeAccountFeeId": "4017192605-OL72362139602-0",' +
      '       "name": "test"' +
      '     }' +
      '   ]' +
      ' }';

    CommercialBillFeeExternalQuery query = new CommercialBillFeeExternalQuery();
    query.calloutResponse = query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is null');
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    Id finAccountId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);

    FinServ__FinancialAccount__c mockFinAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      new FinServ__FinancialAccount__c(
        Id = finAccountId,
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = '4011643101-403456789',
        FinServ__FinancialAccountNumber__c = '403456789',
        Product_Type__c = 'CAP-CIS:CDA',
        Source_System_Status__c = 'Open',
        Source_System_Status_Display__c = 'Open'
      ),
      new Map<String, Object>{
        'Product_Code_Display__c' => 'DDA',
        'Product_Name_Display__c' => 'Monthly Interest Account',
        'Account_Number__c' => '4034-56789'
      }
    );

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = mockFinAccount,
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );

    return mockFar;
  }
  @isTest
  static void testCreateFinancialAccounts() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createCommercialBillFeeContext();
    CommercialBillFeeExternalQuery query = new CommercialBillFeeExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);

    query.calloutResponse = new CommercialBillFeeExternalQuery.FeeTableCalloutResponse();
    ((CommercialBillFeeExternalQuery.FeeTableCalloutResponse) query.calloutResponse)
      .fees = new List<CommercialBillFeeExternalQuery.FeeTableModel>();
    CommercialBillFeeExternalQuery.FeeTableModel feeModel = new CommercialBillFeeExternalQuery.FeeTableModel();
    feeModel.compositeAccountFeeId = '4017192605-OL72362139602-0';
    feeModel.name = 'Denis Lai';
    ((CommercialBillFeeExternalQuery.FeeTableCalloutResponse) query.calloutResponse)
      .fees.add(feeModel);
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
   * @description Create commercial bill fee context for API
   * @name createCommercialBillContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createCommercialBillFeeContext() {
    Test.setMock(HttpCalloutMock.class, new CommercialBillFeeTestMock());
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CommercialBillFee'
    );
    return context;
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class CommercialBillFeeTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_cbFee');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
