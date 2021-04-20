/**
 * @author Lance Shi
 * @since March 2021
 * @description Mock implementation of Azure api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 */
public with sharing class AzureServiceMock extends Service {
  @TestVisible
  private static final String IDENTITY_TOKEN_RESPONSE =
    '{' +
    '  \"refresh_token_expires_in\" : \"0\",' +
    '  \"api_product_list\" : \"[helloworld, HelloWorld_OAuth2-Product]\",' +
    '  \"api_product_list_json\" : [ \"helloworld\", \"HelloWorld_OAuth2-Product\" ],' +
    '  \"developer.email\" : \"developer@example.com\",' +
    '  \"token_type\" : \"Bearer\",' +
    '  \"issued_at\" : \"1521077832490\",' +
    '  \"client_id\" : \"testKey\",' +
    '  \"access_token\" : \"testaccesstoken\",' +
    '  \"refresh_token\" : \"samplerefreshtoken\",' +
    '  \"id_token\" : \"sampleidtoken\",' +
    '  \"application_name\" : \"47bc6c8d-34f3-4141-b9e6-f1679a8240e7\",' +
    '  \"scope\" : \"\",' +
    '  \"expires_in\" : 3599,' +
    '  \"refresh_count\" : \"0\",' +
    '  \"status\" : \"approved\"' +
    '}';

  /**
   * @description construct a mock with hardcoded success value
   */
  public AzureServiceMock() {
    response.statusCode = 200;
    response.body = AzureServiceMock.IDENTITY_TOKEN_RESPONSE;
    response.successful = true;
  }

  /**
   * @param redirectURL redirect url in the http request
   * @param code code in the http request
   * @return `HttpCalloutResponse` api response
   * @description get the mock response
   */
  public override HttpCalloutResponse getIdentityTokens(
    String redirectURL,
    String code
  ) {
    return response;
  }

  /**
   * @param existingRefreshToken existing refresh token id
   * @return `HttpCalloutResponse` api response
   * @description get the mock response
   */
  public override HttpCalloutResponse getRefreshIdToken(
    String existingRefreshToken
  ) {
    return response;
  }
}
