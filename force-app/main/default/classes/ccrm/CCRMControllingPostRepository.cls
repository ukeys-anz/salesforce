/**
 * @author Naman Garg
 * @since 06/2024
 * @description This class provide SOQL and DML helper for class related to CCRMControllingPostActions.
 */

public with sharing class CCRMControllingPostRepository {
  /**
   * @description Retrieves a list of user records
   * @param lanIdsSet A set of Lan Ids
   * @return List<User> List of active user Records
   */
  public List<User> getActiveLanIdUser(Set<String> lanIdsSet) {
    if (lanIdsSet.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Lan_Id__c, IsActive
      FROM User
      WHERE Lan_Id__c IN :lanIdsSet AND IsActive = TRUE
      WITH USER_MODE
    ];
  }
}
