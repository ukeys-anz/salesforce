/**
 * @author Ashish Kumar
 * @since  08/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Test class of AccountRegistrationQuery
 */
@isTest
public class AccountRegistrationExternalQueryTest {
  /**
   * @description test method for createAccountRegistration
   */
  @isTest
  static void createAccountRegistrationTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new AccountRegistrationExternalQueryTest.AccountRegistrationQueryTestMock()
    );
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AccountRegistration'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    AccountRegistrationExternalQuery accountQuery = new AccountRegistrationExternalQuery();
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      5,
      result.externalRecords.size(),
      'Response not returned correctly'
    );
    System.assertEquals(
      '*****5685',
      result.externalRecords[0].get('crnLast4Digits'),
      'CRN Not populated correctly'
    );
    System.assertEquals(
      'A - Active',
      result.externalRecords[0].get('registrationStatus'),
      'Registration Status Not populated correctly'
    );
    System.assertEquals(
      'Customer Registration Number',
      result.externalRecords[0].get('registrationType'),
      'Registration Status Not populated correctly'
    );
    System.assertEquals(
      'I - Issued',
      result.externalRecords[4].get('registrationStatus'),
      'Registration Status Not populated correctly'
    );
  }
  /**
   * @description test method for buildEndpoint
   */
  @isTest
  static void buildEndpointTest() {
    String strAccNum = '2345685859';
    ExternalObjectQueryBase.QueryModeEnum queryMode = ExternalObjectQueryBase.QueryModeEnum.RELATED_LIST;
    AccountRegistrationExternalQuery obj = new AccountRegistrationExternalQuery();
    obj.parentId = strAccNum;
    Test.startTest();
    String strEndPoint = obj.buildEndpoint(queryMode);
    Test.stopTest();
    System.assertEquals(
      false,
      strEndPoint.contains('{accountNumber}'),
      'Endpoint not formed correctly'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AccountRegistrationQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_accountRegistrationResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
