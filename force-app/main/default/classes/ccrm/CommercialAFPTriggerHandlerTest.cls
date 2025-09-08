/**
 * @author       : Naman Garg
 * @since        : Aug 2025
 * @description  : This is test class for CommercialAppFormProductTriggerHandler
 **/

@isTest
public class CommercialAFPTriggerHandlerTest {
  static Lib_MockProvider userInfoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider commercialOppRepoMock;
  static Lib_MockProvider appFormProductRepoMock;
  static Lib_MockProvider oppTeamMemberRepo;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userInfoMock = Lib_MockProvider.forType(UserInfoRepository.class);
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );

    appFormProductRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
    oppTeamMemberRepo = Lib_MockProvider.forType(
      CommercialOppTeamMemberRepository.class
    );
  }

  @isTest
  static void beforeInsertTest() {
    registerMocks();

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

    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
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

    CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
    handler.records = records;

    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.isNotNull(
      records[0].Close_Date__c,
      'Close date not updated on Application form product'
    );
  }

  @isTest
  static void afterInsertTest() {
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

    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
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
    CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
    handler.records = records;

    Test.startTest();
    handler.onAfterInsert();
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
  static void onBeforeUpdateTest() {
    registerMocks();
    List<Database.Error> errors;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    User userRec = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Commercial_Segment__c = 'CBO'
    );

    //GIVEN records, oldMap, afpList
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Customer Acceptance',
        ApplicationFormId = afId,
        OwnerId = userRec.Id,
        Close_Date__c = DateTimeUtils.getNextWeekdayDate(4)
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Opportunity Identified',
        OwnerId = userRec.Id,
        Close_Date__c = DateTimeUtils.getNextWeekdayDate(4)
      )
    };

    List<ApplicationForm> afpList = new List<ApplicationForm>{
      new ApplicationForm(
        Id = afId,
        Opportunity = new Opportunity(
          Id = oppId,
          RecordTypeId = RTOpportunity.commercialOpportunity
        )
      )
    };

    // Mock the Repo Methods
    commercialOppRepoMock.mock('getUsers', new List<User>{ userRec });
    userInfoMock.mock('checkProfile', true);
    appFormProductRepoMock.mock('getApplicationForms', afpList);

    CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    errors = records[0].getErrors();

    //THEN it should assert successfully
    Assert.isTrue(
      errors.isEmpty(),
      'Expected no errors, but found: ' + errors.size()
    );
  }

  @isTest
  static void onBeforeUpdateTest2() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    User userRec = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Commercial_Segment__c = 'CBO'
    );

    //GIVEN records, oldMap, afpList
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Opportunity Identified',
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.ambitApplication
        ),
        OwnerId = userRec.Id,
        Close_Date__c = DateTimeUtils.getNextWeekdayDate(4),
        Source_System_status__c = 'Credit Approved & Offered'
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Opportunity Identified',
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.ambitApplication
        ),
        OwnerId = userRec.Id,
        Close_Date__c = DateTimeUtils.getNextWeekdayDate(4)
      )
    };

    List<ApplicationForm> afpList = new List<ApplicationForm>{
      new ApplicationForm(
        Id = afId,
        RecordTypeId = RTApplicationForm.ambitApplication,
        Opportunity = new Opportunity(
          Id = oppId,
          RecordTypeId = RTOpportunity.commercialOpportunity
        )
      )
    };

    // Mock the Repo Methods
    commercialOppRepoMock.mock('getUsers', new List<User>{ userRec });
    userInfoMock.mock('checkProfile', true);
    appFormProductRepoMock.mock('getApplicationForms', afpList);

    CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      'Opportunity Identified',
      records[0].Stage,
      'Stage should not get changed as source system status is not valid'
    );
  }

  @isTest
  static void onBeforeUpdateTest3() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    User userRec = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Commercial_Segment__c = 'CBO'
    );

    //GIVEN records, oldMap, afpList
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Opportunity Won',
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.ambitApplication
        ),
        OwnerId = userRec.Id
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Customer Acceptance',
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.ambitApplication
        ),
        OwnerId = userRec.Id
      )
    };

    List<ApplicationForm> afpList = new List<ApplicationForm>{
      new ApplicationForm(
        Id = afId,
        RecordTypeId = RTApplicationForm.ambitApplication,
        Opportunity = new Opportunity(
          Id = oppId,
          RecordTypeId = RTOpportunity.commercialOpportunity
        )
      )
    };

    // Mock the Repo Methods
    commercialOppRepoMock.mock('getUsers', new List<User>{ userRec });
    userInfoMock.mock('checkProfile', false);
    appFormProductRepoMock.mock('getApplicationForms', afpList);

    CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      System.Today(),
      records[0].Close_Date__c,
      'Close Date should get updated to today\'s date'
    );
  }

  @isTest
  static void onBeforeUpdateTest4() {
    registerMocks();

    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    User userRec = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Commercial_Segment__c = 'CBO'
    );

    //GIVEN records, oldMap, afpList
    List<ApplicationFormProduct> records = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Needs Analysis',
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.ambitApplication
        ),
        OwnerId = userRec.Id
      )
    };

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpId => new ApplicationFormProduct(
        Id = afpId,
        Stage = 'Opportunity Identified',
        ApplicationFormId = afId,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.ambitApplication
        ),
        OwnerId = userRec.Id
      )
    };

    // Mock the Repo Methods
    userInfoMock.mock('checkProfile', false);

    CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      System.Today(),
      records[0].Last_Updated_Stage_Date__c,
      'Last Update stage Date should get updated to today\'s date'
    );
  }

  @isTest
  static void onAfterUpdateTest() {
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

    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId
      ),
      new ApplicationFormProduct(
        Id = afpId,
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

    CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onAfterUpdate(oldMap);
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
}
