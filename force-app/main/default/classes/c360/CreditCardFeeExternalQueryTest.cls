/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group Platform
 * @description Test class of CreditCardFeeExternalQuery
 */
@isTest
private class CreditCardFeeExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }
  private static FinServ__FinancialAccountRole__c getMockedData() {
    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = Lib_FakeIdGenerator.getMockId(
            Account.SobjectType
          ),
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

  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    Account acc = new Account(
      External_Id__c = 'CAP-CIS_4011643101',
      Source_System_Name__c = 'CAP-CIS'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    faRepoMock.mock(
      'getIndustryNamesByCodes',
      new Map<String, String>{ '6220' => 'Test Industry' }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    Test.setMock(
      HttpCalloutMock.class,
      new CreditCardFeeExternalQueryTest.CreditCardFeeTestMock()
    );
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CreditCardFee'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CreditCardFeeExternalQuery accountQuery = new CreditCardFeeExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(15, firstRecord.get('FeeAmount'), 'FeeAmount mismatch');
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CreditCardFeeTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_creditCardFeeResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
