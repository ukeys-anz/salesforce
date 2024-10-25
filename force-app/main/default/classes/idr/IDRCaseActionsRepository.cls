/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRCaseActions.
 * @runTests IDRCaseActionsHelperTest
 */
public with sharing class IDRCaseActionsRepository {
  /**
   * @description Query PEND Tasks whose Status is not completed
   * @param caseIds case Ids in current context
   * @return list of Pend tasks
   */
  public List<Task> queryPendTasks(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT Id, Status
      FROM Task
      WHERE
        WhatId IN :caseIds
        AND Status != :IDRConstants.TASK_STATUS_COMPLETED
        AND Type = :IDRConstants.TASK_TYPE_PEND_CASE
        AND RecordType.Id = :IDRConstants.IDR_TASK_RT_ID
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Query Feature Management to get if the current user is having required permissions
   * @param permissionName String custom permission name
   * @return Boolean true/false based on users assigned permissions
   */
  public Boolean checkUserPermission(String permissionName) {
    return FeatureManagement.checkPermission(permissionName);
  }
  /**
   * @description Query Tasks whose Case Owner is changed and Status is not closed
   * @param caseIds case Ids in current context
   * @return list of Pend tasks
   */
  public List<Task> queryCaseOwnerChangedTasks(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT Id, WhatId, OwnerId, Last_Assigned_Owner__c
      FROM Task
      WHERE WhatId IN :caseIds AND IsClosed != TRUE
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Query Feature Management to get if the current user is having required permissions
   * @param permissionName String custom permission name
   * @return Boolean true/false based on users assigned permissions
   */
  public Boolean checkUserPermission(String permissionName) {
    return FeatureManagement.checkPermission(permissionName);
  }
  /**
   * @description Query Tasks whose Case Owner is changed and Status is not closed
   * @param caseIds case Ids in current context
   * @return list of Pend tasks
   */
  public List<Task> queryCaseOwnerChangedTasks(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT Id, WhatId, OwnerId, Last_Assigned_Owner__c
      FROM Task
      WHERE WhatId IN :caseIds AND IsClosed != TRUE
    ];
  }
}
