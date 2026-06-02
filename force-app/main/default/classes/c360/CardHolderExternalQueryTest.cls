/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group  Platform
 * @description CardHolder external query test class
 */
@isTest
private class CardHolderExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }
  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    Test.startTest();
    Account acc = new Account(
      External_Id__c = 'CAP-CIS_4715149920842161',
      Source_System_Name__c = 'CAP-CIS'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    faRepoMock.mock(
      'getIndustryNamesByCodes',
      new Map<String, String>{ '6220' => 'Test Industry' }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = Lib_FakeIdGenerator.getMockId(
          Account.SobjectType
        ),
        Account_Key__c = '4715149920842161-7234567890121234',
        FinServ__FinancialAccountNumber__c = '7234567890121234',
        Product_Type__c = 'CAP-CIS:PCA'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4715149920842161'
      )
    );
    Test.setMock(
      HttpCalloutMock.class,
      new CardHolderExternalQueryTest.CardHolderTestMock()
    );
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CardHolder'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CardHolderExternalQuery accountQuery = new CardHolderExternalQuery();
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
    Assert.areEqual(
      'ANZ TDM PRIVATIZED VALUE',
      firstRecord.get('CardholderName'),
      'CardholderName mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CardHolderTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_cardHolderResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
