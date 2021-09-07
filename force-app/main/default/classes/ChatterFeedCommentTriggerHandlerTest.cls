/*
 * @author Asteward Mikho
 * @since  08/2021
 * @description ChatterFeedCommentTriggerHandlerTest is the test class to cover tests for {@link ChatterFeedCommentTriggerHandler}
 */
@isTest
public with sharing class ChatterFeedCommentTriggerHandlerTest {
  @testSetup
  static void setup() {
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = '1';
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = '82jfsa80534';
    insert accnt;
    Case newCase = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      AccountId = accnt.Id,
      Origin = 'Email',
      Status = 'Open',
      Type = 'Cards',
      Subject = 'Test Subject'
    );
    insert newCase;
    FeedItem post = new FeedItem();
    post.ParentId = newCase.Id;
    post.Body = 'Test Post';
    insert post;
  }
  @isTest
  static void testEditFeedComment() {
    FeedItem post = [SELECT Id FROM FeedItem LIMIT 1];
    FeedComment comment = new FeedComment();
    comment.FeedItemId = post.Id;
    comment.commentBody = 'This is comment';
    insert comment;
    comment.commentBody = 'This is edit';
    Boolean exceptionThrown = false;
    try {
      update comment;
    } catch (Exception e) {
      exceptionThrown = (e.getMessage()
          .contains('You cannot edit feed comments.'))
        ? true
        : false;
    }
    System.assertEquals(true, exceptionThrown);
  }
  @isTest
  static void testDeleteFeedItem() {
    FeedItem post = [SELECT Id FROM FeedItem LIMIT 1];
    FeedComment comment = new FeedComment();
    comment.FeedItemId = post.Id;
    comment.commentBody = 'Test Post';
    insert comment;
    Boolean exceptionThrown = false;
    try {
      delete comment;
    } catch (Exception e) {
      exceptionThrown = (e.getMessage()
          .contains('You do not have permission to delete this comment'))
        ? true
        : false;
    }
    System.assertEquals(true, exceptionThrown);
  }
}
