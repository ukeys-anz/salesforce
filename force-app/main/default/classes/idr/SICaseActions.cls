/**
 * @author Olivier Saier
 * @since  12/2020
 * @description SICaseActions is class to handle all the Actions related to CMOS Systemic Issues.
 * Set as with sharing because updates on SI may follow updates on complaints, only by SI Team users who have write access to SI.
 */
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.CyclomaticComplexity')
public with sharing class SICaseActions {
  /**
   * @description applyDefaults method is called before onBeforeInsert to set the default values for the records.
   * @param records Records to process
   */
  public static void applyDefaults(List<Case> records) {
    for (Case record : (List<Case>) records) {
      if (record.RecordTypeId == IDRConstants.SI_RT_ID) {
        CommonUtil.handleMasking(
          record,
          null,
          SObjectType.Case.FieldSets.SI_Masked_Fields.getFields()
        );
      }
    }
  }

  /**
   * @description Entry point called by CaseTriggerHandler.onBeforeUpdate()
   * @param records Records to process
   * @param oldMap Map of the old values of the records to process
   */
  public static void beforeUpdate(List<Case> records, Map<Id, Case> oldMap) {
    for (Case record : (List<Case>) records) {
      Case oldRecord = (Case) oldMap.get(record.id);
      if (record.RecordTypeId == IDRConstants.SI_RT_ID) {
        //Align status and workflow: Records in Monitoring workflow step should be closed
        //Note that SI_Workflow_Step__c being a dependent picklist of Status, not all combinations need to be handled by trigger
        if (
          record.Status != oldRecord.Status ||
          record.SI_Workflow_Step__c != oldRecord.SI_Workflow_Step__c
        ) {
          record = alignStatusToWorkflow(record, oldRecord);
        }
        CommonUtil.handleMasking(
          record,
          oldRecord,
          SObjectType.Case.FieldSets.SI_Masked_Fields.getFields()
        );
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
      record.SI_Workflow_Step__c == 'Monitoring' &&
      oldRecord.SI_Workflow_Step__c != 'Monitoring'
    ) {
      record.Status = 'Closed';
    } else if (
      record.SI_Workflow_Step__c != 'Monitoring' &&
      oldRecord.SI_Workflow_Step__c == 'Monitoring'
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
        record.RecordTypeId == IDRConstants.SI_RT_ID &&
        record.SI_Workflow_Step__c == 'Monitoring'
      ) {
        monitoringTasks.add(createMonitoringTask(record, 3));
        monitoringTasks.add(createMonitoringTask(record, 6));
      }
    }
    if (monitoringTasks.size() > 0) {
      if (
        Task.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Task.fields.ActivityDate.isCreateable() &&
        Schema.sObjectType.Task.fields.IsReminderSet.isCreateable() &&
        Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
        Schema.sObjectType.Task.fields.RecordTypeId.isCreateable() &&
        Schema.sObjectType.Task.fields.ReminderDateTime.isCreateable() &&
        Schema.sObjectType.Task.fields.Subject.isCreateable() &&
        Schema.sObjectType.Task.fields.Type.isCreateable() &&
        Schema.sObjectType.Task.fields.WhatId.isCreateable()
      ) {
        insert monitoringTasks;
      } else {
        CommonUtil.logAndThrowIAE(
          'SICaseActions',
          'afterInsert',
          'Not enough permissions to create Task.'
        );
      }
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
        record.RecordTypeId == IDRConstants.SI_RT_ID &&
        ((Case) oldMap.get(record.id)).SI_Workflow_Step__c != 'Monitoring' &&
        record.SI_Workflow_Step__c == 'Monitoring'
      ) {
        casesToProcessWhenMonitoring.add(record);
      }
    }
    if (casesToProcessWhenMonitoring.size() > 0) {
      Task[] monitoringTasks = new List<Task>();
      for (Case record : casesToProcessWhenMonitoring) {
        monitoringTasks.add(createMonitoringTask(record, 3));
        monitoringTasks.add(createMonitoringTask(record, 6));
      }
      if (monitoringTasks.size() > 0) {
        if (
          Task.sObjectType.getDescribe().isCreateable() &&
          Schema.sObjectType.Task.fields.ActivityDate.isCreateable() &&
          Schema.sObjectType.Task.fields.IsReminderSet.isCreateable() &&
          Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
          Schema.sObjectType.Task.fields.RecordTypeId.isCreateable() &&
          Schema.sObjectType.Task.fields.ReminderDateTime.isCreateable() &&
          Schema.sObjectType.Task.fields.Subject.isCreateable() &&
          Schema.sObjectType.Task.fields.Type.isCreateable() &&
          Schema.sObjectType.Task.fields.WhatId.isCreateable()
        ) {
          insert monitoringTasks;
        } else {
          CommonUtil.logAndThrowIAE(
            'SICaseActions',
            'afterUpdate',
            'Not enough permissions to create Task.'
          );
        }
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
  private static void removePendingMonitoringTasks(
    List<Case> cases,
    Map<Id, Case> oldMap
  ) {
    Task[] tasksToReplace = new List<Task>();
    Case[] casesToProcessWhenReopened = new List<Case>();

    for (Case c : (List<Case>) cases) {
      if (
        c.RecordTypeId == IDRConstants.SI_RT_ID &&
        ((Case) oldMap.get(c.id)).SI_Workflow_Step__c == 'Monitoring' &&
        c.SI_Workflow_Step__c != 'Monitoring'
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

  /**
   * @description Show the total count of complaints linked under the SI record
   * @param complaints list of child complaints that have been linked to or unliked from a systemic issue
   */
  public static void rollupToParentSI(Case[] complaints) {
    List<Case> systemicIssuesToUpdate = new List<Case>();
    Set<id> systemicIssueIds = new Set<id>();

    //get the ids of the SIs to update
    for (Case complaint : complaints) {
      systemicIssueIds.add(complaint.IDR_Parent_Systemic_Issue__c);
    }
    //query the SIs and the related complaints and add the size of the complaints to the SI's SI_Complaint_Count__c
    for (Case si : [
      SELECT SI_Complaint_Count__c, (SELECT id FROM Complaints__r)
      FROM Case
      WHERE Id IN :systemicIssueIds
    ]) {
      //add the value in the map to a list so we can update it
      systemicIssuesToUpdate.add(
        new Case(id = si.Id, SI_Complaint_Count__c = si.Complaints__r.size())
      );
    }
    if (Case.sObjectType.getDescribe().isUpdateable()) {
      update systemicIssuesToUpdate;
    } else {
      CommonUtil.logAndThrowIAE(
        'SICaseActions',
        'rollupToParentSI',
        'Not enough permissions to update Case.'
      );
    }
  }
}
