/**
 * @author       : Akanksha Kulkarni
 * @since        : Nov 2024
 * @description  : Test class for CommercialOpportunityEventBuilder
 **/

@isTest
public class CommercialOpportunityEventBuilderTest {
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
  static void buildOpportunityNodeTest() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
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
        Reference_Number__c = '87687',
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
        AccountId = accId,
        Account = new Account(
          Id = accId,
          External_Id__c = 'CAP-CIS_823749823',
          Source_System_Id__c = 'SYSTEM-123'
        ),
        Application_Numbers__c = 'APP-001',
        RecordTypeId = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    };
    ApplicationForm afList = new ApplicationForm(
      Id = afId,
      AccountId = accId,
      Reference_Number__c = 'APP-001',
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
    OpportunityEventModel.OpportunityDetails jsonPayload = CommercialOpportunityEventBuilder.buildOpportunityNode(
      oppList[0],
      afList,
      oliList[0],
      records[0]
    );
    Test.stopTest();
    System.assertEquals(
      'APP-001',
      jsonPayload.orderID,
      'OrderID value mismatch'
    );
  }

  @isTest
  static void buildOpportunityNodeTestNegative() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        Application_Numbers__c = 'APP-001',
        RecordTypeId = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    };
    ApplicationForm afList = new ApplicationForm(
      Id = afId,
      AccountId = accId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    );
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(Id = oliId, OpportunityId = oppId)
    };
    Test.startTest();
    OpportunityEventModel.OpportunityDetails jsonPayload = CommercialOpportunityEventBuilder.buildOpportunityNode(
      oppList[0],
      afList,
      oliList[0],
      null
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      jsonPayload,
      'MasterNode should not be null for negative scenario.'
    );
  }
}
