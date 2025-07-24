/**
 * @author       : Naman Garg
 * @since        : May 2025
 * @description  : QueryLeadToReferralStatusMapping is the class for Lead_To_Referral_Status_Mapping__mdt Configuration object
 **/
public with sharing class QueryLeadToReferralStatusMapping {
  private static List<Lead_To_Referral_Status_Mapping__mdt> leadToReferralStatusList = [
    SELECT
      Id,
      MasterLabel,
      Lead_Outcome__c,
      Lead_Status__c,
      Record_Type_Name__c,
      Referral_Status__c
    FROM Lead_To_Referral_Status_Mapping__mdt
    WITH SYSTEM_MODE
  ];

  private static Map<String, Lead_To_Referral_Status_Mapping__mdt> leadToReferralStatusMap = (Map<String, Lead_To_Referral_Status_Mapping__mdt>) ListUtil.mapBy(
    leadToReferralStatusList,
    Lead_To_Referral_Status_Mapping__mdt.MasterLabel
  );

  /**
   * @description Returns a Lead_To_Referral_Status_Mapping__mdt for the statusKey
   * @param statusKey The scope key is a Combination of RecordType-Status-LeadOutcome.
   * @return The metadata record associated with statusKey
   */
  public static Lead_To_Referral_Status_Mapping__mdt get(String statusKey) {
    return leadToReferralStatusMap.get(statusKey);
  }
}
