/**
 * @author Greg Shaw
 * @since 09/2023
 * @description Quality Assessment task related actions for CMOS
 * @runTests IDRQualityAssessmentTaskActionsTest
 */

public with sharing class IDRQualityAssessmentTaskActions {

  public static final String STATUS_PENDING = 'Pending';
  /**
   * @description For all Assessments going from Completed to Pending set their Compliance Tasks to Expired.
   * @param lstAssessments new Trigger Values
   * @param mpOldAssessments old Trigger Values
   */
  public static void checkOnReversionToPending(
  List<Quality_Assessment__c> lstAssessments,
  Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    if ( Task.SObjectType.getDescribe().isUpdateable() &&
        Schema.SObjectType.Task.fields.Status.isUpdateable()
    ) {
      Quality_Assessment__c oOldAssessment;
      Set<Id> stPendingIds = new Set<Id>();
      for (Quality_Assessment__c oAssessment : lstAssessments) {
        if (
          (oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment ||
          oAssessment.RecordTypeId ==
          IDRConstants.idrtCallLetterReviewQualityAssessment) &&
          oAssessment.Status__c == STATUS_PENDING &&
          mpOldAssessments != null &&
          (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) != null &&
          oOldAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE
        ) {
          stPendingIds.add(oAssessment.Id);
        }
      }
      System.debug('PendingIds: ' + stPendingIds);
      List<Task> lstUpdateTasks = new List<Task>();
      for (Task oTask : [SELECT Id, Status
                          FROM Task
                          WHERE Status = 'Open'
                          AND WhatId IN :stPendingIds]) {
        oTask.Status = 'Expired';
        lstUpdateTasks.add(oTask);
      }
      update lstUpdateTasks;
    }
  }
  /**
   * @description method to create Compliance Task if Quality Assessment record's status is changed to Completed
   * @param lstAssessments new Trigger values
   * @param mpOldAssessments old Trigger values
   */
  public static void createComplianceTasks(
    List<Quality_Assessment__c> lstAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Quality_Assessment__c oOldAssessment;
    Set<Id> stCompletedIds = new Set<Id>();
    for (Quality_Assessment__c oAssessment : lstAssessments) {
      if (
        (oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment ||
        oAssessment.RecordTypeId ==
        IDRConstants.idrtCallLetterReviewQualityAssessment) &&
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE &&
        (mpOldAssessments == null ||
        (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) == null ||
        oAssessment.Status__c != oOldAssessment.Status__c)
      ) {
        stCompletedIds.add(oAssessment.Id);
      }
    }
    if (
      stCompletedIds.size() > 0 &&
      Task.SObjectType.getDescribe().isCreateable() &&
      Schema.SObjectType.Task.fields.ActivityDate.isCreateable() &&
      Schema.SObjectType.Task.fields.OwnerId.isCreateable() &&
      Schema.SObjectType.Task.fields.RecordTypeId.isCreateable() &&
      Schema.SObjectType.Task.fields.Subject.isCreateable() &&
      Schema.SObjectType.Task.fields.WhatId.isCreateable()
    ) {
      List<Quality_Assessment__c> lstCompletedAssessments = [
        SELECT
          Id,
          TeamManager__c,
          TeamManager__r.Name, Case_Manager__c,
          Related_Case__r.CaseNumber__c
        FROM Quality_Assessment__c
        WHERE
          Id IN :stCompletedIds
          AND TeamManager__c != NULL
          AND Case_Manager__c != NULL
      ];
      List<Task> lstComplianceTasks = new List<Task>();
      for (Quality_Assessment__c oAssessment : lstCompletedAssessments) {
        lstComplianceTasks.add(
          new Task(
            RecordTypeId = GetHelpConstants.TASK_COMPLIANCE_RT_ID,
            OwnerId = oAssessment.TeamManager__c,
            WhatId = oAssessment.Id,
            Subject = IDRConstants.TASK_QA_COMPLIANCE_SUBJECT + oAssessment.TeamManager__r.Name + ' : case ' + oAssessment.Related_Case__r.CaseNumber__c,
            ActivityDate = Date.today().addDays(7),
            Status = 'Open',
            Priority = 'Normal'
          )
        );
      }
      if (lstComplianceTasks.size() > 0) {
        insert lstComplianceTasks;
      }
    }
  }
}