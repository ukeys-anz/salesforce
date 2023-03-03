@isTest
public class SingleSignOnCacheUtilTest {
  @isTest
  public static void validateSsoUrl() {
    Test.startTest();
    String url = SingleSignOnCacheUtil.getSingleSignOnUrl();
    Test.stopTest();
    System.assert(String.isNotEmpty(url), 'SSO URL was not fetched');
  }
}
