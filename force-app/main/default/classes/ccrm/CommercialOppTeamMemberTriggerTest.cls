@isTest
private class CommercialOppTeamMemberTriggerTest {
  @isTest
  static void createOppTeamMemberTest() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    System.runAs(ccrmUser) {
      List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
        1,
        null
      );
      Test.startTest();
      List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
      OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
      oppTeamMember.OpportunityId = opps[0].Id;
      oppTeamMember.UserId = ccrmUser.Id;
      oppTeamMember.TeamMemberRole = 'Asset Finance';
      oppTeamMembers.add(oppTeamMember);
      insert oppTeamMembers;
      Test.stopTest();
      Assert.areEqual(1, oppTeamMembers.size(), 'Size is not 1');
    }
  }
}
