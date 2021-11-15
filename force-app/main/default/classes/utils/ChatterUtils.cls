/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description ChatterUtils for making a chatter post and a comment
 * @group Chatter
 */
public with sharing class ChatterUtils {
  /**
   * @param recordId record id to make a post on `ChatterUtils` class
   * @param postContents post to be send to chatter component
   * @return `String` return the feedItemId for real Chatter post and will make a post
   * @return `String` return the `MockingPostId` for Mock Chatter post to check
   * if the MockChatterPoster has been triggered
   * @description MakeAPost for Mocking Chatter to check if `ChatterUtils` has been triggered
   * Point: RealChatterPoster has no test, as if we want to test it, we need
   * to use `@isTest(SeeAllData=true)` that will make some risk
   */
  public static String makeAPost(String recordId, String postContents) {
    String info;
    if (!Test.isRunningTest()) {
      info = RealChatterPoster.makeAPost(recordId, postContents);
    } else {
      info = MockChatterPoster.makeAPost('MockParentRecordId', 'MockingPost');
    }
    return info;
  }
}
