/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL for Territory related queries.
 * UnusedLocalVariable Surpressed : Used variable in dynamic query
 */
@SuppressWarnings('PMD.UnusedLocalVariable')
public without sharing class TerritoryActionsRepository {
  /**
   * @description getTerrritories method return Territories associated to teh given ids of the Territory
   * @param idsOfTerritory Id of the Territories
   * @return List<Territory__c> Territory__c List
   * Used SYSTEM_MODE for Territories context
   */
  public List<Territory__c> getTerrritories(Set<ID> idsOfTerritory) {
    if (idsOfTerritory.isEmpty()) {
      return new List<Territory__c>();
    }
    return [
      SELECT Id, Primary_Franchise_Owner__c
      FROM Territory__c
      WHERE Id IN :idsOfTerritory
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description This method is used to get map of Id vs territory records based on territory id set
   * @name getMapofTerritories
   * @param idsOfTerritory list of sobject record ids
   * @return Map<Id, Territory__c>
   */
  public Map<Id, Territory__c> getTerritoryMap(Set<Id> idsOfTerritory) {
    if (idsOfTerritory.isEmpty()) {
      return new Map<Id, Territory__c>();
    }
    return new Map<Id, Territory__c>(
      [
        SELECT Primary_Franchise_Owner__c
        FROM Territory__c
        WHERE ID IN :idsOfTerritory
        WITH SYSTEM_MODE
      ]
    );
  }

  /**
   * @description This method is used to get share records of object corresponding to territory sharing metadata
   * @name getShareRecords
   * @param lstOfSobject List of sobjects
   * @param territoryMdt territory sharing metadata
   * @param strParentField parent object field
   * @return List<SObject> list of shared records
   */
  public List<SObject> getShareRecords(
    List<SObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt territoryMdt,
    String strParentField
  ) {
    if (lstOfSobject.isEmpty()) {
      return new List<SObject>();
    }
    String strRowCause = territoryMdt.Row_Cause__c;
    String strQuery =
      'SELECT Id, UserOrGroupId,' +
      String.escapeSingleQuotes(strParentField) +
      ' FROM ' +
      String.escapeSingleQuotes(territoryMdt.Sharing_Object__c) +
      ' WHERE ' +
      String.escapeSingleQuotes(strParentField) +
      ' IN: lstOfSobject and RowCause = :strRowCause';
    return Database.query(strQuery);
  }

  /**
   * @description This method is used to build query
   * @name getSobjectRecord
   * @param objTerritoryMtd sobject territory metadata record
   * @param strLookupFields lookup fields
   * @param idsOfRecords sobject record ids
   * @param strWhereFilter where clause filter
   * @return String sobject query
   * @US CC-1894
   */
  public List<SObject> getSobjectRecord(
    Territory_Based_Sharing_Config__mdt objTerritoryMtd,
    String strLookupFields,
    List<Id> idsOfRecords,
    String strWhereFilter
  ) {
    String strQuery =
      'SELECT Id,' +
      String.escapeSingleQuotes(strLookupFields) +
      String.escapeSingleQuotes(objTerritoryMtd.Territory_Field__c) +
      ',OwnerId FROM ' +
      String.escapeSingleQuotes(objTerritoryMtd.Object_Name__c) +
      ' ' +
      strWhereFilter;
    return Database.query(strQuery);
  }

  /**
   * @description This method is used to get Territory_Based_Sharing_Config__mdt values
   * @name getTerritorySharingMetadata
   * @return List<Territory_Based_Sharing_Config__mdt>
   */
  public List<Territory_Based_Sharing_Config__mdt> getTerritorySharingMetadata() {
    return Territory_Based_Sharing_Config__mdt.getAll().values();
  }

  /**
   * @description get list of territories for given set of Territory Names
   * @name getTerritoriesbyTerritoryNames
   * @param setOfTerritoryName Set of String containing Territory Names
   * @return List<Territory__c> list of Territories
   */
  public List<Territory__c> getTerritoriesbyTerritoryNames(
    Set<String> setOfTerritoryName
  ) {
    if (setOfTerritoryName.isEmpty()) {
      return new List<Territory__c>();
    }
    return new List<Territory__c>(
      [
        SELECT Id, Name
        FROM Territory__c
        WHERE Name IN :setOfTerritoryName
        WITH SYSTEM_MODE
      ]
    );
  }
}
