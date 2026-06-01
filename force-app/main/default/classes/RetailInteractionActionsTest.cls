/**
 * @author Karen Valeriano
 * @since January 2026
 * @description tests for {@link RetailInteractionActions}
 */
@isTest
private class RetailInteractionActionsTest {
  static Lib_MockProvider interactionActionRepoMock;

  static void registerMocks() {
    interactionActionRepoMock = Lib_MockProvider.forType(
      CCRMInteractionActionsRepository.class
    );
  }

  static User testUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    Lan_Id__c = 'TestLanId123',
    ProfileId = QueryProfile.anzxUser.Id
  );

  static Account testAccount = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
    Name = 'Test Customer Account',
    Source_System_ID__c = '111111000000',
    OCV_ID__c = '2200993355'
  );

  static Interaction recordWithSensitiveData = new Interaction(
    Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
    Comment__c = 'Comment Passport is P12345678 and Credit Card 4111 1111 1111 1111',
    Optional_Notes__c = 'Optional Notes TAX 9876543210',
    RecordTypeId = RTInteraction.retailInteraction,
    Category__c = 'CAP Diary Comments',
    AccountId = testAccount.Id,
    OwnerId = testUser.Id,
    LastModifiedById = testUser.Id
  );

  static Interaction recordWithOutSensitiveData = new Interaction(
    Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
    Comment__c = 'Comment Only',
    Optional_Notes__c = 'Optional Notes Only',
    RecordTypeId = RTInteraction.retailInteraction,
    Category__c = 'CAP Diary Comments',
    AccountId = testAccount.Id,
    OwnerId = testUser.Id,
    LastModifiedById = testUser.Id
  );

  static Interaction recordWithNullFields = new Interaction(
    Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
    Comment__c = null,
    Optional_Notes__c = ''
  );

  static Interaction recordWithMixedSensitiveData = new Interaction(
    Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
    Comment__c = 'Customer provided Passport P87654321 and TAX 1234567890',
    Optional_Notes__c = 'Credit Card 5555 5555 5555 4444 on file'
  );

  @isTest
  static void testPerformRedactionSensitiveData() {
    Test.startTest();
    RetailInteractionActions.performRedaction(
      new List<Interaction>{ recordWithSensitiveData }
    );
    Test.stopTest();

    Assert.areEqual(
      'Comment Passport is P****5678 and Credit Card ************1111',
      recordWithSensitiveData.Comment__c,
      'Comment__c should be redacted'
    );
    Assert.areEqual(
      'Optional Notes TAX ******3210',
      recordWithSensitiveData.Optional_Notes__c,
      'Optional_Notes__c should be redacted'
    );
  }

  @isTest
  static void testPerformRedactionNoSensitiveData() {
    Test.startTest();
    RetailInteractionActions.performRedaction(
      new List<Interaction>{ recordWithOutSensitiveData }
    );
    Test.stopTest();

    Assert.areEqual(
      'Comment Only',
      recordWithOutSensitiveData.Comment__c,
      'Comment__c should not be redacted'
    );
    Assert.areEqual(
      'Optional Notes Only',
      recordWithOutSensitiveData.Optional_Notes__c,
      'Optional_Notes__c should not be redacted'
    );
  }

  @isTest
  static void testPerformRedactionNullFields() {
    Test.startTest();
    RetailInteractionActions.performRedaction(
      new List<Interaction>{ recordWithNullFields }
    );
    Test.stopTest();

    Assert.areEqual(
      null,
      recordWithNullFields.Comment__c,
      'Comment__c should remain null'
    );
    Assert.areEqual(
      '',
      recordWithNullFields.Optional_Notes__c,
      'Optional_Notes__c should remain empty'
    );
  }

  @isTest
  static void testPerformRedactionMultipleSensitiveDataTypes() {
    Test.startTest();
    RetailInteractionActions.performRedaction(
      new List<Interaction>{ recordWithMixedSensitiveData }
    );
    Test.stopTest();

    Assert.areEqual(
      'Customer provided Passport P****4321 and TAX ******7890',
      recordWithMixedSensitiveData.Comment__c,
      'Comment__c should redact both Passport and TAX'
    );
    Assert.areEqual(
      'Credit Card ************4444 on file',
      recordWithMixedSensitiveData.Optional_Notes__c,
      'Optional_Notes__c should redact Credit Card'
    );
  }

  @isTest
  static void testPerformRedactionMultipleRecords() {
    Test.startTest();
    RetailInteractionActions.performRedaction(
      new List<Interaction>{
        recordWithSensitiveData,
        recordWithOutSensitiveData,
        recordWithMixedSensitiveData
      }
    );
    Test.stopTest();

    Assert.areEqual(
      'Comment Passport is P****5678 and Credit Card ************1111',
      recordWithSensitiveData.Comment__c,
      'First record should be redacted'
    );
    Assert.areEqual(
      'Comment Only',
      recordWithOutSensitiveData.Comment__c,
      'Second record should not be redacted'
    );
    Assert.areEqual(
      'Customer provided Passport P****4321 and TAX ******7890',
      recordWithMixedSensitiveData.Comment__c,
      'Third record should be redacted'
    );
  }

  @isTest
  static void testPublishCloudEventsWithCapDiaryComment() {
    registerMocks();

    // Mock the repository methods
    interactionActionRepoMock.mock(
      'getCustomers',
      new List<Account>{ testAccount }
    );
    interactionActionRepoMock.mock('getOpportunities', new List<Opportunity>());
    interactionActionRepoMock.mock(
      'getFinAccounts',
      new List<FinServ__FinancialAccount__c>()
    );
    interactionActionRepoMock.mock('getUsers', new List<User>{ testUser });

    Test.startTest();
    RetailInteractionActions.publishCloudEvents(
      new List<Interaction>{ recordWithSensitiveData },
      'create'
    );
    Test.stopTest();

    // Verify cloud events were published (check the @TestVisible field)
    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isNotNull(
      publishedEvents,
      'Cloud events should be created for CAP diary comments'
    );
    Assert.areEqual(1, publishedEvents.size(), 'Should create 1 cloud event');
  }

  @isTest
  static void testPublishCloudEventsEmptyList() {
    Test.startTest();
    RetailInteractionActions.publishCloudEvents(
      new List<Interaction>(),
      'create'
    );
    Test.stopTest();

    // Verify no cloud events were created due to early return
    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isTrue(
      publishedEvents == null || publishedEvents.isEmpty(),
      'No cloud events should be created for empty list'
    );
  }

  @isTest
  static void testPublishCloudEventsNullList() {
    Test.startTest();
    RetailInteractionActions.publishCloudEvents(null, 'create');
    Test.stopTest();

    // Verify no cloud events were created due to early return
    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isTrue(
      publishedEvents == null || publishedEvents.isEmpty(),
      'No cloud events should be created for null list'
    );
  }

  @isTest
  static void testPerformRedactionEmptyList() {
    Test.startTest();
    RetailInteractionActions.performRedaction(new List<Interaction>());
    Test.stopTest();

    Assert.isTrue(true, 'Should handle empty list without errors');
  }

  @isTest
  static void testPerformRedactionNullList() {
    Test.startTest();
    RetailInteractionActions.performRedaction(null);
    Test.stopTest();

    Assert.isTrue(true, 'Should handle null list without errors');
  }

  @isTest
  static void testPublishCloudEventsErrorHandling() {
    registerMocks();

    // Mock the repository to throw an exception
    interactionActionRepoMock.mockException(
      'getCustomers',
      new System.DmlException('Test exception')
    );

    Test.startTest();
    try {
      RetailInteractionActions.publishCloudEvents(
        new List<Interaction>{ recordWithSensitiveData },
        'create'
      );
      Assert.fail('Expected exception to be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof System.DmlException,
        'Should throw the original exception'
      );
      Assert.areEqual(
        'Test exception',
        e.getMessage(),
        'Exception message should match'
      );
    }
    Test.stopTest();
  }
}
