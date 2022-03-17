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
  }

  /* 
    @description Test that a 404 is returned when the one of the parameters are blank 
  */
  @isTest
  static void testFailedAPICallBlank() {
    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChatterMigrate'; //Request URL
    req.httpMethod = 'POST';

    Map<String, String> payload = new Map<String, String>{
      'victimID' => VICTIM_EXTERNAL_ID
    };

    req.requestBody = Blob.valueOf(JSON.serialize(payload));
    RestContext.request = req;
    RestContext.response = res;

    System.assertEquals(
      false,
      ChatterMigrationServiceController.migrate(),
      'Expecting the migrate controller to fail without both VictimId and SurvivorId'
    );
    System.assert(
      (RestContext.response.statusCode == 400),
      'API Response did not return with a 400'
    );

    Test.stopTest();
  }

  /* 
    @description Test that a 404 is returned when one of the Ids are not found
  */
  @isTest
  static void testFailedAPIWrongVictimId() {
    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChatterMigrate'; //Request URL
    req.httpMethod = 'POST';

    Map<String, String> payload = new Map<String, String>{
      'victimId' => 'ThisShouldFail',
      'survivorId' => SURVIVOR_EXTERNAL_ID
    };
    req.requestBody = Blob.valueOf(JSON.serialize(payload));
    RestContext.request = req;
    RestContext.response = res;

    System.assertEquals(
      false,
      ChatterMigrationServiceController.migrate(),
      'Expecting the migrate controller to fail with a incorrect Account External ID'
    );
    System.assert(
      (RestContext.response.statusCode == 404),
      'API Response did not return with a 404'
    );

    Test.stopTest();
  }

  /* 
    @description Test that a 200 is returned and successful migration of Chatter Posts
  */
  @isTest
  static void testMigrationAPICall() {
    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/ChatterMigrate'; //Request URL
    req.httpMethod = 'POST';

    Map<String, String> payload = new Map<String, String>{
      'victimId' => VICTIM_EXTERNAL_ID,
      'survivorId' => SURVIVOR_EXTERNAL_ID
    };
    req.requestBody = Blob.valueOf(JSON.serialize(payload));
    RestContext.request = req;
    RestContext.response = res;

    System.assertEquals(
      true,
      ChatterMigrationServiceController.migrate(),
      'Expecting the migrate controller to migrate successfully and return true'
    );
    System.assert(
      (RestContext.response.statusCode == 200),
      'API Response did not return with a Successful 200'
    );

    List<Account> accounts = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = :SURVIVOR_OCV
    ];
    List<FeedItem> feed = [
      SELECT Body, BestCommentId, CommentCount, LikeCount, Type
      FROM FeedItem
      WHERE ParentId = :accounts[0].Id
    ];
    System.assert(
      (feed.size() == 2),
      'Expected that the Survivor Account to have 2 feed items in the test'
    );

    Test.stopTest();
  }
}
