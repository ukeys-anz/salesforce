/**
 * @author Anuja Vats
 * @since 03/2024
 * @description Quality Assessment Dipute tasks related actions for CMOS
 * @runTests IDRQualityAssessmentDisputeTaskTest
 */
public with sharing class IDRQualityAssessmentsDisputeTaskActions {
  /**
   * @description method to create Dispute Tasks if Team Manager / CQ Manager / CQ Lead response changes on Quality Assessment
   * @param lstAssessments new Trigger values
   * @param mpOldAssessments old Trigger values
   */
  public static void createDisputeTasks(
    List<Quality_Assessment__c> lstAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Map<Id, String> changedFieldOnRecord = generateChangeFieldOnRecordMap(
      lstAssessments,
      mpOldAssessments
    );
    if (changedFieldOnRecord.isEmpty()) {
      return;
    }
    List<Quality_Assessment__c> listUpdatedCQAssessments = getUpdatedQARelatedFields(
      changedFieldOnRecord.keyset()
    );
    List<Task> lstDisputeTasks = generateDisputeTask(
      changedFieldOnRecord,
      listUpdatedCQAssessments
    );
    DMLUtil.insertRecords(lstDisputeTasks, false, true);
  }
  /**
   * @description method to get Quality Assessment Details for all the QA records updated
   * @param updatedCQAssessmentsIds Quality Assessment Id
   * @return List of Quality Assessment object
   */
  private static List<Quality_Assessment__c> getUpdatedQARelatedFields(
    Set<Id> updatedCQAssessmentsIds
  ) {
    return [
      SELECT
        Id,
        OwnerId,
        Name,
        TeamManager__c,
        TeamManager__r.Name,
        Case_Manager__c,
        Case_Manager__r.Name,
        C_Q_Specialist__c,
        C_Q_Specialist__r.ManagerId,
        Related_Case__r.CaseNumber__c
      FROM Quality_Assessment__c
      WHERE Id IN :updatedCQAssessmentsIds
    ];
  }
  /**
   * @description method to write a common function to create a Task.
   * @param oAssessment Quality Assessment Object
   * @param taskFields Fields from TaskWrapper
   * @return Task object
   */
  private static Task getDisputeTask(
    Quality_Assessment__c oAssessment,
    TaskWrapper taskFields
  ) {
    Task taskObj = new Task();
    taskObj.RecordTypeId = GetHelpConstants.TASK_COMPLIANCE_RT_ID;
    taskObj.OwnerId = taskFields.ownerId;
    taskObj.WhatId = oAssessment.Id;
    taskObj.Subject = taskFields.strSubject;
    taskObj.Description = taskFields.strDescription;
    taskObj.ActivityDate = Date.today().addDays(taskFields.daysDueIn);
    taskObj.Status = 'Open';
    taskObj.Priority = 'Normal';
    return taskObj;
  }
  /**
   * @description method to create list of Dispute Tasks if Team Manager / CQ Manager / CQ Lead response changes on Quality Assessment
   * @param changedFieldOnRecord Map of Changed Fields
   * @param listUpdatedCQAssessments List of Quality Assessments
   * @return List of Tasks
   */
  @TestVisible
  private static List<Task> generateDisputeTask(
    Map<ID, String> changedFieldOnRecord,
    List<Quality_Assessment__c> listUpdatedCQAssessments
  ) {
    List<Task> lstDisputeTasks = new List<Task>();

    TaskWrapper taskFields;
    for (Quality_Assessment__c oAssessment : listUpdatedCQAssessments) {
      //don't think this stement is required
      if (!(changedFieldOnRecord.keyset().contains(oAssessment.Id))) {
        return null;
      }
      taskFields = new TaskWrapper();
      switch on changedFieldOnRecord.get(oAssessment.Id) {
        when 'Team_Manager_Response__c' {
          taskFields.strSubject =
            IDRConstants.TM_REJECTS_CQ_REVIEW_TASK_SUBJECT +
            oAssessment.Name +
            ' for ' +
            String.valueOf(oAssessment.Case_Manager__r.Name);
          taskFields.strDescription = IDRConstants.TM_REJECTS_CQ_REVIEW_TASK_DESC;
          taskFields.ownerId = oAssessment.C_Q_Specialist__r.ManagerId;
          taskFields.daysDueIn = 5;
        }
        when 'C_Q_Manager_Response__c' {
          taskFields.strSubject =
            IDRConstants.CQ_MANAGER_REV_COMPLETED_TASK_SUBJECT +
            oAssessment.Name +
            ' for ' +
            String.valueOf(oAssessment.Case_Manager__r.Name);
          taskFields.strDescription = IDRConstants.CQ_MANAGER_REV_COMPLETED_TASK_DESC;
          taskFields.ownerId = oAssessment.TeamManager__c;
          taskFields.daysDueIn = 5;
        }
        when 'TM_Response_to_C_Q_Manager_Review__c' {
          taskFields.strSubject =
            IDRConstants.TM_REJECTS_CQ_MANAGER_REV_TASK_SUBJECT +
            oAssessment.Name +
            ' for ' +
            String.valueOf(oAssessment.Case_Manager__r.Name);
          taskFields.strDescription = IDRConstants.TM_REJECTS_CQ_MANAGER_REV_TASK_DESC;
          taskFields.ownerId = getCQLeadQueueId();
          taskFields.daysDueIn = 5;
        }
        when 'C_Q_Lead_Response__c' {
          taskFields.strSubject =
            IDRConstants.CQ_LEAD_RESPONSE_TASK_SUBJECT +
            oAssessment.Name +
            ' for ' +
            String.valueOf(oAssessment.Case_Manager__r.Name);
          taskFields.strDescription = IDRConstants.CQ_LEAD_RESPONSE_TASK_DESC;
          taskFields.ownerId = oAssessment.TeamManager__c;
          taskFields.daysDueIn = 5;
        }
      }
      lstDisputeTasks.add(getDisputeTask(oAssessment, taskFields));
    }
    return lstDisputeTasks;
  }
  /**
   * @description method to generate a map with changes fields in current list of updated Assessments
   * @param lstAssessments List Of Assessments
   * @param mpOldAssessments Map of Old Assessments
   * @return Map<ID, String> Map of Changed Fields
   */
  @TestVisible
  private static Map<ID, String> generateChangeFieldOnRecordMap(
    List<Quality_Assessment__c> lstAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Map<Id, String> changedFieldOnRecord = new Map<Id, String>();

    for (Quality_Assessment__c oAssessment : lstAssessments) {
      if (
        !(oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment &&
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE &&
        (mpOldAssessments.get(oAssessment.Id) != null ||
        mpOldAssessments != null))
      ) {
        return new Map<ID, String>();
      }
      if (
        oAssessment.Team_Manager_Response__c !=
        mpOldAssessments.get(oAssessment.Id).Team_Manager_Response__c &&
        oAssessment.Team_Manager_Response__c ==
        IDRConstants.TEAM_MANAGER_REJECTION_RESPONSE
      ) {
        changedFieldOnRecord.put(oAssessment.Id, 'Team_Manager_Response__c');
      } else if (
        oAssessment.C_Q_Manager_Response__c !=
        mpOldAssessments.get(oAssessment.Id).C_Q_Manager_Response__c &&
        oAssessment.C_Q_Manager_Response__c != null
      ) {
        changedFieldOnRecord.put(oAssessment.Id, 'C_Q_Manager_Response__c');
      } else if (
        oAssessment.TM_Response_to_C_Q_Manager_Review__c !=
        mpOldAssessments.get(oAssessment.Id)
          .TM_Response_to_C_Q_Manager_Review__c &&
        oAssessment.TM_Response_to_C_Q_Manager_Review__c ==
        IDRConstants.TM_REJECTS_CQ_MANAGER_RESPONSE
      ) {
        changedFieldOnRecord.put(
          oAssessment.Id,
          'TM_Response_to_C_Q_Manager_Review__c'
        );
      } else if (
        oAssessment.C_Q_Lead_Response__c !=
        mpOldAssessments.get(oAssessment.Id).C_Q_Lead_Response__c &&
        oAssessment.C_Q_Lead_Response__c != null
      ) {
        changedFieldOnRecord.put(oAssessment.Id, 'C_Q_Lead_Response__c');
      }
    }
    return changedFieldOnRecord;
  }
  /**
   * @description Get Queue details for CQ Leads
   * @return QueueId
   */
  private static Id getCQLeadQueueId() {
    List<Group> cqLeadQueue = [
      SELECT Id
      FROM Group
      WHERE DeveloperName = 'C_Q_Leads' AND Type = 'Queue'
      LIMIT 1
    ];
    if (cqLeadQueue.isEmpty()) {
      return null;
    }
    return cqLeadQueue.get(0).Id;
  }
  /**
   * @description Wrapper Class to wrap task fields
   * @param strSubject Subject of the Task
   * @param strDescription Description of the Task
   * @param ownerId Owner of the Task
   * @param daysDueIn Days in which Task is Due
   */
  class TaskWrapper {
    /**
     * @description Subject of the Task
     */
    String strSubject { get; set; }
    /**
     * @description Description of the Task
     */
    String strDescription { get; set; }
    /**
     * @description Owner of the Task
     */
    String ownerId { get; set; }
    /**
     * @description Days in which Task is Due
     */
    Integer daysDueIn { get; set; }
  }
}
