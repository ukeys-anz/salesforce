/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL for Territory related queries.
 */
public with sharing class TerritoryActionsRepository {
  /**
   * @description getTerrritories method return Territories associated to teh given ids of the Territory
   * @param idsOfTerritory Id of the Territories
   * @return List<Territory__c> Territory__c List
   */
  public List<Territory__c> getTerrritories(Set<ID> idsOfTerritory) {
    if (!Schema.sObjectType.Territory__c.isQueryable()) {
      return new List<Territory__c>();
    }
    if (idsOfTerritory.isEmpty()) {
      return new List<Territory__c>();
    }
    return [
      SELECT Id, Primary_Franchise_Owner__c
      FROM Territory__c
      WHERE Id IN :idsOfTerritory
      WITH SECURITY_ENFORCED
    ];
  }
}
