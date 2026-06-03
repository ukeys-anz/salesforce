/**
 * @author Karen Valeriano
 * @since January 2026
 * @description Test class for {@link RetailInteractionTriggerHandler}
 */
@isTest
private class RetailInteractionTriggerHandlerTest {
  static Lib_MockProvider interactionActionRepoMock;

  static void registerMocks() {
    interactionActionRepoMock = Lib_MockProvider.forType(
      CCRMInteractionActionsRepository.class
    );
  }

  static User testUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    Lan_Id__c = 'TestLanId456',
    ProfileId = QueryProfile.anzxUser.Id
  );

  static Account testAccount = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
    Name = 'Test Retail Account',
    Source_System_ID__c = '222222000000',
    OCV_ID__c = '3300114466'
  );

  /**
   * @description Test isValidRecord method returns true for Retail Interaction record type
   */
  @isTest
  static void testIsValidRecordWithRetailInteraction() {
    Interaction retailInteraction = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Comment__c = 'Test retail interaction',
      AccountId = testAccount.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();

    Test.startTest();
    Boolean isValid = handler.isValidRecord(retailInteraction);
    Test.stopTest();

    Assert.areEqual(
      true,
      isValid,
      'Retail Interaction record type should be valid'
    );
  }

  /**
   * @description Test isValidRecord method returns false for non-Retail Interaction record type
   */
  @isTest
  static void testIsValidRecordWithNonRetailInteraction() {
    Interaction nonRetailInteraction = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.call,
      Comment__c = 'Test call interaction',
      AccountId = testAccount.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();

    Test.startTest();
    Boolean isValid = handler.isValidRecord(nonRetailInteraction);
    Test.stopTest();

    Assert.areEqual(
      false,
      isValid,
      'Non-Retail Interaction record type should not be valid'
    );
  }

  /**
   * @description Test onBeforeInsert performs redaction and masking on sensitive fields
   */
  @isTest
  static void testOnBeforeInsertRedactionAndMasking() {
    Interaction recordWithSensitiveData = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Name = 'Customer called with Passport P12345678',
      Comment__c = 'Credit Card 4111 1111 1111 1111 used for payment',
      Optional_Notes__c = 'TAX number 9876543210 provided',
      Category__c = 'CAP Diary Comments',
      AccountId = testAccount.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();
    handler.allRecords = new List<Interaction>{ recordWithSensitiveData };
    handler.context = TriggerOperation.BEFORE_INSERT;

    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.areEqual(
      'Customer called with Passport P****5678',
      recordWithSensitiveData.Name,
      'Name field should be redacted'
    );
    Assert.areEqual(
      'Credit Card ************1111 used for payment',
      recordWithSensitiveData.Comment__c,
      'Comment__c field should be redacted'
    );
    Assert.areEqual(
      'TAX number ******3210 provided',
      recordWithSensitiveData.Optional_Notes__c,
      'Optional_Notes__c field should be redacted'
    );
  }

  /**
   * @description Test onBeforeInsert handles null and empty fields
   */
  @isTest
  static void testOnBeforeInsertWithNullFields() {
    Interaction recordWithNullFields = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Name = null,
      Comment__c = null,
      Optional_Notes__c = '',
      Category__c = 'CAP Diary Comments',
      AccountId = testAccount.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();
    handler.allRecords = new List<Interaction>{ recordWithNullFields };
    handler.context = TriggerOperation.BEFORE_INSERT;

    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.areEqual(null, recordWithNullFields.Name, 'Name should remain null');
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

  /**
   * @description Test onBeforeInsert with multiple records
   */
  @isTest
  static void testOnBeforeInsertWithMultipleRecords() {
    Interaction record1 = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Name = 'Passport P11111111',
      Comment__c = 'Credit Card 5555 5555 5555 4444',
      Optional_Notes__c = 'Normal text',
      AccountId = testAccount.Id
    );

    Interaction record2 = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Name = 'No sensitive data',
      Comment__c = 'Just a comment',
      Optional_Notes__c = 'TAX 1234567890',
      AccountId = testAccount.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();
    handler.allRecords = new List<Interaction>{ record1, record2 };
    handler.context = TriggerOperation.BEFORE_INSERT;

    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.areEqual(
      'Passport P****1111',
      record1.Name,
      'First record Name should be redacted'
    );
    Assert.areEqual(
      'Credit Card ************4444',
      record1.Comment__c,
      'First record Comment__c should be redacted'
    );
    Assert.areEqual(
      'No sensitive data',
      record2.Name,
      'Second record Name should not be redacted'
    );
    Assert.areEqual(
      'TAX ******7890',
      record2.Optional_Notes__c,
      'Second record Optional_Notes__c should be redacted'
    );
  }

  /**
   * @description Test onAfterInsert publishes cloud events
   */
  @isTest
  static void testOnAfterInsertPublishesCloudEvents() {
    registerMocks();

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

    Interaction retailInteraction = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Comment__c = 'CAP diary comment',
      Optional_Notes__c = 'Additional notes',
      Category__c = 'CAP Diary Comments',
      AccountId = testAccount.Id,
      OwnerId = testUser.Id,
      LastModifiedById = testUser.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();
    handler.allRecords = new List<Interaction>{ retailInteraction };
    handler.context = TriggerOperation.AFTER_INSERT;

    Test.startTest();
    handler.onAfterInsert();
    Test.stopTest();

    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isNotNull(publishedEvents, 'Cloud events should be created');
    Assert.areEqual(
      1,
      publishedEvents.size(),
      'Should create 1 cloud event for the interaction'
    );
  }

  /**
   * @description Test onAfterInsert with multiple interactions
   */
  @isTest
  static void testOnAfterInsertWithMultipleInteractions() {
    registerMocks();

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

    Interaction interaction1 = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Comment__c = 'First interaction',
      Category__c = 'CAP Diary Comments',
      AccountId = testAccount.Id,
      OwnerId = testUser.Id,
      LastModifiedById = testUser.Id
    );

    Interaction interaction2 = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Comment__c = 'Second interaction',
      Category__c = 'CAP Diary Comments',
      AccountId = testAccount.Id,
      OwnerId = testUser.Id,
      LastModifiedById = testUser.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();
    handler.allRecords = new List<Interaction>{ interaction1, interaction2 };
    handler.context = TriggerOperation.AFTER_INSERT;

    Test.startTest();
    handler.onAfterInsert();
    Test.stopTest();

    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isNotNull(publishedEvents, 'Cloud events should be created');
    Assert.areEqual(
      2,
      publishedEvents.size(),
      'Should create 2 cloud events for both interactions'
    );
  }

  /**
   * @description Test that handler filters records correctly based on record type
   */
  @isTest
  static void testHandlerFiltersRecordsByRecordType() {
    Interaction retailInteraction = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.retailInteraction,
      Comment__c = 'Retail interaction',
      AccountId = testAccount.Id
    );

    Interaction callInteraction = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.call,
      Comment__c = 'Call interaction',
      AccountId = testAccount.Id
    );

    Interaction messageInteraction = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      RecordTypeId = RTInteraction.message,
      Comment__c = 'Message interaction',
      AccountId = testAccount.Id
    );

    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();
    handler.allRecords = new List<Interaction>{
      retailInteraction,
      callInteraction,
      messageInteraction
    };
    handler.context = TriggerOperation.BEFORE_INSERT;

    Test.startTest();
    List<SObject> filteredRecords = handler.records;
    Test.stopTest();

    Assert.areEqual(
      1,
      filteredRecords.size(),
      'Should only include Retail Interaction records'
    );
    Assert.areEqual(
      retailInteraction.Id,
      filteredRecords[0].Id,
      'Filtered record should be the retail interaction'
    );
  }

  /**
   * @description Test constructor initializes handler correctly
   */
  @isTest
  static void testConstructor() {
    Test.startTest();
    RetailInteractionTriggerHandler handler = new RetailInteractionTriggerHandler();
    Test.stopTest();

    Assert.isNotNull(handler, 'Handler should be instantiated');
  }
}
