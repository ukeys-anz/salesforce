/**
 * @author Batya Aisman Sufrin
 * @since Dec 2022
 * @description Test class for {@link AuthService}
 * @group Services
 */
@isTest
public inherited sharing class AuthServiceTest {
  //jwt containing a single claim of exp 26/11/2050
  public final static String IDTESTVALUE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI1NTMwMzIxNzh9.eAWGLhTYhn4y9M2t2OHeTLIe7MLPObBFK2Nli8CPTD4';
  public final static String IDTESTVALUEFORGE2 = getForgeV2StaffJWT();
  private static final String FORGE_TOKEN_RESPONSE = '{"access_token":"xxxxx","expires_in":900}';

  /**
   * @return string staffJWT
   * @description gets the staffJWT
   */
  public static String getForgeV2StaffJWT() {
    if (String.isNotBlank(IDTESTVALUEFORGE2)) {
      return IDTESTVALUEFORGE2;
    }
    String headerJson = '{"typ":"JWT","kid":"fK2HSN5juEOPzIzlvjig51vqGEU=","alg":"RS512"}';
    String payloadJson = Service.getStaticResource('mock_ForgeV2Payload');
    String encodedHeader = EncodingUtil.base64Encode(Blob.valueOf(headerJson))
      .toString();
    String encodedPayload = EncodingUtil.base64Encode(Blob.valueOf(payloadJson))
      .toString();

    return encodedHeader + '.' + encodedPayload;
  }
  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetForgeJWTToken() {
    Forgerock_Auth__mdt forgeAuth = new Forgerock_Auth__mdt();
    forgeAuth.Encrypted_Forge_Client_Id__c = '1234';
    forgeAuth.Encrypted_Forge_Client_Secret__c = 'xxxxxxx';

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new JWTResponseMock());
    AuthService authService = new AuthService();
    HttpCalloutResponse response = authService.getForgeJWTToken(
      Service.IdType.OCVID,
      '1111',
      IDTESTVALUE,
      forgeAuth
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetForgeJWTTokenv2() {
    Forgerock_Auth__mdt forgeAuth = Forgerock_Auth__mdt.getInstance('ForgeV2');
    StaffTokenRequestModel staffModelWrapper = new StaffTokenRequestModel();
    staffModelWrapper.anzTokenType = forgeAuth.Forgev2_subject_token_type__c;
    staffModelWrapper.idType = Service.IdType.OCVID;
    staffModelWrapper.idValue = '1111';
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new JWTResponseMock());
    AuthService authService = new AuthService();

    HttpCalloutResponse response = authService.getForgeJWTToken(
      staffModelWrapper,
      IDTESTVALUEFORGE2,
      forgeAuth
    );
    Test.stopTest();
    Assert.areNotEqual(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetForgeJWTPayload() {
    String idToken = IDTESTVALUEFORGE2;
    Forgerock_Auth__mdt forgeAuth = Forgerock_Auth__mdt.getInstance('ForgeV2');
    StaffTokenRequestModel staffModelWrapper = new StaffTokenRequestModel();
    staffModelWrapper.anzTokenType = forgeAuth.Forgev2_subject_token_type__c;
    staffModelWrapper.idType = Service.IdType.OCVID;
    staffModelWrapper.idValue = '1111';
    Test.startTest();
    String payload = AuthService.getJWT2Payload(
      staffModelWrapper,
      idToken,
      forgeAuth
    );
    Test.stopTest();
    Assert.areNotEqual(null, payload, 'Response body should not be null.');
  }

  /**
   * @description test method for getForgeJWEToken when successful
   */
  @isTest
  public static void testGetForgeJWEToken() {
    String idToken = IDTESTVALUEFORGE2;
    Forgerock_Auth__mdt forgeAuth = Forgerock_Auth__mdt.getInstance(
      'CCRM_CACHE_360'
    );
    StaffTokenRequestModel staffModelWrapper = new StaffTokenRequestModel();
    staffModelWrapper.anzTokenType = 'staff';
    staffModelWrapper.realm = 'system';
    staffModelWrapper.apiScopesRequested = 'CCRM_CACHE_360';
    staffModelWrapper.isSecureWafFlow = true;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new JWTResponseMock());
    AuthService authService = new AuthService();
    HttpCalloutResponse response = authService.getForgeJWEToken(
      staffModelWrapper,
      idToken,
      forgeAuth
    );
    Test.stopTest();
    Assert.areNotEqual(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  /**
   * @description test method for getForgeJWEToken when successful
   */
  @isTest
  public static void testGetForgeJWEPayload() {
    String idToken = IDTESTVALUEFORGE2;
    Forgerock_Auth__mdt forgeAuth = Forgerock_Auth__mdt.getInstance(
      'CCRM_CACHE_360'
    );
    StaffTokenRequestModel staffModelWrapper = new StaffTokenRequestModel();
    staffModelWrapper.anzTokenType = 'staff';
    staffModelWrapper.realm = 'system';
    staffModelWrapper.apiScopesRequested = 'CCRM_CACHE_360';
    staffModelWrapper.isSecureWafFlow = true;
    Test.startTest();
    String payload = AuthService.getJWEPayload(
      staffModelWrapper,
      idToken,
      forgeAuth
    );
    Test.stopTest();
    Assert.areNotEqual(null, payload, 'payload should not be null.');
  }

  /**
   * @description create HTTP mock response for testisng
   */
  public class JWTResponseMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponses
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = FORGE_TOKEN_RESPONSE;
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
