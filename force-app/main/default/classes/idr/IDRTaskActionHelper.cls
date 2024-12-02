/**
 * @author Sneha Malik
 * @since  02/2023
 * @description IDRTaskActionHelper is helper class for IDRTaskActions to handle ExcessiveClassLength.
 * without sharing: used to perform system generated Tasks which is not accessible by the end user.
 * @group IDR(Internal Dispute Resolution)
 */
public without sharing class IDRTaskActionHelper {
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final IDRTaskActionsRepository TASK_REPOSITORY = (IDRTaskActionsRepository) Lib_InstanceProvider.forType(
    IDRTaskActionsRepository.class
  );
  /**
   * @description create task records for complaint assignment / New file attached / New Email Attached / New comment on closed case.
   * @param taskRecordList task record for insert
   */
  public static Void insertAssignmentTask(List<Task> taskRecordList) {
    //insert Assignment Tasks on New Correspondence received on Closed Complaint
    if (
      !Task.SObjectType.getDescribe().isCreateable() ||
      Security.stripInaccessible(AccessType.CREATABLE, taskRecordList)
        .getRemovedFields()
        .isEmpty() == false
    ) {
      CommonUtil.logAndThrowIAE(
        'IDRTaskActionHelper',
        'insertAssignmentTask',
        'Not enough permissions to create Task.'
      );
    }
    List<Task> taskToInsert = verifyAssignmentTask(taskRecordList);
    List<Database.SaveResult> results = DML.doInsert(
      taskToInsert,
      new DmlConfig().allowPartial().withoutSharing()
    );
    logError(taskToInsert, results);
  }
  /**
   * @description Build Log message to return and add in Log entry for file deletion
   * @param taskToInsert List of Tasks
   * @param results Database results
   */
  private static void logError(
    List<Task> taskToInsert,
    List<Database.SaveResult> results
  ) {
    for (Integer i = 0; i < taskToInsert.size(); i++) {
      Database.SaveResult sr = results[i];
      if (sr.isSuccess()) {
        continue;
      }
      String errorMessage =
        'Unable to create assignment tasks ' +
        +' associated case: ' +
        taskToInsert[i].WhatId +
        ' associated case owner/queue: ' +
        taskToInsert[i].OwnerId +
        ' ';
      for (Database.Error err : sr.getErrors()) {
        errorMessage += err;
        Logger.error(errorMessage);
        Logger.saveLog();
      }
    }
  }
  /**
   * @description verify task records for complaint assignment / New file attached / New Email Attached / New comment on closed case.
   * @param taskRecordList task record for insert
   * @return  Tasks that can be insterted
   */
  public static List<Task> verifyAssignmentTask(List<Task> taskRecordList) {
    Map<String, Task> recordsToInsert = new Map<String, Task>();

    Set<Id> caseIds = ListUtil.getIds(taskRecordList, Task.WhatId);

    //This logic works for only CMOS rec type (IDR Task) and wont impact other streams
    if (caseIds.isEmpty() || !Task.SObjectType.getDescribe().isQueryable()) {
      return new List<Task>();
    }
    List<Task> existingTasks = TASK_REPOSITORY.getexistingTasks(caseIds);

    Map<String, Task> existingTasksMap = (Map<String, Task>) ListUtil.mapBy(
      existingTasks,
      TASK.Subject
    );

    for (Task recTask : taskRecordList) {
      if (
        !recordsToInsert.containsKey(recTask.Subject.trim()) &&
        !existingTasksMap.containsKey(recTask.Subject.trim())
      ) {
        recordsToInsert.put(recTask.Subject, recTask);
      }
    }
    return recordsToInsert.values();
  }
  /**
   * @description getCasestoUpdate will get Cases to Update Additional Correspondence Reviewed field on Case.
   * when Task status is completed.
   * @param newTasks The Task record list.
   * @return Set of caseIds
   */
  public static Set<Id> getCasestoUpdate(List<Task> newTasks) {
    String strCasePrefix = Case.getSObjectType().getDescribe().getKeyPrefix();
    Set<Id> caseIds = new Set<Id>();
    List<Task> lsttasks = ListUtil.filter(newTasks)
      .equals(Task.Status, IDRConstants.TASK_STATUS_COMPLETED)
      .isNotNull(Task.Subject)
      .contains(Task.Subject, IDRConstants.TASK_CORRESPONDENCE_SUBJECT)
      .isNotNull(Task.WhatId)
      .toList();
    for (Task taskObj : lsttasks) {
      if (((String) taskObj.WhatId).left(3) != strCasePrefix) {
        continue;
      }
      caseIds.add(taskObj.WhatId);
    }
    return caseIds;
  }

  /**
   * @description updateCases will update Additional Correspondence Reviewed field on Case.
   * when Task status is completed.
   * @param newTasks The Task record list.
   */
  public static void updateCases(List<Task> newTasks) {
    Set<Id> caseIds = getCasestoUpdate(newTasks);
    if (
      !Case.SObjectType.getDescribe().isQueryable() ||
      !Schema.SObjectType.Case.fields.IDR_Additional_Correspondence_reviewed__c.isUpdateable()
    ) {
      return;
    }
    List<Case> casesToUpdate = TASK_REPOSITORY.getCasestobeUpdated(caseIds);

    ListUtil.setField(
      casesToUpdate,
      Case.IDR_Additional_Correspondence_reviewed__c,
      true
    );

    DML.doUpdate(casesToUpdate);
  }
}
