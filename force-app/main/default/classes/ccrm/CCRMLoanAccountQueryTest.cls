/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Loan Account external query test class
 */
@isTest
private class CCRMLoanAccountQueryTest {
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
      'CAP-CIS:ILS',
      acct.Id,
      '4011643101-503456793',
      '503456793'
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
  static void createLoanAccountsTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMLoanAccountQueryTest.CCRMLoanAccountTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'LoanAccount'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMLoanAccountQuery loanAcct = new CCRMLoanAccountQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = loanAcct.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      result.queryResult.size(),
      1,
      'Size of accounts is not 1'
    );
    System.assertEquals(
      'Buck Hattie',
      result.queryResult[0].get('AccountName'),
      'Name mismatch'
    );
    System.assertEquals(
      '5034-56793',
      result.queryResult[0].get('AccountNumber'),
      'Account number mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMLoanAccountTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_loanAccountResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'ils-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
