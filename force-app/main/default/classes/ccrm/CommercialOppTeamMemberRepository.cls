/**
 * @author Ayushi Gupta
 * @since  June 2025
 * @description CommercialOppTeamMember Repository
 */
public with sharing class CommercialOppTeamMemberRepository {
  /**
   * @description to get opp team member related to commercial opp
   * @param oppTeamMemberIdsSet opp team member ids set
   * @return List<OpportunityTeamMember>
   */
  public List<OpportunityTeamMember> getOppTeamMembersRelatedToCommercialOpp(
    Set<Id> oppTeamMemberIdsSet
  ) {
    if (oppTeamMemberIdsSet.isEmpty()) {
      return new List<OpportunityTeamMember>();
    }
    return [
      SELECT Id, OpportunityId, UserId
      FROM OpportunityTeamMember
      WHERE
        Id IN :oppTeamMemberIdsSet
        AND Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
      WITH USER_MODE
    ];
  }

  /**
   * @description to get app form products related to commercial opp
   * @param oppIds opp ids set
   * @return List<ApplicationForm>
   */
  public List<ApplicationForm> getAppFormsRelatedToCommercialOpp(
    Set<Id> oppIds
  ) {
    if (oppIds.isEmpty()) {
      return new List<ApplicationForm>();
    }
    return [
      SELECT Id, OpportunityId
      FROM ApplicationForm
      WHERE OpportunityId IN :oppIds
      WITH USER_MODE
    ];
  }

  /**
   * @description to get app form share records
   * @param userIds user ids set
   * @return List<ApplicationFormShare>
   */
  public List<ApplicationFormShare> getAppFormShareRecords(Set<Id> userIds) {
    if (userIds.isEmpty()) {
      return new List<ApplicationFormShare>();
    }
    return [
      SELECT Id
      FROM ApplicationFormShare
      WHERE UserOrGroupId IN :userIds AND RowCause = 'Manual'
      WITH USER_MODE
    ];
  }
  /**
   * @description to get opp team members related to opp
   * @param oppIds opp ids set
   * @return List<OpportunityTeamMember>
   */
  public List<OpportunityTeamMember> getOppTeamMembersRelatedToOpp(
    Set<Id> oppIds
  ) {
    if (oppIds.isEmpty()) {
      return new List<OpportunityTeamMember>();
    }
    return [
      SELECT Id, UserId, OpportunityId
      FROM OpportunityTeamMember
      WHERE OpportunityId IN :oppIds
      WITH USER_MODE
    ];
  }
}
