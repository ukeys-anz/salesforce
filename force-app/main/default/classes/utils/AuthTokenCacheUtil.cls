/**
 * @author Aidan Majewski
 * @since  10/2020
 * @description Auth token session and org cache methods
 */
public with sharing class AuthTokenCacheUtil {
  private final static String ORGPART = 'local.OrgAzureTokens.';
  private final static String SESSIONPART = 'local.SessionAzureTokens.';

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
        '1',
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
      if (
        Cache.Org.contains(
          AuthTokenCacheUtil.ORGPART +
          'refreshToken' +
          userId
        ) && Cache.Org.contains(AuthTokenCacheUtil.ORGPART + 'idToken' + userId)
      ) {
        // move tokens to session cache
        Cache.Session.put(
          AuthTokenCacheUtil.SESSIONPART +
          'refreshToken' +
          userId,
          Cache.Org.get(AuthTokenCacheUtil.ORGPART + 'refreshToken' + userId),
          28800,
          Cache.Visibility.NAMESPACE,
          true
        );
        Cache.Session.put(
          AuthTokenCacheUtil.SESSIONPART +
          'idToken' +
          userId,
          Cache.Org.get(AuthTokenCacheUtil.ORGPART + 'idToken' + userId),
          28800,
          Cache.Visibility.NAMESPACE,
          true
        );

        // remove org cache tokens
        Cache.Org.remove(AuthTokenCacheUtil.ORGPART + 'refreshToken' + userId);
        Cache.Org.remove(AuthTokenCacheUtil.ORGPART + 'idToken' + userId);
      } else {
        Lib_SystemLog.createSingleLog(
          AuthTokenCacheUtil.class.getName(),
          'storeAzureSessionTokens',
          '1',
          'Login Flow Invocable method did not receive Azure Refresh or Id Token for user: ' +
          userId,
          Lib_SystemLog.Severity.ERROR
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
    if (
      Cache.Session.contains(
        AuthTokenCacheUtil.SESSIONPART +
        'refreshToken' +
        userId
      )
    ) {
      return (String) Cache.Session.get(
        AuthTokenCacheUtil.SESSIONPART +
        'refreshToken' +
        userId
      );
    } else {
      //notify user to log in again
      Lib_SystemLog.createSingleLog(
        AuthTokenCacheUtil.class.getName(),
        'getSessionRefreshToken',
        '1',
        'Session Refresh Token not found for user ' + userId,
        Lib_SystemLog.Severity.WARNING
      );
      throw new TokenCacheException(
        'No active token found, please log out, and back into Salesforce'
      );
    }
  }

  /**
   * @description retrieves current user's id token from session cache
   * @return String id token
   * @exception TokenCacheException throws when no token is found
   */
  public static String getSessionIdToken() {
    Id userId = UserInfo.getUserId();
    if (
      Cache.Session.contains(
        AuthTokenCacheUtil.SESSIONPART +
        'idToken' +
        userId
      )
    ) {
      return (String) Cache.Session.get(
        AuthTokenCacheUtil.SESSIONPART +
        'idToken' +
        userId
      );
    } else {
      //notify user to log in again
      Lib_SystemLog.createSingleLog(
        AuthTokenCacheUtil.class.getName(),
        'getSessionIdToken',
        '1',
        'Session Id Token not found for user ' + userId,
        Lib_SystemLog.Severity.WARNING
      );
      throw new TokenCacheException(
        'No active token found, please log out, and back into Salesforce'
      );
    }
  }

  /**
   * @description custom exception thrown when a token session cache miss occurs
   */
  public class TokenCacheException extends Exception {
  }
}
