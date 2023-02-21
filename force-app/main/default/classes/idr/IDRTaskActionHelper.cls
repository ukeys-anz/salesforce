/**
 * @author Sneha Malik
 * @since  02/2023
 * @description IDRTaskActionHelper is helper class for IDRTaskActions to handle ExcessiveClassLength.
 * without sharing: used to perform system generated Tasks which is not accessible by the end user.
 * @group IDR(Internal Dispute Resolution)
 */
public without sharing class IDRTaskActionHelper {
  /**
   * @description create task records for complaint assignment / New file attached / New Email Attached / New comment on closed case.
   * @param records task record for insert 
   */
  public static Void insertAssignmentTask(List<Task> records) {
    if (!records.isEmpty()) {
      //insert Assignment Tasks on New Correspondence received on Closed Complaint
      if (
        Task.SObjectType.getDescribe().isCreateable() &&
        Schema.SObjectType.Task.fields.ActivityDate.isCreateable() &&
        Schema.SObjectType.Task.fields.IsReminderSet.isCreateable() &&
        Schema.SObjectType.Task.fields.OwnerId.isCreateable() &&
        Schema.SObjectType.Task.fields.RecordTypeId.isCreateable() &&
        Schema.SObjectType.Task.fields.Subject.isCreateable() &&
        Schema.SObjectType.Task.fields.WhatId.isCreateable()
      ) {
        List<Task> taskToInsert = verifyAssignmentTask(records);
        insert taskToInsert;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRTaskActionHelper',
          'insertAssignmentTask',
          'Not enough permissions to create Task.'
        );
      }
    }
  }
  /**
   * @description verify task records for complaint assignment / New file attached / New Email Attached / New comment on closed case.
   * @param records task record for insert 
   * @return  Tasks that can be insterted
   */
  public static List<Task> verifyAssignmentTask(List<Task> records) {
    Map<String,Task> recordsToInsert = new Map<String,Task>();
    Map<String,Task> existingTasksMap = new Map<String,Task>();
    Task[] existingTasks = new List<Task>();
    Set<Id> caseIds = new Set<Id>();
        
    for(Task recTask: records){
      caseIds.add(recTask.WhatId);
    }
    if (!caseIds.isEmpty() && Task.SObjectType.getDescribe().isQueryable()) {
      existingTasks = [
        SELECT Id, Status, Subject, WhatId
        FROM Task
        WHERE
          WhatId IN :caseIds
          AND RecordTypeId = :IDRConstants.IDR_TASK_RT_ID
          AND Status != :IDRConstants.TASK_STATUS_COMPLETED 
        ];
      for(Task taskRec: existingTasks){
        existingTasksMap.put(taskRec.Subject, taskRec);
      }        
      for(Task recTask: records){
        if (!recordsToInsert.containsKey(recTask.Subject) && !existingTasksMap.containsKey(recTask.Subject)) {
          recordsToInsert.put(recTask.Subject, recTask);
        }
      }
    }
    return recordsToInsert.values();
  }
}
