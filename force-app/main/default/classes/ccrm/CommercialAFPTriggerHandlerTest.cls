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
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userInfoMock = Lib_MockProvider.forType(UserInfoRepository.class);
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );

    appFormProductRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
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
}
