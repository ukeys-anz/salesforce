/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description CustomerRelationNotesTriggerActions is class to handle all the MLCRM (Mobile Lending CRM) Actions
 */
public with sharing class CustomerRelationNotesTriggerActions {
  /**
   * @description This method to update is new flag checkbox to false during implicit update while lead creation
   * @name validatePrimaryRelationshipNotes
   * @param oldMap Map of old map
   * @param records List of customer relationship records
   * @author Ashish Kumar
   * @US CC-2175
   */
  public static void validatePrimaryRelationshipNotes(
    Map<Id, Customer_Relationship__c> oldMap,
    List<Customer_Relationship__c> records
  ) {
    Set<Id> idsOfPrimaryOwner = new Set<Id>();
    Set<Id> idsOfCustomer = new Set<Id>();
    String strNotesPrimaryKey;
    for (Customer_Relationship__c objRelationship : records) {
      if (
        (oldMap == null ||
        (oldMap != null &&
        (oldMap.get(objRelationship.Id).Relationship_To_Franchise__c !=
        objRelationship.Relationship_To_Franchise__c ||
        oldMap.get(objRelationship.Id).OwnerId != objRelationship.OwnerId ||
        oldMap.get(objRelationship.Id).Territory__c !=
        objRelationship.Territory__c)))
      ) {
        idsOfCustomer.add(objRelationship.Customer__c);
      }
    }
    if (!idsOfCustomer.isEmpty()) {
      Map<String, Integer> mapOfPrimaryNotes = new Map<String, Integer>();
      for (Customer_Relationship__c objRelation : [
        SELECT Id, Customer__c, Territory__r.Primary_Franchise_Owner__c
        FROM Customer_Relationship__c
        WHERE
          Customer__c IN :idsOfCustomer
          AND Relationship_To_Franchise__c = 'Primary'
      ]) {
        strNotesPrimaryKey =
          String.valueOf(objRelation.Customer__c) +
          String.valueOf(objRelation.Territory__r.Primary_Franchise_Owner__c);
        if (!mapOfPrimaryNotes.containsKey(strNotesPrimaryKey)) {
          mapOfPrimaryNotes.put(strNotesPrimaryKey, 1);
        } else {
          Integer counter = mapOfPrimaryNotes.get(strNotesPrimaryKey);
          mapOfPrimaryNotes.put(strNotesPrimaryKey, counter + 1);
        }
        if (objRelation.Territory__r.Primary_Franchise_Owner__c != null) {
          idsOfPrimaryOwner.add(
            objRelation.Territory__r.Primary_Franchise_Owner__c
          );
        }
      }

      Map<Id, Territory__c> mapOfTerritory = new Map<Id, Territory__c>(
        [
          SELECT Id, Primary_Franchise_Owner__c
          FROM Territory__c
          WHERE Primary_Franchise_Owner__c IN :idsOfPrimaryOwner
        ]
      );
      for (Customer_Relationship__c objRelationship : records) {
        String strFranchiseOwnerId = mapOfTerritory.get(
            objRelationship.Territory__c
          )
          ?.Primary_Franchise_Owner__c;
        if (
          oldMap == null &&
          strFranchiseOwnerId != null &&
          !mapOfPrimaryNotes.containsKey(
            objRelationship.Customer__c + strFranchiseOwnerId
          )
        ) {
          objRelationship.addError(LABEL.MLCRM_Minimum_Primary_Notes_Error);
        } else if (
          strFranchiseOwnerId != null &&
          mapOfPrimaryNotes.containsKey(
            objRelationship.Customer__c + strFranchiseOwnerId
          ) &&
          mapOfPrimaryNotes.get(
            objRelationship.Customer__c + strFranchiseOwnerId
          ) > 1
        ) {
          objRelationship.addError(LABEL.MLCRM_Maximum_Primary_Notes_Error);
        }
      }
    }
  }
}