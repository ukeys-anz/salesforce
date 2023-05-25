/**
 * @author Aidan Majewski
 * @since 10/2020
 * @description  Test class for {@link AuthTokenCacheUtil}
 * @group Utils
 */
@isTest
public class AuthTokenCacheUtilTest {
  //jwt containing a single claim of exp 26/11/2020
  private final static String EXPIREDTOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MDYzNDczNzh9.-hm-9aM803s3TqiDyj7iaUi-tujRy2l8IddQWHKiXr4';
  //jwt containing a single claim of exp 26/11/2050
  public final static String IDTESTVALUE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI1NTMwMzIxNzh9.eAWGLhTYhn4y9M2t2OHeTLIe7MLPObBFK2Nli8CPTD4';

  /**
   * @description tests the storage and cleanup of the cache
   * GIVEN a value is stored in the org cache, it is correctly transferred to session cache
   * GIVEN a value is stored in the org cache, it is removed after the method executes
   */
  @isTest
  static void testTransferOrgToSession() {
    Id userId = UserInfo.getUserId();
    User testUser = new User(id = userId);
    Cache.Org.put(
      'local.OrgAzureTokens.idToken' + userId,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    AuthTokenCacheUtil.storeRefreshTokenField(
      testUser,
      AzureTestRefreshToken.REFRESHTESTVALUE
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
    User anzxUser = createTestUserwithProfile('ANZx Standard User');
    User anzUser = createTestUserwithProfile('ANZ Standard User');

    Test.startTest();
    AuthTokenCacheUtil.storeAzureOrgTokens(
      anzxUser,
      AzureTestRefreshToken.REFRESHTESTVALUE,
      IDTESTVALUE
    );
    AuthTokenCacheUtil.storeRefreshTokenField(
      anzUser,
      AzureTestRefreshToken.REFRESHTESTVALUE
    );
    Test.stopTest();
    System.assertEquals(
      AzureTestRefreshToken.REFRESHTESTVALUE,
      AuthTokenCacheUtil.getRefreshToken()
    );
    System.assert(
      !Cache.Org.contains('local.OrgAzureTokens.idToken' + anzUser.Id),
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
    String profileName = 'ANZx Standard User';
    AuthTokenCacheUtil.storeAzureSessionTokens(
      '000000000000000000',
      profileName
    );
    Test.stopTest();
    //Cannot actually test this one since the log is created in big object
    System.assertEquals(
      'ANZx Standard User',
      profileName,
      'Profile name should be as expected.'
    );
  }

  /**
   * @description tests the session cache retrieval works
   * GIVEN a value is stored in the session cache, it can be retrieved with the getter methods
   */
  @isTest
  static void testSessionCacheHit() {
    Id userId = UserInfo.getUserId();
    User user = new User(Id = userId);
    String idTokenResult;
    String refreshTokenResult;

    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    AuthTokenCacheUtil.storeRefreshTokenField(
      user,
      AzureTestRefreshToken.REFRESHTESTVALUE
    );
    Test.startTest();
    idTokenResult = AuthTokenCacheUtil.getSessionIdToken();
    refreshTokenResult = AuthTokenCacheUtil.getRefreshToken();
    Test.stopTest();
    System.assertEquals(
      IDTESTVALUE,
      idTokenResult,
      'Failed to retrieve id token from session cache'
    );
    System.assertEquals(
      AzureTestRefreshToken.REFRESHTESTVALUE,
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
      AuthTokenCacheUtil.getRefreshToken();
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
      1,
      exceptions.size(),
      'An exception was not thrown by session retrieve method'
    );
  }

  /**
   * @description tests session cache miss on Id token and the refresh process
   * GIVEN session cache does not id token but does contain refresh, a new token is requested and returned
   */
  @isTest
  static void testSessionCacheRefresh() {
    User testUser = new User(Id = UserInfo.getUserId());
    //add a refresh token
    AuthTokenCacheUtil.storeRefreshTokenField(
      testUser,
      AzureTestRefreshToken.REFRESHTESTVALUE
    );

    Test.startTest();
    String newToken = AuthTokenCacheUtil.getRefreshToken();
    Test.stopTest();

    System.assertEquals(
      AzureTestRefreshToken.REFRESHTESTVALUE,
      newToken,
      'Token should be as expected.'
    );
  }

  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetStaffToken() {
    Id userId = UserInfo.getUserId();
    User testUser = createTestuserWithRefreshTokenField(userId);
    update testUser;
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    String accessToken = AuthTokenCacheUtil.getStaffToken(
      Service.IdType.OCVID,
      '1111'
    );
    System.assertEquals(
      accessToken,
      'xxxxx',
      'The accessToken should be as expected.'
    );
    Test.stopTest();
  }

  /**
   * @description test method for getForgeJWTToken when retrieving from cache instead of api
   */
  @isTest
  public static void testGetStaffTokenFromCache() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    String accessToken = AuthTokenCacheUtil.getStaffToken(
      Service.IdType.OCVID,
      '1111'
    );
    System.assertEquals(
      accessToken,
      AuthServiceTest.IDTESTVALUE,
      'The accessToken should be as expected.'
    );
    Test.stopTest();
  }

  /**
   * @description tests the token expiry checker
   * GIVEN a JWT is supplied with an exp claim, boolean is returned if the exp datetime has passed
   */
  @isTest
  static void testExpiredToken() {
    Test.startTest();
    Boolean result = AuthTokenCacheUtil.isTokenValid(
      AuthTokenCacheUtilTest.EXPIREDTOKEN
    );
    Test.stopTest();
    System.assert(
      !result,
      'Token validity checker should return false when expiry date has passed'
    );
  }

  @isTest
  public static void testGetStaffTokenFailure() {
    Id userId = UserInfo.getUserId();
    User testUser = createTestuserWithRefreshTokenField(userId);
    update testUser;
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    HttpCalloutResponse res = getForgeTokenInvalidResponse();
    Service s = ServiceProvider.getService(AuthService.class);
    s.setCalloutResponse(res);

    Test.startTest();
    String exceptionMsg = '';
    try {
      AuthTokenCacheUtil.getStaffToken(Service.IdType.OCVID, '1111');
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    System.assertEquals(
      'Get access token failed',
      exceptionMsg,
      'Error message should be as expected.'
    );

    Test.stopTest();
  }

  private static HttpCalloutResponse getForgeTokenInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Get access token failed');
    response.statusCode = 500;
    response.body = 'Get access token failed';
    response.successful = false;
    return response;
  }

  /**
   * @description method for creating test user with profile
   * @param profile
   * @return user
   */
  private static User createTestUserwithProfile(String profile) {
    User thisUser = new User(Id = UserInfo.getUserId());
    Profile testProfile = CommonUtil.getProfileByName(Profile);
    User testUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'Id' => thisUser.Id,
        'ProfileId' => testProfile.Id
      }
    );
    return thisUser;
  }
  /**
   * @description method for creating test user with refresh_token__c value stored
   * @param userId userId
   * @return User testuser
   */
  private static User createTestuserWithRefreshTokenField(Id userId) {
    User testUser = new User(
      Id = userId,
      Refresh_Token__c = AzureTestRefreshToken.REFRESHTESTVALUE
    );
    return testUser;
  }
}
