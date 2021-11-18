/**
 * @author Farid Masjedi
 * @since Sep 2021
 * @description RealChatterPoster for real `ChatterUtils` class
 * when testing is not running.
 * Point: test is not written for this class, as if we want test it
 * we need to use `@isTest(SeeAllData=true)`
 */
public with sharing class RealChatterPoster {
  /**
   * @param recordId record id to make a post on `ChatterUtils` class
   * @param postContents post to be send to chatter component
   * @return `String` return `feedItemId`
   * @return make the new chatter post using `ConnectApi.FeedElement`
   * @description MakeAPost for Mocking Chatter to check if `ChatterUtils` has been triggered
   */
  public static String makeAPost(String recordId, String postContents) {
    ConnectApi.FeedElement newPost = ConnectApi.ChatterFeeds.postFeedElement(
      Network.getNetworkId(),
      recordId,
      ConnectApi.FeedElementType.FEEDITEM,
      postContents
    );

    return newPost.Id;
  }
}
