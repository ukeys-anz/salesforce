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

  static Interaction makeGeneralInteraction() {
    return new Interaction(
      Name = 'Test Interaction',
      recordTypeId = RTInteraction.CommercialInteraction,
      Category__c = CCRMConstants.INTER_CAT_GENERAL,
      InteractionType = 'Call',
      StartTime = System.now(),
      Optional_Notes__c = 'Test Optional Notes'
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
  static void publishCloudEventsOnCreateTest() {
    registerMocks();
    User ccrmUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Lan_Id__c = 'TestLanId'
    );
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
    registerMocks();
    User ccrmUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Lan_Id__c = 'TestLanId'
    );

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
  static void publishCloudEventsNegativeTest() {
    registerMocks();
    User ccrmUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Lan_Id__c = 'TestLanId'
    );

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
    interactionActionRepoMock.mockException(
      'getUsers',
      new QueryException('invalid parameters')
    );

    Boolean exceptionThrown = false;
    String errorMessage = '';
    // Test
    Test.startTest();
    try {
      CommercialInteractionActions.publishCloudEvents(
        intListAll,
        CCRMConstants.ACTION_CODE_CREATE
      );
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }

    Test.stopTest();

    //Check Asserts
    // THEN it should throw an exception
    Assert.areEqual(
      true,
      exceptionThrown,
      'An exception should have been thrown.'
    );
    Assert.areEqual(
      'invalid parameters',
      errorMessage,
      'The correct exception message should be logged.'
    );
  }

  @isTest
  static void createBrokerInteractionAttendeeTest() {
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id brokerId = Lib_FakeIdGenerator.getMockId(Contact.SobjectType);

    Interaction intRec = makeGeneralInteraction();
    intRec.Id = interactionId;
    intRec.Broker__c = brokerId;

    Test.startTest();
    CommercialInteractionActions.createBrokerInteractionAttendee(
      new List<Interaction>{ intRec }
    );
    Test.stopTest();

    List<InteractionAttendee> attendees = (List<InteractionAttendee>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(1, attendees.size(), 'No Attendees created');
    Assert.areEqual(
      brokerId,
      attendees[0].ContactId,
      'Attendee contact not linked to Broker'
    );
  }

  @isTest
  static void createBrokerInteractionAttendeeNegativeTest() {
    registerMocks();
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id brokerId = Lib_FakeIdGenerator.getMockId(Contact.SobjectType);

    Interaction intRec = makeGeneralInteraction();
    intRec.Id = interactionId;
    intRec.Broker__c = brokerId;

    dmlRepoMock.mockException('doInsert', new DmlException('Insert failed!'));

    Boolean exceptionThrown = false;
    String errorMessage = '';
    Test.startTest();
    try {
      CommercialInteractionActions.createBrokerInteractionAttendee(
        new List<Interaction>{ intRec }
      );
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    Assert.areEqual(
      true,
      exceptionThrown,
      'An exception should have been thrown.'
    );
    Assert.areEqual(
      'Insert failed!',
      errorMessage,
      'The correct exception message should be logged.'
    );
  }

  @isTest
  static void setCustomerOnInteractionOnInsertTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Interaction> intList = new List<Interaction>{
      makeGeneralInteraction()
    };
    intList[0].Opportunity__c = oppId;
    Opportunity opp = new Opportunity(Id = oppId, AccountId = accId);
    interactionActionRepoMock.mock(
      'getOpportunities',
      new List<Opportunity>{ opp }
    );
    Test.startTest();
    CommercialInteractionActions.setCustomerOnInteraction(intList, null);
    Test.stopTest();

    Assert.areEqual(
      accId,
      intList[0].AccountId,
      'Customer is not updated on Interaction'
    );
  }

  @isTest
  static void setCustomerOnInteractionNegativeTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Interaction> intList = new List<Interaction>{
      makeGeneralInteraction()
    };
    intList[0].Opportunity__c = oppId;
    interactionActionRepoMock.mockException(
      'getOpportunities',
      new QueryException('getOpportunities failed')
    );
    Boolean exceptionThrown = false;
    String errorMessage = '';
    Test.startTest();
    try {
      CommercialInteractionActions.setCustomerOnInteraction(intList, null);
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(true, exceptionThrown, 'Exception should be thrown');
    Assert.areEqual(
      'getOpportunities failed',
      errorMessage,
      'Correct error message should be logged'
    );
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

  @isTest
  static void testPerformRedactionTest() {
    //GIVEN List of Interaction Record
    List<Interaction> interactionList = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        Name = 'Sample Interaction',
        RecordTypeId = RTInteraction.CommercialInteraction,
        comment__c = 'Test 1234123412341234',
        optional_Notes__c = 'Test 1234123412341234'
      )
    };

    String expectedResult = 'Test ************1234';

    //WHEN calling a performRedaction method

    Test.startTest();
    CommercialInteractionActions.performRedaction(interactionList);
    Test.stopTest();

    Interaction actualInteractionInstance = interactionList[0];

    //THEN sensitive info must be redacted
    Assert.areEqual(
      expectedResult,
      actualInteractionInstance.comment__c,
      'Redaction is Not Completed'
    );
    Assert.areEqual(
      expectedResult,
      actualInteractionInstance.Optional_Notes__c,
      'Redaction is Not Completed'
    );
  }

  @isTest
  static void testPerformRedactionOptionalNotesTest() {
    //GIVEN List of Interaction Record
    List<Interaction> interactionList = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        Name = 'Sample Interaction',
        RecordTypeId = RTInteraction.CommercialInteraction,
        Optional_Notes__c = 'Test 1234123412341234'
      )
    };

    String expectedResult = 'Test ************1234';

    //WHEN calling a performRedaction method

    Test.startTest();
    CommercialInteractionActions.performRedaction(interactionList);
    Test.stopTest();

    Interaction actualInteractionInstance = interactionList[0];

    //THEN sensitive info must be redacted
    Assert.areEqual(
      expectedResult,
      actualInteractionInstance.Optional_Notes__c,
      'Redaction is Not Completed'
    );
  }

  @isTest
  static void testPerformRedactionNegativeTest() {
    //GIVEN List of Interaction Record
    List<Interaction> interactionList = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        Name = 'Sample Interaction - Empty Comment',
        RecordTypeId = RTInteraction.CommercialInteraction,
        comment__c = 'This is a safe comment',
        optional_Notes__c = 'This is a safe comment'
      )
    };

    //WHEN calling performRedaction method for all cases
    Test.startTest();
    CommercialInteractionActions.performRedaction(interactionList);
    Test.stopTest();

    Interaction actualInteractionInstance = interactionList[0];

    //THEN sensitive info must be redacted
    Assert.areEqual(
      'This is a safe comment',
      actualInteractionInstance.comment__c,
      'Redaction should not occur on safe comment'
    );
    Assert.areEqual(
      'This is a safe comment',
      actualInteractionInstance.optional_Notes__c,
      'Redaction should not occur on safe comment'
    );
  }

  @IsTest
  static void testValidateAndPopulateCLG() {
    registerMocks();

    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> interactions = new List<Interaction>{
      new Interaction(
        Id = interactionId,
        AccountId = accountId,
        CLGCustomer__c = clgAccountId
      )
    };
    Map<Id, Interaction> interactionsOldMap = new Map<Id, Interaction>{
      interactionId => new Interaction(
        Id = interactionId,
        AccountId = accountId,
        CLGCustomer__c = null
      )
    };
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>{
        new FinServ__AccountAccountRelation__c(
          FinServ__Account__c = accountId,
          FinServ__RelatedAccount__c = clgAccountId
        )
      }
    );
    Test.startTest();
    CommercialInteractionActions.validateAndPopulateCLG(
      interactions,
      interactionsOldMap
    );
    Test.stopTest();

    Assert.areEqual(
      clgAccountId,
      interactions[0].CLGCustomer__c,
      'CLGCustomer__c should be auto-populated with the only related CLG'
    );
  }

  @IsTest
  static void testValidateAndPopulateCLGSetNullNoValidCLGFFound() {
    registerMocks();
    //Given List Of Interaction
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> interactions = new List<Interaction>{
      new Interaction(
        Id = interactionId,
        AccountId = clgAccountId,
        CLGCustomer__c = null
      )
    };
    Map<Id, Interaction> interactionsOldMap = new Map<Id, Interaction>{
      interactionId => new Interaction(
        Id = interactionId,
        AccountId = clgAccountId,
        CLGCustomer__c = clgAccountId
      )
    };
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>()
    );
    // WHEN Interaction Associated to Clg and CLG field Updated to null
    Test.startTest();
    CommercialInteractionActions.validateAndPopulateCLG(
      interactions,
      interactionsOldMap
    );
    Test.stopTest();
    //THEN no errors should be thrown and It should get updated to null
    Assert.isFalse(interactions[0].hasErrors());
    Assert.areEqual(
      null,
      interactions[0].CLGCustomer__c,
      'CLGCustomer__c should be null'
    );
  }

  @IsTest
  static void testValidateAndPopulateCLGSetNullValidCLGFFound() {
    registerMocks();
    //Given List Of Interaction
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> interactions = new List<Interaction>{
      new Interaction(
        Id = interactionId,
        AccountId = accountId,
        CLGCustomer__c = null
      )
    };
    Map<Id, Interaction> interactionsOldMap = new Map<Id, Interaction>{
      interactionId => new Interaction(
        Id = interactionId,
        AccountId = accountId,
        CLGCustomer__c = clgAccountId
      )
    };
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>{
        new FinServ__AccountAccountRelation__c(
          FinServ__Account__c = accountId,
          FinServ__RelatedAccount__c = clgAccountId
        )
      }
    );
    // WHEN Interaction is associated to a normal account and CLG field is updated to null
    Test.startTest();
    CommercialInteractionActions.validateAndPopulateCLG(
      interactions,
      interactionsOldMap
    );
    Test.stopTest();
    //THEN It should Add an error on record
    Assert.isTrue(interactions[0].hasErrors());
  }

  @IsTest
  static void testValidateAndPopulateCLGNegative() {
    registerMocks();
    //Given List Of Interaction
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> interactions = new List<Interaction>{
      new Interaction(
        Id = interactionId,
        AccountId = accountId,
        CLGCustomer__c = clgAccountId2
      )
    };
    Map<Id, Interaction> interactionsOldMap = new Map<Id, Interaction>{
      interactionId => new Interaction(
        Id = interactionId,
        AccountId = accountId,
        CLGCustomer__c = clgAccountId
      )
    };
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>{
        new FinServ__AccountAccountRelation__c(
          FinServ__Account__c = accountId,
          FinServ__RelatedAccount__c = clgAccountId
        )
      }
    );
    // WHEN Interaction is associated to CLG which is not accounts Parent
    Test.startTest();
    CommercialInteractionActions.validateAndPopulateCLG(
      interactions,
      interactionsOldMap
    );
    Test.stopTest();
    //THEN It should Add an error on record
    Assert.isTrue(interactions[0].hasErrors());
  }

  @IsTest
  static void testPopulateCLGWithSingleRelatedCLG() {
    registerMocks();

    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, Account> accountsWithRecordTypeMockMap = new Map<Id, Account>();
    List<Interaction> interactions = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        AccountId = accountId,
        CLGCustomer__c = null
      )
    };
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>{
        new FinServ__AccountAccountRelation__c(
          FinServ__Account__c = accountId,
          FinServ__RelatedAccount__c = clgAccountId
        )
      }
    );
    interactionActionRepoMock.mock(
      'getAccountsWithRecordTypes',
      accountsWithRecordTypeMockMap
    );

    Test.startTest();
    CommercialInteractionActions.populateCLG(interactions, null);
    Test.stopTest();

    Assert.areEqual(
      clgAccountId,
      interactions[0].CLGCustomer__c,
      'CLGCustomer__c should be auto-populated with the only related CLG'
    );
  }

  @IsTest
  static void testPopulateCLGWhenCustomerIsCLG() {
    registerMocks();

    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Account accountMock = new Account(
      Id = accountId,
      RecordTypeId = RTAccount.clgAccount
    );
    Map<Id, Account> accountsWithRecordTypeMockMap = new Map<Id, Account>{
      accountId => accountMock
    };

    List<Interaction> interactions = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        AccountId = accountId,
        CLGCustomer__c = null
      )
    };
    interactionActionRepoMock.mock(
      'getRelatedCLGAccounts',
      new List<FinServ__AccountAccountRelation__c>()
    );
    interactionActionRepoMock.mock(
      'getAccountsWithRecordTypes',
      accountsWithRecordTypeMockMap
    );

    Test.startTest();
    CommercialInteractionActions.populateCLG(interactions, null);
    Test.stopTest();

    Assert.areEqual(
      accountId,
      interactions[0].CLGCustomer__c,
      'CLGCustomer__c should be auto-populated with the only related CLG'
    );
  }

  @isTest
  static void testupdateNameWithChannelChange() {
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> interactionList = new List<Interaction>{
      new Interaction(
        Id = intId,
        Name = 'SampleInteraction Appointment',
        RecordTypeId = RTInteraction.CommercialInteraction,
        InteractionType = 'Seminar'
      )
    };

    Map<Id, Interaction> oldMap = new Map<Id, Interaction>{
      intId => new Interaction(
        Id = intId,
        Name = 'SampleInteraction Appointment',
        RecordTypeId = RTInteraction.CommercialInteraction,
        InteractionType = 'Appointment'
      )
    };

    Test.startTest();
    CommercialInteractionActions.updateNameWithChannelChange(
      interactionList,
      oldMap
    );
    Test.stopTest();

    Assert.areEqual(
      'SampleInteraction Seminar',
      interactionList[0].Name,
      'Name should be updated with the new channel'
    );
  }

  @IsTest
  static void testsetNameWithChannel() {
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> interactionList = new List<Interaction>{
      new Interaction(
        Id = intId,
        InteractionType = 'Call-Inbound',
        Name = 'SampleInteraction',
        RecordTypeId = RTInteraction.CommercialInteraction
      )
    };

    Test.startTest();
    CommercialInteractionActions.setNameWithChannel(interactionList);
    Test.stopTest();

    Assert.areEqual(
      'SampleInteraction Call-Inbound',
      interactionList[0].Name,
      'Name should be updated with the new channel'
    );
  }
}
