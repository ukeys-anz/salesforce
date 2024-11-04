/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Other Limits And Liabilities Account external query test class
 */
@isTest
private class CCRMOtherLimitsAndLiabilitiesQueryTest {
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
      'CAP-CIS:OLL',
      acct.Id,
      '4011643101-523456789',
      '523456789'
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
  static void testOtherLimitLibalitiesQry() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMOtherLimitsAndLiabilitiesQueryTest.CCRMOtherLimitsAndLiabilitiesQueryTestMock()
    );
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'OtherLimitsAndLiabilities'
    );
    conn.query(context);
    CCRMOtherLimitsAndLiabilitiesQuery limitLiabQry = new CCRMOtherLimitsAndLiabilitiesQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = limitLiabQry.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.queryResult[0];
    System.assertEquals(
      'Stephan Pedersen',
      firstRecord.get('AccountName'),
      'Name mismatch'
    );
    System.assertEquals(
      '5234-56789',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMOtherLimitsAndLiabilitiesQueryTestMock implements HttpCalloutMock {
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
