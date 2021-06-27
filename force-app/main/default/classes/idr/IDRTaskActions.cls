/**
 * @author Himabindu Nekkanti
 * @since  02/2021
 * @description IDRTaskActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class IDRTaskActions {
  private static final String SI_QUEUE_DEVELOPER_NAME = 'Systemic_Issue_Team';

  @TestVisible
  public static final String IDR_TASK_SUBJECT = 'Please Review PSI';

  @TestVisible
  private static final String SI_DUE_DATE_ERROR_MESSAGE = 'Only the case owner is allowed to edit the due date';

  public static Group siQueue = [
    SELECT id
    FROM group
    WHERE
      developername = :SI_QUEUE_DEVELOPER_NAME
      AND Type = :IDRConstants.QUEUE_TYPE
  ];

  /**
   * @description beforeInsertActions is called onBeforeInsert. any logic that needs to be executed on before insert is executed from here
   * @param records The Task record list.
   */
  public static void beforeInsertActions(list<Task> records) {
    for (Task record : records) {
      if (
        record.RecordTypeId == IDRConstants.SI_TASK_RT_ID ||
        record.RecordTypeId == IDRConstants.IDR_TASK_RT_ID
      ) {
        CommonUtil.handleMasking(
          record,
          null,
          SObjectType.Task.FieldSets.IDR_Masked_Fields.getFields()
        );
        populateFieldsOnTask(record, null);
      }
    }
  }

  /**
   * @description populate the required field on Task record
   * @param record The Task record list.
   * @param oldRec oldmap of the task record
   */
  public static void populateFieldsOnTask(Task record, Task oldRec) {
    if (
      record.Status == 'Completed' &
      (oldRec == null ||
      oldRec.Status != 'Completed')
    ) {
      record.Completed_Date__c = Date.today();
    }
  }

  /**
   * @description beforeUpdateActions is called onBeforeUpdate
   * @param records The Task record list.
   * @param oldMap Map of the old values of the records to process
   */
  public static void beforeUpdateActions(
    list<Task> records,
    Map<Id, Task> oldMap
  ) {
    for (Task record : records) {
      if (
        record.RecordTypeId == IDRConstants.SI_TASK_RT_ID ||
        record.RecordTypeId == IDRConstants.IDR_TASK_RT_ID
      ) {
        Task oldRecord = (Task) oldMap.get(record.id);
        CommonUtil.handleMasking(
          record,
          oldRecord,
          SObjectType.Task.FieldSets.IDR_Masked_Fields.getFields()
        );
        populateFieldsOnTask(record, oldRecord);
      }
    }
    validateSIDueDate(records, oldMap);
  }

  /**
   * @description possibleSystemicIssueActions(records, oldMap) method handles the following
   * 1. Calls rollupToParentSI to update the counter of linked complaints on the parent systemic issue record
   * 2. Calls createTaskforPSI method to generate task if the complaint is a PSI and created/updated by L1 user
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate.
   */
  public static void possibleSystemicIssueActions(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    Case[] childComplaints = new List<Case>(); //records to rollup on parent systemic issue
    Task[] siTasks = new List<Task>();
    for (Case record : records) {
      Case oldRec;
      if (oldMap != null) {
        oldRec = (Case) oldMap.get(record.id);
      }

      //should a parent systemic issue's rollup field be updated?
      if (
        IDRCaseActions.isIDRComplaintType(record) &&
        (oldRec == null ||
        record.IDR_Parent_Systemic_Issue__c !=
        oldRec.IDR_Parent_Systemic_Issue__c)
      ) {
        //just linked or unliked?
        if (String.isNotBlank(record.IDR_Parent_Systemic_Issue__c)) {
          childComplaints.add(record);
        } else if (oldRec != null) {
          childComplaints.add(oldRec);
        }
      }
      //validate case for PSI task creation
      if (validateCaseForPSITask(record, oldRec)) {
        siTasks.add(populateTaskFields(record));
      }
    }
    //rollup on parent systemic issue
    if (!childComplaints.isEmpty()) {
      SICaseActions.rollupToParentSI(childComplaints);
    }
    //insert SI Tasks
    if (!siTasks.isEmpty()) {
      if (
        Task.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Task.fields.ActivityDate.isCreateable() &&
        Schema.sObjectType.Task.fields.IsReminderSet.isCreateable() &&
        Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&
        Schema.sObjectType.Task.fields.RecordTypeId.isCreateable() &&
        Schema.sObjectType.Task.fields.Subject.isCreateable() &&
        Schema.sObjectType.Task.fields.WhatId.isCreateable()
      ) {
        insert siTasks;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRCaseActions',
          'possibleSystemicIssueActions',
          'Not enough permissions to create Task.'
        );
      }
    }
  }

  /**
   * @description Validates a complaint record for creating PSI task
   * @param record from case trigger
   * @param oldRec from case trigger
   * @return Boolean returns true or false based on validation
   */
  private static Boolean validateCaseForPSITask(Case record, Case oldRec) {
    if (
      IDRCaseActions.isIDRComplaintType(record) &&
      record.IDR_Is_Common__c == 'Yes' &&
      FeatureManagement.checkPermission('IDR_Level_1') &&
      (oldRec == null ||
      record.IDR_Is_Common__c != oldRec.IDR_Is_Common__c)
    ) {
      //create task if it is a possible systemic issue and level 1 user is making the change
      return true;
    } else if (
      oldRec != null &&
      IDRCaseActions.isIDRComplaintType(record) &&
      record.IDR_Is_Common__c == 'Yes' &&
      record.isClosed == true &&
      oldRec.isEscalated == true
    ) {
      //create task if the complaint is a PSI, escalated and closed.
      return true;
    } else {
      return false;
    }
  }
  /**
   * @description populate task fields for creating possible systemic issue task
   * @param c Parent case of the tasks
   * @return An instance of a Task
   */
  private static Task populateTaskFields(Case c) {
    Date activityDate = Date.today().addDays(5);
    return new Task(
      RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
      OwnerId = siQueue.Id,
      WhatId = c.Id,
      Subject = IDR_TASK_SUBJECT,
      ActivityDate = activityDate,
      IsReminderSet = true,
      ReminderDateTime = (DateTime) (activityDate - 2)
    );
  }

  /**
   * @description validate SI Task due date and throw error if the due date is updated by anyone who is not the case owner
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values
   */
  private static void validateSIDueDate(
    list<Task> records,
    Map<Id, Task> oldMap
  ) {
    Set<Id> caseIds = new Set<Id>();
    List<Task> siTasks = new List<Task>();
    Map<Id, Id> caseOwnerMap = new Map<Id, Id>();

    for (Task record : records) {
      Task oldRec = (Task) oldMap.get(record.id);
      if (
        record.RecordTypeId == IDRConstants.SI_TASK_RT_ID &&
        record.ActivityDate != oldRec.ActivityDate &&
        oldRec.ActivityDate != null
      ) {
        caseIds.add(record.WhatId);
        siTasks.add(record);
      }
    }
    if (Case.sObjectType.getDescribe().isQueryable()) {
      for (Case caseRec : [SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds]) {
        caseOwnerMap.put(caseRec.Id, caseRec.OwnerId);
      }
    }

    for (Task siTask : siTasks) {
      if (
        caseOwnerMap.containsKey(siTask.WhatId) &&
        caseOwnerMap.get(siTask.WhatId) != UserInfo.getUserId()
      ) {
        siTask.addError(SI_DUE_DATE_ERROR_MESSAGE);
      }
    }
  }
}
