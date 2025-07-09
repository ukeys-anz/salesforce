trigger OpportunityTeamMemberTrigger on OpportunityTeamMember(
  after insert,
  after delete
) {
  CommercialOppTeamMemberTriggerHandler commercialHandler = new CommercialOppTeamMemberTriggerHandler();
}
