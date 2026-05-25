/**
 * @author       : Kritika Sharma
 * @since        : April, 2026
 * @description  : Utility class to map Lead Status and Opportunity Stage to iKnow statuses using Custom Metadata.
 */
public with sharing class ReferralStatusMapper {
  /**
   * @description Retrieves the status/stage to iKnow status metadata mapping for Opportunity and Lead objects.
   * @param objName The object name indicating whether Lead Status or Opportunity Stage changed
   * @return List<Referral_and_Opportunity_Status_mapping__mdt> A list of iKnow mapped status and stage records
   */
  public static List<Referral_and_Opportunity_Status_mapping__mdt> getMappingByObject(
    String objName
  ) {
    List<Referral_and_Opportunity_Status_mapping__mdt> mappingList = [
      SELECT
        Source_Object__c,
        CRM_Referral_Status__c,
        CRM_Opportunity_Stage__c,
        iKnow_Status__c,
        iKnow_Stage__c,
        Channel__c
      FROM Referral_and_Opportunity_Status_mapping__mdt
      WHERE Is_Active__c = TRUE AND Source_Object__c = :objName
      WITH SYSTEM_MODE
    ];
    return mappingList;
  }
}
