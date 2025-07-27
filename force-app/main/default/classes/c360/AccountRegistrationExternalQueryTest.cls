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
    Assert.areEqual(
      5,
      result.externalRecords.size(),
      'Response not returned correctly'
    );
    Assert.areEqual(
      '*****5685',
      result.externalRecords[0].get('crnLast4Digits'),
      'CRN Not populated correctly'
    );
    Assert.areEqual(
      'A - Active',
      result.externalRecords[0].get('registrationStatus'),
      'Registration Status Not populated correctly'
    );
    Assert.areEqual(
      'Customer Registration Number',
      result.externalRecords[0].get('registrationType'),
      'Registration Status Not populated correctly'
    );
    Assert.areEqual(
      'I - Issued',
      result.externalRecords[4].get('registrationStatus'),
      'Registration Status Not populated correctly'
    );
    Assert.areEqual(
      '************2833',
      result.externalRecords[4].get('cardLast4digits'),
      'Card Number Not populated correctly'
    );
  }

  @IsTest
  static void testGetMaskedRegistrationNumber() {
    AccountRegistrationExternalQuery obj = new AccountRegistrationExternalQuery();
    String result = obj.getMaskedRegistrationNumber(4, '1234567890');
    // Verify the output
    Assert.areEqual(
      '****1234567890',
      result,
      'Should mask with correct number of asterisks'
    );
  }

  @isTest
  static void tesRecordDetailWithExternalId() {
    Test.setMock(HttpCalloutMock.class, new AccountRegistrationExternalQueryTest.AccountRegistrationQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextWithExternalId(
      'AccountRegistration'
    );
    AccountRegistrationExternalQuery accountQuery = new AccountRegistrationExternalQuery();
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      result.externalRecords[0].get('AdditionalInformation'),
      'No further information available',
      'Record detail for account registration not showing proper details'
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
