/**
 * @author Ashish Kumar
 * @since  08/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Test class of CCRMAccountRegistrationQuery
 */
@isTest
public class CCRMAccountRegistrationQueryTest {
  /**
   * @description test method for createAccountRegistration
   */
  @isTest
  static void createAccountRegistrationTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMAccountRegistrationQueryTest.CCRMAccountRegistrationQueryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'AccountRegistration'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMAccountRegistrationQuery accountQuery = new CCRMAccountRegistrationQuery();
    Test.startTest();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      5,
      result.queryResult.size(),
      'Response not returned correctly'
    );
    System.assertEquals(
      '*****5685',
      result.queryResult[0].get('crnLast4Digits'),
      'CRN not populated correctly'
    );
    System.assertEquals(
      'A - Active',
      result.queryResult[0].get('registrationStatus'),
      'Registration Status not populated correctly'
    );
    System.assertEquals(
      'Customer Registration Number',
      result.queryResult[0].get('registrationType'),
      'Registration Type not populated correctly'
    );
    System.assertEquals(
      'I - Issued',
      result.queryResult[4].get('registrationStatus'),
      'Registration Status not populated correctly'
    );
  }

  /**
   * @description test method for buildEndpoint
   */
  @isTest
  static void buildEndpointTest() {
    String parent = 'loanAccount';
    Map<String, String> params = new Map<String, String>{
      'loanAccount' => '1212344-34343434'
    };
    CCRMAccountRegistrationQuery obj = new CCRMAccountRegistrationQuery();
    Test.startTest();
    String strEndPoint = obj.buildEndpoint(parent, params);
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
  public class CCRMAccountRegistrationQueryTestMock implements HttpCalloutMock {
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
