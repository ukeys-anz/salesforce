/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRCaseActions.
 * @runTests IDRCaseActionsHelperTest
 */
public with sharing class IDRCaseActionsRepository {
  public static final String TASK_STATUS_COMPLETED = 'Completed';
  public static final String TASK_TYPE_PEND_CASE = 'Pend Case';
  public static final Set<String> CLOSED_WITHDRAWN_STATUS = new Set<String>{
    IDRConstants.CLOSED_STATUS,
    IDRConstants.PROVISIONALLY_CLOSED_STATUS,
    IDRConstants.WITHDRAWN_STATUS
  };
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
        AND Status != :TASK_STATUS_COMPLETED
        AND Type = :TASK_TYPE_PEND_CASE
        AND RecordType.Id = :RTTask.idrTask
      WITH USER_MODE
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
      WITH USER_MODE
    ];
  }
  /**
   *  @description Query Users who have either Permission set IDR_Level_2 or IDR_Level_3, using SYSTEM_MODE as current user won't be able to access to scope of case owners.
   *  @param userId Set of User Ids who are case owners.
   *  @return `List<User>` of Users which have either IDR_Level_2 or IDR_Level_3 PSG.
   */
  public List<User> queryL2L3User(Set<Id> userId) {
    if (userId.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id
      FROM User
      WHERE
        Id IN (
          SELECT AssigneeId
          FROM PermissionSetAssignment
          WHERE
            AssigneeId IN :userId
            AND PermissionSet.Name IN :IDRConstants.PSG_L2_L3_USERS
        )
      WITH SYSTEM_MODE
    ];
  }

  /**
   *  @description Query Account's related Cases
   *  @param sAccountIds Set of AccountIds
   *  @return List<Cases> list of Cases associated with AccountIds
   */
  public List<Case> queryRelatedCases(Set<Id> sAccountIds) {
    if (sAccountIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT
        Id,
        CaseNumber,
        OwnerId,
        Priority,
        Account.Name,
        Account.ExtraCareTimePeriod__c
      FROM Case
      WHERE
        Status NOT IN :CLOSED_WITHDRAWN_STATUS
        AND AccountId IN :sAccountIds
        AND RecordType.Id = :RTCase.customerComplaint
    ];
  }
  /**
   *  @description Query Cases and related Account
   *  @param accountIds Set of AccountIds
   *  @return List<Account>
   */
  public List<Account> getAccountsWithExtraCareFlag(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, ExtraCareTimePeriod__c
      FROM Account
      WHERE Id IN :accountIds
      WITH USER_MODE
    ];
  }
}
