/**
 * @since 09/2024
 * @description This class provides SOQL and DML helpers for classes related SICaseActions.
 * @runTests SICaseActionsTest
 */
public with sharing class SICaseActionsRepository {
  /**
   * @description Query Complaints on SI Cases
   * @param systemicIssueIds Systemic Issue Ids in current context
   * @return list of cases
   */
  public List<Case> queryComplaintsOnCases(Set<Id> systemicIssueIds) {
    if (systemicIssueIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT id, SI_Complaint_Count__c, (SELECT id FROM Complaints__r)
      FROM Case
      WHERE Id IN :systemicIssueIds
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description Query SI Cases whose Status is closed and Workflowstep is Assessing
   * @param closedCases List of Cases
   * @return list of cases
   */
  public List<Case> queryClosedSICases(List<id> closedCases) {
    if (closedCases.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT SI_Workflow_Step__c
      FROM Case
      WHERE
        Id IN :closedCases
        AND Status = :IDRConstants.CLOSED_STATUS
        AND SI_Workflow_step__c = :IDRConstants.SI_WF_STEP_ASSESSING
    ];
  }

  /**
   * @description Query Tasks to delete when Status is updated to Monitoring
   * @param caseIds case Ids in current context
   * @return list of Tasks
   */
  public List<Task> queryMonitoringTasksToDelete(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT Id
      FROM Task
      WHERE
        Type = :IDRConstants.SI_WF_STEP_MONITORING
        AND IsClosed = FALSE
        AND WhatId IN :caseIds
    ];
  }
}