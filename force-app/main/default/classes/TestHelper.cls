/**
 * @author Shermal Warnakula
 * @since Jan 2021
 * @description Helper class providing common methods for APEX unit test classes
 */
@isTest
public with sharing class TestHelper {
  /**
   * @description Adding both Azure and Forge test tokens to Cache
   * @param ocvId Customer OCV ID
   */
  public static void addTokensForApiCallout(String ocvId) {
    addAzureTokenToCache();
    addForgeTokenToCache(ocvId);
  }

  /**
   * @description Adding test Azure token to Cache
   */
  public static void addAzureTokenToCache() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
  }

  /**
   * @description Adding test Forge token to Cache
   * @param ocvId Customer OCV ID
   */
  public static void addForgeTokenToCache(String ocvId) {
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      AuthServiceTest.IDTESTVALUE
    );
  }
}
