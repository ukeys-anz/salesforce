/**
 * @author Olivier Saier
 * @since  12/2020
 * @description SICaseActions is class to handle all the Actions related to CMOS Systemic Issues
 */
public with sharing class SICaseActions {
  public static final Id SI_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Systemic_Issue')
    .getRecordTypeId();

  public static final Id SI_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Systemic_Issue_Task')
    .getRecordTypeId();

  /**
   * @description Entry point called by CaseTriggerHandler.onBeforeUpdate()
   * @param records Records to process
   * @param oldMap Map of the old values of the records to process
   */
  public static void beforeUpdate(List<Case> records, Map<Id, Case> oldMap) {
    for (Case record : (List<Case>) records) {
      Case oldRecord = (Case) oldMap.get(record.id);
      //Align status and workflow: Records in Monitoring workflow step should be closed
      //Note that SI_Workflow_Step__c being a dependent picklist of Status, not all combinations need to be handled by trigger
      if (
        record.RecordTypeId == SI_RT_ID &&
        (record.Status != oldRecord.Status ||
        record.SI_Workflow_Step__c != oldRecord.SI_Workflow_Step__c)
      ) {
        record = alignStatusToWorkflow(record, oldRecord);
      }
    }
  }

  /**
   * @description Update status depending on how workflow changes
   * @param record Case to process
   * @param oldRecord Previous values of the records to process
   * @return The updated case record
   */
  private static Case alignStatusToWorkflow(Case record, Case oldRecord) {
    if (
      record.SI_Workflow_Step__c == '4' &&
      oldRecord.SI_Workflow_Step__c != '4'
    ) {
      record.Status = 'Closed';
    } else if (
      record.SI_Workflow_Step__c != '4' &&
      oldRecord.SI_Workflow_Step__c == '4'
    ) {
      record.Status = 'Open';
    }
    return record;
  }

  /**
   * @description Entry point called by CaseTriggerHandler.onAfterInsert()
   * @param records Records to process
   */
  public static void afterInsert(List<Case> records) {
    Task[] monitoringTasks = new List<Task>();
    for (Case record : records) {
      if (
        record.RecordTypeId == SI_RT_ID &&
        record.SI_Workflow_Step__c == '4'
      ) {
        monitoringTasks.add(createMonitoringTask(record, 3));
        monitoringTasks.add(createMonitoringTask(record, 6));
      }
    }
    if (
      monitoringTasks.size() > 0 &&
      Task.sObjectType.getDescribe().isCreateable()
    ) {
      insert monitoringTasks;
    }
  }

  /**
   * @description Entry point called by CaseTriggerHandler.onAfterUpdate()
   * @param records Records to process
   * @param oldMap Map of the old values of the records to process
   */
  public static void afterUpdate(List<Case> records, Map<Id, Case> oldMap) {
    removePendingMonitoringTasks(records, oldMap);
    //Create monitoring tasks, only when SI_Workflow_Step__c has just been set to Monitoring
    Case[] casesToProcessWhenMonitoring = new List<Case>();
    for (Case record : (List<Case>) records) {
      if (
        record.RecordTypeId == SI_RT_ID &&
        ((Case) oldMap.get(record.id)).SI_Workflow_Step__c != '4' &&
        record.SI_Workflow_Step__c == '4'
      ) {
        casesToProcessWhenMonitoring.add(record);
      }
    }
    if (casesToProcessWhenMonitoring.size() > 0) {
      Task[] allTasksToInsert = new List<Task>();
      for (Case record : casesToProcessWhenMonitoring) {
        allTasksToInsert.add(createMonitoringTask(record, 3));
        allTasksToInsert.add(createMonitoringTask(record, 6));
      }
      if (
        Task.sObjectType.getDescribe().isCreateable() &&
        allTasksToInsert.size() > 0
      ) {
        insert allTasksToInsert;
      }
    }
  }

  /**
   * @description Create a task to remind case owner to monitor the SI
   * @param c Parent case of the tasks
   * @param months Months from now to set due date
   * @return An instance of a Task
   */
  private static Task createMonitoringTask(Case c, Integer months) {
    Date activityDate = Date.today().addMonths(months);
    return new Task(
      RecordTypeId = SI_TASK_RT_ID,
      OwnerId = c.OwnerId,
      WhatId = c.Id,
      Subject = 'Monitor Issue ' +
        c.CaseNumber.replaceFirst('^0+', '') +
        ' (' +
        months +
        ' mo)',
      Type = 'Monitoring',
      ActivityDate = activityDate,
      IsReminderSet = true,
      ReminderDateTime = (DateTime) (activityDate - 1)
    );
  }

  /**
   * @description Remove pending monitoring tasks when cases are no longer in Monitoring
   * @param cases Cases to process, which the tasks relates to
   * @param oldMap Map of the old values of the records to process
   */
  private static void removePendingMonitoringTasks(
    List<Case> cases,
    Map<Id, Case> oldMap
  ) {
    Task[] tasksToReplace = new List<Task>();
    Case[] casesToProcessWhenReopened = new List<Case>();

    for (Case c : (List<Case>) cases) {
      if (
        c.RecordTypeId == SI_RT_ID &&
        ((Case) oldMap.get(c.id)).SI_Workflow_Step__c == '4' &&
        c.SI_Workflow_Step__c != '4'
      ) {
        casesToProcessWhenReopened.add(c);
      }
    }
    if (
      Task.sObjectType.getDescribe().isQueryable() &&
      casesToProcessWhenReopened.size() > 0
    ) {
      Set<Id> caseIds = (new Map<Id, Case>(casesToProcessWhenReopened))
        .keySet();
      tasksToReplace.addAll(
        [
          SELECT Id
          FROM Task
          WHERE Type = 'Monitoring' AND IsClosed = FALSE AND WhatId IN :caseIds
        ]
      );
      if (
        Task.sObjectType.getDescribe().isDeletable() &&
        tasksToReplace.size() > 0
      ) {
        delete tasksToReplace;
      }
    }
  }
}
