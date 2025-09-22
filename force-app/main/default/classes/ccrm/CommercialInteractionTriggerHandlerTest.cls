/**
 * @author       : Advait Yermalkar
 * @since        : 08-08-2025
 * @description  : This is the Test class for CommercialInteractionTriggerHandler
 **/
@IsTest
public class CommercialInteractionTriggerHandlerTest {
  static Lib_MockProvider interactionActionRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    interactionActionRepoMock = Lib_MockProvider.forType(
      CCRMInteractionActionsRepository.class
    );
  }

  static Interaction makeGeneralInteraction() {
    return new Interaction(
      Name = 'SampleInteraction',
      recordTypeId = RTInteraction.CommercialInteraction,
      Category__c = CCRMConstants.INTER_CAT_GENERAL,
      InteractionType = 'Call-Inbound',
      StartTime = System.now(),
      comment__c = 'Test 1234123412341234',
      optional_Notes__c = 'Test 1234123412341234'
    );
  }
  static Interaction makeCapInteraction() {
    return new Interaction(
      Name = 'Test Interaction',
      Comment__c = 'Test Comment',
      Permanent__c = true,
      Expiry_Date__c = System.Today(),
      recordTypeId = RTInteraction.CommercialInteraction,
      Category__c = CCRMConstants.INTER_CAT_CAPDIARYCOMMENTS,
      InteractionType = 'Call'
    );
  }

  @isTest
  static void beforeInsertTest() {
    registerMocks();
    //GIVEN records
    List<Interaction> records = new List<Interaction>{
      makeGeneralInteraction()
    };
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    records[0].Opportunity__c = oppId;
    records[0].AccountId = null;
    records[0].CLGCustomer__c = null;
    records[0].Comment__c = 'Credit Card Number 12345678901234';
    records[0].optional_Notes__c = 'TFN Number 0134024094209';

    Opportunity opp = new Opportunity(Id = oppId, AccountId = accId);
    interactionActionRepoMock.mock(
      'getOpportunities',
      new List<Opportunity>{ opp }
    );

    Account accountMock = new Account(
      Id = accId,
      RecordTypeId = RTAccount.clgAccount
    );
    Map<Id, Account> accountsWithRecordTypeMockMap = new Map<Id, Account>{
      accId => accountMock
    };
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>()
    );
    interactionActionRepoMock.mock(
      'getAccountsWithRecordTypes',
      accountsWithRecordTypeMockMap
    );

    CommercialInteractionTriggerHandler handler = new CommercialInteractionTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should redact Properly and pass all asserts
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].comment__c,
      'should redact Comment field on insertion'
    );
    Assert.areEqual(
      'TFN Number *********4209',
      records[0].optional_Notes__c,
      'should redact Optional Notes field on insertion'
    );
    Assert.areEqual(
      'SampleInteraction Call-Inbound',
      records[0].Name,
      'Name should be updated with the new channel'
    );
    Assert.areEqual(
      accId,
      records[0].AccountId,
      'Customer is not updated on Interaction'
    );
    Assert.areEqual(
      accId,
      records[0].CLGCustomer__c,
      'CLGCustomer__c should be auto-populated with the only related CLG'
    );
  }

  @isTest
  static void beforeInsertErrorTest() {
    //GIVEN records
    List<Interaction> records = new List<Interaction>{
      new Interaction(Optional_Notes__c = '<img>Google.com</img>')
    };
    CommercialInteractionTriggerHandler handler = new CommercialInteractionTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should throw an error
    Assert.isTrue(
      records[0].hasErrors(),
      'should throw error while inserting record with Image in Account Plan field'
    );
  }

  @isTest
  static void beforeUpdateTest() {
    registerMocks();
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Interaction> records = new List<Interaction>{
      makeGeneralInteraction()
    };
    records[0].Id = intId;
    records[0].Comment__c = 'Credit Card Number 12345678901234';
    records[0].optional_Notes__c = 'TFN Number 0134024094209';
    records[0].Name = 'SampleInteraction Appointment';
    records[0].InteractionType = 'Seminar';
    records[0].Opportunity__c = oppId;
    records[0].AccountId = null;
    records[0].CLGCustomer__c = clgAccountId;

    Map<Id, Interaction> oldMap = new Map<Id, Interaction>{
      intId => new Interaction(
        Id = intId,
        Name = 'SampleInteraction Appointment',
        RecordTypeId = RTInteraction.CommercialInteraction,
        InteractionType = 'Appointment',
        CLGCustomer__c = clgAccountIdOld
      )
    };

    Opportunity opp = new Opportunity(Id = oppId, AccountId = accId);
    interactionActionRepoMock.mock(
      'getOpportunities',
      new List<Opportunity>{ opp }
    );
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>{
        new FinServ__AccountAccountRelation__c(
          FinServ__Account__c = accId,
          FinServ__RelatedAccount__c = clgAccountId
        )
      }
    );
    Account accountMock = new Account(
      Id = clgAccountId,
      RecordTypeId = RTAccount.clgAccount
    );
    Map<Id, Account> accountsWithRecordTypeMockMap = new Map<Id, Account>{
      clgAccountId => accountMock
    };
    interactionActionRepoMock.mock(
      'getAccountsWithRecordTypes',
      accountsWithRecordTypeMockMap
    );

    CommercialInteractionTriggerHandler handler = new CommercialInteractionTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //Assert is should redact Properly and pass all asserts
    Assert.areEqual(
      'Credit Card Number **********1234',
      records[0].comment__c,
      'should redact Comment field on insertion'
    );
    Assert.areEqual(
      'TFN Number *********4209',
      records[0].optional_Notes__c,
      'should redact Optional Notes field on insertion'
    );
    Assert.areEqual(
      accId,
      records[0].AccountId,
      'Customer is not updated on Interaction'
    );
    Assert.areEqual(
      clgAccountId,
      records[0].CLGCustomer__c,
      'Should fallback to AccountId itself if no CLGs exist and account is CLG'
    );
  }

  @isTest
  static void beforeUpdateErrorTest() {
    //GIVEN records
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> records = new List<Interaction>{
      new Interaction(Optional_Notes__c = '<img>Google.com</img>')
    };

    Map<Id, Interaction> oldMap = new Map<Id, Interaction>{
      intId => new Interaction(Optional_Notes__c = 'Sample Optional Notes')
    };

    CommercialInteractionTriggerHandler handler = new CommercialInteractionTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should throw an error
    Assert.isTrue(
      records[0].hasErrors(),
      'should throw error while inserting record with Image in Account Plan field'
    );
  }

  @isTest
  static void afterInsertTest() {
    registerMocks();
    //Create Mock Ids
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SobjectType);
    Id finAccountId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );
    Id brokerId = Lib_FakeIdGenerator.getMockId(Contact.SobjectType);

    // Create Mock Data
    Account mockCustomer = new Account(
      Id = accId,
      Name = 'Test Customer',
      Source_System_ID__c = '111111000000',
      Source_System_Name__c = 'CAP-CIS1',
      OCV_ID__c = '2200993355'
    );

    Opportunity mockOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(Id = oppId),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );

    FinServ__FinancialAccount__c mockFinAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      new FinServ__FinancialAccount__c(
        Id = finAccountId,
        Name = 'DDA-234500817',
        FinServ__FinancialAccountNumber__c = '234500817'
      ),
      new Map<String, Object>{ 'Product_Code_Display__c' => 'DDA' }
    );
    User ccrmUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Lan_Id__c = 'TestLanId'
    );

    //Create Interaction Data to be Inserted

    List<Interaction> intListGen = new List<Interaction>{
      makeGeneralInteraction()
    };
    intListGen[0].Opportunity__c = oppId;
    intListGen[0].OwnerId = ccrmUser.Id;
    intListGen[0] = (Interaction) TestUtil.setFields(
      intListGen[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000',
        'AccountId' => accId
      }
    );
    intListGen[0].Broker__c = brokerId;

    List<Interaction> intListCap = new List<Interaction>{
      makeCapInteraction()
    };
    intListCap[0].OwnerId = ccrmUser.Id;
    intListCap[0].Financial_Account__c = finAccountId;
    intListCap[0].AccountId = accId;
    intListCap[0] = (Interaction) TestUtil.setFields(
      intListCap[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000'
      }
    );

    List<Interaction> intListAll = new List<Interaction>(
      new List<Interaction>{ intListGen[0], intListCap[0] }
    );

    // Mock the Repo Methords
    interactionActionRepoMock.mock(
      'getCustomers',
      new List<Account>{ mockCustomer }
    );
    interactionActionRepoMock.mock(
      'getOpportunities',
      new List<Opportunity>{ mockOpp }
    );
    interactionActionRepoMock.mock(
      'getFinAccounts',
      new List<FinServ__FinancialAccount__c>{ mockFinAccount }
    );
    interactionActionRepoMock.mock('getUsers', new List<User>{ ccrmUser });

    CommercialInteractionTriggerHandler handler = new CommercialInteractionTriggerHandler();
    handler.records = intListAll;

    //WHEN calling a method
    Test.startTest();
    handler.onAfterInsert();
    Test.stopTest();
    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;

    //Then
    Assert.isNotNull(
      publishedEvents,
      'CeModels should be created successfully'
    );
    Assert.areEqual(
      2,
      publishedEvents.size(),
      'CeModels should be created successfully'
    );
    List<InteractionAttendee> attendees = (List<InteractionAttendee>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      brokerId,
      attendees[0].ContactId,
      'Attendee contact not linked to Broker'
    );
  }

  @isTest
  static void afterUpdateTest() {
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SobjectType);
    Id finAccountId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );

    Account mockCustomer = new Account(
      Id = accId,
      Name = 'Test Customer',
      Source_System_ID__c = '111111000000',
      Source_System_Name__c = 'CAP-CIS1',
      OCV_ID__c = '2200993355'
    );

    Opportunity mockOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(Id = oppId),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );

    FinServ__FinancialAccount__c mockFinAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      new FinServ__FinancialAccount__c(
        Id = finAccountId,
        Name = 'DDA-234500817',
        FinServ__FinancialAccountNumber__c = '234500817'
      ),
      new Map<String, Object>{ 'Product_Code_Display__c' => 'DDA' }
    );

    User ccrmUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Lan_Id__c = 'TestLanId'
    );

    List<Interaction> intListGen = new List<Interaction>{
      makeGeneralInteraction()
    };
    intListGen[0].Opportunity__c = oppId;
    intListGen[0].OwnerId = ccrmUser.Id;
    intListGen[0] = (Interaction) TestUtil.setFields(
      intListGen[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000',
        'AccountId' => accId
      }
    );

    List<Interaction> intListCap = new List<Interaction>{
      makeCapInteraction()
    };
    intListCap[0].OwnerId = ccrmUser.Id;
    intListCap[0].Financial_Account__c = finAccountId;
    intListCap[0].AccountId = accId;
    intListCap[0] = (Interaction) TestUtil.setFields(
      intListCap[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000'
      }
    );

    List<Interaction> intListAll = new List<Interaction>(
      new List<Interaction>{ intListGen[0], intListCap[0] }
    );

    interactionActionRepoMock.mock(
      'getCustomers',
      new List<Account>{ mockCustomer }
    );
    interactionActionRepoMock.mock(
      'getOpportunities',
      new List<Opportunity>{ mockOpp }
    );
    interactionActionRepoMock.mock(
      'getFinAccounts',
      new List<FinServ__FinancialAccount__c>{ mockFinAccount }
    );
    interactionActionRepoMock.mock('getUsers', new List<User>{ ccrmUser });

    Map<Id, Interaction> oldMap = new Map<Id, Interaction>{
      interactionId => new Interaction(
        Id = interactionId,
        Name = 'SampleInteraction Appointment',
        RecordTypeId = RTInteraction.CommercialInteraction,
        InteractionType = 'Appointment'
      )
    };

    CommercialInteractionTriggerHandler handler = new CommercialInteractionTriggerHandler();
    handler.records = intListAll;

    //WHEN calling a method
    Test.startTest();
    handler.onAfterUpdate(oldMap);
    Test.stopTest();

    //Then Only one event should be published
    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isNotNull(
      publishedEvents,
      'CeModels should be created successfully'
    );
    Assert.areEqual(
      1,
      publishedEvents.size(),
      'CeModels should be created successfully'
    );
    InteractionCloudEventModel publishedEventInstance1 = (InteractionCloudEventModel) JSON.deserialize(
      publishedEvents[0].Data_1__c,
      InteractionCloudEventModel.class
    );
    Assert.areEqual(
      'com.anzx.salesforce.interaction.v1alpha1.iteraction.ccrm_interaction.update',
      publishedEventInstance1.ce_type,
      'CeModels were not created successfully on update'
    );
  }
}
