/**
 * @author Ashish Kumar
 * @since May 9 2025
 * @description Provides SOQL helpers for Interaction object
 */
public with sharing class InteractionActionsRepository {
  /**
   * @description This method is used to execute the query
   * @name executeQuery
   * @param strObjectName sobject name
   * @param setOfParentId set of parent lookup id
   * @return Map<Id, Sobject> map of sobject records
   * @author Ashish Kumar
   * @US CC-1058
   */
  public Map<Id, Sobject> executeQuery(
    String strObjectName,
    Set<Id> setOfParentId
  ) {
    if (setOfParentId.isEmpty()) {
      return new Map<Id, Sobject>();
    }
    String strQuery =
      'SELECT Id,Territory__c FROM ' +
      String.escapeSingleQuotes(strObjectName) +
      ' WHERE Id IN: setOfParentId WITH USER_MODE';
    return new Map<Id, Sobject>(Database.query(strQuery));
  }
}
