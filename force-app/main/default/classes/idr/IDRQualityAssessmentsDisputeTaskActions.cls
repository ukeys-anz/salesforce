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
    DMLUtil.insertRecords(
      lstDisputeTasks,
      DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
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
    taskObj.ActivityDate = getTaskDueDate(taskFields.daysDueIn);
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
    Map<Id, String> changedFieldOnRecord,
    List<Quality_Assessment__c> listUpdatedCQAssessments
  ) {
    List<Task> lstDisputeTasks = new List<Task>();
    String cqLeadQueueId = getCQLeadQueueId();
    for (Quality_Assessment__c oAssessment : listUpdatedCQAssessments) {
      if (!(changedFieldOnRecord.containsKey(oAssessment.Id))) {
        continue;
      }
      TaskWrapper taskFields = new TaskWrapper();
      switch on changedFieldOnRecord.get(oAssessment.Id) {
        when 'Team_Manager_Response__c' {
          taskfields = populateTaskWrapper(
            oAssessment,
            IDRConstants.TM_REJECTS_CQ_REVIEW_TASK_SUBJECT,
            oAssessment.C_Q_Specialist__r.ManagerId,
            IDRConstants.TM_REJECTS_CQ_REVIEW_TASK_DESC
          );
        }
        when 'C_Q_Manager_Response__c' {
          taskfields = populateTaskWrapper(
            oAssessment,
            IDRConstants.CQ_MANAGER_REV_COMPLETED_TASK_SUBJECT,
            oAssessment.TeamManager__c,
            IDRConstants.CQ_MANAGER_REV_COMPLETED_TASK_DESC
          );
        }
        when 'TM_Response_to_C_Q_Manager_Review__c' {
          taskfields = populateTaskWrapper(
            oAssessment,
            IDRConstants.TM_REJECTS_CQ_MANAGER_REV_TASK_SUBJECT,
            cqLeadQueueId,
            IDRConstants.TM_REJECTS_CQ_MANAGER_REV_TASK_DESC
          );
        }
        when 'C_Q_Lead_Response__c' {
          taskfields = populateTaskWrapper(
            oAssessment,
            IDRConstants.CQ_LEAD_RESPONSE_TASK_SUBJECT,
            oAssessment.TeamManager__c,
            IDRConstants.CQ_LEAD_RESPONSE_TASK_DESC
          );
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
   * @return Map<Id, String> changedFieldsOnRecord Map of Changed Fields
   */
  @TestVisible
  private static Map<ID, String> generateChangeFieldOnRecordMap(
    List<Quality_Assessment__c> lstAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Map<Id, String> changedFieldsOnRecord = new Map<Id, String>();
    Map<Id, Quality_Assessment__c> mpOldAssessmentsRec = mpOldAssessments;
    for (Quality_Assessment__c oAssessment : lstAssessments) {
      if (
        (oAssessment.RecordTypeId != IDRConstants.idrtCQQualityAssessment) ||
        (mpOldAssessments.get(oAssessment.Id) == null) ||
        (oAssessment.Status__c != QualityAssessmentActions.STATUS_COMPLETE)
      ) {
        continue;
      }
      changedFieldsOnRecord = getChangedFieldsWithSpecificValue(
        oAssessment,
        'Team_Manager_Response__c',
        IDRConstants.TEAM_MANAGER_REJECTION_RESPONSE,
        mpOldAssessmentsRec
      );
      if (!changedFieldsOnRecord.isEmpty()) {
        continue;
      }
      changedFieldsOnRecord = getChangedFieldsOnRecord(
        oAssessment,
        'C_Q_Manager_Response__c',
        changedFieldsOnRecord,
        mpOldAssessmentsRec
      );
      if (!changedFieldsOnRecord.isEmpty()) {
        continue;
      }
      changedFieldsOnRecord = getChangedFieldsWithSpecificValue(
        oAssessment,
        'TM_Response_to_C_Q_Manager_Review__c',
        IDRConstants.TM_REJECTS_CQ_MANAGER_RESPONSE,
        mpOldAssessmentsRec
      );
      if (!changedFieldsOnRecord.isEmpty()) {
        continue;
      }
      changedFieldsOnRecord = getChangedFieldsOnRecord(
        oAssessment,
        'C_Q_Lead_Response__c',
        changedFieldsOnRecord,
        mpOldAssessmentsRec
      );
    }
    return changedFieldsOnRecord;
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
   * @param oAssessment quality assessment record
   * @param subject Subject of the Task
   * @param ownerId Owner of the Task
   * @param description description of the task
   * @return TaskWrapper Object
   */
  private static TaskWrapper populateTaskWrapper(
    Quality_Assessment__c oAssessment,
    String subject,
    String ownerId,
    String description
  ) {
    TaskWrapper taskFields = new TaskWrapper();
    taskFields.strSubject =
      subject +
      oAssessment.Name +
      ' for ' +
      String.valueOf(oAssessment.Case_Manager__r.Name);
    taskFields.strDescription = description;
    taskFields.ownerId = ownerId;
    taskFields.daysDueIn = 5;
    return taskFields;
  }
  /**
   * @description Method to check if field on record changed for a particular value, if yes put it on map
   * @param oAssessment Updated Quality Assessment record
   * @param fieldAPIName field which has updated
   * @param fieldValue value of the updated field
   * @param mpOldAssessments map of old assessment record
   * @return Map<Id, String> mpOldAssessments Map of record Id, and field API Name
   */
  private static Map<Id, String> getChangedFieldsWithSpecificValue(
    Quality_Assessment__c oAssessment,
    String fieldAPIName,
    String fieldValue,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Map<Id, String> changedFieldsOnRecord = new Map<Id, String>();
    if (
      oAssessment.get(fieldAPIName) !=
      mpOldAssessments.get(oAssessment.Id).get(fieldAPIName) &&
      oAssessment.get(fieldAPIName) == fieldValue
    ) {
      changedFieldsOnRecord.put(oAssessment.Id, fieldAPIName);
    }
    return changedFieldsOnRecord;
  }
  /**
   * @description Method to check if field on record changed for a particular value, if yes put it on map
   * @param oAssessment Updated Quality Assessment record
   * @param fieldAPIName field which has updated
   * @param changedFieldsOnRecord map of record Id, and field API Name
   * @param mpOldAssessments map of old records
   * @return Map of record Id, and field API Name
   */
  private static Map<Id, String> getChangedFieldsOnRecord(
    Quality_Assessment__c oAssessment,
    String fieldAPIName,
    Map<Id, String> changedFieldsOnRecord,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Map<Id, String> updatedFieldsOnRecord = new Map<Id, String>();
    if (!changedFieldsOnRecord.isEmpty()) {
      return updatedFieldsOnRecord;
    }
    if (
      oAssessment.get(fieldAPIName) !=
      mpOldAssessments.get(oAssessment.Id).get(fieldAPIName) &&
      oAssessment.get(fieldAPIName) != null
    ) {
      updatedFieldsOnRecord.put(oAssessment.Id, fieldAPIName);
    }
    return updatedFieldsOnRecord;
  }
  /**
   * @description Method to return TaskdDueDate after adding certain business days
   * @param businessDaysToAdd number of business days to add
   * @return TaskdDueDate
   */
  private static Date getTaskDueDate(Integer businessDaysToAdd) {
    DateTime expectedDueDate = DateTimeUtils.addBusinessDays(
      CommonUtil.getBusinessHours().Id,
      DateTime.Now(),
      businessDaysToAdd
    );
    return Date.valueOf(expectedDueDate);
  }
  /**
   * @description Wrapper Class to wrap task fields
   * @param strSubject Subject of the Task
   * @param strDescription Description of the Task
   * @param ownerId Owner of the Task
   * @param daysDueIn Days in which Task is Due
   */
  public class TaskWrapper {
    /**
     * @description Subject of the Task
     */
    public String strSubject { get; set; }
    /**
     * @description Description of the Task
     */
    public String strDescription { get; set; }
    /**
     * @description Owner of the Task
     */
    public String ownerId { get; set; }
    /**
     * @description Days in which Task is Due
     */
    public Integer daysDueIn { get; set; }
  }
}
