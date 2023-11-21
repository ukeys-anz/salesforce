/**
 * @author Hitesh W
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for CCRMAccountRelationshipQuery
 */
@isTest
private class CCRMAccountRelationshipQueryTest {
  @TestSetup
  static void createTestData() {
    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Business_Account')
      .getRecordTypeId();
    Account acct = TestDataFactory.createBusinessRecordTypeAccount(
      '4040r00000E3yPTABB',
      customerRecordTypeId,
      '4040r00000E3yPTABB'
    );

    Id bankingRecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
      .get('BankingAccount')
      .getRecordTypeId();
    FinServ__FinancialAccount__c finAccount = TestDataFactory.createC360FinancialAccount(
      bankingRecordTypeId,
      'CAP-CIS:DDA',
      acct.Id,
      '3424909811',
      '000000000'
    );
  }

  @isTest
  static void testAccountRelationshipQuery() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMAccountRelationshipQueryTest.CCRMAccountRelationshipQueryTestMock()
    );
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'AccountRelationship'
    );
    conn.query(context);
    CCRMAccountRelationshipQuery accRelQry = new CCRMAccountRelationshipQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accRelQry.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      result.queryResult.size(),
      5,
      'Size of accounts is not 5'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMAccountRelationshipQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_accountRelationship');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'account-relationship-query');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
