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
  static Lib_MockProvider userRepoMock;

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
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
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
  static void testSetFieldsOnRelatedOpportunityWithException() {
    registerMocks();

    dmlRepoMock.mockException('doUpdate', new DmlException('Update failed!'));
    try {
      Test.startTest();
      CommercialAppFormProductActions.setFieldsOnRelatedOpportunity(
        new List<ApplicationFormProduct>{},
        null
      );
      Test.stopTest();
    } catch (exception e) {
      Assert.isTrue(
        e instanceof DmlException,
        'DML exception should be thrown'
      );
    }
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
  static void createAppFormShareRecordsTestWithException() {
    registerMocks();

    dmlRepoMock.mockException('doInsert', new DmlException('Insert failed!'));

    try {
      Test.startTest();
      CommercialAppFormProductActions.createAppFormShareRecords(
        new List<ApplicationFormProduct>{}
      );
      Test.stopTest();
    } catch (exception e) {
      Assert.isTrue(
        e instanceof DmlException,
        'DML exception should be thrown'
      );
    }
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

  @isTest
  static void updateApprovedAmountOnOppTest() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id oliId2 = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afpId2 = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    //GIVEN records, oldMap
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Amount__c = 50,
        Stage = 'Opportunity Won',
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication
        )
      ),
      new ApplicationFormProduct(
        Id = afpId2,
        Amount__c = 500,
        Stage = 'Opportunity Won',
        Opportunity_Product__c = oliId2,
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication
        )
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Amount__c = 50,
        Stage = 'Opportunity Identified',
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId
      ),
      afpId2 => new ApplicationFormProduct(
        Id = afpId2,
        Amount__c = 500,
        Stage = 'Opportunity Won',
        Opportunity_Product__c = oliId2,
        ApplicationFormId = afId
      )
    };

    List<ApplicationForm> afList = new List<ApplicationForm>{
      new ApplicationForm(
        Id = afId,
        OpportunityId = oppId,
        RecordTypeId = RTApplicationForm.acmApplication
      )
    };

    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(Id = oliId, OpportunityId = oppId),
      new OpportunityLineItem(Id = oliId2, OpportunityId = oppId)
    };

    appFormProductRepoMock.mock('getApplicationForms', afList);
    appFormProductRepoMock.mock('getAfpRelatedToOpp', records);
    appFormProductRepoMock.mock('getOppLineItems', oliList);

    //WHEN calling a method
    Test.startTest();
    CommercialAppFormProductActions.updateApprovedAmountOnOpp(records, oldMap);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Opportunity> updatedRecords = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.areEqual(
      new Opportunity(Id = oppId, Approved_Amount__c = 550),
      updatedRecords[0],
      'Opportunity approved amount should updated correctly'
    );
  }

  @isTest
  static void updateApprovedAmountOnOppAmbitTest() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afId2 = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afpId2 = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    //GIVEN records, oldMap
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Amount__c = 50,
        Stage = 'Opportunity Won',
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication
        )
      ),
      new ApplicationFormProduct(
        Id = afpId2,
        Amount__c = 500,
        Stage = 'Opportunity Won',
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId2,
        ApplicationForm = new ApplicationForm(
          Id = afId2,
          RecordTypeId = RTApplicationForm.ambitApplication
        )
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Amount__c = 50,
        Stage = 'Opportunity Identified',
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId
      ),
      afpId2 => new ApplicationFormProduct(
        Id = afpId2,
        Amount__c = 500,
        Stage = 'Opportunity Identified',
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId2
      )
    };

    List<ApplicationForm> afList = new List<ApplicationForm>{
      new ApplicationForm(
        Id = afId,
        OpportunityId = oppId,
        RecordTypeId = RTApplicationForm.acmApplication
      ),
      new ApplicationForm(
        Id = afId2,
        OpportunityId = oppId,
        RecordTypeId = RTApplicationForm.ambitApplication
      )
    };

    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(Id = oliId, OpportunityId = oppId)
    };

    appFormProductRepoMock.mock('getApplicationForms', afList);
    appFormProductRepoMock.mock('getAfpRelatedToOpp', records);
    appFormProductRepoMock.mock('getOppLineItems', oliList);

    //WHEN calling a method
    Test.startTest();
    CommercialAppFormProductActions.updateApprovedAmountOnOpp(records, oldMap);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Opportunity> updatedRecords = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.areEqual(
      new Opportunity(Id = oppId, Approved_Amount__c = 500),
      updatedRecords[0],
      'Opportunity approved amount should updated correctly in case of Ambit'
    );
  }

  @isTest
  static void updateApprovedAmountOnOppTestWithException() {
    registerMocks();

    dmlRepoMock.mockException('doUpdate', new DmlException('Update failed!'));

    try {
      Test.startTest();
      CommercialAppFormProductActions.updateApprovedAmountOnOpp(null, null);
      Test.stopTest();
    } catch (exception e) {
      Assert.isTrue(
        e instanceof DmlException,
        'DML exception should be thrown'
      );
    }
  }

  @isTest
  static void calculateEstimatedRevenueOnOppTest() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id oliId2 = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afpId2 = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    //GIVEN records, oldMap
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Revenue__c = 50,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication
        )
      ),
      new ApplicationFormProduct(
        Id = afpId2,
        Revenue__c = 50,
        Opportunity_Product__c = oliId2,
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication
        )
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Revenue__c = 500,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId
      ),
      afpId2 => new ApplicationFormProduct(
        Id = afpId2,
        Revenue__c = 500,
        Opportunity_Product__c = oliId2,
        ApplicationFormId = afId
      )
    };

    List<ApplicationForm> afList = new List<ApplicationForm>{
      new ApplicationForm(
        Id = afId,
        OpportunityId = oppId,
        RecordTypeId = RTApplicationForm.acmApplication
      )
    };

    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(Id = oliId, OpportunityId = oppId),
      new OpportunityLineItem(Id = oliId2, OpportunityId = oppId)
    };

    appFormProductRepoMock.mock('getApplicationForms', afList);
    appFormProductRepoMock.mock('getAfpRelatedToOpp', records);
    appFormProductRepoMock.mock('getOppLineItems', oliList);

    //WHEN calling a method
    Test.startTest();
    CommercialAppFormProductActions.calculateEstimatedRevenueOnOpp(
      records,
      oldMap
    );
    Test.stopTest();

    //THEN it should assert successfully
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Opportunity> updatedRecords = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.areEqual(
      new Opportunity(Id = oppId, Estimated_Revenue__c = 100),
      updatedRecords[0],
      'Opportunity estimated revenue should updated correctly'
    );
  }

  @isTest
  static void calculateEstimatedRevenueOnOppAmbitTest() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afId2 = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afpId2 = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    //GIVEN records, oldMap
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Revenue__c = 50,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication
        )
      ),
      new ApplicationFormProduct(
        Id = afpId2,
        Revenue__c = 500,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId2,
        ApplicationForm = new ApplicationForm(
          Id = afId2,
          RecordTypeId = RTApplicationForm.ambitApplication
        )
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Revenue__c = 500,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId
      ),
      afpId2 => new ApplicationFormProduct(
        Id = afpId2,
        Revenue__c = 50,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId2
      )
    };

    List<ApplicationForm> afList = new List<ApplicationForm>{
      new ApplicationForm(
        Id = afId,
        OpportunityId = oppId,
        RecordTypeId = RTApplicationForm.acmApplication
      ),
      new ApplicationForm(
        Id = afId2,
        OpportunityId = oppId,
        RecordTypeId = RTApplicationForm.ambitApplication
      )
    };

    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(Id = oliId, OpportunityId = oppId)
    };

    appFormProductRepoMock.mock('getApplicationForms', afList);
    appFormProductRepoMock.mock('getAfpRelatedToOpp', records);
    appFormProductRepoMock.mock('getOppLineItems', oliList);

    //WHEN calling a method
    Test.startTest();
    CommercialAppFormProductActions.calculateEstimatedRevenueOnOpp(
      records,
      oldMap
    );
    Test.stopTest();

    //THEN it should assert successfully
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Opportunity> updatedRecords = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.areEqual(
      new Opportunity(Id = oppId, Estimated_Revenue__c = 500),
      updatedRecords[0],
      'Opportunity estimated revenue should update correctly in case of Ambit'
    );
  }

  @isTest
  static void calculateEstimatedRevenueOppTestWithException() {
    registerMocks();

    dmlRepoMock.mockException('doUpdate', new DmlException('Update failed!'));

    try {
      Test.startTest();
      CommercialAppFormProductActions.calculateEstimatedRevenueOnOpp(
        null,
        null
      );
      Test.stopTest();
    } catch (exception e) {
      Assert.isTrue(
        e instanceof DmlException,
        'DML exception should be thrown'
      );
    }
  }

  @isTest
  static void checkSkipStageTest() {
    registerMocks();
    List<Database.Error> errors;
    Database.Error error;
    userRepoMock.mock('checkProfile', true);
    userRepoMock.mock('checkRole', false);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    User userRec = new User(Id = userId, Commercial_Segment__c = 'CBO');

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
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
        OwnerId = userId
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProductId => new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Opportunity Lost',
        ApplicationFormId = appFormId
      )
    };
    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );
    commercialOppRepoMock.mock('getUsers', new List<User>{ userRec });
    Test.startTest();
    CommercialAppFormProductActions.checkSkipStage(appFormProductList, oldMap);
    Test.stopTest();
    errors = appFormProductList[0].getErrors();
    Assert.isFalse(errors.isEmpty(), 'Error not found');
    error = errors.get(0);
    Assert.areEqual(
      'You cannot reopen a closed stage.',
      error.getMessage(),
      'Error not found'
    );
  }

  @isTest
  static void checkStageOnInsertTest() {
    registerMocks();
    String expMsg = 'Stage can only be set to Opportunity Identified.';
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Approved & Offered',
        ApplicationFormId = appFormId
      )
    };

    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );

    Test.startTest();
    CommercialAppFormProductActions.checkStageOnInsert(appFormProductList);
    Test.stopTest();
    List<Database.Error> errors = appFormProductList[0].getErrors();
    Database.Error error = errors.get(0);
    Assert.areEqual(expMsg, error.getMessage(), 'No error occured');
  }

  @isTest
  static void createAppFormSharesForOppOwnerTest() {
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId
    );
    Test.startTest();
    List<ApplicationFormShare> appFormShares = CommercialAppFormProductActions.createAppFormSharesForOppOwner(
      new List<ApplicationForm>{ appFormobj }
    );
    Test.stopTest();
    Assert.areEqual(1, appFormShares.size(), 'Size is not 1');
    Assert.areEqual(
      appFormId,
      appFormShares[0].ParentId,
      'App Form Share record is not created'
    );
  }

  @isTest
  static void updateStageOnOpportunityTest() {
    registerMocks();
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormProductId2 = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Opportunity opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      StageName = 'New'
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Opportunity Won',
        ApplicationFormId = appFormId,
        ApplicationForm = new ApplicationForm(
          RecordTypeId = RTApplicationForm.acmApplication,
          OpportunityId = opp.Id
        )
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProductId => new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Opportunity Identified',
        ApplicationFormId = appFormId,
        ApplicationForm = new ApplicationForm(
          RecordTypeId = RTApplicationForm.acmApplication,
          OpportunityId = opp.Id
        )
      )
    };
    ApplicationFormProduct appFormProductObj = new ApplicationFormProduct(
      Id = appFormProductId2,
      Stage = 'Opportunity Won',
      ApplicationForm = new ApplicationForm(
        RecordTypeId = RTApplicationForm.acmApplication,
        OpportunityId = opp.Id
      )
    );
    appFormProductRepoMock.mock(
      'getRelatedAFP',
      new List<ApplicationFormProduct>{ appFormProductObj }
    );
    appFormProductRepoMock.mock(
      'getAfpRelatedToOpp',
      new List<ApplicationFormProduct>{
        appFormProductObj,
        appFormProductList[0]
      }
    );
    commercialOppRepoMock.mock(
      'getOpenTasksOnClosedOpportunity',
      new List<Map<String, Object>>{}
    );
    Test.startTest();
    CommercialAppFormProductActions.updateStageOnOpportunity(
      appFormProductList,
      oldMap
    );
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Opportunity> updatedRecords = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.areEqual(
      'Opportunity Won',
      updatedRecords[0].StageName,
      'Opportunity record is updated'
    );
  }
  @isTest
  static void updateStageOnOpportunityTestNegativeCase() {
    registerMocks();
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormProductId2 = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Opportunity opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      StageName = 'New'
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Customer Acceptance',
        ApplicationFormId = appFormId,
        ApplicationForm = new ApplicationForm(
          RecordTypeId = RTApplicationForm.acmApplication,
          OpportunityId = opp.Id
        )
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProductId => new ApplicationFormProduct(
        Id = appFormProductId,
        Stage = 'Opportunity Identified',
        ApplicationFormId = appFormId,
        ApplicationForm = new ApplicationForm(
          RecordTypeId = RTApplicationForm.acmApplication,
          OpportunityId = opp.Id
        )
      )
    };
    ApplicationFormProduct appFormProductObj = new ApplicationFormProduct(
      Id = appFormProductId2,
      Stage = 'Opportunity Won',
      ApplicationForm = new ApplicationForm(
        RecordTypeId = RTApplicationForm.acmApplication,
        OpportunityId = opp.Id
      )
    );
    appFormProductRepoMock.mock(
      'getRelatedAFP',
      new List<ApplicationFormProduct>{ appFormProductObj }
    );
    appFormProductRepoMock.mock(
      'getAfpRelatedToOpp',
      new List<ApplicationFormProduct>{
        appFormProductObj,
        appFormProductList[0]
      }
    );
    commercialOppRepoMock.mock(
      'getOpenTasksOnClosedOpportunity',
      new List<Map<String, Object>>{}
    );
    Test.startTest();
    CommercialAppFormProductActions.updateStageOnOpportunity(
      appFormProductList,
      oldMap
    );
    Test.stopTest();
    Assert.isNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should not have been invoked'
    );
  }

  @isTest
  static void populateStageTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afpId2 = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Opportunity Won',
        ApplicationForm = new ApplicationForm(
          RecordTypeId = RTApplicationForm.acmApplication,
          OpportunityId = oppId
        )
      ),
      new ApplicationFormProduct(
        Id = afpId2,
        Stage = 'Cancelled',
        ApplicationForm = new ApplicationForm(
          RecordTypeId = RTApplicationForm.ambitApplication,
          OpportunityId = oppId
        )
      )
    };
    Map<Id, List<ApplicationFormProduct>> appFormProductsByOppId = new Map<Id, List<ApplicationFormProduct>>{
      oppId => afpList
    };

    Test.startTest();
    List<Opportunity> opps = CommercialAppFormProductActions.populateStage(
      appFormProductsByOppId
    );
    Test.stopTest();
    Assert.areEqual(
      'Opportunity Won',
      opps[0].StageName,
      'Opp stage is not Opp Won. '
    );
  }

  @isTest
  static void testSyncSettlementDateAndAmountToOppProductSuccess() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);

    Date initialDate = System.today().addDays(5);
    Date newSettlementDate = System.today().addDays(10);
    Decimal newAmount = 5000.00;

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(Id = oppId, CloseDate = initialDate)
    );

    ApplicationFormProduct oldAfp = new ApplicationFormProduct(
      Id = afpId,
      ApplicationFormId = appFormId,
      Close_Date__c = initialDate,
      Amount__c = 1000.00,
      Opportunity_Product__c = oliId
    );

    ApplicationFormProduct newAfp = new ApplicationFormProduct(
      Id = afpId,
      ApplicationFormId = appFormId,
      Close_Date__c = newSettlementDate,
      Amount__c = newAmount,
      Opportunity_Product__c = oliId
    );

    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );

    Test.startTest();
    CommercialAppFormProductActions.syncSettlementDateAndAmountToOppProduct(
      new List<ApplicationFormProduct>{ newAfp },
      new Map<Id, ApplicationFormProduct>{ afpId => oldAfp }
    );
    Test.stopTest();

    Assert.areEqual(
      newSettlementDate,
      newSettlementDate,
      'Settlement Date mismatch on OLI'
    );
    Assert.areEqual(newAmount, newAmount, 'Amount mismatch on OLI');
    Assert.areEqual(
      newSettlementDate,
      newSettlementDate,
      'Opp CloseDate mismatch'
    );
  }

  @isTest
  static void testSyncSettlementDateAndAmountToOppProductNoChange() {
    registerMocks();

    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Date today = System.today();

    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = afpId,
      Close_Date__c = today,
      Amount__c = 100
    );

    Test.startTest();
    CommercialAppFormProductActions.syncSettlementDateAndAmountToOppProduct(
      new List<ApplicationFormProduct>{ afp },
      new Map<Id, ApplicationFormProduct>{ afpId => afp }
    );
    Test.stopTest();

    Assert.isNull(
      dmlRepoMock.getHistory('doUpdate'),
      'No DML should be performed when no fields changed'
    );
  }

  @isTest
  static void setPotentialDuplicateFlagTest() {
    registerMocks();

    //GIVEN records, oldMap
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = appFormProdId,
        ApplicationFormId = appFormId,
        Reference_Number__c = '1234',
        Is_Potential_Duplicate__c = false,
        Stage = 'Opportunity Won'
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProdId => new ApplicationFormProduct(
        Id = appFormProdId,
        ApplicationFormId = appFormId,
        Reference_Number__c = '123456',
        Is_Potential_Duplicate__c = false,
        Stage = 'Opportunity Won'
      )
    };

    Map<Id, ApplicationForm> appFormMap = new Map<Id, ApplicationForm>{
      appFormId => new ApplicationForm(
        Id = appFormId,
        OpportunityId = oppId,
        RecordTypeId = RTApplicationForm.bbdApplication
      )
    };

    List<ApplicationFormProduct> existingAfpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        ApplicationFormId = appFormProdId,
        Reference_Number__c = '1234',
        Is_Potential_Duplicate__c = false,
        Stage = 'Opportunity Won'
      ),
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        ApplicationFormId = appFormProdId,
        Reference_Number__c = '1234',
        Is_Potential_Duplicate__c = false,
        Stage = 'Opportunity Won'
      )
    };

    appFormProductRepoMock.mock('getApplicationFormsList', appFormMap);
    appFormProductRepoMock.mock('getExistingAfpList', existingAfpList);
    dmlRepoMock.mock(
      'doUpdate',
      TestUtil.getMockSaveResult('{"success":true}')
    );

    //WHEN calling a method
    Test.startTest();
    CommercialAppFormProductActions.setPotentialDuplicateFlag(records, oldMap);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<ApplicationFormProduct> updatedRecords = (List<ApplicationFormProduct>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    //THEN it should update AFP Record
    Assert.areEqual(
      true,
      updatedRecords[0].Is_Potential_Duplicate__c,
      'should update the potential duplicate flag to true'
    );
  }
}
