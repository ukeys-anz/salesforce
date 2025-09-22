/**
 * @author       : Mildeep Singh
 * @since        : August 2025
 * @description  : This is test class for CommercialOppTeamMemberTriggerHandler
 **/
@isTest
public with sharing class CommercialOppTeamMembrTriggerHandlerTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider oppTeamMemberRepo;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    oppTeamMemberRepo = Lib_MockProvider.forType(
      CommercialOppTeamMemberRepository.class
    );
  }
  @isTest
  static void afterInsertTest() {
    registerMocks();

    // GIVEN OpportunityTeamMember
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id memberId = Lib_FakeIdGenerator.getMockId(
      OpportunityTeamMember.SObjectType
    );
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      Id = memberId,
      OpportunityId = oppId,
      UserId = userId
    );
    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        RecordTypeId = RTOpportunity.commercialOpportunity
      )
    );
    oppTeamMemberRepo.mock(
      'getOppTeamMembersRelatedToCommercialOpp',
      new List<OpportunityTeamMember>{ oppTeamMember }
    );
    oppTeamMemberRepo.mock(
      'getAppFormsRelatedToCommercialOpp',
      new List<ApplicationForm>{ appFormobj }
    );
    CommercialOppTeamMemberTriggerHandler handler = new CommercialOppTeamMemberTriggerHandler();
    handler.records = new List<OpportunityTeamMember>{ oppTeamMember };

    // WHEN calling onAfterInsert
    Test.startTest();
    handler.onAfterInsert();
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    // THEN AppFormShare record should be created
    Assert.areEqual(appFormShares.size(), 1, 'App Form Record is not shared');
  }

  @isTest
  static void deleteAppFormShareRecordsTest() {
    registerMocks();

    // GIVEN OpportunityTeamMember
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id memberId = Lib_FakeIdGenerator.getMockId(
      OpportunityTeamMember.SObjectType
    );
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      Id = memberId,
      UserId = userId
    );
    ApplicationFormShare appFormShare = new ApplicationFormShare(
      ParentId = appFormId,
      UserOrGroupId = userId,
      RowCause = 'Manual'
    );
    oppTeamMemberRepo.mock(
      'getAppFormShareRecords',
      new List<ApplicationFormShare>{ appFormShare }
    );

    CommercialOppTeamMemberTriggerHandler handler = new CommercialOppTeamMemberTriggerHandler();
    handler.records = new List<OpportunityTeamMember>{ oppTeamMember };

    // THEN calling onAfterDelete
    Test.startTest();
    handler.onAfterDelete();
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');

    // THEN AppFormShare record should be created
    Assert.areEqual(
      appFormShares.size(),
      1,
      'App Form Share Record is not deleted'
    );
  }
}
