/**
 * @author MLCRM Developer
 * @since 08/2024
 * @description This class provide SOQL for User related queries.
 */
public with sharing class UserActionsRepository {
  /**
   * @since  08/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name getUserMapFromUserIds
   * @param idsofUserIds ids of sObject records
   * @return Map<Id, User> map of sObject records
   * @description  method to get map of users for given set of ids
   */
  public Map<Id, User> getUserMapFromUserIds(Set<ID> idsofUserIds) {
    if (!Schema.sObjectType.User.isQueryable()) {
      return new Map<Id, User>();
    }
    if (idsofUserIds.isEmpty()) {
      return new Map<Id, User>();
    }
    return new Map<Id, User>(
      [SELECT Id, Username, profile.Name FROM User WHERE Id IN :idsofUserIds]
    );
  }
}
