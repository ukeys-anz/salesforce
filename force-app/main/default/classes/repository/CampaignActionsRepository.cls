/**
 * @author Prahlad Bhadani
 * @since  02/2025
 * @group Platform
 * @description Repository class for CampaignActions
 */
public with sharing class CampaignActionsRepository {
  /**
   * @description get default campaign
   * @name getDefaultCampaign
   * @return List<Campaign>
   * @param campaignCodes set of campaign codes
   */
  public List<Campaign> getDefaultCampaign(Set<String> campaignCodes) {
    if (campaignCodes.isEmpty()) {
      return new List<Campaign>();
    }
    return [
      SELECT Id, Code__c, Name
      FROM Campaign
      WHERE Code__c = :campaignCodes
      WITH USER_MODE
    ];
  }

  /**
   * @description get campaign records ending after today from campaign codes
   * @name getCampaignRecords
   * @return List<Campaign>
   * @param campaignCodes set of campaign codes
   */
  public List<Campaign> getCampaignRecords(Set<String> campaignCodes) {
    if (campaignCodes.isEmpty()) {
      return new List<Campaign>();
    }
    return [
      SELECT Id, Code__c, Priority__c, Description, Description__c, Name
      FROM Campaign
      WHERE Code__c IN :campaignCodes AND EndDate >= TODAY
      WITH USER_MODE
    ];
  }
}