/**
 * @author Mairaj H
 * @since  10/2022
 * @group Platform
 * @description CampaignActions is class to handle all the Campaign Actions
 */
public with sharing class CampaignActions {
  public static final Set<String> DEFAULT_CAMPAIGN_CODES = new Set<String>{
    Label.Commercial_DefaultCampaign,
    Label.MobileLending_DefaultCampaign,
    Label.Referral_DefaultCampaign
  };
  private static final CampaignActionsRepository CAMPAIGN_REPOSITORY = (CampaignActionsRepository) Lib_InstanceProvider.forType(
    CampaignActionsRepository.class
  );

  /**
   * @description Set default campaign of manually created commercial leads.
   * @name setDefaultCampaignOnCommercialLead
   * @param records List of leads to process
   */
  public static void setDefaultCampaignOnCommercialLead(List<Lead> records) {
    Map<String, Campaign> defaultCampaignMap = getDefaultCampaign();
    Campaign defaultCampaign = defaultCampaignMap.get(
      Label.Commercial_DefaultCampaign
    );
    List<Lead> ccrmLeadList = ListUtil.filter(records)
      .isNull(Lead.Campaign_Code__c)
      .toList();

    ListUtil.setField(
      ccrmLeadList,
      Lead.Campaign_Code__c,
      defaultCampaign?.Code__c
    );
  }

  /**
   * @description Set default campaign on Referral Lead
   * @name setDefaultCampaignOnReferralLead
   * @param records List of leads to process
   */
  public static void setDefaultCampaignOnReferralLead(List<Lead> records) {
    Map<String, Campaign> defaultCampaignMap = getDefaultCampaign();
    Campaign defaultCampaign = defaultCampaignMap.get(
      Label.Referral_DefaultCampaign
    );
    List<Lead> referralLeadList = ListUtil.filter(records)
      .isNull(Lead.Campaign_Code__c)
      .toList();

    ListUtil.setField(
      referralLeadList,
      Lead.Campaign_Code__c,
      defaultCampaign?.Code__c
    );
  }

  /**
   * @description Set default campaign of manually created ML leads.
   * @name setDefaultCampaignOnMLLead
   * @param records List of leads to process
   */
  public static void setDefaultCampaignOnMLLead(List<Lead> records) {
    Map<String, Campaign> defaultCampaignMap = getDefaultCampaign();
    Campaign defaultCampaign = defaultCampaignMap.get(
      Label.MobileLending_DefaultCampaign
    );
    List<Lead> mlcrmLeadList = ListUtil.filter(records)
      .isNull(Lead.Campaign_Code__c)
      .toList();

    ListUtil.setField(
      mlcrmLeadList,
      Lead.Campaign_Code__c,
      defaultCampaign?.Code__c
    );
    ListUtil.setField(
      mlcrmLeadList,
      Lead.Campaign_Name__c,
      defaultCampaign?.Name
    );
  }

  /**
   * @description Set default campaign of manually created leads.
   * @name getDefaultCampaign
   * @return `defaultCampaignMap`
   */
  public static Map<String, Campaign> getDefaultCampaign() {
    List<Campaign> defaultCampaign = CAMPAIGN_REPOSITORY.getDefaultCampaign(
      DEFAULT_CAMPAIGN_CODES
    );
    return (Map<String, Campaign>) ListUtil.mapBy(
      defaultCampaign,
      Campaign.Code__c
    );
  }
}
