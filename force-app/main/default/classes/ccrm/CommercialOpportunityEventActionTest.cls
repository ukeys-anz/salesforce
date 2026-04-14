/**
 * @author       : Akanksha Kulkarni
 * @since        : Nov 2025
 * @description  : Test class for CommercialOpportunityEventAction
 **/

@isTest
public class CommercialOpportunityEventActionTest {
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
  static void publishApplicationFormEventTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

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
      )
    };

    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    };
    ApplicationForm afList = new ApplicationForm(
      Id = afId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    );
    Map<Id, ApplicationForm> appFormRecords = new Map<Id, ApplicationForm>();
    appFormRecords.put(afId, afList);

    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(Id = oliId, OpportunityId = oppId)
    };

    Test.startTest();
    List<Cloud_Event__e> cloudEvents = CommercialOpportunityEventAction.publishApplicationFormEvent(
      oppList,
      appFormRecords,
      oliList,
      records,
      'insert'
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      cloudEvents.size(),
      '1 Cloud Event Model instances should be created'
    );
  }

  @isTest
  static void publishApplicationFormEventTestException() {
    try {
      Test.startTest();
      CommercialOpportunityEventAction.publishApplicationFormEvent(
        null,
        null,
        null,
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
}
