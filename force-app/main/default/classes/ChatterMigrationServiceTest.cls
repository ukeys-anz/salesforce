/**
 * @author Mouhamed "Mo" Assafiri"
 * @since  11/2020
 * @description Test class to cover tests for {@link ChatterMigrationService}
 */
@isTest
public with sharing class ChatterMigrationServiceTest {
  private static final string VICTIM_OCV = 'OCVID887766';
  private static final string SURVIVOR_OCV = 'OCVID8877662';

  private static final string VICTIM_EXTERNAL_ID = 'OCVID887766CAPSYSID123';
  private static final string SURVIVOR_EXTERNAL_ID = 'OCVID887766CAPSYSID123-2';

  @testSetup
  static void testSetup() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Profile p = CommonUtil.getProfileByName('Minimum Access - External Apps');
      UserRole role = CommonUtil.getUserRoleByDevName('ANZx');

      User apiUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'OCVUserTest',
          'ProfileId' => p.Id,
          'UserRoleId' => role.Id
        }
      );
      insert apiUser;

      // Assign Case related PS on API User
      List<String> psNames = new List<String>{
        'Enforce_mTLS',
        'FinancialServicesCloudStandard',
        'Read_Write_Customer_Details',
        'Moderate_Chatter'
      };
      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :psNames
      ];
      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(apiUser.id, ps.Id));
      }
      insert psaList;
    }

    Faker faker = new Faker('AU');

    // Insert Account (Victim and Survivor) records
    List<String> companyNames = faker.text.realWords(2);
    List<Account> accounts = new List<Account>();

    accounts.add(
      new Account(
        Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
        OCV_ID__c = VICTIM_OCV,
        ANZx_Customer__c = true,
        External_Id__c = VICTIM_EXTERNAL_ID
      )
    );

    companyNames = faker.text.realWords(2);
    accounts.add(
      new Account(
        Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
        OCV_ID__c = SURVIVOR_OCV,
        ANZx_Customer__c = true,
        External_Id__c = SURVIVOR_EXTERNAL_ID
      )
    );

    insert accounts;

    //Inserts Two Feed Items into the VICTIM account
    List<FeedItem> posts = new List<FeedItem>();
    FeedItem post = new FeedItem();
    post.ParentId = accounts[0].id;
    post.Body = 'This is a test post 1';
    posts.add(post);

    FeedItem post2 = new FeedItem();
    post2.ParentId = accounts[0].id;
    post2.Body = 'This is a test post 2';
    posts.add(post2);

    insert posts;

    //Insert FeedComments into the above posts

    List<FeedComment> comments = new List<FeedComment>();
    for (FeedItem createdPost : posts) {
      comments.add(
        new FeedComment(
          CommentBody = 'Testing Comment',
          FeedItemId = createdPost.Id,
          CommentType = 'TextComment'
        )
      );
    }

    insert comments;
  }

  /* 
    @description Test that a 404 is returned when the one of the parameters are blank 
  */
  @isTest
  static void testFailedAPICallBlank() {
    User usr = TestUtil.getUserByFirstName('OCVUserTest');

    prepareRequest(VICTIM_EXTERNAL_ID, null);

    Test.startTest();
    System.runAs(usr) {
      ChatterMigrationServiceController.migrate();
    }
    Test.stopTest();

    System.assert(
      (RestContext.response.statusCode == 400),
      'API Response did not return with a 400'
    );

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      RestContext.response.responseBody.toString()
    );

    System.assertEquals(
      'Bad paylod: required input missing',
      response.get('error'),
      'API Response did not contain error message'
    );
  }

  /* 
    @description Test that a 404 is returned when one of the Ids are not found
  */
  @isTest
  static void testFailedAPIWrongVictimId() {
    User usr = TestUtil.getUserByFirstName('OCVUserTest');

    prepareRequest('ThisShouldFail', SURVIVOR_EXTERNAL_ID);

    Test.startTest();
    System.runAs(usr) {
      ChatterMigrationServiceController.migrate();
    }
    Test.stopTest();

    System.assert(
      (RestContext.response.statusCode == 404),
      'API Response did not return with a 404'
    );

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      RestContext.response.responseBody.toString()
    );

    System.assertEquals(
      'The victimId used does not match with any Accounts',
      response.get('error'),
      'API Response did not contain error message'
    );
  }

  /* 
    @description Test that a 200 is returned and successful migration of Chatter Posts
  */
  @isTest
  static void testMigrationAPICall() {
    User usr = TestUtil.getUserByFirstName('OCVUserTest');

    prepareRequest(VICTIM_EXTERNAL_ID, SURVIVOR_EXTERNAL_ID);

    Test.startTest();
    System.runAs(usr) {
      ChatterMigrationServiceController.migrate();
    }
    Test.stopTest();

    System.assert(
      (RestContext.response.statusCode == 200),
      'API Response did not return with a Successful 200'
    );

    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      RestContext.response.responseBody.toString()
    );

    System.assertEquals(
      'true',
      response.get('success'),
      'API Response did not contain success message'
    );

    SystemModeActions systemAction = new SystemModeActions(
      'ChatterMigrationServiceTest',
      'testMigrationAPICall'
    );
    List<FeedItem> feedOld = systemAction.query(
      'SELECT Body, BestCommentId, CommentCount, LikeCount, Type FROM FeedItem WHERE ParentId = \'' +
      ChatterMigrationService.getAccountIdFromExternalId(VICTIM_EXTERNAL_ID) +
      '\''
    );

    List<FeedItem> feedNew = systemAction.query(
      'SELECT Body, BestCommentId, CommentCount, LikeCount, Type FROM FeedItem WHERE ParentId = \'' +
      ChatterMigrationService.getAccountIdFromExternalId(SURVIVOR_EXTERNAL_ID) +
      '\''
    );

    List<FeedComment> feedComments = systemAction.query(
      'SELECT CommentBody, CreatedById, CreatedDate, FeedItemId, CommentType From FeedComment'
    );

    System.assert(
      (feedOld.size() == 0),
      'Expected that the Victim Account to have 0 feed items in the test'
    );

    System.assert(
      (feedNew.size() == 2),
      'Expected that the Survivor Account to have 2 feed items in the test'
    );

    System.assert(
      (feedComments.size() == 2),
      'Expected that the Feed has 2 comments copied over'
    );
  }

  /**
   * @description Method to prepare REST requests for test scenarios.
   * @param victimId
   * @param survivorId
   */
  private static void prepareRequest(String victimId, String survivorId) {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChatterMigrate'; //Request URL
    req.httpMethod = 'POST';

    Map<String, String> payload = new Map<String, String>();

    if (String.isNotBlank(victimId)) {
      payload.put('victimId', victimId);
    }

    if (String.isNotBlank(survivorId)) {
      payload.put('survivorId', survivorId);
    }

    req.requestBody = Blob.valueOf(JSON.serialize(payload));
    RestContext.request = req;
    RestContext.response = res;
  }
}
