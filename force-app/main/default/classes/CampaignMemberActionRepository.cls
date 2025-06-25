/**
 * @author MLCRM Developer
 * @since 12/2024
 * @description This class provide SOQL for Campaign Member related queries.
 */
public with sharing class CampaignMemberActionRepository {
  /**
   * @description getCampaignMember method return campaign member associated to the given ids of the lead
   * @param leadIds Id of the leads
   * @return List<CampaignMember> Campaign Member List
   */
  public List<CampaignMember> getCampaignMember(Set<ID> leadIds) {
    if (leadIds.isEmpty()) {
      return new List<CampaignMember>();
    }
    return [
      SELECT LeadId, Campaign.EndDate
      FROM CampaignMember
      WHERE leadId = :leadIds
      WITH USER_MODE
    ];
  }
}
