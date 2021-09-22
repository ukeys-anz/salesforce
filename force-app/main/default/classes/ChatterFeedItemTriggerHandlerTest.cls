/*
 * @author Asteward Mikho
 * @since  08/2021
 * @description ChatterFeedItemTriggerHandlerTest is the test class to cover tests for {@link ChatterFeedItemTriggerHandler}
 */
@isTest
public with sharing class ChatterFeedItemTriggerHandlerTest {
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
  }
  @isTest
  static void testEditFeedItem() {
    Case newCase = [SELECT Id FROM Case LIMIT 1];
    FeedItem post = new FeedItem();
    post.ParentId = newCase.Id;
    post.Body = 'Test Post';
    insert post;

    Boolean exceptionThrown = false;
    try {
      post.Body = 'This is edit'; /* Since we have disabled Chatter post "Edit" feature in Chatter settings
       Move this into try block to catch "Field is not Writeable" exception*/
      update post;
    } catch (SObjectException e) {
      exceptionThrown = (e.getMessage().contains('Field is not writeable'))
        ? true
        : false;
    }
    System.assertEquals(true, exceptionThrown);
  }
  @isTest
  static void testDeleteFeedItem() {
    Case newCase = [SELECT Id FROM Case LIMIT 1];
    FeedItem post = new FeedItem();
    post.ParentId = newCase.Id;
    post.Body = 'Test Post';
    insert post;
    Boolean exceptionThrown = false;
    try {
      delete post;
    } catch (Exception e) {
      exceptionThrown = (e.getMessage()
          .contains('You do not have permission to delete this comment'))
        ? true
        : false;
    }
    System.assertEquals(true, exceptionThrown);
  }
}
