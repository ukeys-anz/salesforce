/**
 * @author Aidan
 * @since  09/2021
 * @description Util to get SSO URL from Auth Provider
 * @group Utility
 */
public class SingleSignOnCacheUtil {
  /**
   * @description Calls Org cache to retrieve single sign on url
   * @return `String` a sso initialization url
   */
  @AuraEnabled(cacheable=true)
  public static String getSingleSignOnUrl() {
    return (String) Cache.Org.get(
      SsoCache.class,
      'local.Utility.SsoKickoffUrl'
    );
  }

  class SsoCache implements Cache.CacheBuilder {
    /**
     * @description Cachebuilder inner class
     * @precondition Fired when the given value only is not yet cached
     * @param urlVar dummy string input, as the method does not require arg
     * @return `Object` the sso url as an Object
     */
    public Object doLoad(String urlVar) {
      return [
        SELECT SsoKickoffUrl
        FROM AuthProvider
        WHERE DeveloperName = 'ANZ_Single_Sign_On'
      ]
      .SsoKickoffUrl;
    }
  }
}
