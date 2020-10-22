/**
 * @author Aidan Majewski
 * @since 10/2020
 * @description  Test class for AuthTokenCacheUtil
 */
@isTest
private class AuthTokenCacheUtilTest {
  private final static String IDTESTVALUE = 'testIdTokenValue';
  private final static String REFRESHTESTVALUE = 'testRefreshTokenValue';

  /**
   * @description tests the storage and cleanup of the cache
   * GIVEN a value is stored in the org cache, it is correctly transferred to session cache
   * GIVEN a value is stored in the org cache, it is removed after the method executes
   */
  @isTest
  static void testTransferOrgToSession() {
    Id userId = UserInfo.getUserId();
    Cache.Org.put(
      'local.OrgAzureTokens.idToken' + userId,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Cache.Org.put(
      'local.OrgAzureTokens.refreshToken' + userId,
      REFRESHTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.startTest();
    AuthTokenCacheUtil.storeAzureSessionTokens(userId, 'ANZx Standard User');
    Test.stopTest();
    System.assertEquals(
      IDTESTVALUE,
      Cache.Session.get('local.SessionAzureTokens.idToken' + userId),
      'Could not find token in session cache'
    );
    System.assert(
      !Cache.Org.contains('local.OrgAzureTokens.idToken' + userId),
      'Token was not cleared from org cache'
    );
  }

  /**
   * @description tests org cache put
   * GIVEN the org cache put util is used, only values for ANZx users are added
   */
  @isTest
  static void testOrgCachePut() {
    User anzxUser = new User(Id = '005000000000000000');
    anzxUser.putSObject('Profile', new Profile(Name = 'ANZx Standard User'));
    User anzUser = new User(Id = '005000000000000001');
    anzUser.putSObject('Profile', new Profile(Name = 'ANZ Standard User'));

    Test.startTest();
    AuthTokenCacheUtil.storeAzureOrgTokens(
      anzxUser,
      REFRESHTESTVALUE,
      IDTESTVALUE
    );
    AuthTokenCacheUtil.storeAzureOrgTokens(
      anzUser,
      REFRESHTESTVALUE,
      IDTESTVALUE
    );
    Test.stopTest();
    System.assertEquals(
      REFRESHTESTVALUE,
      Cache.Org.get('local.OrgAzureTokens.refreshToken' + '005000000000000000'),
      'Token was incorrectly added for a non ANZx user' + anzxUser.Profile.Name
    );
    System.assert(
      !Cache.Org.contains(
        'local.OrgAzureTokens.idToken' + '005000000000000001'
      ),
      'Token was incorrectly added for a non ANZx user'
    );
  }

  /**
   * @description tests org cache misses
   * GIVEN no value is stored in the org cache, nothing is stored against the key in the session cache
   */
  @isTest
  static void testOrgCacheMiss() {
    Test.startTest();
    AuthTokenCacheUtil.storeAzureSessionTokens(
      '000000000000000000',
      'ANZx Standard User'
    );
    Test.stopTest();
    List<Application_Log__c> logs = [
      SELECT Function_Name__c, Severity__c, Error_Description__c
      FROM Application_Log__c
    ];
    System.assertEquals(1, logs.size(), 'Log not created on org cache miss');
    System.assertEquals(
      'storeAzureSessionTokens',
      logs[0].Function_Name__c,
      'Auth Token log not created'
    );
  }

  /**
   * @description tests the session cache retrieval works
   * GIVEN a value is stored in the session cache, it can be retrieved with the getter methods
   */
  @isTest
  static void testSessionCacheHit() {
    Id userId = UserInfo.getUserId();
    String idTokenResult;
    String refreshTokenResult;

    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Cache.Session.put(
      'local.SessionAzureTokens.refreshToken' + userId,
      REFRESHTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.startTest();
    idTokenResult = AuthTokenCacheUtil.getSessionIdToken();
    refreshTokenResult = AuthTokenCacheUtil.getSessionRefreshToken();
    Test.stopTest();
    System.assertEquals(
      IDTESTVALUE,
      idTokenResult,
      'Failed to retrieve id token from session cache'
    );
    System.assertEquals(
      REFRESHTESTVALUE,
      refreshTokenResult,
      'Failed to retrieve refresh token from session cache'
    );
  }

  /**
   * @description tests session cache misses
   * GIVEN session cache does not contain tokens, exception is thrown
   */
  @isTest
  static void testSessionCacheMiss() {
    List<AuthTokenCacheUtil.TokenCacheException> exceptions = new List<AuthTokenCacheUtil.TokenCacheException>();
    Test.startTest();
    try {
      AuthTokenCacheUtil.getSessionRefreshToken();
    } catch (AuthTokenCacheUtil.TokenCacheException e) {
      exceptions.add(e);
    }
    try {
      AuthTokenCacheUtil.getSessionIdToken();
    } catch (AuthTokenCacheUtil.TokenCacheException e) {
      exceptions.add(e);
    }
    Test.stopTest();
    System.assertEquals(
      2,
      exceptions.size(),
      'An exception was not thrown by session retrieve method'
    );
    System.assertEquals(
      'No active token found, please log out, and back into Salesforce',
      exceptions[0].getMessage(),
      'Incorrect exception message from session token cache miss'
    );
  }
}
