/**
 * @author Aidan Majewski
 * @since  10/2020
 * @description Auth token session and org cache methods
 * @group Utils
 */
public with sharing class AuthTokenCacheUtil {
  private final static String ORGPART = 'local.OrgAzureTokens.';
  private final static String SESSIONPART = 'local.SessionAzureTokens.';
  @TestVisible
  private final static String STAFFPART = 'local.ForgeToken.';
  private final static Non_Prod_Settings__c NON_PROD_SETTINGS = Non_Prod_Settings__c.getInstance(
    UserInfo.getUserId()
  );

  /**
   * @description move the tokens for the current user from org to session cache
   */
  @InvocableMethod(
    label='Store Auth Token'
    description='Stores the auth tokens from org cache into session cache'
    category='Apex'
  )
  public static void moveAuthTokens() {
    Id userId = UserInfo.getUserId();
    if (User.sObjectType.getDescribe().isQueryable()) {
      User currentUser = [SELECT Profile.Name FROM User WHERE Id = :userId];
      AuthTokenCacheUtil.storeAzureSessionTokens(
        userId,
        currentUser.Profile.Name
      );
    } else {
      Lib_SystemLog.createSingleLog(
        AuthTokenCacheUtil.class.getName(),
        'moveAuthTokens',
        '',
        'Unable to query user to check if ANZx user to perform token caching',
        Lib_SystemLog.Severity.ERROR
      );
    }
  }

  /**
   * @description store tokens to the org cache, with a specified user as the key, ANZx only
   * @param u user to store the tokens against, requires Profile.Name for validation
   * @param refreshToken Azure AD refresh token
   * @param idToken Azure AD id token
   */
  public static void storeAzureOrgTokens(
    User u,
    String refreshToken,
    String idToken
  ) {
    if (u.Profile.Name == 'ANZx Standard User') {
      Cache.Org.put(
        AuthTokenCacheUtil.ORGPART +
        'refreshToken' +
        u.Id,
        refreshToken,
        300,
        Cache.Visibility.NAMESPACE,
        false
      );
      Cache.Org.put(
        AuthTokenCacheUtil.ORGPART +
        'idToken' +
        u.Id,
        idToken,
        300,
        Cache.Visibility.NAMESPACE,
        false
      );
    }
  }

  /**
   * @description move the tokens for the current user from org to session cache, ANZx only
   * @param userId current user
   * @param profileName current user's profile
   */
  @TestVisible
  private static void storeAzureSessionTokens(Id userId, String profileName) {
    if (profileName == 'ANZx Standard User') {
      String refreshToken = (String) Cache.Org.get(
        AuthTokenCacheUtil.ORGPART +
        'refreshToken' +
        userId
      );
      String idToken = (String) Cache.Org.get(
        AuthTokenCacheUtil.ORGPART +
        'idToken' +
        userId
      );
      if (refreshToken != null && idToken != null) {
        // move tokens to session cache
        Cache.Session.put(
          AuthTokenCacheUtil.SESSIONPART +
          'refreshToken' +
          userId,
          refreshToken,
          28800,
          Cache.Visibility.NAMESPACE,
          true
        );
        Cache.Session.put(
          AuthTokenCacheUtil.SESSIONPART +
          'idToken' +
          userId,
          idToken,
          3420,
          Cache.Visibility.NAMESPACE,
          true
        );

        // remove org cache tokens
        Cache.Org.remove(AuthTokenCacheUtil.ORGPART + 'refreshToken' + userId);
        Cache.Org.remove(AuthTokenCacheUtil.ORGPART + 'idToken' + userId);
      } else {
        Lib_SystemLog.createSingleLogAsync(
          AuthTokenCacheUtil.class.getName(),
          'storeAzureSessionTokens',
          '',
          'Login Flow Invocable method did not receive Azure Refresh or Id Token for user: ' +
          userId
        );
      }
    }
  }

  /**
   * @description retrieves current user's refresh token from session cache
   * @return String refresh token
   */
  public static String getSessionRefreshToken() {
    Id userId = UserInfo.getUserId();
    String refreshToken = (String) Cache.Session.get(
      AuthTokenCacheUtil.SESSIONPART +
      'refreshToken' +
      userId
    );
    if (refreshToken != null) {
      return refreshToken;
    } else {
      //notify user to log in again
      Lib_SystemLog.createSingleLog(
        AuthTokenCacheUtil.class.getName(),
        'getSessionRefreshToken',
        '',
        'Session Refresh Token not found for user ' + userId,
        Lib_SystemLog.Severity.WARNING
      );
      throw new TokenCacheException('Connection issue, please sign in again');
    }
  }

  /**
   * @description retrieves current user's id token from session cache
   * @return String id token
   * @exception TokenCacheException throws when no token is found
   */
  @AuraEnabled
  public static String getSessionIdToken() {
    Id userId = UserInfo.getUserId();
    String refreshToken = NON_PROD_SETTINGS.SSO_Not_Configured__c
      ? AzureTestRefreshToken.REFRESHTESTVALUE
      : (String) Cache.Session.get(
          AuthTokenCacheUtil.SESSIONPART +
          'refreshToken' +
          userId
        );
    String idToken = (String) Cache.Session.get(
      AuthTokenCacheUtil.SESSIONPART +
      'idToken' +
      userId
    );
    if (idToken != null && AuthTokenCacheUtil.isTokenValid(idToken)) {
      return idToken;
    } else if (refreshToken != null) {
      // Id token was not there, if refresh token exists try and refresh the Id token and return it
      return AuthTokenCacheUtil.refreshIdToken(refreshToken);
    } else {
      //notify user to log in again
      Lib_SystemLog.createSingleLog(
        AuthTokenCacheUtil.class.getName(),
        'getSessionIdToken',
        '',
        'Session Id Token not found for user ' + userId,
        Lib_SystemLog.Severity.WARNING
      );
      throw new TokenCacheException(
        'Oh dear! Looks like we\'ve messed up and lost a connection downstream.\nThe quick fix is to sign in again and all should be right.'
      );
    }
  }

  /**
   * @description refreshes the Azure Id and refresh tokens, using refresh_token grant type
   * @param existingRefreshToken the existing refresh token to send to microsoft token endpoint
   * @return String new Id token
   */
  private static String refreshIdToken(String existingRefreshToken) {
    Id userId = UserInfo.getUserId();
    String idToken;
    String refreshToken;
    HTTPResponse res;
    try {
      AuthRepository authRepo = new AuthRepository();
      IdentityModel idenModel = authRepo.getRefreshIdToken(
        existingRefreshToken
      );

      refreshToken = idenModel.refreshToken;
      idToken = idenModel.idToken;

      // place new tokens in session cache
      Cache.Session.put(
        AuthTokenCacheUtil.SESSIONPART +
        'refreshToken' +
        userId,
        refreshToken,
        28800,
        Cache.Visibility.NAMESPACE,
        true
      );
      Cache.Session.put(
        AuthTokenCacheUtil.SESSIONPART +
        'idToken' +
        userId,
        idToken,
        3420,
        Cache.Visibility.NAMESPACE,
        true
      );
    } catch (Exception e) {
      Boolean logResult = lib_systemLog.logAPIError(
        AuthTokenCacheUtil.class.getName(),
        'refreshIdToken',
        e.getMessage(),
        e.getTypeName(),
        null,
        res != null ? res.getBody() : null,
        null,
        null,
        res?.getStatusCode()
      );
    }

    return (String) idToken;
  }

  /**
   * @description retrieves staff token from forgerock via mulesoft
   * @param ocvId ocvID
   * @return String staff token
   * @exception TokenCacheException throws when no token is found
   */
  @AuraEnabled
  public static String getStaffToken(String ocvId) {
    String staffToken = (String) Cache.Session.get(
      STAFFPART +
      'forgeJWTToken' +
      ocvId
    );

    if (staffToken != null && AuthTokenCacheUtil.isTokenValid(staffToken)) {
      return staffToken;
    }

    Integer expiresIn = 300; // default minimum value
    try {
      IdentityModel responseModel = ForgeTokenHandler.getForgeJWTToken(ocvId);
      staffToken = responseModel.accessToken;
      expiresIn = responseModel.expiresIn.intValue();
    } catch (Exception e) {
      Lib_SystemLog.createSingleLog(
        AuthTokenCacheUtil.class.getName(),
        'getStaffToken',
        '1',
        'Unable to retrieve staff token',
        Lib_SystemLog.Severity.WARNING
      );
      throw new TokenCacheException(e.getMessage());
    }

    Cache.Session.put(
      STAFFPART +
      'forgeJWTToken' +
      ocvId,
      staffToken,
      expiresIn
    );

    return staffToken;
  }

  /**
   * @description checks expiry date contained in a jwt
   * @param token the JWT to examine, could be azure id token or forge staff token
   * @return boolean true if the token is valid, false if it has expired
   * @exception TokenCacheException throws when the token supplied was not of expected format
   */
  public static boolean isTokenValid(String token) {
    if (token == null) {
      return false;
    }

    //strip jwt header
    List<String> tokenParts = token.split('\\.');
    if (tokenParts.size() < 2) {
      throw new TokenCacheException(
        'Invalid format when checking token validity'
      );
    }

    //decode claims to json map, the first part is header, second part is claims
    String decodedString = EncodingUtil.base64Decode(tokenParts[1]).toString();
    Map<String, Object> tokenMap = (Map<String, Object>) (JSON.deserializeUntyped(
      decodedString
    ));

    //Azure token has expiry as 'exp' key
    Long expiry = (Long) tokenMap.get('exp');
    Datetime expiryDateTime = DateTime.newInstance(expiry * 1000);

    //add one minute to ensure the token is valid for at least 1 minute when the check is made
    return expiryDateTime > Datetime.now().addMinutes(1);
  }

  /**
   * @description custom exception thrown when a token session cache miss occurs
   */
  public class TokenCacheException extends Exception {
  }
}
