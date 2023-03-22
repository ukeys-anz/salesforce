/**
 * @author Vidhya Raghavan
 * @since Dec 2022
 * @description Mock implementation of mule api service for home loan, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */

public with sharing class HomeLoanServiceMock extends Service {
  /**
   * @description constructor which sets default code as succesful
   */

  public HomeLoanServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  private static final string HOMELOAN_ACCOUNTS_RESPONSE = getStaticResource(
    'mock_homeloanaccounts'
  );

  /**
   * @param ocvId customerID to receive Home Loan Accounts
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for homeLoan api
   */

  public override HttpCalloutResponse getHomeLoanAccounts(String ocvId) {
    if (!preset) {
      response.body = HomeLoanServiceMock.HOMELOAN_ACCOUNTS_RESPONSE;
    }
    return response;
  }
}
