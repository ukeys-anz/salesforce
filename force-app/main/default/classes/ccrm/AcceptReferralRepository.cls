/**
 * @author Ayushi Gupta
 * @since  07/2025
 * @description Repo class of AcceptReferralController
 */
public with sharing class AcceptReferralRepository {
  /**
   * @description getCampaignMember to get campaign members
   * @param leadId lead Id
   * @return List<CampaignMember> campaign members list
   */
  public List<CampaignMember> getCampaignMember(Id leadId) {
    return [
      SELECT Id, LeadId
      FROM CampaignMember
      WHERE LeadId = :leadId
      WITH USER_MODE
    ];
  }

  /**
   * @description getLeadRecord to get lead record
   * @param leadId lead Id
   * @return Lead lead record
   */
  public Lead getLeadRecord(Id leadId) {
    return [
      SELECT Id, Campaign_Code__c
      FROM Lead
      WHERE Id = :leadId
      WITH USER_MODE
      LIMIT 1
    ];
  }
}
