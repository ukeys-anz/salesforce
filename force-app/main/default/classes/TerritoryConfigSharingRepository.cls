/**
 * @author MLCRM Developer
 * @since 11/2024
 * @description Repository Class for TerritoryConfigSharingBatch
 */
public inherited sharing class TerritoryConfigSharingRepository {
  /**
   * @description getTerrritories method return Territories associated to teh given ids of the Territory
   * @param strUserTerritoryQuery userTerritory query
   * @param lstOfTerritories list of territories
   * @param objDateTime dateTime used in query
   * @param statusActive status value
   * @return List<Territory__c> Territory__c List
   */
  public List<User_Territory__c> getUserTerritoriesToRecalc(
    String strUserTerritoryQuery,
    List<Territory__c> lstOfTerritories,
    DateTime objDateTime,
    String statusActive
  ) {
    return Database.query(strUserTerritoryQuery);
  }

  /**
   * @name getListOfTerritories
   * @description This method is returns list of Territories using lastmodifieddate
   * @param objDateTime dateTime used in query
   * @return List<Territory__c> list of Territory__c records
   */
  public List<Territory__c> getListOfTerritories(DateTime objDateTime) {
    return [
      SELECT Id, Access_Scope__c
      FROM Territory__c
      WHERE lastModifiedDate >= :objDateTime
      WITH USER_MODE
    ];
  }

  /**
   * @name getTerritoryRecalculationTimeFrame
   * @description if test is running then return fixed value else returns instance of Territory_Based_Sharing_Config__mdt
   * @return Territory_Based_Sharing_Config__mdt- Territory_Recalculation_TImeFrame metadata
   */
  public Territory_Based_Sharing_Config__mdt getTerritoryRecalculationTimeFrame() {
    if (!Test.isRunningTest()) {
      return Territory_Based_Sharing_Config__mdt.getInstance(
        'Territory_Recalculation_TImeFrame'
      );
    }
    return new Territory_Based_Sharing_Config__mdt(
      MasterLabel = 'Territory_Recalculation_TImeFrame',
      DeveloperName = 'Territory_Recalculation_TImeFrame',
      Recalculation_Timeframe__c = 5
    );
  }

  /**
   * @description This method is used to get user territories record ids
   * @name getActiveTerritoryMetadata
   * @return List<Territory_Based_Sharing_Config__mdt> list of active metadata records
   * @author Ashish Kumar
   * @US CC-4493
   */
  public List<Territory_Based_Sharing_Config__mdt> getActiveTerritoryMetadata() {
    if (!Schema.sObjectType.Territory_Based_Sharing_Config__mdt.isQueryable()) {
      return new List<Territory_Based_Sharing_Config__mdt>();
    }
    return [
      SELECT
        Active__c,
        Eligible_Record_Types__c,
        Excluded_Users__c,
        IsParentIdField__c,
        Lookup_Fields__c,
        Object_Name__c,
        Recalculation_Timeframe__c,
        Row_Cause__c,
        Sharing_Object__c,
        Sharing_Scope__c,
        Territory_Field__c
      FROM Territory_Based_Sharing_Config__mdt
      WHERE Active__c = TRUE
    ];
  }
}
