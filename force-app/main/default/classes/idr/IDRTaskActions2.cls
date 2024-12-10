/**
 * @author Greg Shaw
 * @since  07/2023
 * @description IDRTaskActions2 was split from IDRTaskActions because that class was getting too long
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDRCaseActionsTest, IDRTaskActionsTest, TaskTriggerHandlerTest
 * StdCyclomaticComplexity Suppressed : The complexity of this class is more than expected but still readable
 */

@SuppressWarnings('PMD.StdCyclomaticComplexity')
public with sharing class IDRTaskActions2 {
  public static final String TASK_TYPE_GENERAL = 'General Task/ Reminder';
  public static final String TASK_SUBJECT_URGENT = 'Urgent Case Allocation';
  public static final String IDR_TASK_SUBJECT = 'Please Review PSI';
  private static final String IDR_LEVEL_1 = 'IDR_Level_1';

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final IDRTaskActionsRepository TASK_REPOSITORY = (IDRTaskActionsRepository) Lib_InstanceProvider.forType(
    IDRTaskActionsRepository.class
  );

  /**
   * @description Check Tasks for the Subject 'Urgent Case Allocation'
   * @param lstTasks List of Tasks from Trigger
   * NcssMethodCount Suppressed : To have all the code lines together in one place.
   */
  @SuppressWarnings('PMD.NcssMethodCount')
  public static void checkForUrgentCaseAllocationTask(List<Task> lstTasks) {
    Set<Id> stCaseIds = new Set<Id>();
    String strCasePrefix = Case.getSObjectType().getDescribe().getKeyPrefix();
    String strGroupPrefix = Group.getSObjectType().getDescribe().getKeyPrefix();
    Map<Id, Set<String>> mpGroup2Recipients = new Map<Id, Set<String>>();
    List<Task> listUrgentTasks = ListUtil.filter(lstTasks)
      .equals(Task.Type, TASK_TYPE_GENERAL)
      .contains(Task.Subject, TASK_SUBJECT_URGENT)
      .isNotNull(Task.WhatId)
      .toList();
    for (Task oTask : listUrgentTasks) {
      if (((String) oTask.WhatId).left(3) != strCasePrefix) {
        continue;
      }
      stCaseIds.add(oTask.WhatId);
      if (
        ((String) oTask.OwnerId).left(3) == strGroupPrefix &&
        !mpGroup2Recipients.containsKey(oTask.OwnerId)
      ) {
        mpGroup2Recipients.put(oTask.OwnerId, new Set<String>());
      }
    }
    if (stCaseIds.isEmpty()) {
      return;
    }
    CustomNotificationType oNotificationType = CommonUtil.getCustomNotificationTypeByName(
      'CMOS'
    );
    if (oNotificationType == null) {
      Logger.error('Failed to retrieve CMOS Custom Notification Type: ', '');
      Logger.saveLog();
      return;
    }
    Set<String> stRecipients;
    List<Case> urgentCases = TASK_REPOSITORY.queryCasesForUrgentTasks(
      stCaseIds
    );
    Map<Id, Case> mpId2Case = new Map<Id, Case>(urgentCases);
    Map<Id, Set<Id>> mpUserId2Groups = new Map<Id, Set<Id>>();
    Set<Id> stGroups;
    List<GroupMember> memberList = TASK_REPOSITORY.queryGroupMember(
      mpGroup2Recipients
    );
    for (GroupMember oGroupMember : memberList) {
      stRecipients = mpGroup2Recipients.get(oGroupMember.GroupId);
      stRecipients.add(oGroupMember.UserOrGroupId);
      if (
        (stGroups = mpUserId2Groups.get(oGroupMember.UserOrGroupId)) == null
      ) {
        stGroups = new Set<Id>();
        mpUserId2Groups.put(oGroupMember.UserOrGroupId, stGroups);
      }
      stGroups.add(oGroupMember.GroupId);
    }
    // Find all inactive users in groups
    List<User> users = TASK_REPOSITORY.queryInactiveUsers(mpUserId2Groups);
    for (User oUser : users) {
      for (Id idGroup : mpUserId2Groups.get(oUser.Id)) {
        // Remove inactive users from all recipient lists
        mpGroup2Recipients.get(idGroup).remove(oUser.Id);
      }
    }
    List<Task> finalTasksToUpdate = ListUtil.filter(lstTasks)
      .equals(Task.Type, TASK_TYPE_GENERAL)
      .contains(Task.Subject, TASK_SUBJECT_URGENT)
      .toList();
    for (Task oTask : finalTasksToUpdate) {
      if (((String) oTask.OwnerId).left(3) == strGroupPrefix) {
        stRecipients = mpGroup2Recipients.get(oTask.OwnerId);
      } else {
        stRecipients = new Set<String>{ oTask.OwnerId };
      }
      if (stRecipients == null) {
        continue;
      }
      CommonUtil.sendInAppNotification(
        new InAppNotificationWrapper(
          oNotificationType.Id,
          oTask.Id,
          stRecipients,
          TASK_SUBJECT_URGENT,
          'Request for urgent allocation of Case: ' +
          mpId2Case.get(oTask.WhatId).CaseNumber
        )
      );
    }
  }

  /**
   * @description Ensure that QA Compliance Tasks can only be completed if the Assessment has a Team Manager response
   * @param lstTasks Updated Tasks
   * @param mpOldTasks Old version of Tasks
   */
  public static void validateQAComplianceTask(
    List<Task> lstTasks,
    Map<Id, Task> mpOldTasks
  ) {
    Map<Id, List<Task>> mpQualityAssessmentId2Tasks = new Map<Id, List<Task>>();
    List<Task> lstQATasks;
    String strQAPrefix = Quality_Assessment__c.getSObjectType()
      .getDescribe()
      .getKeyPrefix();
    List<Task> updatedTasks = ListUtil.filter(lstTasks, mpOldTasks)
      .equals(Task.RecordTypeId, GetHelpConstants.TASK_COMPLIANCE_RT_ID)
      .equals(Task.Status, IDRConstants.TASK_STATUS_COMPLETED)
      .isNotNull(Task.WhatId)
      .toList();
    for (Task oTask : updatedTasks) {
      lstQATasks = mpQualityAssessmentId2Tasks.get(oTask.WhatId);
      if (((String) oTask.WhatId).left(3) != strQAPrefix) {
        continue;
      }
      if (lstQATasks == null) {
        lstQATasks = new List<Task>();
        mpQualityAssessmentId2Tasks.put(oTask.WhatId, lstQATasks);
      }
      lstQATasks.add(oTask);
    }
    List<Quality_Assessment__c> lstQAassessments = TASK_REPOSITORY.queryQualityAssessments(
      mpQualityAssessmentId2Tasks.keySet()
    );
    for (Quality_Assessment__c oAssessment : lstQAassessments) {
      lstQATasks = mpQualityAssessmentId2Tasks.get(oAssessment.Id);
      if (lstQATasks.isEmpty()) {
        continue;
      }
      for (Task oTask : lstQATasks) {
        if (
          (String.isBlank(oAssessment.Team_Manager_Response__c) ||
          String.isBlank(oAssessment.Team_Manager_Comments__c)) &&
          oTask.Subject.contains(IDRConstants.TASK_QA_COMPLIANCE_SUBJECT)
        ) {
          oTask.addError(IDRConstants.TASK_QA_CLOSE_ERROR);
        }
      }
    }
  }
  /**
   * @description Update Date On Hold From Task to Case and Case Status to On Hold
   * @param lstTasks List of Tasks from Trigger
   * @param setToValue Boolean
   */
  public static void updateOnHoldDateonCase(
    List<Task> lstTasks,
    Boolean setToValue
  ) {
    Map<Id, Date> caseIdtoDateValue = getOnHoldDateFromTask(lstTasks);

    List<Case> lstcasestoUpdate = setCaseFields(caseIdtoDateValue, setToValue);

    DML_REPOSITORY.updateRecords(
      lstcasestoUpdate,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }

  /**
   * @description To update Map with Id and corresponding Date value of Task
   * @param newTasks List of new tasks
   * @return Map of Ids
   */
  @TestVisible
  private static Map<Id, Date> getOnHoldDateFromTask(List<Task> newTasks) {
    Map<Id, Date> caseIdtoDateValue = new Map<Id, Date>();

    for (Task oTask : newTasks) {
      if (!isValidPendTask(oTask)) {
        continue;
      }
      caseIdtoDateValue.put(
        OTask.WhatId,
        Date.valueOf(oTask.Date_Case_on_Hold_From__c)
      );
      if (oTask.Status == IDRConstants.TASK_STATUS_COMPLETED) {
        caseIdtoDateValue.put(OTask.WhatId, null);
      }
    }
    return caseIdtoDateValue;
  }
  /**
   * @description To check if the boolean is returning a Valid Pend Task
   * @param oTask New Task
   * @return Boolean
   */
  @TestVisible
  private static Boolean isValidPendTask(Task oTask) {
    if (
      oTask.RecordTypeId == IDRConstants.IDR_TASK_RT_ID &&
      oTask.Type == IDRConstants.TASK_TYPE_PEND_CASE &&
      String.isNotBlank(oTask.WhatId) &&
      String.valueOf(oTask.WhatId).startsWith('500')
    ) {
      return true;
    }
    return false;
  }
  /**
   * @description To Set case fields Date and Boolean value as required
   * @param caseIdtoDateValue List of new Tasks
   * @param setToValue Boolean value to set the case field
   * @return List of Cases
   */
  @TestVisible
  private static List<Case> setCaseFields(
    Map<Id, Date> caseIdtoDateValue,
    Boolean setToValue
  ) {
    List<Case> casestoUpdate = new List<Case>();

    for (Id caseId : caseIdtoDateValue.keyset()) {
      if (setToValue) {
        casestoUpdate.add(
          new Case(
            Id = caseId,
            IDR_Date_Case_on_Hold_From__c = caseIdtoDateValue.get(caseId),
            Status = IDRConstants.ON_HOLD_STATUS
          )
        );
      } else {
        casestoUpdate.add(
          new Case(Id = caseId, IDR_Date_Case_on_Hold_From__c = null)
        );
      }
    }
    return casestoUpdate;
  }
  /**
   * @description To Set case fields Date and Boolean value as required
   * @param newTasks List of new Tasks
   */
  public static void assignPendTasktoCaseOwner(List<Task> newTasks) {
    Map<Id, Date> caseDateMap = getOnHoldDateFromTask(newTasks);
    List<Case> caselist = TASK_REPOSITORY.queryCases(caseDateMap.keyset());
    Map<Id, Case> caseMap = new Map<Id, Case>(caseList);
    setTaskOwnerId(caseMap, newTasks);
  }
  /**
   * @description To Set case fields Date and Boolean value as required
   * @param caseMap Map of Id and Case
   * @param newTasks List of new Tasks
   */
  public static void setTaskOwnerId(
    Map<Id, Case> caseMap,
    List<Task> newTasks
  ) {
    for (Task oTask : newTasks) {
      if (!isValidPendTask(oTask)) {
        continue;
      }
      if (caseMap.get(oTask.WhatId) == null) {
        continue;
      }
      oTask.OwnerId = caseMap.get(oTask.WhatId).OwnerId;
    }
  }
  /**
   * @description method to get existing SI Tasks on a case record
   * @param caseIds Set of Complaint Case Id where IDR_Is_Common__c ='yes'
   * @param subject Subject of the Task
   * @return new Map<Id, Task>(existingTasksOnCase) Map of Tasks for Case records
   */
  public static Map<Id, Task> getExistingSITasksOnCase(
    Set<Id> caseIds,
    String subject
  ) {
    List<Task> existingTasksOnCase = TASK_REPOSITORY.getExistingSITasksOnCase(
      caseIds,
      subject
    );
  
    return (Map<Id, Task>) ListUtil.mapBy(existingTasksOnCase, Task.WhatId);
  }
  /**
   * @description method to get existing SI Tasks on a case record
   * @param oldMap Map of Old case records
   * @param records List of new case records
   * @param siCaseTasks Map of existing tasks for case records
   * @return siTasksToInsert List of SI Tasks to insert
   */
  public static List<Task> getSITasksToInsert(
    Map<Id, SObject> oldMap,
    List<Case> records,
    Map<Id, Task> siCaseTasks
  ) {
    List<Task> siTasksToInsert = new List<Task>();
    for (Case record : records) {
      Case oldRec = (Case) oldMap.get(record.Id);
      //validate case for PSI task creation
      if (validateCaseForPSITask(record, oldRec, siCaseTasks)) {
        siTasksToInsert.add(populateTaskFields(record));
      }
    }
    return siTasksToInsert;
  }
  /**
   * @description Validates a complaint record for creating PSI task
   * @param record from case trigger
   * @param oldRec from case trigger
   * @param siCaseTasks store existing SI task on a case
   * @return Boolean returns true or false based on validation
   */
  private static Boolean validateCaseForPSITask(
    Case record,
    Case oldRec,
    Map<Id, Task> siCaseTasks
  ) {
    if (!FeatureManagement.checkPermission(IDR_LEVEL_1)) {

      return false;
    }
    if (
      record.IsClosed &&
      record.IDR_Is_Common__c == 'Yes' &&
      (oldRec == null ||
      (oldRec.Status != record.Status &&
      (!(siCaseTasks.containsKey(record.Id)))) ||
      oldRec.IDR_Is_Common__c != record.IDR_Is_Common__c)
    ) {
      return true;
    }
    return false;
  }
  /**
   * @description populate task fields for creating possible systemic issue task
   * @param c Parent case of the tasks
   * @return An instance of a Task
   */
  private static Task populateTaskFields(Case c) {
    Date activityDate = Date.today().addDays(5);
    return new Task(
      RecordTypeId = RTTask.idrSystemTask,
      Type = IDRConstants.TASK_TYPE_SYSTEMIC_ISSUE,
      Priority = IDRConstants.TASK_PRIORITY_NORMAL,
      OwnerId = QueryQueue.get('Systemic_Issue_Team').Id,
      WhatId = c.Id,
      Subject = IDR_TASK_SUBJECT,
      ActivityDate = activityDate,
      IsReminderSet = true,
      ReminderDateTime = (Datetime) (activityDate - 2)
    );
  }
}