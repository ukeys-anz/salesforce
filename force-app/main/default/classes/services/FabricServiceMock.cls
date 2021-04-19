/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Mock implementation of fabric api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 */
public with sharing class FabricServiceMock extends Service {
  @TestVisible
  private static final String ACCOUNTS_AND_GOALS_SUCCESS_RESPONSE = getStaticResource(
    'mock_accountsAndGoals'
  );
  @TestVisible
  private static final String TRANSACTION_HISTORY_SUCCESS_RESPONSE = getStaticResource(
    'mock_transactionHistory'
  );

  public override HttpCalloutResponse getAccountsAndGoals(String ocvId) {
    if (response.statusCode == null) {
      response.statusCode = 200;
      response.body = FabricServiceMock.ACCOUNTS_AND_GOALS_SUCCESS_RESPONSE;
      response.successful = true;
    }
    return response;
  }

  public override HttpCalloutResponse getTransactionHistory(
    String ocvId,
    String accountNumber,
    String paramUrl
  ) {
    if (response.statusCode == null) {
      response.statusCode = 200;
      response.body = FabricServiceMock.TRANSACTION_HISTORY_SUCCESS_RESPONSE;
      response.successful = true;
    }
    return response;
  }
}
