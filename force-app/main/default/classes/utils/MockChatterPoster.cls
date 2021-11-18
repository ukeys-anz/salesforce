/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description MockChatterPoster for mocking `ChatterUtils` class
 * when testing is running. (To avoid using @isTest(seeAllData=true))
 */
public with sharing class MockChatterPoster {
  // public static String expectedId = 'MockParentRecordId';
  public static string expectedFeedItemId = 'MockingPostId';

  /**
   * @param parentRecord record id to make a post on `ChatterUtils` class
   * @param text post to be send to chatter component
   * @return `String` return fake `feedItemId`
   * @description MakeAPost for Mocking Chatter to check if `ChatterUtils` has been triggered
   */
  public static String makeAPost(String parentRecord, String text) {
    /*
     * @description if record id is `23572357`, this should throw an error
     */
    if (parentRecord != '23572357') {
      String info = expectedFeedItemId;
      return info;
    } else {
      String msg = 'No Chatter post has been made';
      AuraHandledException error = new AuraHandledException(msg);
      error.setMessage(msg);
      throw error;
    }
  }
}
