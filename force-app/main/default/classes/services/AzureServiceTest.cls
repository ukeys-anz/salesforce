/**
 * @author Lance Shi
 * @date March 2021
 * @description Test class for {@link AzureService}
 * @group Services
 */
@isTest
public with sharing class AzureServiceTest {
  public static final String JSON_GOOD_TOKEN =
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

  @isTest
  public static void testGetIdentityToken() {
    AzureService serviceClass = new AzureService();
    Test.setMock(
      HttpCalloutMock.class,
      new AzureMockService(JSON_GOOD_TOKEN, 200)
    );
    HttpCalloutResponse resp = serviceClass.getIdentityTokens(
      ANZAzureADAuthProviderTest.REDIRECT_URL,
      'code'
    );
    System.assertNotEquals(
      null,
      resp.body,
      'Response body should not be null.'
    );
  }

  @isTest
  public static void testGetRefreshIdToken() {
    AzureService serviceClass = new AzureService();
    Test.setMock(
      HttpCalloutMock.class,
      new AzureMockService(JSON_GOOD_TOKEN, 200)
    );
    HttpCalloutResponse resp = serviceClass.getRefreshIdToken(
      'testRefreshTokenValue'
    );
    System.assertNotEquals(
      null,
      resp.body,
      'Response body should not be null.'
    );
  }

  /**
   *
   * @author Lance Shi
   * @since 2020
   * @description AzureMockService is the internal class to help mock the rest response
   */
  public class AzureMockService implements HttpCalloutMock {
    String jsonResponse;
    Integer httpCode;

    /**
     * @description AzureMockService is the constructor of the mock service
     * @param json String
     * @param code Integer
     */
    public AzureMockService(String json, Integer code) {
      this.jsonResponse = json;
      this.httpCode = code;
    }

    /**
     * @description respond is the method to mock the http response
     * @param req HTTPRequest
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      // Create the response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(jsonResponse);
      res.setStatusCode(this.httpCode);
      return res;
    }
  }
}
