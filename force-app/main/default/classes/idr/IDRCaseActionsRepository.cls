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
    return [
      SELECT Id, Status
      FROM Task
      WHERE
        WhatId IN :caseIds
        AND Status != :IDRConstants.TASK_STATUS_COMPLETED
        AND Type = :IDRConstants.TASK_TYPE_PEND_CASE
        AND RecordType.Id = :IDRConstants.IDR_TASK_RT_ID
    ];
  }
}
