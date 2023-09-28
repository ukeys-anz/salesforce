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
    if (
      Task.SObjectType.getDescribe().isUpdateable() &&
      Schema.SObjectType.Task.fields.Status.isUpdateable() &&
      Quality_Assessment__Share.SObjectType.getDescribe().isDeletable()
    ) {
      Quality_Assessment__c oOldAssessment;
      Map<Id, Quality_Assessment__c> mpId2PendingAssessments = new Map<Id, Quality_Assessment__c>();
      Set<Id> stUserIds = new Set<Id>();
      for (Quality_Assessment__c oAssessment : lstAssessments) {
        if (
          oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment &&
          oAssessment.Status__c == STATUS_PENDING &&
          mpOldAssessments != null &&
          (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) != null &&
          oOldAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE
        ) {
          mpId2PendingAssessments.put(oAssessment.Id, oAssessment);
          stUserIds.add(oAssessment.TeamManager__c);
          stUserIds.add(oAssessment.Case_Manager__c);
        }
      }
      System.debug('PendingIds: ' + mpId2PendingAssessments);
      List<Task> lstUpdateTasks = new List<Task>();
      for (Task oTask : [
        SELECT Id, Status
        FROM Task
        WHERE Status = 'Open' AND WhatId IN :mpId2PendingAssessments.keySet()
      ]) {
        oTask.Status = IDRConstants.TASK_STATUS_EXPIRED;
        lstUpdateTasks.add(oTask);
      }
      update lstUpdateTasks;
      List<Quality_Assessment__Share> lstQAShare = new List<Quality_Assessment__Share>();
      Quality_Assessment__c oQAssessment;
      for (Quality_Assessment__Share oQAShare : [
        SELECT Id, UserOrGroupId, ParentId
        FROM Quality_Assessment__Share
        WHERE
          ParentId IN :mpId2PendingAssessments.keySet()
          AND UserOrGroupId IN :stUserIds
      ]) {
        if (
          (oQAssessment = mpId2PendingAssessments.get(oQAShare.ParentId)) !=
          null &&
          (oQAShare.UserOrGroupId == oQAssessment.TeamManager__c ||
          oQAShare.UserOrGroupId == oQAssessment.Case_Manager__c)
        ) {
          lstQAShare.add(oQAShare);
        }
      }
      if (lstQAShare.size() > 0) {
        try {
          delete lstQAShare;
        } catch (Exception e) {
          Logger.error(
            'Error deleting Quality Assessment Sharing records: ' +
            e.getMessage()
          );
          Logger.saveLog();
        }
      }
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
        oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment &&
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE &&
        (mpOldAssessments == null ||
        (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) == null ||
        oAssessment.Status__c != oOldAssessment.Status__c)
      ) {
        stCompletedIds.add(oAssessment.Id);
      }
    }
    System.debug('CompletedIds: ' + stCompletedIds);
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
          OwnerId,
          TeamManager__c,
          TeamManager__r.Name,
          Case_Manager__c,
          Related_Case__r.CaseNumber__c
        FROM Quality_Assessment__c
        WHERE
          Id IN :stCompletedIds
          AND TeamManager__c != NULL
          AND Case_Manager__c != NULL
      ];
      List<Task> lstComplianceTasks = new List<Task>();
      List<Quality_Assessment__Share> lstQAShare = new List<Quality_Assessment__Share>();
      for (Quality_Assessment__c oAssessment : lstCompletedAssessments) {
        lstComplianceTasks.add(
          new Task(
            RecordTypeId = GetHelpConstants.TASK_COMPLIANCE_RT_ID,
            OwnerId = oAssessment.TeamManager__c,
            WhatId = oAssessment.Id,
            Subject = IDRConstants.TASK_QA_COMPLIANCE_SUBJECT +
              oAssessment.TeamManager__r.Name +
              ' : case ' +
              oAssessment.Related_Case__r.CaseNumber__c,
            ActivityDate = Date.today().addDays(7),
            Status = 'Open',
            Priority = 'Normal'
          )
        );
        System.debug('Assessment: ' + oAssessment);
        if (oAssessment.OwnerId != oAssessment.TeamManager__c) {
          lstQAShare.add(
            new Quality_Assessment__Share(
              AccessLevel = 'Read',
              ParentId = oAssessment.Id,
              UserOrGroupId = oAssessment.TeamManager__c
            )
          );
        }
        if (
          oAssessment.OwnerId != oAssessment.Case_Manager__c &&
          oAssessment.Case_Manager__c != oAssessment.TeamManager__c
        ) {
          lstQAShare.add(
            new Quality_Assessment__Share(
              AccessLevel = 'Read',
              ParentId = oAssessment.Id,
              UserOrGroupId = oAssessment.Case_Manager__c
            )
          );
        }
        System.debug('Share: ' + lstQAShare);
      }
      if (lstComplianceTasks.size() > 0) {
        try {
          insert lstComplianceTasks;
        } catch (Exception e) {
          Logger.error(
            'Error creating Quality Assessment Tasks: ' + e.getMessage()
          );
          Logger.saveLog();
        }
      }

      if (lstQAShare.size() > 0) {
        try {
          insert lstQAShare;
        } catch (Exception e) {
          System.debug('Exception: ' + e.getMessage());
          Logger.error(
            'Error creating Quality Assessment Sharing records: ' +
            e.getMessage()
          );
          Logger.saveLog();
        }
      }
    }
  }
}
