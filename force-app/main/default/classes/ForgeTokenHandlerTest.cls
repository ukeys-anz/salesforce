/**
 * @author Lance Shi
 * @since 11/2020
 * @description Covers {@link ForgeTokenHandler}
 */
@isTest
public class ForgeTokenHandlerTest {
  //jwt containing a single claim of exp 26/11/2050
  public final static String IDTESTVALUE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI1NTMwMzIxNzh9.eAWGLhTYhn4y9M2t2OHeTLIe7MLPObBFK2Nli8CPTD4';

  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetForgeJWTToken() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    IdentityModel respModel = ForgeTokenHandler.getForgeJWTToken('1111');
    String accessToken = respModel.accessToken;
    System.assertEquals(
      accessToken,
      'xxxxx',
      'The accessToken should be as expected.'
    );
    Test.stopTest();
  }
}
