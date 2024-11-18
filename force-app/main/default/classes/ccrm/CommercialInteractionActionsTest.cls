/**
 * @author Ayushi Gupta
 * @since  23/05/2024
 * @description Test class for CommercialInteractionActions
 */
@isTest
private class CommercialInteractionActionsTest {
  static Lib_MockProvider interactionActionRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    interactionActionRepoMock = Lib_MockProvider.forType(
      CCRMInteractionActionsRepository.class
    );
  }

  @isTest
  static void publishCloudEventsOnCreateTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    registerMocks();
    ccrmUser.Lan_Id__c = 'TestLanId';

    //Create Mock Ids
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SobjectType);
    Id finAccountId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );

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

    //Create Interaction Data to be Inserted
    List<Interaction> intListGen = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
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

    List<Interaction> intListCap = CCRMTestDataFactory.createCapInteractionData(
      1,
      ccrmUser,
      accId,
      finAccountId
    );
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

    // Test
    Test.startTest();
    CommercialInteractionActions.publishCloudEvents(
      intListAll,
      CCRMConstants.ACTION_CODE_CREATE
    );
    Test.stopTest();

    //Check Asserts
    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isNotNull(
      publishedEvents,
      'CeModels should be created successfully'
    );
    Assert.areEqual(
      2,
      publishedEvents.size(),
      'CeModels should be created successfully'
    );
    InteractionCloudEventModel publishedEventInstance1 = (InteractionCloudEventModel) JSON.deserialize(
      publishedEvents[0].Data_1__c,
      InteractionCloudEventModel.class
    );

    InteractionCloudEventModel publishedEventInstance2 = (InteractionCloudEventModel) JSON.deserialize(
      publishedEvents[1].Data_1__c,
      InteractionCloudEventModel.class
    );

    Assert.areEqual(
      'com.anzx.salesforce.interaction.v1alpha1.iteraction.ccrm_interaction.create',
      publishedEventInstance1.ce_type,
      'CeModels were not created successfully on create'
    );
    Assert.areEqual(
      'com.anzx.salesforce.interaction.v1alpha1.interaction.cap_diarycomment.create',
      publishedEventInstance2.ce_type,
      'CeModels were not created successfully on create'
    );
  }

  @isTest
  static void publishCloudEventsOnUpdateTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    registerMocks();
    ccrmUser.Lan_Id__c = 'TestLanId';

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

    List<Interaction> intListGen = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
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

    List<Interaction> intListCap = CCRMTestDataFactory.createCapInteractionData(
      1,
      ccrmUser,
      accId,
      finAccountId
    );
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

    Test.startTest();
    CommercialInteractionActions.publishCloudEvents(
      intListAll,
      CCRMConstants.ACTION_CODE_UPDATE
    );
    Test.stopTest();
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

  @isTest
  static void getOppsIdsAssociatedWithInteractionsTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Set<Id> oppsIds = new Set<Id>();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Interaction> intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );

    Test.startTest();
    oppsIds = CommercialInteractionActions.getOppsIdsAssociatedWithInteractions(
      intRec,
      null
    );
    Test.stopTest();

    System.assertEquals(1, oppsIds.size(), 'Size is not 1');
  }

  @isTest
  static void getOppsIdsAssociatedWithInteractionsWithOldMapTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Set<Id> oppsIds = new Set<Id>();
    List<Interaction> intRec;
    Map<Id, Interaction> oldMap;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id updatedOppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      updatedOppId
    );
    intRec[0].AccountId = accId;
    intRec[0].Id = intId;
    oldMap = new Map<Id, Interaction>{
      intId => new Interaction(
        Id = intId,
        Opportunity__c = oppId,
        AccountId = accId
      )
    };

    Test.startTest();
    oppsIds = CommercialInteractionActions.getOppsIdsAssociatedWithInteractions(
      intRec,
      oldMap
    );
    Test.stopTest();

    System.assertEquals(1, oppsIds.size(), 'Size is not 1');
  }

  @isTest
  static void updateCustomerOnInteractionTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Map<Id, Id> oppIdToCustomerIdMap;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Opportunity opp = CCRMTestDataFactory.createStaticOpportunityData(
      oppId,
      'Test Opp',
      CCRMConstants.CCRM_OPP_RT_ID,
      'Opportunity Identified'
    );
    opp.AccountId = accId;
    List<Interaction> intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intRec[0].AccountId = null;
    oppIdToCustomerIdMap = new Map<Id, Id>{ oppId => accId };

    Test.startTest();
    CommercialInteractionActions.updateCustomerOnInteraction(
      intRec,
      oppIdToCustomerIdMap
    );
    Test.stopTest();

    System.assertEquals(accId, intRec[0].AccountId, 'No Account Found');
  }

  @isTest
  static void getUpdatedNameOrChannelInteractionsTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Interaction> updatedInteractions;

    List<Interaction> intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intRec[0].Id = (String) Lib_FakeIdGenerator.getMockId(
      Interaction.SObjectType
    );
    Interaction updatedInt = new Interaction(
      Id = intRec[0].Id,
      InteractionType = 'Email',
      Name = 'Test Interaction'
    );

    Test.startTest();
    updatedInteractions = CommercialInteractionActions.getUpdatedNameOrChannelInteractions(
      new List<Interaction>{ updatedInt },
      new Map<Id, Interaction>{ intRec[0].Id => intRec[0] }
    );
    Test.stopTest();

    System.assertEquals(1, updatedInteractions.size(), 'No Interactions found');
  }

  @isTest
  static void updateInteractionNameTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    List<Interaction> intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intRec[0].Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);

    Interaction updatedInt = new Interaction(
      Id = intRec[0].Id,
      Name = 'Test Call',
      InteractionType = 'Email'
    );

    Test.startTest();
    CommercialInteractionActions.updateInteractionName(
      new List<Interaction>{ updatedInt },
      new Map<Id, Interaction>{ intRec[0].Id => intRec[0] }
    );
    Test.stopTest();

    System.assert(updatedInt.Name.contains('Email'), 'Name not updated');
  }

  @isTest
  static void setCustomerOnInteractionOnInsertTest() {
    registerMocks();
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Interaction> intList;
    intList = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    Opportunity opp = new Opportunity(Id = oppId, AccountId = accId);
    interactionActionRepoMock.mock(
      'getOpportunities',
      new List<Opportunity>{ opp }
    );
    Test.startTest();
    CommercialInteractionActions.setCustomerOnInteraction(intList, null);
    Test.stopTest();

    System.assertEquals(
      accId,
      intList[0].AccountId,
      'Customer is not updated on Interaction'
    );
  }

  @isTest
  static void setInteractionNameOnInsertTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    List<Interaction> intList;
    intList = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      null
    );

    Test.startTest();
    CommercialInteractionActions.setInteractionName(
      intList,
      new Map<Id, Interaction>()
    );
    Test.stopTest();

    System.assertEquals('Test 1 Call', intList[0].Name, 'Name is not updated');
  }

  @isTest
  static void setInteractionNameOnUpdateTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    List<Interaction> intList;
    Map<Id, Interaction> oldMap;
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    intList = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intList[0].Id = intId;
    intList[0].Name = 'Test Other';
    oldMap = new Map<Id, Interaction>{
      intId => new Interaction(
        Id = intId,
        Name = 'Test Updated Interaction Other',
        InteractionType = 'Other'
      )
    };

    Test.startTest();
    CommercialInteractionActions.setInteractionName(intList, oldMap);
    Test.stopTest();

    System.assertEquals('Test  Call', intList[0].Name, 'Name is not updated');
  }

  @isTest
  static void testRestrictImagesInRichTextFields() {
    //GIVEN List of Interaction Record
    List<Interaction> interactionList = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        Name = 'Sample Interaction'
      )
    };

    //WHEN calling a restrictImagesInRichTextFields method
    Test.startTest();
    CommercialInteractionActions.restrictImagesInRichTextFields(
      interactionList,
      null
    );
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      interactionList[0].hasErrors(),
      'Error while inserting Interaction record with Image.'
    );
  }
}
