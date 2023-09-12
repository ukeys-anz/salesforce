/**
 * @author Greg Shaw
 * @since 09/2023
 * @description Quality Assessment task related actions for CMOS
 */

public with sharing class IDRQualityAssessmentTaskActions {
  public static void createComplianceTasks(
    List<Quality_Assessment__c> lstAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Quality_Assessment__c oOldAssessment;
    Set<Id> stCompletedIds = new Set<Id>();
    for (Quality_Assessment__c oAssessment : lstAssessments) {
      if (
        (oAssessment.RecordTypeId == IDRConstants.idrtCQ_QUALITY_ASSESSMENT ||
        oAssessment.RecordTypeId ==
        IDRConstants.idrtCALL_LETTER_REVIEW_QUALITY_ASSESSMENT) &&
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE &&
        oAssessment.Sub_Status__c ==
        QualityAssessmentActions.SUB_STATUS_EVALUATION_COMPLETED &&
        (mpOldAssessments == null ||
        (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) == null ||
        oAssessment.Status__c != oOldAssessment.Status__c ||
        oAssessment.Sub_Status__c != oOldAssessment.Sub_Status__c)
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
            //            Subject = IDRConstants.TASK_QA_COMPLIANCE_SUBJECT + oAssessment.Team_Manager__r.Name + ' : case ' + oAssessment.Related_Case__r.CaseNumber__c,
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
