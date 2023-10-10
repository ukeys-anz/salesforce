/*
 * @author Asteward Mikho
 * @since  08/2021
 * @description ChatterFeedCommentTriggerHandlerTest is the test class to cover tests for {@link ChatterFeedCommentTriggerHandler}
 */
@isTest
public with sharing class ChatterFeedCommentTriggerHandlerTest {
  @testSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    // Create coach user
    System.runAs(TestDataFactory.thisUser) {
      User coachUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'TestCoachUser',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => coachRole.Id
        }
      );
      insert coachUser;
      //Assign Permission set group as coach
      PermissionSetGroup psgCoach = [
        SELECT Id
        FROM PermissionSetGroup
        WHERE DeveloperName = 'Coach'
        LIMIT 1
      ];
      Test.calculatePermissionSetGroup(new List<String>{ psgCoach.Id });
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = coachUser.Id,
        PermissionSetGroupId = psgCoach.Id
      );
      insert psa;
    }
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
    Boolean exceptionThrown = false;
    try {
      comment.commentBody = 'This is edit'; /* Since we have disabled Chatter post "Edit" feature in Chatter settings
       Move this into try block to catch "Field is not Writeable" exception*/
      update comment;
      System.assert(
        false,
        'Failed to prevent against user updating a not writeable feed comment.'
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
    FeedItem post = [SELECT Id FROM FeedItem LIMIT 1];
    FeedComment comment = new FeedComment();
    comment.FeedItemId = post.Id;
    comment.commentBody = 'Test Post';
    insert comment;
    Boolean exceptionThrown = false;
    try {
      delete comment;
      System.assert(
        false,
        'Failed to prevent against user deleting feed comment when lack of permission'
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
  static void testInteractionFeedCommentInsertWithoutMasking() {
    String valueToPost = '1234567344';
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');
    FeedItem post = new FeedItem();
    FeedComment comment = new FeedComment();

    System.runAs(coachUser) {
      Test.startTest();
      post = createInteractionAndFeedItem();
      comment.FeedItemId = post.Id;
      comment.commentBody = valueToPost;
      insert comment;
      //Creating Chatter Post for the Interaction record
      Test.stopTest();
    }

    FeedComment insertedComment = [
      SELECT Id, commentBody
      FROM FeedComment
      WHERE FeedItemId = :post.Id
    ];
    // THEN the chatter should  be created withot the masking of the digit
    System.assertEquals(
      valueToPost,
      insertedComment.commentBody,
      'There will be no masking done for the feed comment posted'
    );
  }

  @isTest
  static void testInteractionFeedCommentInsertWithMasking() {
    String valueToPost = '1234567344738686386868';
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');
    FeedItem post = new FeedItem();
    FeedComment comment = new FeedComment();

    System.runAs(coachUser) {
      Test.startTest();
      post = createInteractionAndFeedItem();
      comment.FeedItemId = post.Id;
      comment.commentBody = valueToPost;
      insert comment;
      //Creating Chatter Post for the Interaction record
      Test.stopTest();
    }
    FeedComment insertedComment = [
      SELECT Id, commentBody
      FROM FeedComment
      WHERE FeedItemId = :post.Id
    ];
    // THEN the chatter should  be created withot the masking of the digit
    System.assertNotEquals(
      valueToPost,
      insertedComment.commentBody,
      'There will be masking done for the feed comment posted'
    );
  }
  /**
   * @description helper method to create interaction record
   * @return Return FeedItemRecord
   */
  static FeedItem createInteractionAndFeedItem() {
    Interaction testInteraction = new Interaction();

    testInteraction = TestDataFactory.createInteraction(
      GetHelpConstants.INTERACTION_STORE_RT_ID,
      InteractionConstants.NONCUSTOMER,
      'New Interaction',
      System.now(),
      false
    );
    testInteraction.InteractionType = InteractionConstants.STORE;
    insert testInteraction;

    FeedItem post = new FeedItem();
    post.ParentId = testInteraction.Id;
    post.Body = 'Test Post';
    insert post;

    return post;
  }
}
