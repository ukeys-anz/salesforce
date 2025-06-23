/**
 * @author       : Naman Garg
 * @since        : May 2025
 * @description  : QueryReferralCustomerNeedMapping is the class for Referral_Customer_Need_Mapping__mdt Configuration object
 **/
public with sharing class QueryReferralCustomerNeedMapping {
  private static List<Referral_Customer_Need_Mapping__mdt> referralCustomerNeedsList = [
    SELECT
      Id,
      MasterLabel,
      Customer_Need__c,
      Lead_Record_Type__c,
      Referral_Customer_Needs__c
    FROM Referral_Customer_Need_Mapping__mdt
    WITH SYSTEM_MODE
  ];

  private static Map<String, Referral_Customer_Need_Mapping__mdt> referralCustomerNeedsMap = (Map<String, Referral_Customer_Need_Mapping__mdt>) ListUtil.mapBy(
    referralCustomerNeedsList,
    Referral_Customer_Need_Mapping__mdt.MasterLabel
  );

  /**
   * @description Returns a Referral_Customer_Need_Mapping__mdt for the statusKey
   * @param key Record Type concatenated with Referral Customer needs
   * @return The metadata record associated with key
   */
  public static Referral_Customer_Need_Mapping__mdt get(String key) {
    return referralCustomerNeedsMap.get(key);
  }
}
