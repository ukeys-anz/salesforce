@isTest
public with sharing class ConcurrentSessionsPolicyConditionTest {
  /**
   * @description Test non concurrent login
   */
  @isTest
  static void testNonConcurrentLogins() {
    Profile profile = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];
    User user = createUserWithProfile(profile.id);
    LoginEvent loginEvent = new LoginEvent();
    loginEvent.UserId = user.id;
    ConcurrentSessionsPolicyCondition eventCondition = new ConcurrentSessionsPolicyCondition();
    System.assertEquals(false, eventCondition.evaluate((SObject) loginEvent));
  }

  /**
   * @description Helper to create a user with the given profileId.
   * @param profileId
   * @return `User`
   */
  static User createUserWithProfile(String profileId) {
    // Usernames have to be unique.
    String username = 'ConcurrentSessionsPolicyConditionTest@Test.com';
    User user = new User(
      Alias = 'standt',
      Email = 'standarduser@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profileId,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = username
    );
    insert user;
    return user;
  }
}