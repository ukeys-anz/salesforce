/**
 * @author       : Ankit Garg
 * @since        : Aug 2025
 * @description  : QueryTerritoryBasedSharingConfig is the class for Territory_Based_Sharing_Config__mdt Configuration object
 **/
public with sharing class QueryTerritoryBasedSharingConfig {
  private static List<Territory_Based_Sharing_Config__mdt> territorySharingConfigList = [
    SELECT
      Id,
      MasterLabel,
      Active__c,
      Eligible_Record_Types__c,
      Excluded_Users__c,
      Lookup_Fields__c,
      Object_Name__c,
      Recalculation_Timeframe__c,
      Row_Cause__c,
      Sharing_Object__c,
      Sharing_Scope__c,
      Territory_Field__c,
      IsParentIdField__c
    FROM Territory_Based_Sharing_Config__mdt
    WHERE Active__c = TRUE
    WITH SYSTEM_MODE
  ];

  public static Map<String, Territory_Based_Sharing_Config__mdt> territorySharingConfigByObjectMap = (Map<String, Territory_Based_Sharing_Config__mdt>) ListUtil.mapBy(
    territorySharingConfigList,
    Territory_Based_Sharing_Config__mdt.Object_Name__c
  );

  /**
   * @description Returns a Territory_Based_Sharing_Config__mdt for the objectName
   * @param objectName The scope key is an Object Name
   * @return The metadata record associated with objectName
   */
  public static Territory_Based_Sharing_Config__mdt get(String objectName) {
    return territorySharingConfigByObjectMap.get(objectName);
  }
}
