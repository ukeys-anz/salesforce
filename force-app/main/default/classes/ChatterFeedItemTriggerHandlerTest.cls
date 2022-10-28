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

    List<Case> caseList = new List<Case>();

    Case newCase = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      AccountId = accnt.Id,
      Origin = 'Email',
      Status = 'Open',
      Type = 'Cards',
      Subject = 'Test Subject - NCC'
    );
    caseList.add(newCase);

    Case newANZxComplaintCase = new Case(
      RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID,
      AccountId = accnt.Id,
      Origin = 'Email',
      Status = 'Open',
      Type = 'Cards',
      Subject = 'Test Subject - ANZx Complaint'
    );
    caseList.add(newANZxComplaintCase);
    insert caseList;
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
      System.assert(
        false,
        'Failed to prevent against user updating a not writeable feed item.'
      );
    } catch (SObjectException e) {
      exceptionThrown = (e.getMessage().contains('Field is not writeable'))
        ? true
        : false;
    }
    System.assertEquals(true, exceptionThrown, 'Field is not writeable');
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
      System.assert(
        false,
        'Failed to prevent against user deleting feed item whenn not having permission.'
      );
    } catch (Exception e) {
      exceptionThrown = (e.getMessage()
          .contains('You do not have permission to delete this comment'))
        ? true
        : false;
    }
    System.assertEquals(
      true,
      exceptionThrown,
      'You do not have permission to delete this comment'
    );
  }

  @isTest
  static void testFeedItemContainsURL() {
    Case newCase = [SELECT Id FROM Case LIMIT 1];

    Boolean exceptionThrown = false;
    try {
      FeedItem post = new FeedItem();
      post.ParentId = newCase.Id;
      post.Body = 'hallo, www.google.com';
      insert post;
      System.assert(
        false,
        'Failed to prevent against user posting feed item with url.'
      );
    } catch (Exception e) {
      exceptionThrown = (e.getMessage()
          .contains('Please remove urls from chatter post'))
        ? true
        : false;
    }
    System.assertEquals(true, exceptionThrown, 'getting unexpected error');
  }

  @isTest
  static void testInsertFeedItem() {
    //GIVEN a Case chatter is created with non-excessive body length
    Case newCase = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.COMPLAINT_RT_ID
      LIMIT 1
    ];

    FeedItem post = new FeedItem();
    post.ParentId = newCase.Id;
    post.Body = 'Test Post 🎉';

    // WHEN the Chatter is inserted
    Test.startTest();
    insert post;
    Test.stopTest();

    FeedItem insertedPost = [
      SELECT Id, Body
      FROM FEEDITEM
      WHERE ParentId = :newCase.Id
    ];

    // THEN the chatter should be successfully created
    System.assertNotEquals(
      null,
      insertedPost,
      'FeedItem should be successfully inserted.'
    );
  }

  @isTest
  static void testInsertFeedItemExcessiveSize() {
    //GIVEN a Case chatter is created with an excessive body length
    Faker faker = new Faker('AU');
    String longBody = faker.randomString(5000);

    Case newCase = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.COMPLAINT_RT_ID
      LIMIT 1
    ];

    FeedItem post = new FeedItem();
    post.ParentId = newCase.Id;
    post.Body = longBody;

    // WHEN the Chatter is inserted
    Boolean exceptionThrown = false;
    try {
      insert post;
      System.assert(
        false,
        'Failed to prevent against inserting excessive feed item body.'
      );
    } catch (DMLException e) {
      exceptionThrown = (e.getMessage()
          .contains('Error: Your post is too long'))
        ? true
        : false;
    }

    // THEN the chatter should not be created and an exception should be thrown
    System.assertEquals(
      true,
      exceptionThrown,
      'Exception should be thrown if content exceeds 4000 bytes'
    );
  }
}
