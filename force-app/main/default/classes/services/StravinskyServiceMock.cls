/**
 * @author Paul Boyington
 * @since May 2022
 * @description Mock implementation of Stravinsky api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class StravinskyServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public StravinskyServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String CLOSE_PACKAGE_RESPONSE_ALL_FIELDS = getStaticResource(
    'mock_accountClosure'
  );

  /**
   * @param ocvId customer id
   * @param packageId package id
   * @param checkingAccount the account number for the checking account
   * @param savingsAccount the account number for the savings account
   * @return `HttpCalloutResponse` method response
   * @description stravinsky package closure api
   */
  public override HttpCalloutResponse closePackage(
    String ocvId,
    String packageId,
    String checkingAccount,
    String savingsAccount
  ) {
    if (!preset) {
      response.body = CLOSE_PACKAGE_RESPONSE_ALL_FIELDS;
    }
    return response;
  }
}
