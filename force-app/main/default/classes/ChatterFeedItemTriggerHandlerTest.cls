/*
 * @author Asteward Mikho
 * @since  08/2021
 * @description ChatterFeedItemTriggerHandlerTest is the test class to cover tests for {@link ChatterFeedItemTriggerHandler}
 */
@isTest
public with sharing class ChatterFeedItemTriggerHandlerTest {
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
  static void testFeedItemContainsEmail() {
    //GIVEN a Case chatter is created with email on chatter body
    Case newCase = [SELECT Id FROM Case LIMIT 1];

    FeedItem post = new FeedItem();
    post.ParentId = newCase.Id;
    post.Body = 'hello test.user@anztest.com';

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
    System.assertEquals(
      insertedPost.Body,
      'hello test.user@anztest.com',
      'FeedItem should be successfully inserted.'
    );
  }

  @isTest
  static void testFeedItemContainsEmailAndURL() {
    //GIVEN a Case chatter is created with email and url on chatter post
    Case newCase = [SELECT Id FROM Case LIMIT 1];

    try {
      FeedItem post = new FeedItem();
      post.ParentId = newCase.Id;
      post.Body = 'hallo, test.user@anztest.com. you will navigate to www.google.com';
      insert post;
      System.assert(
        false,
        'Failed to prevent against user posting feed item with url.'
      );
    } catch (Exception e) {
      Boolean exceptionThrown = e.getMessage()
        .contains('Please remove urls from chatter post');
      System.assertEquals(
        true,
        exceptionThrown,
        'The chatter post contains url.'
      );
    }
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

  @isTest
  static void testInteractionFeedItemUpdateWithoutMasking() {
    String valueToPost = '1234567344';
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');
    FeedItem post = new FeedItem();
    Interaction testInteraction = new Interaction();

    System.runAs(coachUser) {
      Test.startTest();
      testInteraction = createTestInteraction();
      post.ParentId = testInteraction.Id;
      post.Body = valueToPost;

      //Creating Chatter Post for the Interaction record
      insert post;
      Test.stopTest();
    }

    FeedItem insertedPost = [
      SELECT Id, Body
      FROM FEEDITEM
      WHERE ParentId = :testInteraction.Id
    ];
    // THEN the chatter should  be created withot the masking of the digit
    System.assertEquals(
      valueToPost,
      insertedPost.Body,
      'There will be no masking done for the feed item posted'
    );
  }

  @isTest
  static void testInteractionFeedItemUpdateWithMasking() {
    String valueToPost = '1234567344738686';
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');
    FeedItem post = new FeedItem();
    Interaction testInteraction = new Interaction();
    System.runAs(coachUser) {
      Test.startTest();
      testInteraction = createTestInteraction();
      post.ParentId = testInteraction.Id;
      post.Body = valueToPost;

      //Creating Chatter Post for the Interaction record
      insert post;
      Test.stopTest();
    }
    FeedItem insertedPost = [
      SELECT Id, Body
      FROM FEEDITEM
      WHERE ParentId = :testInteraction.Id
    ];
    // THEN the chatter should  be created with the masking of the digit
    System.assertNotEquals(
      valueToPost,
      insertedPost.Body,
      'There will be masking done for the feed item posted'
    );
  }
  /**
   * @description helper method to create interaction record
   * @return Return Interaction Record
   */
  static Interaction createTestInteraction() {
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

    return testInteraction;
  }
}
