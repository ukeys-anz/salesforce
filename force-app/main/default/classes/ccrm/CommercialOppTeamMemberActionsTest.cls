/**
 * @author       : Ayushi Gupta
 * @since        : June 2025
 * @description  : Test class for CommercialOppTeamMemberActions
 **/
@isTest
public class CommercialOppTeamMemberActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider oppTeamMemberRepo;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    oppTeamMemberRepo = Lib_MockProvider.forType(
      CommercialOppTeamMemberRepository.class
    );
  }
  @isTest
  static void createAppFormShareRecordsTest() {
    registerMocks();
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

    Test.startTest();
    CommercialOppTeamMemberActions.createAppFormShareRecords(
      new List<OpportunityTeamMember>{ oppTeamMember }
    );
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(appFormShares.size(), 1, 'App Form Record is not shared');
  }
  @isTest
  static void createAppFormShareRecordsNegativeTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id memberId = Lib_FakeIdGenerator.getMockId(
      OpportunityTeamMember.SObjectType
    );
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      Id = memberId,
      OpportunityId = oppId,
      UserId = userId
    );
    oppTeamMemberRepo.mock(
      'getOppTeamMembersRelatedToCommercialOpp',
      new List<OpportunityTeamMember>()
    );
    oppTeamMemberRepo.mock(
      'getAppFormsRelatedToCommercialOpp',
      new List<ApplicationForm>()
    );

    Test.startTest();
    CommercialOppTeamMemberActions.createAppFormShareRecords(
      new List<OpportunityTeamMember>{ oppTeamMember }
    );
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(appFormShares.size(), 0, 'App Form Record is shared');
  }

  @isTest
  static void deleteAppFormShareRecordsTest() {
    registerMocks();
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
    Test.startTest();
    CommercialOppTeamMemberActions.deleteAppFormShareRecords(
      new List<OpportunityTeamMember>{ oppTeamMember }
    );
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      appFormShares.size(),
      1,
      'App Form Share Record is not deleted'
    );
  }

  @isTest
  static void deleteAppFormShareRecordsNegativeTest() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id memberId = Lib_FakeIdGenerator.getMockId(
      OpportunityTeamMember.SObjectType
    );
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      Id = memberId,
      UserId = userId
    );
    oppTeamMemberRepo.mock(
      'getAppFormShareRecords',
      new List<ApplicationFormShare>()
    );
    Test.startTest();
    CommercialOppTeamMemberActions.deleteAppFormShareRecords(
      new List<OpportunityTeamMember>{ oppTeamMember }
    );
    Test.stopTest();
    List<ApplicationFormShare> appFormShares = (List<ApplicationFormShare>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      appFormShares.size(),
      0,
      'App Form Share Record is deleted'
    );
  }
}
