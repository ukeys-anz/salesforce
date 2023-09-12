/**
 * @author Mairaj H
 * @since  10/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMCampaignActions is class to handle all the Campaign Actions
 */
public with sharing class CCRMCampaignActions {
  //Constant Values
  public static final String CCRM_DEFAULT_CAMPAIGN = Label.CCRM_DefaultCampaign;
  public static final String ML_DEFAULT_CAMPAIGN = Label.MLCRM_DefaultCampaign;

  /**
   * @description Set default campaign of manually created leads.
   * @name setDefaultCampaign
   * @param records List of leads to process
   */
  public static void setDefaultCampaign(List<Lead> records) {
    if (!Campaign.SObjectType.getDescribe().isAccessible()) {
      return;
    }
    Map<String, Campaign> defaultCampaignMap = getDefaultCampaign();

    for (Lead record : records) {
      if (
        !defaultCampaignMap.isEmpty() && String.isBlank(record.Campaign_Code__c)
      ) {
        if (
          CCRMLeadUtil.isCCRMLeadType(record) &&
          defaultCampaignMap.containsKey(CCRM_DEFAULT_CAMPAIGN)
        ) {
          record.Campaign_Code__c = defaultCampaignMap.get(
              CCRM_DEFAULT_CAMPAIGN
            )
            .Code__c;
        } else if (
          CCRMLeadUtil.isMLCRMLeadType(record) &&
          defaultCampaignMap.containsKey(ML_DEFAULT_CAMPAIGN)
        ) {
          record.Campaign_Code__c = defaultCampaignMap.get(ML_DEFAULT_CAMPAIGN)
            .Code__c;
        }
      }
      //CC-4179 populate campaign Name from Campaign for ML
      if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        defaultCampaignMap != null &&
        defaultCampaignMap.containsKey(ML_DEFAULT_CAMPAIGN) &&
        String.isBlank(record.Campaign_Name__c)
      ) {
        record.Campaign_Name__c = defaultCampaignMap.get(ML_DEFAULT_CAMPAIGN)
          .Name;
      }
    }
  }

  /**
   * @description Get list of Campaigns from Campaign_Code__c on CCRM Leads.
   * @name getCCRMLeadCampaigns
   * @param records List of lead records.
   * @return Map<String, Campaign> Type where Key is Campaign_Code__c.
   */
  public static Map<String, Campaign> getCCRMLeadCampaigns(List<Lead> records) {
    Set<String> campaignCodes = new Set<String>();
    Map<String, Campaign> mapCampaignCodeRecord = new Map<String, Campaign>();

    if (Schema.sObjectType.Campaign.isQueryable() == false) {
      return mapCampaignCodeRecord;
    }

    for (Lead selectLead : records) {
      if (
        (CCRMLeadUtil.isCCRMLeadType(selectLead) ||
        CCRMLeadUtil.isMLCRMLeadType(selectLead)) &&
        !String.isBlank(selectLead.Campaign_Code__c)
      ) {
        campaignCodes.add(selectLead.Campaign_Code__c);
      }
    }

    if (campaignCodes.isEmpty()) {
      return mapCampaignCodeRecord;
    }

    for (Campaign campaignRecord : [
      SELECT Id, Code__c, Priority__c, Description, Description__c, Name
      FROM Campaign
      WHERE Code__c IN :campaignCodes AND EndDate >= TODAY
      WITH USER_MODE
    ]) {
      mapCampaignCodeRecord.put(campaignRecord.Code__c, campaignRecord);
    }

    return mapCampaignCodeRecord;
  }

  /**
   * @description Set default campaign of manually created leads.
   * @name getDefaultCampaign
   * @return `defaultCampaignMap`
   */
  public static Map<String, Campaign> getDefaultCampaign() {
    Set<String> defaultCampaignCodes = new Set<String>();
    defaultCampaignCodes.add(CCRM_DEFAULT_CAMPAIGN);
    defaultCampaignCodes.add(ML_DEFAULT_CAMPAIGN);
    List<Campaign> defaultCampaign = new List<Campaign>();
    Map<String, Campaign> defaultCampaignMap = new Map<String, Campaign>();
    try {
      defaultCampaign = [
        SELECT Id, Code__c, Name
        FROM Campaign
        WHERE Code__c = :defaultCampaignCodes
        WITH SECURITY_ENFORCED
      ];
      if (defaultCampaign.isEmpty()) {
        Logger.error(
          'No default campaign exist. Please create default campaign with Campaign Code = ' +
          defaultCampaignCodes
        );
        Logger.saveLog();
        return defaultCampaignMap;
      } else {
        for (Campaign camp : defaultCampaign) {
          defaultCampaignMap.put(camp.Code__c, camp);
        }
      }
    } catch (System.QueryException qe) {
      Logger.error('InsufficientAccessException', qe);
      Logger.saveLog();
    }
    return defaultCampaignMap;
  }
}
