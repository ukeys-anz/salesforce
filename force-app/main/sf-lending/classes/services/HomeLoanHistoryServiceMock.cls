/**
 * @author ramvilas
 * @since May 2025
 * @description Mock implementation of mule api service for home loan history, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
 public with sharing class HomeLoanHistoryServiceMock extends HomeLoanHistoryService{
    /**
   * @description constructor which sets default code as succesful
   */

  public HomeLoanHistoryServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  private static final String LIST_OF_ACCOUNT_CHANGES_RESPONSE = getStaticResource(
    'mock_listOfLoanAccountChanges'
  );
  public override HttpCalloutResponse getListOfLoanAccountChanges(
    String ocvId,
    String loanAccNumber
  ) {
    if (!preset) {
      response.body = HomeLoanHistoryServiceMock.LIST_OF_ACCOUNT_CHANGES_RESPONSE;
    }
    return response;
  }
}