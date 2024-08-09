/**
 * @author Kopal Goswami, Shivam Swaraj
 * @since 07/2024
 * @description Provides SOQL and DML helpers for CoachNudgeTaskAction,CoachNudgeTaskAutoExpireScheduler
 */

public with sharing class CoachNudgeRepository {
  /**
     * @description To query all the tasks associated with rla records Ids
     * @param rlaRecordIds set of RLA Ids
    
     * @return List<Task> list of RLA 
     */
  public List<Task> queryTaskWithRLA(Set<Id> rlaRecordIds) {
    if (rlaRecordIds.isEmpty() || SObjectType.Task.isQueryable() == false) {
      return new List<Task>();
    }
    // Query Task associated to Residential loan application records
    return [
      SELECT Id, Status, Sub_Status__c
      FROM Task
      WHERE
        WhatId IN :rlaRecordIds
        AND Status != :GetHelpTaskActions.TASK_STATUS_EXPIRED
    ];
  }
  /**
   * @description To query all the tasks records which needs to be updated expired
   * @return List<Task> list of Tasks in system to expire
   */
  public List<Task> queryTasksToExpire() {
    if (SObjectType.Task.isQueryable() == false) {
      return new List<Task>();
    }
    return [
      SELECT Id, Status, Sub_Status__c, OwnerId
      FROM Task
      WHERE
        ActivityDate < TODAY
        AND ActivityDate = LAST_N_DAYS:2
        AND Status IN (
          :GetHelpTaskActions.TASK_STATUS_NOT_STARTED,
          :GetHelpTaskActions.TASK_STATUS_NEW
        )
        AND RecordTypeId IN (
          :GetHelpConstants.COACH_NUDGE_RT_ID,
          :GetHelpConstants.CALLBACK_REQUEST_RT_ID
        )
    ];
  }

  /**
   * @description To query all the RLA Ids that have a Cancelled status
   * @param taskRelatedRlaIds set of RLA Ids
   * @return Set<Id> Set of RLA Ids without cancelled status
   */
  public Set<Id> queryRLAIdsWithCancelledStatus(Set<Id> taskRelatedRlaIds) {
    if (
      taskRelatedRlaIds.isEmpty() ||
      SObjectType.ResidentialLoanApplication.isQueryable() == false
    ) {
      return new Set<Id>();
    }

    Set<Id> rlaIdsWithCancelledStatus = new Map<Id, ResidentialLoanApplication>(
        [
          SELECT Id
          FROM ResidentialLoanApplication
          WHERE
            Id IN :taskRelatedRlaIds
            AND Status = :GetHelpConstants.RLA_STATUS_CANCELLED
        ]
      )
      .keySet();

    return rlaIdsWithCancelledStatus;
  }
}
