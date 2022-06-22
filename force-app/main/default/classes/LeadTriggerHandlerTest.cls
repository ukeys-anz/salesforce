/**
 * @author Emma Bindi
 * @since  05/2022
 * @description Test class to cover tests for {@link LeadTriggerHandler}
 */
@IsTest
public with sharing class LeadTriggerHandlerTest {
  @TestSetup
  static void setup() {
    // Insert lead which we will match & convert to an account later
    List<Lead> leadsList = new List<Lead>();

    for (Integer i = 0; i < 2; i++) {
      Lead l = new Lead();
      l.Firstname = 'Jasmina';
      l.Lastname = 'Schmidtt' + i;
      l.Email = 'Jasmina.Schmidtt' + i + '@gmail.com';
      l.MobilePhone = '040112313' + i;
      l.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;
      leadsList.add(l);
    }
    insert leadsList;

    // Insert 2 chatter posts on the Leads which will be migrated to the respective Accounts upon conversion
    List<FeedItem> chatterPostList = new List<FeedItem>();

    for (Lead lead : leadsList) {
      for (Integer i = 0; i < 2; i++) {
        FeedItem chatterPost = new FeedItem();
        chatterPost.Body = 'The body of this wonderful chatter post' + i;
        chatterPost.Type = 'TextPost';
        chatterPost.ParentId = lead.Id;
        chatterPostList.add(chatterPost);
      }
    }
    insert chatterPostList;

    // Insert a comment on each of the chatter posts inserted above
    // which will also be migrated to the accounts upon conversion
    List<FeedComment> chatterCommentList = new List<FeedComment>();

    for (FeedItem chatterPost : chatterPostList) {
      FeedComment chatterComment = new FeedComment();
      chatterComment.CommentBody = 'Yes I totally agree';
      chatterComment.CommentType = 'TextComment';
      chatterComment.FeedItemId = chatterPost.Id;
      chatterCommentList.add(chatterComment);
    }
    insert chatterCommentList;
  }

  @IsTest
  public static void testChatterMigrationOnLeadConversion() {
    // Get the existing Lead Ids
    List<Lead> leadsToBeConverted = [
      SELECT Id
      FROM Lead
      WHERE FirstName = 'Jasmina'
    ];

    // Retrieve the Leads chatter posts & comments
    List<FeedItem> leadsChatterPostList = [
      SELECT Id, Body, ParentId, CommentCount
      FROM FeedItem
      WHERE ParentId IN :leadsToBeConverted
    ];

    System.assertEquals(
      4,
      leadsChatterPostList.size(),
      'Sanity check - there should be 4 chatter posts for this test case.'
    );

    // Insert an account which matches existing lead so that conversion takes place
    Faker faker = new Faker('AU');

    List<Account> accountList = new List<Account>();

    for (Integer i = 0; i < 2; i++) {
      Account acc = new Account(
        FirstName = 'Jasmina',
        LastName = 'Schmidtt' + i,
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = true,
        RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
        PersonEmail = 'Jasmina.Schmidtt' + i + '@gmail.com',
        PersonMobilePhone = '040112313' + i
      );
      accountList.add(acc);
    }

    Test.startTest();
    // When these accounts are inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert accountList;
    }
    Test.stopTest();

    // Query for the inserted account Ids
    List<Account> newAccounts = [
      SELECT Id
      FROM Account
      WHERE Id IN :accountList
    ];

    // Query for the Account's chatter posts to make sure migration occurred
    List<FeedItem> accountsChatterPostList = [
      SELECT Id, Body, ParentId, CommentCount
      FROM FeedItem
      WHERE ParentId IN :newAccounts
    ];

    System.assertEquals(
      true,
      accountsChatterPostList[0]
        .Body.contains('The body of this wonderful chatter post'),
      'Lead chatter should be migrated to account'
    );

    List<FeedComment> feedCommentList = [
      SELECT CommentBody, CreatedById, CreatedDate, FeedItemId, CommentType
      FROM FeedComment
    ];

    System.assertEquals(
      8,
      feedCommentList.size(),
      'Lead chatter post comments should be migrated to accounts'
    );
  }

  @IsTest
  public static void testLeadConversionWithNoChatter() {
    String firstName = 'Pierre';
    String lastName = 'Medallion';
    String email = 'Pierre.Medallion@gmail.com';
    String mobilePhone = '0401555444';

    Lead l = new Lead();
    l.Firstname = firstName;
    l.Lastname = lastName;
    l.Email = email;
    l.MobilePhone = mobilePhone;
    l.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;
    insert l;

    // Get the existing Lead Ids
    Lead leadToBeConverted = [
      SELECT Id
      FROM Lead
      WHERE LastName = 'Medallion'
      LIMIT 1
    ];

    // Retrieve the Leads chatter posts & comments
    List<FeedItem> leadsChatterPostList = [
      SELECT Id, Body, ParentId, CommentCount
      FROM FeedItem
      WHERE ParentId = :leadToBeConverted.Id
    ];
    System.assertEquals(
      0,
      leadsChatterPostList.size(),
      'Sanity check - there should be no chatter for this test case.'
    );

    // Insert an account which matches existing lead so that conversion takes place
    Faker faker = new Faker('AU');

    Account acc = new Account(
      FirstName = firstName,
      LastName = lastName,
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = email,
      PersonMobilePhone = mobilePhone
    );

    Test.startTest();
    // When these accounts are inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert acc;
    }
    Test.stopTest();

    // Query for the inserted account Ids
    Account newAccount = [SELECT Id FROM Account WHERE Id = :acc.Id LIMIT 1];

    // Query for the Account's chatter posts to make sure migration occurred
    List<FeedItem> accountsChatterPostList = [
      SELECT Id, Body, ParentId, CommentCount
      FROM FeedItem
      WHERE ParentId = :acc.Id
    ];
    System.assertEquals(
      0,
      accountsChatterPostList.size(),
      'No chatter records should have been migrated if not existing on Lead.'
    );

    System.assertNotEquals(
      null,
      newAccount,
      'Lead should have been converted successully.'
    );
  }
}
