/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormProductActionsTest is the test class for CommercialAppFormProductActions.
 */
@isTest
private class CommercialAppFormProductActionsTest {
  static Lib_MockProvider appFormProductRepoMock;
  static Lib_MockProvider commercialOppRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider oppTeamMemberRepo;

  static void registerMocks() {
    appFormProductRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    oppTeamMemberRepo = Lib_MockProvider.forType(
      CommercialOppTeamMemberRepository.class
    );
  }

  @isTest
  static void testSetFieldsOnRelatedOpportunity() {
    registerMocks();
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      Opportunity = new Opportunity(
        Id = oppId,
        CloseDate = DateTimeUtils.getNextWeekdayDate(1)
      )
    );
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormobj.Id,
      CCRMConstants.NEED_ANALYSIS
    );
    afpList[0].Id = appFormProdId;
    // Mock the Repo Methods
    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );

    Test.startTest();
    CommercialAppFormProductActions.setFieldsOnRelatedOpportunity(
      afpList,
      null
    );
    Test.stopTest();
    List<Opportunity> opp = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      afpList[0].close_date__c,
      opp[0].CloseDate,
      'Date populated'
    );
  }

  @isTest
  static void testfetchvalidRecordId() {
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.NEED_ANALYSIS
    );

    Test.startTest();
    Set<Id> validAppFormRecordId = CommercialAppFormProductActionsHelper.fetchvalidRecordId(
      afpList,
      null
    );
    Test.stopTest();
    Assert.areEqual(1, validAppFormRecordId.size(), 'valid records are found');
  }
  @isTest
  static void testsetOpportunityCloseDateField() {
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      Opportunity = new Opportunity(
        Id = oppId,
        CloseDate = DateTimeUtils.getNextWeekdayDate(1)
      )
    );
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormobj.Id,
      CCRMConstants.NEED_ANALYSIS
    );
    afpList[0].Id = appFormProdId;
    Test.startTest();
    List<Opportunity> oppToUpdate = CommercialAppFormProductActionsHelper.setOpportunityCloseDateField(
      new List<ApplicationForm>{ appFormobj },
      afpList
    );
    Test.stopTest();
    Assert.areEqual(
      oppToUpdate[0].closeDate,
      afpList[0].Close_Date__c,
      'Opportunityclose date matches app form prod close date'
    );
  }

  @isTest
  static void testPopulateCloseDate() {
    registerMocks();

    //GIVEN Application Form, App form Product list, Opportunity Line Item list
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        CloseDate = DateTimeUtils.getNextWeekdayDate(1)
      )
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Stage = CCRMConstants.NEW_STAGE,
        ApplicationFormId = appFormId,
        ProductId = productId
      )
    };

    List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        opportunityId = oppId,
        Product2Id = productId,
        Expected_Settlement_Date__c = DateTimeUtils.getWeekday(
          system.today().addDays(1),
          true,
          true
        )
      )
    };

    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );
    appFormProductRepoMock.mock('getOppProductRelatedToAFP', oppLineItemList);

    //WHEN populateCloseDate method get called
    Test.startTest();
    CommercialAppFormProductActions.populateCloseDate(appFormProductList);
    Test.stopTest();

    //THEN Close date on AFP should get updated
    Assert.isNotNull(
      appFormProductList[0].Close_Date__c,
      'Close date not updated on Application form product'
    );
  }

  @isTest
  static void testPopulateCloseDateForAmbitOnStageChangePositive() {
    registerMocks();

    // Create mock Opportunity and ApplicationForm
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    // Create a mock ApplicationForm with 'ambitApplication' RecordTypeId
    ApplicationForm appForm = new ApplicationForm(
      Id = appFormId,
      RecordTypeId = RTApplicationForm.ambitApplication
    );

    // Create a mock ApplicationFormProduct record with Stage as 'Closed Won'
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = appFormProductId,
      ApplicationFormId = appFormId,
      Stage = CCRMConstants.OPP_WON
    );

    // Set mock ApplicationForm in repository
    List<ApplicationForm> appFormList = new List<ApplicationForm>{ appForm };
    // Mock the getApplicationForms method to return the application form we created
    appFormProductRepoMock.mock('getApplicationForms', appFormList);
    // WHEN calling populateCloseDateForAmbitOnStageChange
    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      afp
    };
    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>();
    oldMap.put(
      afp.Id,
      new ApplicationFormProduct(Stage = CCRMConstants.OPP_IDENTIFIED)
    ); // Simulating Stage before change

    Test.startTest();
    CommercialAppFormProductActions.populateCloseDateForAmbitOnStageChange(
      afpList,
      oldMap
    );
    Test.stopTest();

    // THEN the Close_Date__c field should be populated with today's date
    ApplicationFormProduct updatedAfp = afpList[0];
    Assert.areEqual(
      System.today(),
      updatedAfp.Close_Date__c,
      'Close date should be populated for Closed Won Stage'
    );
  }

  @isTest
  static void testPopulateCloseDateForAmbitOnStageChangeNegative() {
    registerMocks();

    // Create mock Opportunity and ApplicationForm
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    // Create a mock ApplicationForm with a non-'ambitApplication' RecordTypeId
    ApplicationForm appForm = new ApplicationForm(
      Id = appFormId,
      RecordTypeId = RTApplicationForm.bbdApplication
    );

    // Create a mock ApplicationFormProduct record with Stage as 'Prospecting' (not Closed Won)
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = appFormProductId,
      ApplicationFormId = appFormId,
      Stage = CCRMConstants.OPP_IDENTIFIED
    );

    // Set mock ApplicationForm in repository
    List<ApplicationForm> appFormList = new List<ApplicationForm>{ appForm };
    // Mock the getApplicationForms method to return the application form we created
    appFormProductRepoMock.mock('getApplicationForms', appFormList);

    // WHEN calling populateCloseDateForAmbitOnStageChange
    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      afp
    };
    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>();
    oldMap.put(afp.Id, new ApplicationFormProduct(Stage = 'Closed Won')); // Simulating Stage before change

    Test.startTest();
    CommercialAppFormProductActions.populateCloseDateForAmbitOnStageChange(
      afpList,
      oldMap
    );
    Test.stopTest();

    // THEN the Close_Date__c field should NOT be populated since it's not 'ambitApplication'
    ApplicationFormProduct updatedAfp = afpList[0];
    Assert.areEqual(
      null,
      updatedAfp.Close_Date__c,
      'Close date should NOT be populated for non-ambit applications or non-Closed Won stage'
    );
  }

  @isTest
  static void testPopulateStageUpdatedDate() {
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = appFormProductId,
      Stage = CCRMConstants.OPP_IDENTIFIED,
      Last_Updated_Stage_Date__c = System.Today() - 3
    );

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>();
    oldMap.put(afp.Id, new ApplicationFormProduct(Stage = 'Needs Analysis'));

    Test.startTest();
    CommercialAppFormProductActions.populateStageUpdatedDate(
      new List<ApplicationFormProduct>{ afp },
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(
      System.Today(),
      afp.Last_Updated_Stage_Date__c,
      'Last updated stage date is not equal to today'
    );
  }

  @isTest
  static void testMapStageWithSourceSystemStatus() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity
      )
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Approved & Offered',
        ApplicationFormId = appFormId,
        Source_System_Status__c = 'Locked for Assessment'
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProductId => new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Approved & Offered',
        Source_System_Status__c = 'test',
        ApplicationFormId = appFormId
      )
    };

    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );

    Test.startTest();
    CommercialAppFormProductActions.mapStageWithSourceSystemStatus(
      appFormProductList,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(
      'Solution Development',
      appFormProductList[0].Stage,
      'No record updated'
    );
  }

  @isTest
  static void testMapStageWithSourceSystemStatusNegativeCase() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity
      )
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Approved & Offered',
        ApplicationFormId = appFormId,
        Source_System_Status__c = 'test 2'
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProductId => new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Approved & Offered',
        Source_System_Status__c = 'test',
        ApplicationFormId = appFormId
      )
    };

    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );

    Test.startTest();
    CommercialAppFormProductActions.mapStageWithSourceSystemStatus(
      appFormProductList,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(
      'Approved & Offered',
      appFormProductList[0].Stage,
      'Record got updated'
    );
  }
  @isTest
  static void createAppFormShareRecordsTest() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity
      )
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Approved & Offered',
        ApplicationFormId = appFormId,
        Source_System_Status__c = 'test 2'
      )
    };
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      OpportunityId = oppId,
      UserId = userId
    );
    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );
    oppTeamMemberRepo.mock(
      'getOppTeamMembersRelatedToOpp',
      new List<OpportunityTeamMember>{ oppTeamMember }
    );
    Test.startTest();
    CommercialAppFormProductActions.createAppFormShareRecords(
      appFormProductList
    );
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      appFormShares[0].ParentId,
      appFormId,
      'App Form Record is not shared'
    );
  }

  @isTest
  static void createAppFormShareRecordsNegativeTest() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      OwnerId = userId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Approved & Offered',
        ApplicationFormId = appFormId,
        Source_System_Status__c = 'test 2'
      )
    };

    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );
    oppTeamMemberRepo.mock(
      'getOppTeamMembersRelatedToOpp',
      new List<OpportunityTeamMember>()
    );
    Test.startTest();
    CommercialAppFormProductActions.createAppFormShareRecords(
      appFormProductList
    );
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(appFormShares.size(), 0, 'App Form Record is shared');
  }
  @isTest
  static void getOppTeamMemberIdsTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity
      )
    );
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      OpportunityId = oppId,
      UserId = userId
    );
    Map<Id, List<OpportunityTeamMember>> oppIdToTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>{
      oppId => new List<OpportunityTeamMember>{ oppTeamMember }
    };
    Test.startTest();
    Map<Id, Set<Id>> oppIdToMemberIds = CommercialAppFormProductActions.getOppTeamMemberIds(
      new List<ApplicationForm>{ appFormobj },
      oppIdToTeamMembersMap
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      oppIdToMemberIds.values().size(),
      'no team members found'
    );
  }

  @isTest
  static void getOppTeamMemberIdsNegativeTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      OwnerId = userId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    );
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      OpportunityId = oppId,
      UserId = userId
    );
    Map<Id, List<OpportunityTeamMember>> oppIdToTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>{
      oppId => new List<OpportunityTeamMember>{ oppTeamMember }
    };
    Test.startTest();
    Map<Id, Set<Id>> oppIdToMemberIds = CommercialAppFormProductActions.getOppTeamMemberIds(
      new List<ApplicationForm>{ appFormobj },
      oppIdToTeamMembersMap
    );
    Test.stopTest();
    Assert.areEqual(0, oppIdToMemberIds.values().size(), 'team members found');
  }
}
