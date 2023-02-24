/**
 * @author Batya Aisman Sufrin
 * @since Dec 2022
 * @description Test class for {@link AuthRepository}
 * @group Repository
 */
@isTest
public inherited sharing class AuthRepositoryTest {
  /**
   * @description test method for getForgeStaffToken when successful
   */
  @isTest
  public static void testGetForgeStaffToken() {
    //TestHelper.addAzureTokenToCache();
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    AuthRepository authRepo = new AuthRepository();
    IdentityModel respModel = authRepo.getForgeStaffToken(
      Service.IdType.OCVID,
      '1111'
    );
    String accessToken = respModel.accessToken;
    Test.stopTest();

    System.assertEquals(
      accessToken,
      'xxxxx',
      'The accessToken should be as expected.'
    );
  }
}
