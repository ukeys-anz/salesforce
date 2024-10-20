/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRCaseActions.
 * @runTests IDRTaskActionsTest
 */
public with sharing class IDRTaskActionsRepository {
  /**
   * @description Query cases to get the ownerId
   * @param caseIds case Ids in current context
   * @return list of cases
   */
  public List<Case> queryCases(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, OwnerId
      FROM Case
      WHERE Id IN :caseIds
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Quality Assessments for validating QA Compliance Task
   * @param assessmentIds Quality Assessmnet Ids in current context
   * @return list of Quality Assessments
   */
  public List<Quality_Assessment__c> queryQualityAssessments(
    Set<Id> assessmentIds
  ) {
    if (assessmentIds.isEmpty()) {
      return new List<Quality_Assessment__c>();
    }
    return [
      SELECT
        Id,
        Team_Manager_Response__c,
        Team_Manager_Comments__c,
        Case_Manager__c,
        Case_Manager__r.Name,
        Related_Case__r.CaseNumber__c
      FROM Quality_Assessment__c
      WHERE Id IN :assessmentIds
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Method to query Cases related to urgent Tasks
   * @param stCaseIds case Ids in current context
   * @return list of Cases
   */
  public List<Case> queryCasesForUrgentTasks(Set<Id> stCaseIds) {
    if (stCaseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, CaseNumber
      FROM Case
      WHERE Id IN :stCaseIds
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Method to query Group Member for Queue for Urgent Tasks
   * @param mpGroup2Recipients Map of Group Ids and Set of Recipients
   * @return list of GroupMember
   */
  public List<GroupMember> queryGroupMember(
    Map<Id, Set<String>> mpGroup2Recipients
  ) {
    if (mpGroup2Recipients.isEmpty()) {
      return new List<GroupMember>();
    }
    return [
      SELECT GroupId, UserOrGroupId
      FROM GroupMember
      WHERE GroupId IN :mpGroup2Recipients.keySet()
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Method to query Inactive Users in Groups for Urgent Tasks
   * @param mpUserId2Groups Map of User Ids and Set of Groups
   * @return list of Users
   */
  public List<User> queryInactiveUsers(Map<Id, Set<Id>> mpUserId2Groups) {
    if (mpUserId2Groups.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id
      FROM User
      WHERE IsActive = FALSE AND Id IN :mpUserId2Groups.keySet()
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Method to get existing SI tasks on cases
   * @param caseIds Set of Case Ids
   * @param subject Subject of the Task
   * @return list of Tasks
   */
  public List<Task> getExistingSITasksOnCase(Set<Id> caseIds, String subject) {
    if (caseIds.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT Id, Status, Subject, WhatId
      FROM Task
      WHERE
        WhatId IN :caseIds
        AND RecordTypeId = :RTTask.idrSystemTask
        AND Type = :IDRConstants.TASK_TYPE_SYSTEMIC_ISSUE
        AND Subject = :subject
      WITH SECURITY_ENFORCED
    ];
  }
}
