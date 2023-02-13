/**
 * @author Jasmine Nguyen
 * @since December 2022
 * @description Mock implementation of card management api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class AuthServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public AuthServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String FORGE_TOKEN_RESPONSE = '{"access_token":"xxxxx","expires_in":900}';

  /**
   * @param idType Enum for specifying which type of id is used: OCV ID or PERSONA ID
   * @param idValue ocv id or persona Id
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `HttpCalloutResponse` api response
   * @description fetches fake response
   */
  public override HttpCalloutResponse getForgeJWTToken(
    Service.IdType idType,
    String idValue,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    if (!preset) {
      response.body = AuthServiceMock.FORGE_TOKEN_RESPONSE;
    }
    return response;
  }
}
