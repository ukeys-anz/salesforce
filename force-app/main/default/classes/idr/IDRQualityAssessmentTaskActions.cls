/**
 * @author Greg Shaw
 * @since 09/2023
 * @description Quality Assessment task related actions for CMOS
 * @runTests IDRQualityAssessmentTaskActionsTest
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class IDRQualityAssessmentTaskActions {
  /**
   * @description For all Assessments going from Completed to Pending set their Compliance Tasks to Expired.
   * @param lstAssessments new Trigger Values
   * @param mpOldAssessments old Trigger Values
   */
  public static void checkOnReversionFromComplete(
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
      Map<Id, Quality_Assessment__c> mpId2CallLetterPendingAssessments = new Map<Id, Quality_Assessment__c>();
      Set<Id> stUserIds = new Set<Id>();
      for (Quality_Assessment__c oAssessment : lstAssessments) {
        if (
          oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment &&
          (oAssessment.Status__c == QualityAssessmentActions.STATUS_PENDING ||
          oAssessment.Status__c == QualityAssessmentActions.STATUS_WITHDRAWN) &&
          mpOldAssessments != null &&
          (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) != null &&
          oOldAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE
        ) {
          mpId2PendingAssessments.put(oAssessment.Id, oAssessment);
          stUserIds.add(oAssessment.TeamManager__c);
          stUserIds.add(oAssessment.Case_Manager__c);
        }
        if (
          oAssessment.RecordTypeId ==
          IDRConstants.idrtCallLetterReviewQualityAssessment &&
          (oAssessment.Status__c == QualityAssessmentActions.STATUS_PENDING ||
          oAssessment.Status__c == QualityAssessmentActions.STATUS_WITHDRAWN) &&
          mpOldAssessments != null &&
          (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) != null &&
          oOldAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE
        ) {
          mpId2CallLetterPendingAssessments.put(oAssessment.Id, oAssessment);
          if (oAssessment.OwnerId != oAssessment.TeamManager__c) {
            stUserIds.add(oAssessment.TeamManager__c);
          }
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
          (ParentId IN :mpId2PendingAssessments.keySet()
          OR ParentId IN :mpId2CallLetterPendingAssessments.keySet())
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
        if (
          (oQAssessment = mpId2CallLetterPendingAssessments.get(
            oQAShare.ParentId
          )) != null &&
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
    Set<Id> stCompletedCQIds = new Set<Id>();
    Set<Id> correctiveActionsCQIds = new Set<Id>();
    for (Quality_Assessment__c oAssessment : lstAssessments) {
      if (
        oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment &&
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE &&
        (mpOldAssessments == null ||
        (oOldAssessment = mpOldAssessments.get(oAssessment.Id)) == null ||
        (oAssessment.Status__c != oOldAssessment.Status__c &&
        oAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE) ||
        (oAssessment.Corrective_actions_for_TM_CM__c !=
        oOldAssessment.Corrective_actions_for_TM_CM__c &&
        oAssessment.Corrective_actions_for_TM_CM__c != null))
      ) {
          stCompletedCQIds.add(oAssessment.Id);
        if (oAssessment.Corrective_actions_for_TM_CM__c != IDRConstants.CORRECTIVE_ACTIONS_NA) {
          correctiveActionsCQIds.add(oAssessment.Id);
        }
      }
    }
    if (
      (stCompletedCQIds.size() > 0 ||
      correctiveActionsCQIds.size() > 0) &&
      Task.SObjectType.getDescribe().isCreateable() &&
      Schema.SObjectType.Task.fields.ActivityDate.isCreateable() &&
      Schema.SObjectType.Task.fields.OwnerId.isCreateable() &&
      Schema.SObjectType.Task.fields.RecordTypeId.isCreateable() &&
      Schema.SObjectType.Task.fields.Subject.isCreateable() &&
      Schema.SObjectType.Task.fields.WhatId.isCreateable()
    ) {
      List<Quality_Assessment__c> lstCompletedCQAssessments = [
        SELECT
          Id,
          OwnerId,
          TeamManager__c,
          TeamManager__r.Name,
          Case_Manager__c,
          Case_Manager__r.Name,
          Related_Case__r.CaseNumber__c
        FROM Quality_Assessment__c
        WHERE
          (Id IN :stCompletedCQIds
          AND TeamManager__c != NULL
          AND Case_Manager__c != NULL)
          OR (Id IN :correctiveActionsCQIds
          AND TeamManager__c != NULL)
      ];
      List<Task> lstComplianceTasks = new List<Task>();
      for (Quality_Assessment__c oAssessment : lstCompletedCQAssessments) {
        if (stCompletedCQIds.contains(oAssessment.Id)) {
          lstComplianceTasks.add(
            new Task(
              RecordTypeId = GetHelpConstants.TASK_COMPLIANCE_RT_ID,
              OwnerId = oAssessment.TeamManager__c,
              WhatId = oAssessment.Id,
              Subject = IDRConstants.TASK_QA_COMPLIANCE_SUBJECT +
                oAssessment.Case_Manager__r.Name +
                ' : case ' +
                oAssessment.Related_Case__r.CaseNumber__c,
              ActivityDate = Date.today().addDays(7),
              Status = 'Open',
              Priority = 'Normal'
            )
          );
        }
        if (correctiveActionsCQIds.contains(oAssessment.Id)) {
          lstComplianceTasks.add(
            new Task(
              RecordTypeId = GetHelpConstants.TASK_COMPLIANCE_RT_ID,
              OwnerId = oAssessment.TeamManager__c,
              WhatId = oAssessment.Id,
              Subject = IDRConstants.TASK_TM_ATTESTATION_SUBJECT +
                oAssessment.Case_Manager__r.Name,
                Description = 'You must add a task comment detailing the action taken before marking this task as completed.',
              ActivityDate = Date.today().addDays(7),
              Status = 'Open',
              Priority = 'Normal'
            )
          );
        }
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
    }
  }
  /**
   * @description method to apply apex sharing  if Quality Assessment record's status is changed to Completed
   * @param lstAssessments new Trigger values
   * @param mpOldAssessments old Trigger values
   */
  public static void createQAShareRecord(
    List<Quality_Assessment__c> lstAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Quality_Assessment__c oOldAssessment;

    List<Quality_Assessment__Share> lstQAShare = new List<Quality_Assessment__Share>();
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
        if (oAssessment.OwnerId != oAssessment.TeamManager__c) {
          lstQAShare.add(
            new Quality_Assessment__Share(
              AccessLevel = (oAssessment.RecordTypeId ==
                IDRConstants.idrtCQQualityAssessment
                ? 'Edit'
                : 'Read'),
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
    }

    if (lstQAShare.size() > 0) {
      (new WithoutSharing()).insertQAShare(lstQAShare);
    }
  }
  private without sharing class WithoutSharing {
    /**
     * @description Insert Quality_Assessment__Share records
     * @param lstQAShare list of Quality_Assessment__Share records to insert
     */

    public void insertQAShare(List<Quality_Assessment__Share> lstQAShare) {
      try {
        insert lstQAShare;
      } catch (Exception e) {
        System.debug('Exception: ' + e.getMessage());
        Logger.error(
          'Error creating Quality Assessment Sharing records: ' + e.getMessage()
        );
        Logger.saveLog();
      }
    }
  }
}
