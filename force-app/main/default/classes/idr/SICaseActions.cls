/**
 * @author Olivier Saier
 * @since  12/2020
 * @description SICaseActions is class to handle all the Actions related to CMOS Systemic Issues.
 * Set as with sharing because updates on SI may follow updates on complaints, only by SI Team users who have write access to SI.
 */
public with sharing class SICaseActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final SICaseActionsRepository SICASE_REPOSITORY = (SICaseActionsRepository) Lib_InstanceProvider.forType(
    SICaseActionsRepository.class
  );

  /**
   * @description applyDefaults method is called before onBeforeInsert to set the default values for the records.
   * @param records Records to process
   */
  public static void applyDefaults(List<Case> records) {
    for (Case record : (List<Case>) records) {
      if (record.RecordTypeId != RTCase.systemicIssue) {
        continue;
      }
      CommonUtil.handleMasking(
        record,
        null,
        SObjectType.Case.FieldSets.SI_Masked_Fields.getFields()
      );
    }
  }

  /**
   * @description Entry point called by CaseTriggerHandler.onBeforeUpdate()
   * @param records Records to process
   * @param oldMap Map of the old values of the records to process
   */
  public static void beforeUpdate(List<Case> records, Map<Id, Case> oldMap) {
    for (Case record : (List<Case>) records) {
      if (record.RecordTypeId != RTCase.systemicIssue) {
        continue;
      }
      Case oldRecord = (Case) oldMap.get(record.id);
      CommonUtil.handleMasking(
        record,
        oldRecord,
        SObjectType.Case.FieldSets.SI_Masked_Fields.getFields()
      );
    }
  }

  /**
   * @description Entry point called by CaseTriggerHandler to process monitoring tasks
   * @param records Records to process
   * @param oldMap Map of the old values of the records to process
   */
  public static void processMonitoringTasks(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Task[] monitoringTasks = new List<Task>();
    if (!oldMap.isEmpty()) {
      removePendingMonitoringTasks(records, oldMap);
    }
    List<Case> filteredSICases = ListUtil.filter(records, oldMap)
      .equals(Case.RecordTypeId, RTCase.systemicIssue)
      .changed(Case.SI_Workflow_Step__c)
      .equals(Case.SI_Workflow_Step__c, IDRConstants.SI_WF_STEP_MONITORING)
      .toList();
    for (Case record : filteredSICases) {
      monitoringTasks.add(createMonitoringTask(record, 3));
      monitoringTasks.add(createMonitoringTask(record, 6));
    }
    DML_REPOSITORY.doInsert(monitoringTasks);
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
      RecordTypeId = IDRConstants.SI_TASK_RT_ID,
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
  @TestVisible
  private static void removePendingMonitoringTasks(
    List<Case> cases,
    Map<Id, Case> oldMap
  ) {
    if (
      !Task.sObjectType.getDescribe().isQueryable() ||
      !Task.sObjectType.getDescribe().isDeletable()
    ) {
      return;
    }
    Task[] tasksToDelete = new List<Task>();
    Case[] casesToProcessWhenReopened = new List<Case>();

    for (Case c : cases) {
      if (c.RecordTypeId != RTCase.systemicIssue) {
        continue;
      }
      if (
        ((Case) oldMap.get(c.id)).SI_Workflow_Step__c ==
        IDRConstants.SI_WF_STEP_MONITORING &&
        c.SI_Workflow_Step__c != IDRConstants.SI_WF_STEP_MONITORING
      ) {
        casesToProcessWhenReopened.add(c);
      }
    }
    if (casesToProcessWhenReopened.isEmpty()) {
      return;
    }
    Set<Id> caseIds = (new Map<Id, Case>(casesToProcessWhenReopened)).keySet();
    tasksToDelete.addAll(
      SICASE_REPOSITORY.queryMonitoringTasksToDelete(caseIds)
    );
    IDRTaskActions.siSystemDeletingAutoGenTask = true;
    //delete tasksToReplace;
    DML_REPOSITORY.doDelete(tasksToDelete);
  }

  /**
   * @description Show the total count of complaints linked under the SI record
   * @param complaints list of child complaints that have been linked to or unliked from a systemic issue
   */
  public static void rollupToParentSI(Case[] complaints) {
    List<Case> systemicIssuesToUpdate = new List<Case>();
    Set<id> systemicIssueIds = new Set<id>();
    //get the ids of the SIs to update
    for (Case complaint : complaints) {
      if (String.isBlank(complaint.IDR_Parent_Systemic_Issue__c)) {
        continue;
      }
      systemicIssueIds.add(complaint.IDR_Parent_Systemic_Issue__c);
    }
    //query the SIs and the related complaints and add the size of the complaints to the SI's SI_Complaint_Count__c
    List<Case> caselist = SICASE_REPOSITORY.queryComplaintsOnCases(
      systemicIssueIds
    );
    for (Case si : caselist) {
      //add the value in the map to a list so we can update it
      systemicIssuesToUpdate.add(
        new Case(id = si.Id, SI_Complaint_Count__c = si.Complaints__r.size())
      );
    }
    DML_REPOSITORY.doUpdate(systemicIssuesToUpdate);
  }
}