/**
 * @author Greg Shaw
 * @since 09/2023
 * @description Quality Assessment task related actions for CMOS
 * @runTests IDRQualityAssessmentTaskActionsTest
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class IDRQualityAssessmentTaskActions {
  private static final IDRQualityAssessmentRepository QA_REPOSITORY = (IDRQualityAssessmentRepository) Lib_InstanceProvider.forType(
    IDRQualityAssessmentRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description For all Assessments going from Completed to Pending set their Compliance Tasks to Expired.
   * @param lstAssessments new Trigger Values
   * @param mpOldAssessments old Trigger Values
   */
  public static void checkOnReversionFromComplete(
    List<Quality_Assessment__c> lstAssessments,
    Map<Id, Quality_Assessment__c> mpOldAssessments
  ) {
    Map<Id, Quality_Assessment__c> mpId2PendingAssessments = new Map<Id, Quality_Assessment__c>();
    Set<Id> stUserIds = new Set<Id>();

    for (Quality_Assessment__c oAssessment : lstAssessments) {
      Quality_Assessment__c oOldAssessment = mpOldAssessments.get(
        oAssessment.Id
      );
      if (!isValidRecordForReversion(oAssessment, oOldAssessment)) {
        continue;
      }
      mpId2PendingAssessments.put(oAssessment.Id, oAssessment);
      stUserIds.add(oAssessment.Case_Manager__c);
      if (oAssessment.RecordTypeId == IDRConstants.idrtCQQualityAssessment) {
        stUserIds.add(oAssessment.TeamManager__c);
      }
      if (
        oAssessment.RecordTypeId ==
        IDRConstants.idrtCallLetterReviewQualityAssessment &&
        oAssessment.OwnerId != oAssessment.TeamManager__c
      ) {
        stUserIds.add(oAssessment.TeamManager__c);
      }
    }
    updateCQAssessmentsTasks(mpId2PendingAssessments);

    List<Quality_Assessment__Share> lstQAShare = new List<Quality_Assessment__Share>();
    List<Quality_Assessment__Share> qaSharerecords = QA_REPOSITORY.getQAShareRecords(
      mpId2PendingAssessments,
      stUserIds
    );
    for (Quality_Assessment__Share oQAShare : qaSharerecords) {
      Quality_Assessment__c oQAssessment = mpId2PendingAssessments.get(
        oQAShare.ParentId
      );
      if (
        oQAShare.UserOrGroupId == oQAssessment.TeamManager__c ||
        oQAShare.UserOrGroupId == oQAssessment.Case_Manager__c
      ) {
        lstQAShare.add(oQAShare);
      }
    }
    if (
      lstQAShare.isEmpty() ||
      !Quality_Assessment__Share.SObjectType.getDescribe().isDeletable()
    ) {
      return;
    }
    DML_REPOSITORY.doDelete(
      lstQAShare,
      new DmlConfig().allowPartial().systemMode()
    );
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
    if (
      !Task.SObjectType.getDescribe().isCreateable() &&
      !Schema.SObjectType.Task.fields.ActivityDate.isCreateable() &&
      !Schema.SObjectType.Task.fields.OwnerId.isCreateable() &&
      !Schema.SObjectType.Task.fields.RecordTypeId.isCreateable() &&
      !Schema.SObjectType.Task.fields.Subject.isCreateable() &&
      !Schema.SObjectType.Task.fields.WhatId.isCreateable()
    ) {
      return;
    }
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

        if (
          oAssessment.Corrective_actions_for_TM_CM__c !=
          IDRConstants.CORRECTIVE_ACTIONS_NA &&
          oAssessment.Corrective_actions_for_TM_CM__c != null
        ) {
          correctiveActionsCQIds.add(oAssessment.Id);
        }
      }
    }
    if ((!stCompletedCQIds.isEmpty() || !correctiveActionsCQIds.isEmpty())) {
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
          String strSubject =
            IDRConstants.TASK_QA_COMPLIANCE_SUBJECT +
            String.valueOf(oAssessment.Case_Manager__r.Name) +
            ' : CMOS Case ' +
            String.valueOf(oAssessment.Related_Case__r.CaseNumber__c);
          lstComplianceTasks.add(
            getComplianceTask(oAssessment, '', strSubject)
          );
        }
        if (correctiveActionsCQIds.contains(oAssessment.Id)) {
          String strSubject =
            IDRConstants.TASK_TM_ATTESTATION_SUBJECT +
            String.valueOf(oAssessment.Case_Manager__r.Name);
          String strDescription = 'You must add a task comment detailing the action taken before marking this task as completed.';
          lstComplianceTasks.add(
            getComplianceTask(oAssessment, strDescription, strSubject)
          );
        }
      }
      if (!lstComplianceTasks.isEmpty()) {
        DMLUtil.insertRecords(
          lstComplianceTasks,
          DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
          DMLUtil.SYSTEM_MODE
        );
      }
    }
  }
  /**
   * @description method to write a common function to create a Task.
   * @param oAssessment Quality Assessment Object
   * @param strDescription Description of the task
   * @param strSubject Subject of the task
   * @return Task object
   */
  public static Task getComplianceTask(
    Quality_Assessment__c oAssessment,
    String strDescription,
    String strSubject
  ) {
    Task taskObj = new Task();
    taskObj.RecordTypeId = GetHelpConstants.TASK_COMPLIANCE_RT_ID;
    taskObj.OwnerId = oAssessment.TeamManager__c;
    taskObj.WhatId = oAssessment.Id;
    taskObj.Subject = strSubject;
    taskObj.Description = strDescription;
    taskObj.ActivityDate = Date.today().addDays(7);
    taskObj.Status = 'Open';
    taskObj.Priority = 'Normal';
    return taskObj;
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
        // Quality_Assessment__Share record for CaseManager__c is created after a calculated delay.
        // It is therefore handled by Quality_Assessment_CMOS.flow and not here.
      }
    }

    if (lstQAShare.isEmpty()) {
      return;
    }
    DML_REPOSITORY.doInsert(lstQAShare, new DmlConfig().withoutSharing());
  }
  /**
   * @description Get List Of Updated Tasks
   * @param pendingAssessmentKeySet Ids Of QA Records that are moved to 'Pending/Withdrawn' status from 'Complete'
   * @return lstUpdateTasks list of updated related tasks for these QA records
   */
  private static List<Task> getUpdatedTasks(Set<ID> pendingAssessmentKeySet) {
    List<Task> lstUpdateTasks = new List<Task>();
    for (Task oTask : [
      SELECT Id, Status, Subject
      FROM Task
      WHERE
        Status = :IDRConstants.OPEN_STATUS
        AND WhatId IN :pendingAssessmentKeySet
    ]) {
      if (!isValidSubject(oTask.Subject)) {
        continue;
      }
      oTask.Status = IDRConstants.TASK_STATUS_EXPIRED;
      lstUpdateTasks.add(oTask);
    }
    return lstUpdateTasks;
  }
  /**
   * @description Check if subject of the task is valid for the task to get expired
   * @param subject Subject of the Task
   * @return Boolean is the subject is valid
   */
  private static boolean isValidSubject(String subject) {
    if (
      subject.startsWith(IDRConstants.TASK_QA_COMPLIANCE_SUBJECT) ||
      subject.startsWith(IDRConstants.TASK_TM_ATTESTATION_SUBJECT)
    ) {
      return true;
    }
    return false;
  }
  /**
   * @description Check if record is valid for reversion process
   * @param oAssessment QA new record
   * @param oOldAssessment QA old record
   * @return Boolean is the subject is valid
   */
  private static boolean isValidRecordForReversion(
    Quality_Assessment__c oAssessment,
    Quality_Assessment__c oOldAssessment
  ) {
    Set<String> allowedStatus = new Set<String>{
      QualityAssessmentActions.STATUS_PENDING,
      QualityAssessmentActions.STATUS_WITHDRAWN
    };
    Set<String> allowedRecTypes = new Set<String>{
      IDRConstants.idrtCQQualityAssessment,
      IDRConstants.idrtCallLetterReviewQualityAssessment
    };
    if (
      !allowedRecTypes.contains(oAssessment.RecordTypeId) ||
      !allowedStatus.contains(oAssessment.Status__c)
    ) {
      return false;
    }
    if (
      oOldAssessment != null &&
      oOldAssessment.Status__c == QualityAssessmentActions.STATUS_COMPLETE
    ) {
      return true;
    }
    return false;
  }
  /**
   * @description updates the Tasks related to only CQ assessments
   * @param mpId2PendingAssessments Map of ID and CQ/Call_Letter Assessments
   */
  private static void updateCQAssessmentsTasks(
    Map<Id, Quality_Assessment__c> mpId2PendingAssessments
  ) {
    List<Task> lstUpdateTasks = new List<Task>();
    for (Quality_Assessment__c qaRecord : mpId2PendingAssessments.values()) {
      if (qaRecord.RecordTypeId != IDRConstants.idrtCQQualityAssessment) {
        continue;
      }
      lstUpdateTasks = getUpdatedTasks(mpId2PendingAssessments.keySet());
    }
    if (
      lstUpdateTasks.isEmpty() ||
      !Task.SObjectType.getDescribe().isUpdateable() ||
      !Schema.SObjectType.Task.fields.Status.isUpdateable()
    ) {
      return;
    }
    DML_REPOSITORY.doUpdate(
      lstUpdateTasks,
      new DmlConfig().allowPartial().systemMode()
    );
  }
}
