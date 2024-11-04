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
      RecordType = new RecordType(DeveloperName = 'Customer')
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
    repoMock = Lib_MockProvider.forType(ProfileStagingRepository.class);
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
        RecordType_Name__c = 'Customer'
      ),
      events[0],
      'Event should contains info for Customer_Profile_Updates__c from query'
    );
  }

  @IsTest
  static void testGenerateUpdates() {
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

    Assert.isFalse(updates.isEmpty(), 'Should not be empty');
    Assert.areEqual(
      new Customer_Profile_Updates__c(
        Action__c = 'Update',
        Status__c = 'Pending',
        UserLanId__c = currentUser.Lan_Id__c
      ),
      updates[0],
      'Should be the same'
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

    Assert.isTrue(updates.isEmpty(), 'Should be empty when no changes');
  }

  @IsTest
  static void testGenerateEvents() {
    Test.startTest();
    List<Customer_Profile_Update_Event__e> events = new ProfileStagingHandler()
      .generateEvents(new List<Customer_Profile_Updates__c>{ cpu });
    Test.stopTest();

    Assert.isFalse(events.isEmpty(), 'Should not be empty');
    Assert.areEqual(
      cpu.Id,
      events[0].Customer_Profile_Update_Identifier__c,
      'Should have the same id'
    );
    Assert.areEqual(
      'Customer',
      events[0].RecordType_Name__c,
      'Should have the same record type'
    );
  }

  @IsTest
  static void testPublishEvents() {
    registerMocks();
    repoMock.mock(
      'queryCustomerProfileUpdates',
      new List<Customer_Profile_Updates__c>{ cpu }
    );

    Test.startTest();
    new ProfileStagingHandler().publishEvents(new Set<Id>{ cpu.Id });
    Test.stopTest();

    List<Customer_Profile_Update_Event__e> events = (List<Customer_Profile_Update_Event__e>) dmlRepoMock
      .getHistory('doPublish')
      .getParam('events');

    Assert.isFalse(events.isEmpty(), 'Should not be empty');
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
}
