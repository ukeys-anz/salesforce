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
  private static final String LOCK_CARD_RESPONSE = '{"status": true,"eligibilities": ["ELIGIBILITY_CARD_REPLACEMENT_LOST","ELIGIBILITY_CARD_REPLACEMENT_STOLEN","ELIGIBILITY_CARD_REPLACEMENT_DAMAGED","ELIGIBILITY_UNBLOCK"]}';

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

  @TestVisible
  private static final String REPLACE_CARD = getStaticResource(
    'mock_replaceCard'
  );
  @TestVisible
  private static final String GET_STATEMENT = getStaticResource(
    'mock_statement'
  );
  @TestVisible
  private static final String GET_STATEMENTURL = getStaticResource(
    'mock_statementUrl'
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
   * @param ocvId customer id
   * @param accountNumber to retrieve statements for the specific account
   * @param pageSize number of statement records to be returned from Fabric
   * @return `HttpCalloutResponse` the api response
   * @description fetches statement list fake response
   */
  public override HttpCalloutResponse getStatements(
    String ocvId,
    String accountNumber,
    String pageSize
  ) {
    if (!preset) {
      response.body = FabricServiceMock.GET_STATEMENT;
    }
    return response;
  }
  /**
   * @param ocvId customer id
   * @param statementId to retrieve statement url for the specific statement record
   * @return `HttpCalloutResponse` the api response
   * @description fetches statement list fake response
   */
  public override HttpCalloutResponse getStatementUrl(
    String ocvId,
    String statementId
  ) {
    if (!preset) {
      response.body = FabricServiceMock.GET_STATEMENTURL;
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

  /**
   * @param cardNumber card number to get locked
   * @param ocvId customer id
   * @return `HttpCalloutResponse` the api response
   * @description fake lock card api
   */
  public override HttpCalloutResponse lockCard(
    String cardNumber,
    String ocvId
  ) {
    if (!preset) {
      response.body = FabricServiceMock.LOCK_CARD_RESPONSE;
    }

    return response;
  }

  /**
   * @param cardNumber card number to get replaced
   * @param ocvId customer id
   * @param reason reason to replace the card
   * @return `HttpCalloutResponse` the api response
   * @description replace cards api
   */
  public override HttpCalloutResponse replaceCard(
    String cardNumber,
    String ocvId,
    String reason
  ) {
    if (!preset) {
      response.body = FabricServiceMock.REPLACE_CARD;
    }
    return response;
  }
}
