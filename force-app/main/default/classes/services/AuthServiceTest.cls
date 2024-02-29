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

  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetForgeJWTToken() {
    Forgerock_Auth__mdt forgeAuth = new Forgerock_Auth__mdt();
    forgeAuth.Encrypted_Forge_Client_Id__c = '1234';
    forgeAuth.Encrypted_Forge_Client_Secret__c = 'xxxxxxx';

    Test.startTest();
    Service authService = (Service) ServiceProvider.getService(
      AuthService.class
    );
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
    Service authService = (Service) ServiceProvider.getService(
      AuthService.class
    );

    HttpCalloutResponse response = authService.getForgeJWTToken(
      staffModelWrapper,
      IDTESTVALUE,
      forgeAuth
    );
    Test.stopTest();
    Assert.areNotEqual(
      response.body,
      null,
      'Response body should not be null.'
    );
  }

  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetForgeJWTPayload() {
    String idToken = IDTESTVALUE;
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
    Assert.areNotEqual(payload, null, 'Response body should not be null.');
  }
}
