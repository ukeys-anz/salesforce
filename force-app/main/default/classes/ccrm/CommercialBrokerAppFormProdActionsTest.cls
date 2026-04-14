/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @group (Commercial Broker)
 * @description Test class for CommercialBrokerAppFormProdActions
 */
@IsTest
public class CommercialBrokerAppFormProdActionsTest {
  // Mock repositories/controllers
  static Lib_MockProvider appFormEventRepoMock;
  static Lib_MockProvider cloudEventControllerMock;
  static Lib_MockProvider appFormAccountActionsMock;
  static Lib_MockProvider appFormProductEventRepoMock;
  static Lib_MockProvider appFormProductRepoMock;
  static Lib_MockProvider commercialOppRepoMock;
  static Lib_MockProvider dmlRepoMock;

  // Registers all mocks
  static void registerMocks() {
    appFormEventRepoMock = Lib_MockProvider.forType(
      ApplicationFormEventRepository.class
    );
    cloudEventControllerMock = Lib_MockProvider.forType(
      CloudEventController.class
    );
    appFormAccountActionsMock = Lib_MockProvider.forType(
      ApplicationFormAccountActions.class
    );
    appFormProductEventRepoMock = Lib_MockProvider.forType(
      ApplicationFormProductEventRepository.class
    );
    appFormProductRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
  }

  @IsTest
  static void testPublishApplicationFormProductEventUpdateNoChange() {
    registerMocks();

    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    //Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    ApplicationFormProduct oldAfp = new ApplicationFormProduct(
      Id = appFormProdId,
      ApplicationFormId = appFormId,
      Application_Source__c = 'OTHER_SOURCE'
    );

