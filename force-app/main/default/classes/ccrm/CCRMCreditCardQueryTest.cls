/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Credit card Account external query test class
 */
@isTest
private class CCRMCreditCardQueryTest {
  @TestSetup
  static void createTestData() {
    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Business_Account')
      .getRecordTypeId();
    Account acct = TestDataFactory.createBusinessRecordTypeAccount(
      'CAP-CIS_4011643101',
      customerRecordTypeId,
      '4011643101'
    );

    Id bankingRecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
      .get('BankingAccount')
      .getRecordTypeId();
    FinServ__FinancialAccount__c finAccount = TestDataFactory.createC360FinancialAccount(
      bankingRecordTypeId,
      'CAP-CIS:PCA',
      acct.Id,
      '4011643101-7234567890121234',
      '7234567890121234'
    );
    if (finAccount.Id != null) {
      FinServ__FinancialAccountRole__c finRole = [
        SELECT Id, FinServ__FinancialAccount__c, Role_Type__c
        FROM FinServ__FinancialAccountRole__c
        WHERE FinServ__FinancialAccount__c = :finAccount.Id
        LIMIT 1
      ];
      finRole.Role_Type__c = 'PRI';
      update finRole;
    }
  }

  @isTest
  static void createCreditCardAccountsTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMCreditCardQueryTest.CCRMCreditCardQueryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'CreditCard'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMCreditCardQuery cardAccount = new CCRMCreditCardQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = cardAccount.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of accounts is not 1'
    );
    System.assertEquals(
      'Tom Hanks',
      result.queryResult[0].get('AccountName'),
      'Name mismatch'
    );
    System.assertEquals(
      '7234-5678-9012-1234',
      result.queryResult[0].get('AccountNumber'),
      'Name mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMCreditCardQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_creditCardResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'pcb-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
