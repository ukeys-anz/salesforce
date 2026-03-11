/**
 * @author Tan Phan
 * @since 06/2024
 * @description Tests for {@link ProfileStagingHandler}
 */
@isTest
private class ProfileStagingHandlerTest {
  static final Faker FAKER = new Faker('en-AU');

  static Lib_MockProvider repoMock;
  static Lib_MockProvider userMock;
  static Lib_MockProvider dmlRepoMock;

  static User currentUser = new User(Lan_Id__c = FAKER.randomString(6));
  static ConfigTest config = new ConfigTest();
  static Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c(
    Id = Lib_FakeIdGenerator.getMockId(Customer_Profile_Updates__c.SObjectType),
    Customer_Name__r = new Account(
      RecordType = new RecordType(DeveloperName = 'Individual')
    )
  );
  static Account record = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
  );
  static Customer_Profile_Updates__c cpuUpdate = new Customer_Profile_Updates__c(
    Id = cpu.Id,
    Action__c = 'Update',
    Status__c = 'Pending',
    UserLanId__c = currentUser.Lan_Id__c
  );

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    repoMock = Lib_MockProvider.forType(ProfileStagingRepository.class)
      .mock('queryEventConfig', new List<ProfileStagingEventConfig__mdt>());
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('getUser', currentUser);
  }

  @IsTest
  static void testProcess() {
    registerMocks();
    config.processOverride = true;
    repoMock.mock(
      'queryCustomerProfileUpdates',
      new List<Customer_Profile_Updates__c>{ cpu }
    );

    ProfileStagingHandler handler = new ProfileStagingHandler();
    handler.templateCpu = cpuUpdate;

    Test.startTest();
    handler
      .process(
        config,
        new List<SObject>{ record },
        new Map<Id, SObject>{ record.Id => record }
      );
    Test.stopTest();

    List<Customer_Profile_Updates__c> updates = (List<Customer_Profile_Updates__c>) dmlRepoMock
      .getHistory('doInsert')
      .getParam('records');

    List<Customer_Profile_Update_Event__e> events = (List<Customer_Profile_Update_Event__e>) dmlRepoMock
      .getHistory('doPublish')
      .getParam('events');

    Assert.areEqual(
      cpuUpdate,
      updates[0],
      'Customer_Profile_Updates__c should be generated'
    );
    Assert.areEqual(
      new Customer_Profile_Update_Event__e(
        Customer_Profile_Update_Identifier__c = cpu.Id,
        RecordType_Name__c = 'Individual'
      ),
      events[0],
      'Event should contains info for Customer_Profile_Updates__c from query'
    );
  }

  @IsTest
  static void testGenerateUpdatesActionAdd() {
    registerMocks();
    config.processOverride = true;

    Test.startTest();
    List<Customer_Profile_Updates__c> updates = new ProfileStagingHandler()
      .generateUpdates(config, new List<SObject>{ record }, null);
    Test.stopTest();

    Assert.isFalse(updates.isEmpty(), 'List of updates should not be empty');
    Assert.areEqual(
      new Customer_Profile_Updates__c(
        Action__c = 'Add',
        Status__c = 'Pending',
        UserLanId__c = currentUser.Lan_Id__c
      ),
      updates[0],
      'The update should be the same as the Customer_Profile_Updates__c with Action Add'
    );
  }

  @IsTest
  static void testGenerateUpdatesActionUpdate() {
    registerMocks();
    config.processOverride = true;

    Test.startTest();
    List<Customer_Profile_Updates__c> updates = new ProfileStagingHandler()
      .generateUpdates(
        config,
        new List<SObject>{ record },
        new Map<Id, SObject>{ record.Id => record }
      );
    Test.stopTest();

    Assert.isFalse(updates.isEmpty(), 'List of updates should not be empty');
    Assert.areEqual(
      new Customer_Profile_Updates__c(
        Action__c = 'Update',
        Status__c = 'Pending',
        UserLanId__c = currentUser.Lan_Id__c
      ),
      updates[0],
      'The update should be the same as the Customer_Profile_Updates__c with Action Update'
    );
  }

  @IsTest
  static void testGenerateUpdatesNoChanges() {
    registerMocks();
    config.processOverride = false;

    Test.startTest();
    List<Customer_Profile_Updates__c> updates = new ProfileStagingHandler()
      .generateUpdates(
        config,
        new List<SObject>{ record },
        new Map<Id, SObject>{ record.Id => record }
      );
    Test.stopTest();

    Assert.isTrue(
      updates.isEmpty(),
      'List of updates should be empty when no changes'
    );
  }

  @IsTest
  static void testGeneratePlatformEvent() {
    Test.startTest();
    Customer_Profile_Update_Event__e event = new ProfileStagingHandler()
      .generatePlatformEvent(cpu);
    Test.stopTest();

    Assert.isNotNull(event, 'Event should not be null');
    Assert.areEqual(
      cpu.Id,
      event.Customer_Profile_Update_Identifier__c,
      'Event should have the same id as the Customer_Profile_Updates__c'
    );
    Assert.areEqual(
      'Individual',
      event.RecordType_Name__c,
      'Event should have the same record type as the Customer_Profile_Updates__c'
    );
  }

  @IsTest
  static void testGeneratePlatformEventAccountNull() {
    cpu.Customer_Name__r = null;
    Test.startTest();
    Customer_Profile_Update_Event__e event = new ProfileStagingHandler()
      .generatePlatformEvent(cpu);
    Test.stopTest();

    Assert.isNotNull(event, 'Event should not be null');
    Assert.areEqual(
      null,
      event.RecordType_Name__c,
      'Event record type should be null when account is null'
    );
  }

  @IsTest
  static void testGeneratePlatformEventAccountRecordTypeNull() {
    cpu.Customer_Name__r = new Account();
    Test.startTest();
    Customer_Profile_Update_Event__e event = new ProfileStagingHandler()
      .generatePlatformEvent(cpu);
    Test.stopTest();

    Assert.isNotNull(event, 'Event should not be null');
    Assert.areEqual(
      null,
      event.RecordType_Name__c,
      'Event record type should be null when account record type is null'
    );
  }

  @isTest
  static void testGenerateCloudEvent() {
    Test.startTest();
    ProfileStagingEventConfig__mdt mdt = new ProfileStagingEventConfig__mdt(
      RelatedIdField__c = 'Customer_Name__c',
      Subject__c = 'Customer_Name__c',
      PartitionKey__c = 'Customer_Name__c',
      PayloadModel__c = 'ProfileStagingHandlerTest.MockChange'
    );
    Cloud_Event__e event = new ProfileStagingHandler()
      .generateCloudEvent(cpu, mdt);
    Test.stopTest();

    Assert.isNotNull(event, 'Event should not be null');
    Assert.isNotNull(event.Data_1__c, 'Data_1__c should not be null');
    Assert.isTrue(
      event.Data_1__c.contains('"recordTypeName" : "Individual"'),
      'Data_1__c should contain the record type name'
    );
  }

  //test publishEvents for only platform events
  @IsTest
  static void testPublishEventsOnlyPlatformEvent() {
    registerMocks();
    repoMock.mock(
      'queryCustomerProfileUpdates',
      new List<Customer_Profile_Updates__c>{ cpu }
    );
    repoMock.mock('getEventConfig', null);

    Test.startTest();
    new ProfileStagingHandler().publishEvents(new Set<Id>{ cpu.Id });
    Test.stopTest();

    Assert.isFalse(
      repoMock.getHistories('getEventConfig').isEmpty(),
      'getEventConfig should have been called.'
    );

    List<sObject> events = (List<sObject>) dmlRepoMock
      .getHistory('doPublish')
      .getParam('events');
    Assert.isFalse(events.isEmpty(), 'Should not be empty');
    Assert.isTrue(
      events[0] instanceof Customer_Profile_Update_Event__e,
      'Event should be instance of Customer_Profile_Update_Event__e'
    );
  }

  //only cloud event
  @IsTest
  static void testPublishEventsOnlyCloudEvent() {
    registerMocks();
    repoMock.mock(
      'queryCustomerProfileUpdates',
      new List<Customer_Profile_Updates__c>{ cpu }
    );
    repoMock.mock(
      'getEventConfig',
      new ProfileStagingEventConfig__mdt(
        RelatedIdField__c = 'Customer_Name__c',
        Subject__c = 'Customer_Name__c',
        PartitionKey__c = 'Customer_Name__c',
        PayloadModel__c = 'ProfileStagingHandlerTest.MockChange',
        PublishOldEvent__c = false
      )
    );

    Test.startTest();
    new ProfileStagingHandler().publishEvents(new Set<Id>{ cpu.Id });
    Test.stopTest();

    Assert.isFalse(
      repoMock.getHistories('getEventConfig').isEmpty(),
      'getEventConfig should have been called.'
    );

    List<sObject> events = (List<sObject>) dmlRepoMock
      .getHistory('doPublish')
      .getParam('events');
    Assert.isFalse(events.isEmpty(), 'Should not be empty');
    Assert.isTrue(
      events[0] instanceof Cloud_Event__e,
      'Event should be instance of Cloud_Event__e'
    );
  }

  //both platform and cloud events
  @IsTest
  static void testPublishEventsCloudAndPlatformEvents() {
    registerMocks();
    repoMock.mock(
      'queryCustomerProfileUpdates',
      new List<Customer_Profile_Updates__c>{ cpu }
    );
    repoMock.mock(
      'getEventConfig',
      new ProfileStagingEventConfig__mdt(
        RelatedIdField__c = 'Customer_Name__c',
        Subject__c = 'Customer_Name__c',
        PartitionKey__c = 'Customer_Name__c',
        PayloadModel__c = 'ProfileStagingHandlerTest.MockChange',
        PublishOldEvent__c = true
      )
    );

    Test.startTest();
    new ProfileStagingHandler().publishEvents(new Set<Id>{ cpu.Id });
    Test.stopTest();

    Assert.isFalse(
      repoMock.getHistories('getEventConfig').isEmpty(),
      'getEventConfig should have been called.'
    );

    List<sObject> events = (List<sObject>) dmlRepoMock
      .getHistory('doPublish')
      .getParam('events');
    Assert.isFalse(events.isEmpty(), 'Should not be empty');
    Assert.isTrue(
      events[0] instanceof Customer_Profile_Update_Event__e,
      'First event should be instance of Customer_Profile_Update_Event__e'
    );
    Assert.isTrue(
      events[1] instanceof Cloud_Event__e,
      'Second event should be instance of Cloud_Event__e'
    );
  }

  @IsTest
  static void testPublishEventNoResults() {
    registerMocks();
    repoMock.mock(
      'queryCustomerProfileUpdates',
      new List<Customer_Profile_Updates__c>()
    );

    Test.startTest();
    new ProfileStagingHandler().publishEvents(new Set<Id>{ cpu.Id });
    Test.stopTest();

    List<Customer_Profile_Update_Event__e> events = (List<Customer_Profile_Update_Event__e>) dmlRepoMock
      .getHistory('doPublish')
      .getParam('events');

    Assert.isTrue(
      events.isEmpty(),
      'Events should be empty when no updates are found'
    );
  }

  /**
   * @description Extending ProfileStagingConfig for tests
   */
  class ConfigTest extends ProfileStagingConfig {
    Boolean processOverride;

    /**
     * @description Overriding based "process" method to return mock process result
     * @param cpu The Customer_Profile_Updates__c object containing the profile updates.
     * @param record The SObject representing the current record being processed.
     * @param oldRecord The SObject representing the previous version of the record.
     * @return A Boolean value indicating whether the processing was successful.
     */
    public override Boolean process(
      Customer_Profile_Updates__c cpu,
      SObject record,
      SObject oldRecord
    ) {
      if (processOverride == null) {
        return super.process(cpu, record, oldRecord);
      }
      return this.processOverride;
    }

    /**
     * @description This method is used to finalize the customer profile updates.
     * @param cpu The Customer_Profile_Updates__c object containing the profile updates.
     */
    protected override void finalise(Customer_Profile_Updates__c cpu) {
    }
  }

  /**
   * @description Represents the mock change data model for profile staging cloud events.
   */
  public virtual class MockChange extends ProfileStagingCloudEventModel.ProfileUpdate {
    /**
     * @description Initializes the MockChange instance.
     * @param staging The staging object containing profile update details.
     * @param triggerConfig The trigger configuration metadata.
     */
    protected override void init(
      Customer_Profile_Updates__c staging,
      ProfileStagingEventConfig__mdt triggerConfig
    ) {
      super.init(staging, triggerConfig);
    }
  }
}
