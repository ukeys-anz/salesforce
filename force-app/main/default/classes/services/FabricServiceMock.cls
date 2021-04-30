/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Mock implementation of fabric api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class FabricServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public FabricServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String FORGE_TOKEN_RESPONSE = '{"access_token":"xxxxx","expires_in":900}';

  @TestVisible
  private static final String ACCOUNTS_AND_GOALS_SUCCESS_RESPONSE = getStaticResource(
    'mock_accountsAndGoals'
  );
  @TestVisible
  private static final String TRANSACTION_HISTORY_SUCCESS_RESPONSE = getStaticResource(
    'mock_transactionHistory'
  );
  @TestVisible
  private static final String CARD_LIST_SUCCESS_RESPONSE = getStaticResource(
    'mock_cardList'
  );

  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @return `HttpCalloutResponse` the api response
   * @description fetches accounts and goals fake response
   */
  public override HttpCalloutResponse getAccountsAndGoals(String ocvId) {
    if (!preset) {
      response.body = FabricServiceMock.ACCOUNTS_AND_GOALS_SUCCESS_RESPONSE;
    }
    return response;
  }

  public override HttpCalloutResponse getTransactionHistory(
    String ocvId,
    String accountNumber,
    String paramUrl
  ) {
    if (!preset) {
      response.body = FabricServiceMock.TRANSACTION_HISTORY_SUCCESS_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @return `HttpCalloutResponse` the api response
   * @description fetches card list fake response
   */
  public override HttpCalloutResponse getCardList(String ocvId) {
    if (!preset) {
      response.body = FabricServiceMock.CARD_LIST_SUCCESS_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId ocv id
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `HttpCalloutResponse` api response
   * @description fetches fake response
   */
  public override HttpCalloutResponse getForgeJWTToken(
    String ocvId,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    if (!preset) {
      response.body = FabricServiceMock.FORGE_TOKEN_RESPONSE;
    }
    return response;
  }
}
