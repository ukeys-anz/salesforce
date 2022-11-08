/**
 * @author Mairaj H
 * @since  10/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMCampaignActions is class to handle all the Campaign Actions
 */
public with sharing class CCRMCampaignActions {
  /**
   * @description Set default campaign of manually created leads.
   * @name setDefaultCampaign
   * @param records List of leads to process
   */
  public static void setDefaultCampaign(List<Lead> records) {
    List<Lead> leadsToUpdate = new List<Lead>();
    Campaign defaultCampaign = getDefaultCampaign();

    for (Lead record : records) {
      if (
        CCRMLeadUtil.isCCRMLeadType(record) &&
        defaultCampaign != null &&
        String.isBlank(record.Campaign_Code__c)
      ) {
        record.Campaign_Code__c = defaultCampaign.Code__c;
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
        CCRMLeadUtil.isCCRMLeadType(selectLead) &&
        !String.isBlank(selectLead.Campaign_Code__c)
      ) {
        campaignCodes.add(selectLead.Campaign_Code__c);
      }
    }

    for (Campaign campaignRecord : [
      SELECT Id, Code__c, Priority__c, Description, Description__c
      FROM Campaign
      WHERE Code__c IN :campaignCodes AND EndDate >= TODAY
    ]) {
      mapCampaignCodeRecord.put(campaignRecord.Code__c, campaignRecord);
    }

    return mapCampaignCodeRecord;
  }

  /**
   * @description Set default campaign of manually created leads.
   * @name getDefaultCampaign
   * @return `Campaign`
   */
  public static Campaign getDefaultCampaign() {
    String defaultCampaignCode = Label.CCRM_DefaultCampaign;
    List<Campaign> defaultCampaign = new List<Campaign>();
    try {
      defaultCampaign = [
        SELECT Id, Code__c
        FROM Campaign
        WHERE Code__c = :defaultCampaignCode
        WITH SECURITY_ENFORCED
      ];
      if (defaultCampaign.isEmpty()) {
        Logger.error(
          'No default campaign exist. Please create default campaign with Campaign Code = ' +
          defaultCampaignCode
        );
        Logger.saveLog();
        return new Campaign();
      }
    } catch (System.QueryException qe) {
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'getDefaultCampaign'
      );
      log.error(
        'InsufficientAccessException',
        qe.getMessage(),
        qe.getTypeName()
      );
      log.publishEvent();
    }
    return defaultCampaign[0];
  }
}