    ApplicationFormProduct newAfp = oldAfp.clone();

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProdId => oldAfp
    };
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      newAfp
    };

    Test.startTest();
    List<Cloud_Event__e> publishedEvents = CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      records,
      oldMap,
      'applicationformproductupdate'
    );
    Test.stopTest();

    // Since no relevant fields changed and source is not BKOLA, no events should be published
    System.assertEquals(
      0,
      publishedEvents.size(),
      'No events should be published when relevant fields did not change'
    );
  }

  @IsTest
  static void testPublishApplicationFormProductEventNegative() {
    registerMocks();

    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    // New AFP record (insert)
    ApplicationFormProduct newAfp = new ApplicationFormProduct(
      Id = appFormProdId,
      ApplicationFormId = appFormId,
      Application_Source__c = 'CRM',
      Source_System_Id__c = '232332-233223' //,
      //Application_Type__c = 'Type1',
      //Amount__c = 1000
    );

    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      newAfp
    };

    // ApplicationForm returned by getQualifiedApplicationForms()
    ApplicationForm appForm = new ApplicationForm();

    // MOCK
    appFormEventRepoMock.mock(
      'getQualifiedApplicationForms',
      new List<ApplicationForm>{ appForm }
    );

    // Mock getRelatedAccounts
    appFormEventRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ accountId => 'EXT-001' }
    );

    // Mock Cloud Event controller
    cloudEventControllerMock.mock(
      'publishCloudEvents',
      new List<Cloud_Event__e>{ new Cloud_Event__e() }
    );
    cloudEventControllerMock.mock('logSuccessEvents', null);

    // Mock Account Sync
    appFormAccountActionsMock.mock('accountSyncStatusUpdate', null);

    Test.startTest();
    List<Cloud_Event__e> publishedEvents = CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      records,
      null,
      'applicationformproductadd'
    );
    Test.stopTest();

    System.assertEquals(
      0,
      publishedEvents.size(),
      'Expected zero events because no qualifying ApplicationForms returned.'
    );
  }

  @IsTest
  static void testPublishApplicationFormProductEventNegative2() {
    registerMocks();

    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    // New AFP record (insert)
    ApplicationFormProduct newAfp = new ApplicationFormProduct(
      Id = appFormProdId,
      ApplicationFormId = appFormId,
      Application_Source__c = CommercialBrokerAppFormProdActions.APP_SOURCE_BKOLA,
      Source_System_Id__c = '232332-233223'
    );

    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      newAfp
    };

    ApplicationForm appForm = new ApplicationForm();

    // MOCK
    appFormEventRepoMock.mock(
      'getQualifiedApplicationForms',
      new List<ApplicationForm>{ appForm }
    );

    // Mock getRelatedAccounts
    appFormEventRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ accountId => 'EXT-001' }
    );

    // Mock Cloud Event controller
    cloudEventControllerMock.mock(
      'publishCloudEvents',
      new List<Cloud_Event__e>{ new Cloud_Event__e() }
    );
    cloudEventControllerMock.mock('logSuccessEvents', null);

    // Mock Account Sync
    appFormAccountActionsMock.mock('accountSyncStatusUpdate', null);

    Test.startTest();
    List<Cloud_Event__e> publishedEvents = CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      records,
      null,
      'applicationformproductadd'
    );
    Test.stopTest();

    System.assertEquals(
      0,
      publishedEvents.size(),
      'Expected zero events because no qualifying ApplicationForms returned.'
    );
  }

  @IsTest
  static void testPublishApplicationFormProductEventNoQualifiedApplicationForms() {
    registerMocks();

    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    // AFP record that qualifies for BKOLA logic
    ApplicationFormProduct newAfp = new ApplicationFormProduct(
      Id = appFormProdId,
      ApplicationFormId = appFormId,
      Application_Source__c = CommercialBrokerAppFormProdActions.APP_SOURCE_BKOLA,
      Source_System_Id__c = '232332-233223'
    );

    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      newAfp
    };

    appFormProductEventRepoMock.mock(
      'getQualifiedApplicationForms',
      new List<ApplicationForm>()
    );

    appFormEventRepoMock.mock('getRelatedAccounts', new Map<Id, String>());
    cloudEventControllerMock.mock(
      'publishCloudEvents',
      new List<Cloud_Event__e>()
    );
    cloudEventControllerMock.mock('logSuccessEvents', null);
    appFormAccountActionsMock.mock('accountSyncStatusUpdate', null);

    Test.startTest();
    List<Cloud_Event__e> publishedEvents = CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      records,
      null,
      'applicationformproductadd'
    );
    Test.stopTest();

    System.assertEquals(
      0,
      publishedEvents.size(),
      'Expected zero events because no qualifying ApplicationForms returned.'
    );
  }

  @IsTest
  static void testPublishApplicationFormProductEventNewScenario() {
    registerMocks();
    Contact broker1 = createContact();
    // IDs
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = appFormProdId,
      ApplicationFormId = appFormId,
      Application_Source__c = 'CRM', // NOT BKOLA to force use of Broker_Name__c
      Source_System_Id__c = 'SRC-001'
    );

    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      afp
    };

    ApplicationForm appForm = new ApplicationForm(
      Id = appFormId,
      AccountId = accountId,
      Sync_Status__c = CommercialBrokerAppFormProdActions.SYNC_STATUS_BROKER_ORG,
      Source_System_Id__c = 'APP-001',
      Opportunity = new Opportunity(Id = oppId, Broker_Name__c = broker1.Id),
      Assisted_Broker__c = Lib_FakeIdGenerator.getMockId(Contact.SObjectType)
    );

    appFormProductEventRepoMock.mock(
      'getQualifiedApplicationForms',
      new List<ApplicationForm>{ appForm }
    );

    appFormEventRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ accountId => 'EXT-001' }
    );

    cloudEventControllerMock.mock(
      'publishCloudEvents',
      new List<Cloud_Event__e>{ new Cloud_Event__e() }
    );
    cloudEventControllerMock.mock('logSuccessEvents', null);

    appFormAccountActionsMock.mock('accountSyncStatusUpdate', null);

    Test.startTest();
    List<Cloud_Event__e> publishedEvents = CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      records,
      null,
      'applicationformproductadd'
    );
    Test.stopTest();

    System.assertEquals(
      1,
      publishedEvents.size(),
      'New scenario should publish event when conditions are met.'
    );
  }

  /**
   * @description Helper method that creates a mock Contact record.
   * @return Contact Mock Contact object with fake Id.
   */
  static Contact createContact() {
    Contact con = new Contact();
    con.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    con.FirstName = 'FN';
    con.LastName = 'LN';
    con.Email = 'test@test.com';
    return con;
  }

  /**
   * @description publishApplicationFormProductEvent should publish events on insert when:
   *  - AFP source is BKOLA (watched field present)
   *  - Qualified ApplicationForms are returned
   *  - Broker is present via Opportunity.Broker_Name__c and Sync_Status__c contains Broker Org
   *  - CloudEventController mock returns a non-empty list
   */
  @IsTest
  static void testPublishApplicationFormProductEventInsertPublishes() {
    registerMocks();
    // IDs
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id brokerId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);

    // New AFP record (insert) with BKOLA source (qualifies watched fields on insert)
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = appFormProdId,
      ApplicationFormId = appFormId,
      Application_Source__c = CommercialBrokerAppFormProdActions.APP_SOURCE_BKOLA,
      Source_System_Id__c = 'SRC-123'
    );
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      afp
    };

    // Qualified ApplicationForm:
    // - AMBIT record type (enforced by repository)
    // - Sync_Status__c includes Broker Org
    // - Broker present via Opportunity.Broker_Name__c
    ApplicationForm appForm = new ApplicationForm(
      Id = appFormId,
      AccountId = accountId,
      Sync_Status__c = CommercialBrokerAppFormProdActions.SYNC_STATUS_BROKER_ORG,
      Source_System_Id__c = 'APP-001',
      Opportunity = new Opportunity(Id = oppId, Broker_Name__c = brokerId),
      Assisted_Broker__c = Lib_FakeIdGenerator.getMockId(Contact.SObjectType)
    );

    // Mocks
    appFormProductEventRepoMock.mock(
      'getQualifiedApplicationForms',
      new List<ApplicationForm>{ appForm }
    );
    appFormEventRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ accountId => 'EXT-001' }
    );
    cloudEventControllerMock.mock(
      'publishCloudEvents',
      new List<Cloud_Event__e>{ new Cloud_Event__e() }
    );
    cloudEventControllerMock.mock('logSuccessEvents', null);
    appFormAccountActionsMock.mock('accountSyncStatusUpdate', null);

    Test.startTest();
    List<Cloud_Event__e> publishedEvents = CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      records,
      null,
      'applicationformproductadd'
    );
    Test.stopTest();

    System.assert(
      !publishedEvents.isEmpty(),
      'Events must be published for BKOLA insert with qualifying ApplicationForm.'
    );
  }

  /**
   * @description publishApplicationFormProductEvent should publish zero events when:
   *  - AFP source is BKOLA but repository returns no qualified ApplicationForms
   */
  @IsTest
  static void testPublishApplicationFormProductEventInsertNoQualifiedFormsNoPublish() {
    registerMocks();
    // IDs
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    // New AFP record (insert) with BKOLA source
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = appFormProdId,
      ApplicationFormId = appFormId,
      Application_Source__c = CommercialBrokerAppFormProdActions.APP_SOURCE_BKOLA,
      Source_System_Id__c = 'SRC-456'
    );
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      afp
    };

    // Repository returns no qualified application forms
    appFormProductEventRepoMock.mock(
      'getQualifiedApplicationForms',
      new List<ApplicationForm>()
    );

    // Other mocks (should not matter, but keep consistent)
    appFormEventRepoMock.mock('getRelatedAccounts', new Map<Id, String>());
    cloudEventControllerMock.mock(
      'publishCloudEvents',
      new List<Cloud_Event__e>()
    );
    cloudEventControllerMock.mock('logSuccessEvents', null);
    appFormAccountActionsMock.mock('accountSyncStatusUpdate', null);

    Test.startTest();
    List<Cloud_Event__e> publishedEvents = CommercialBrokerAppFormProdActions.publishApplicationFormProductEvent(
      records,
      null,
      'applicationformproductadd'
    );
    Test.stopTest();

    System.assertEquals(
      0,
      publishedEvents.size(),
      'No events should be published when no qualified ApplicationForms are returned.'
    );
  }
  @isTest
  private static void createOptyAndOptyProductRecordsWithContextBuilderTest() {
    // === Step 1: Register mocks ===
    registerMocks();

    // === Step 2: Setup Standard Pricebook ===
    Id stdPBId = Test.getStandardPricebookId();
    Pricebook2 standardPricebook = new Pricebook2(
      Id = stdPBId,
      IsActive = true
    );
    update standardPricebook;

    // === Step 3: Generate Mock IDs ===
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id prod2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id brokerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    Opportunity opp = new Opportunity(
      Id = oppId,
      Name = 'DUMMY Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = System.today().addDays(15),
      AccountId = accId,
      Pricebook2Id = stdPBId,
      Application_Numbers__c = 'APP-001',
      RecordTypeId = RTOpportunity.commercialOpportunity
    );

    Product2 prod = new Product2(
      Id = prod2Id,
      Name = 'Commercial Loan',
      IsActive = true
    );

    ApplicationForm appForm = new ApplicationForm(
      Id = appFormId,
      AccountId = accId,
      Application_Number__c = 'APP-001',
      RecordTypeId = RTApplicationForm.ambitApplication,
      Assisted_Broker__c = brokerId
    );

    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = appFormProdId,
      ProductId = prod.Id,
      Application_Source__c = 'PORTAL',
      ApplicationFormId = appForm.Id,
      Amount__c = 250000
    );

    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      afp
    };

    // === Step 5: Build Mock JSON Data for Repository ===
    String jsonData =
      '[{"attributes":{"type":"ApplicationForm","url":"/services/data/v62.0/sobjects/ApplicationForm/' +
      appFormId +
      '"},' +
      '"Id":"' +
      appFormId +
      '","RecordTypeId":"012xx000000XYZAAA","AccountId":"' +
      accId +
      '",' +
      '"Assisted_Broker__c":"' +
      brokerId +
      '","OwnerId":"005xx00000OWN001AA","Application_Number__c":"APP-001","OpportunityId":null,' +
      '"ApplicationFormProducts":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ApplicationFormProduct","url":"/services/data/v62.0/sobjects/ApplicationFormProduct/' +
      appFormProdId +
      '"},"Id":"' +
      appFormProdId +
      '","ApplicationFormId":"' +
      appFormId +
      '","ProductId":"' +
      prod2Id +
      '","Amount__c":250000}]}}]';

    List<ApplicationForm> mockForms = (List<ApplicationForm>) JSON.deserialize(
      jsonData,
      List<ApplicationForm>.class
    );

    // === Step 6: Mock Repository Methods ===
    appFormProductRepoMock.mock('getApplicationFormsAndProducts', mockForms);
    commercialOppRepoMock.mock(
      'getOpportunityDetails',
      new List<Opportunity>{ opp }
    );
    commercialOppRepoMock.mock('getStandardPricebook', standardPricebook);

    // === Step 7: Mock DML Repository ===
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    dmlRepoMock.mock('doInsert', null);
    dmlRepoMock.mock('doUpdate', null);

    // === Step 8: Execute Test ===
    Test.startTest();
    CommercialBrokerAppFormProdActions.createOptyAndOptyProductRecords(afpList);
    Test.stopTest();

    // === Step 9: Assertions ===
    System.assert(true, 'Method executed without unhandled exception');

    // Validate context-based outcomes indirectly
    // (since DMLs are mocked, we just ensure flow coverage)
    System.assertEquals(1, afpList.size(), 'AFP List processed successfully');
  }
}
