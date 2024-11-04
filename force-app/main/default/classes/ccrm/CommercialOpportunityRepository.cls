/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description This class contains public repository for all queries used in CommercialOpportunityctions
 */
public with sharing class CommercialOpportunityRepository {
  /**
   * @description getUsers to get user records
   * @param userIds set of user ids
   * @return List<User> user list
   */
  public List<User> getUsers(List<Id> userIds) {
    if (userIds.isEmpty() || !PermissionUtils.canQuery('User')) {
      return new List<User>();
    }
    return [SELECT Id, Commercial_Segment__c FROM User WHERE Id IN :userIds];
  }

  /**
   * @description getOpenTasksOnClosedOpportunity to get open tasks
   * @param oppIds set of oppportunity ids
   * @return List<Map<String, Object>> tasks list
   */
  public List<Map<String, Object>> getOpenTasksOnClosedOpportunity(
    Set<Id> oppIds
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    if (oppIds.isEmpty()) {
      return result;
    }
    for (AggregateResult ar : [
      SELECT WhatId
      FROM Task
      WHERE
        WhatId IN :oppIds
        AND Status != :CCRMConstants.STATUS_COMPLETED
        AND Status != :CCRMConstants.STATUS_NOT_REQUIRED
      WITH USER_MODE
      GROUP BY WhatId
    ]) {
      result.add(ar.getPopulatedFieldsAsMap());
    }
    return result;
  }
}
