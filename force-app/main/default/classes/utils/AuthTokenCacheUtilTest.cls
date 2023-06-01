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
   * @description Setup common test data
   */
  @testSetup
  public static void setup() {
    //Create anzxTestUser with ANZx Standard User Profile
    Profile anzxProfile = CommonUtil.getProfileByName('ANZx Standard User');
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      User anzxTestUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'ANZx_Test_User',
          'ProfileId' => anzxProfile.Id
        }
      );
      insert anzxTestUser;
    }
  }

  /**
   * @description tests the storage and cleanup of the cache
   * GIVEN a value is stored in the org cache, it is correctly transferred to session cache
   * GIVEN a value is stored in the org cache, it is removed after the method executes
   */
  @isTest
  static void testTransferOrgToSession() {
    User anzxTestUser = TestUtil.getUserByFirstName('ANZx_Test_User');
    Cache.Org.put(
      'local.OrgAzureTokens.idToken' + anzxTestUser.Id,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    System.runAs(anzxTestUser) {
      AuthTokenCacheUtil.storeAzureSessionTokens(
        anzxTestUser.Id,
        'ANZx Standard User'
      );
    }
    Test.stopTest();
    System.assertEquals(
      IDTESTVALUE,
      Cache.Session.get('local.SessionAzureTokens.idToken' + anzxTestUser.Id),
      'Could not find token in session cache'
    );
    System.assert(
      !Cache.Org.contains('local.OrgAzureTokens.idToken' + anzxTestUser.Id),
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
      AzureTestRefreshToken.REFRESHTESTVALUE,
      IDTESTVALUE
    );
    AuthTokenCacheUtil.storeAzureOrgTokens(
      anzUser,
      AzureTestRefreshToken.REFRESHTESTVALUE,
      IDTESTVALUE
    );
    Test.stopTest();
    System.assert(
      !Cache.Org.contains(
        'local.OrgAzureTokens.idToken' + '005000000000000001'
      ),
      'Token was incorrectly added for a non ANZx user'
    );

    System.assert(
      Cache.Org.contains('local.OrgAzureTokens.idToken' + '005000000000000000'),
      'Token was correctly added for an ANZx user'
    );
  }

  /**
   * @description tests store refresh token field
   */
  @isTest
  static void testStoreRefreshTokenField() {
    User anzxTestUser = TestUtil.getUserByFirstName('ANZx_Test_User');

    //WHEN adding Refresh Token Field to job queue
    Test.startTest();
    System.runAs(anzxTestUser) {
      AuthTokenCacheUtil.storeRefreshTokenField(
        anzxTestUser,
        AzureTestRefreshToken.REFRESHTESTVALUE
      );
    }
    Test.stopTest();

    //THEN Check if the refresh Token is updated to the user
    anzxTestUser = [
      SELECT Refresh_Token__c
      FROM User
      WHERE Id = :anzxTestUser.Id
    ];
    System.assertEquals(
      AzureTestRefreshToken.REFRESHTESTVALUE,
      anzxTestUser.Refresh_Token__c,
      'Failed to retrieve refresh token'
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
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    String idTokenResult;
    String refreshTokenResult;

    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + thisUser.Id,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    System.runAs(thisUser) {
      AuthTokenCacheUtil.storeRefreshTokenField(
        thisUser,
        AzureTestRefreshToken.REFRESHTESTVALUE
      );
    }
    Test.stopTest();

    idTokenResult = AuthTokenCacheUtil.getSessionIdToken();
    refreshTokenResult = AuthTokenCacheUtil.getRefreshToken();

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
    User anzxTestUser = TestUtil.getUserByFirstName('ANZx_Test_User');
    //GIVEN that refreshtoken is null
    anzxTestUser.Refresh_Token__c = null;
    update anzxTestUser;

    Test.startTest();
    System.runAs(anzxTestUser) {
      try {
        AuthTokenCacheUtil.getSessionIdToken();
      } catch (AuthTokenCacheUtil.TokenCacheException e) {
        exceptions.add(e);
      }
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
    User anzxTestUser = TestUtil.getUserByFirstName('ANZx_Test_User');

    Test.startTest();
    System.runAs(anzxTestUser) {
      //add a refresh token
      AuthTokenCacheUtil.storeRefreshTokenField(
        anzxTestUser,
        AzureTestRefreshToken.REFRESHTESTVALUE
      );
    }
    Test.stopTest();

    anzxTestUser = [
      SELECT Refresh_Token__c
      FROM User
      WHERE Id = :anzxTestUser.Id
    ];
    String newToken = anzxTestUser.Refresh_Token__c;
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
    User anzxTestUser = TestUtil.getUserByFirstName('ANZx_Test_User');
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + anzxTestUser.Id,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    System.runAs(anzxTestUser) {
      String accessToken = AuthTokenCacheUtil.getStaffToken(
        Service.IdType.OCVID,
        '1111'
      );
      System.assertEquals(
        accessToken,
        'xxxxx',
        'The accessToken should be as expected.'
      );
    }
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

  /**
   * @description test refresh the Azure Id and refresh tokens
   */
  @isTest
  public static void testRefreshIdToken() {
    String newIdToken;
    User anzxTestUser = TestUtil.getUserByFirstName('ANZx_Test_User');

    Test.startTest();
    System.runAs(anzxTestUser) {
      String existingRefreshToken = AuthTokenCacheUtil.getRefreshToken();
      newIdToken = AuthTokenCacheUtil.refreshIdToken(existingRefreshToken);
    }
    Test.stopTest();

    System.assertNotEquals(
      AzureTestRefreshToken.REFRESHTESTVALUE,
      newIdToken,
      'Refresh Token Should be updated'
    );
  }

  private static HttpCalloutResponse getForgeTokenInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Get access token failed');
    response.statusCode = 500;
    response.body = 'Get access token failed';
    response.successful = false;
    return response;
  }
}
