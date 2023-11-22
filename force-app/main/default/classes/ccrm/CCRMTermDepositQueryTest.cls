/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Term Deposit external query test class
 */
@isTest
private class CCRMTermDepositQueryTest {
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
      'CAP-CIS:CDA',
      acct.Id,
      '4011643101-403456789',
      '403456789'
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
  static void createDepositAccountsTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new CCRMTermDepositTestMock());
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'TermDeposit'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = query.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of accounts is not 1'
    );
    System.assertEquals(
      'Denis Lai',
      result.queryResult[0].get('AccountName'),
      'Name mismatch'
    );
    System.assertEquals(
      'CDA',
      result.queryResult[0].get('ProductCode'),
      'Product code mismatch'
    );
    System.assertEquals(
      '4034-56789',
      result.queryResult[0].get('AccountNumber'),
      'Product code mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMTermDepositTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_termDepositResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
