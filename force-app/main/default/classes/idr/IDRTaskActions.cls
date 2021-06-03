/**
 * @author Himabindu Nekkanti
 * @since  02/2021
 * @description IDRTaskActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public without sharing class IDRTaskActions {
  private static final String SI_QUEUE_DEVELOPER_NAME = 'Systemic_Issue_Team';

  private static final String STOP_COLLECTIONS_QUEUE_NAME = 'IDR_Stop_Collections';

  private static final String START_COLLECTIONS_QUEUE_NAME = 'IDR_Restart_Collections';

  @testVisible
  private static final String STOP_COLLECTIONS_SUBJECT = 'STOP Collection';

  @testVisible
  private static final String START_COLLECTIONS_SUBJECT = 'START Collection';

  @TestVisible
  public static final String IDR_TASK_SUBJECT = 'Please Review PSI';

  public static Group siQueue = [
    SELECT id
    FROM group
    WHERE developername = :SI_QUEUE_DEVELOPER_NAME AND Type = :IDRConstants.QUEUE_TYPE
  ];

  public static Group stopQueue = [
    SELECT id
    FROM group
    WHERE
      developername = :STOP_COLLECTIONS_QUEUE_NAME
      AND Type = :IDRCaseActions.QUEUE_TYPE
  ];

  public static Group startQueue = [
    SELECT id
    FROM group
    WHERE
      developername = :START_COLLECTIONS_QUEUE_NAME
      AND Type = :IDRCaseActions.QUEUE_TYPE
  ];

  /**
   * @description beforeInsertActions is called onBeforeInsert. any logic that needs to be executed on before insert is executed from here
   * @param records The Task record list.
   */
  public static void beforeInsertActions(list<Task> records) {
    for (Task record : records) {
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID ||
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
    checkIDRMaximumTimeTasks(records);
    assignToCollectionsQueue(records);
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
      record.CompletedDate__c = Date.today();
    }
  }
  /**
   * @description assignToCollectionQueue method is used to validate the collection task created by mulesoft and assign to respective collections queue
   * @param records The Task record list.
   */
  public static void assignToCollectionsQueue(list<Task> records) {
    for (Task record : records) {
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID &&
        record.Status == IDRConstants.OPEN_STATUS
      ) {
        if (record.Subject.contains(STOP_COLLECTIONS_SUBJECT)) {
          record.OwnerId = stopQueue.Id;
          record.ActivityDate = Date.today();
        } else if (record.Subject.contains(START_COLLECTIONS_SUBJECT)) {
          record.OwnerId = startQueue.Id;
          record.ActivityDate = Date.today().addDays(14);
        }
      }
    }
  }

  /**
   * @description afterInsertActions is called onAfterInsert. any logic that needs to be executed on after insert is executed from here
   * @param records The Task record list.
   */
  public static void afterInsertActions(list<Task> records) {
    closeOldIDRMaximumTimeTasks(records);
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
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID ||
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
  }
  /**
   * @description afterUpdateActions is called onAfterUpdate. any logic that needs to be executed on after Update is executed from here
   * @param records The Task record list.
   */
  public static void afterUpdateActions(list<Task> records) {
    closeMilestonesOfClosedTask(records);
  }
  /**
   * @description closeOldIDRMaximumTimeTasks will close out old IDR Task reminders against case when a new Task is created.
   * @param taskRecs The Task record list.
   */
  private static void closeOldIDRMaximumTimeTasks(list<Task> taskRecs) {
    Set<Id> currentTask = new Set<Id>();
    Map<Id, ID> caseTaskMap = new Map<Id, ID>();
    for (Task record : taskRecs) {
      if (record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID) {
        currentTask.add(record.Id);
        caseTaskMap.put(record.WhatId, record.Id);
      }
    }

    list<task> oldTasks = new List<task>();
    if (
      caseTaskMap.size() > 0 && Task.sObjectType.getDescribe().isQueryable()
    ) {
      oldTasks = [
        SELECT Id, Status, subject
        FROM Task
        WHERE
          WhatId IN :caseTaskMap.keySet()
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND Id NOT IN :currentTask
          AND isClosed = false
          AND (Subject = :IDRConstants.TASK_SUBJECT_DAY5
          OR Subject = :IDRConstants.TASK_SUBJECT_DAY1)
      ];
    }
    for (task t : oldTasks) {
      t.status = IDRConstants.TASK_STATUS_EXPIRED;
    }
    if (oldTasks.size() > 0 && task.sObjectType.getDescribe().isUpdateable()) {
      update oldTasks;
    }
  }
  /**
   * @description checkIDRMaximumTimeTasks will perform the following actions.
   *1. since record type cannot be set from milestone , the appriapriate Task record type will be set here.
   *2. Edge case scenarios: In the event case is created with a very old date recieved the milestone will create IDR tasks with wrong due date.
   *   we will recalaulate and adust the date to correct date here and also expire any unwanted tasks.
   * @param taskRecs The Task record list.
   */
  private static void checkIDRMaximumTimeTasks(list<Task> taskRecs) {
    list<Task> idrMaximumTimeTasks = new List<Task>();
    Map<Id, ID> taskCaseMap = new Map<Id, ID>();
    Map<Id, String> caseTaskMap = new Map<Id, String>();
    Set<Id> caseIds = new Set<Id>();
    for (Task record : taskRecs) {
      if (
        record.subject == IDRConstants.TASK_SUBJECT_DAY5 ||
        record.subject == IDRConstants.TASK_SUBJECT_DAY1
      ) {
        record.RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID;
        idrMaximumTimeTasks.add(record);
        taskCaseMap.put(record.Id, record.WhatId);
        caseIds.add(record.whatId);
      }
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID &&
        (!caseTaskMap.KeySet().contains(record.WhatId) ||
        (record.subject == IDRConstants.TASK_SUBJECT_DAY1))
      ) {
        caseTaskMap.put(record.WhatId, record.subject);
      }
    }

    validateDueDate(idrMaximumTimeTasks, caseTaskMap);
    if (!caseIds.isEmpty()) {
      assignTaskToCaseOwner(taskRecs, caseIds);
    }
  }
  /**
   * @description validateDueDate will validate update the due date for IDR Tasks.
   * @param idrMaximumTimeTasks The Task record.
   * @param caseTaskMap  map of case  id and task subjects
   */
  public static void validateDueDate(
    list<task> idrMaximumTimeTasks,
    Map<id, string> caseTaskMap
  ) {
    Map<Id, Case> caseMap = new Map<Id, Case>();
    list<case> relatedCaseList = new List<case>();
    if (
      Case.sObjectType.getDescribe().isQueryable() && caseTaskMap.size() > 0
    ) {
      relatedCaseList = [
        SELECT Id, BusinessHoursId, IDR_Date_Received__c, Priority
        FROM Case
        WHERE Id IN :caseTaskMap.keySet()
      ];
    }
    for (case c : relatedCaseList) {
      caseMap.put(c.ID, c);
    }
    for (Task record : idrMaximumTimeTasks) {
      datetime expectedDueDate = calculateExpectedDue(
        record,
        caseMap.get(record.WhatId)
      );

      if (record.ActivityDate > date.valueof(expectedDueDate)) {
        record.ActivityDate = date.valueof(expectedDueDate);
      }

      if (record.subject != caseTaskMap.get(record.WhatId)) {
        record.Status = IDRConstants.TASK_STATUS_EXPIRED;
      }
    }
  }
  /**
   * @description calculateExpectedDue will calaulate the what the due date must be for IDR Tasks.
   * @param record The Task record.
   * @param caseRec the case record that this task is related to.
   * @return datetime new datetime value that expected to be the due date based on the task and case parms.
   */
  public static datetime calculateExpectedDue(task record, case caseRec) {
    datetime expectedDueDate;
    if (
      record.Subject == IDRConstants.TASK_SUBJECT_DAY5 &&
      caseRec.Priority == IDRConstants.TASK_STANDARD_PRIORITY
    ) {
      expectedDueDate = DateTimeUtils.addBusinessDays(
        caseRec.BusinessHoursId,
        caseRec.IDR_Date_Received__c,
        25
      );
    } else if (
      record.Subject == IDRConstants.TASK_SUBJECT_DAY5 &&
      caseRec.Priority != IDRConstants.TASK_STANDARD_PRIORITY
    ) {
      expectedDueDate = DateTimeUtils.addBusinessDays(
        caseRec.BusinessHoursId,
        caseRec.IDR_Date_Received__c,
        16
      );
    } else if (
      record.Subject == IDRConstants.TASK_SUBJECT_DAY1 &&
      caseRec.Priority == IDRConstants.TASK_STANDARD_PRIORITY
    ) {
      expectedDueDate = DateTimeUtils.addBusinessDays(
        caseRec.BusinessHoursId,
        caseRec.IDR_Date_Received__c,
        29
      );
    } else if (
      record.Subject == IDRConstants.TASK_SUBJECT_DAY1 &&
      caseRec.Priority != IDRConstants.TASK_STANDARD_PRIORITY
    ) {
      expectedDueDate = DateTimeUtils.addBusinessDays(
        caseRec.BusinessHoursId,
        caseRec.IDR_Date_Received__c,
        20
      );
    }
    return expectedDueDate;
  }
  /**
   * @description closeMilestonesOfClosedTask will mark Maximum IDR milestones as completed
   *               when the corresponding Taks completed.
   *
   * @param taskRecs List of task records.
   */
  private static void closeMilestonesOfClosedTask(list<Task> taskRecs) {
    set<Id> caseIDSet = new Set<Id>();
    for (task t : taskRecs) {
      if (
        t.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID &&
        t.Status == 'Completed' &&
        (t.Subject == IDRConstants.TASK_SUBJECT_DAY5 ||
        t.Subject == IDRConstants.TASK_SUBJECT_DAY1)
      ) {
        caseIDSet.add(t.WhatId);
      }
    }
    List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
    if (
      caseIDSet.size() > 0 &&
      CaseMilestone.sObjectType.getDescribe().isUpdateable()
    ) {
      cmsToUpdate = [
        SELECT Id, completionDate
        FROM CaseMilestone cm
        WHERE
          caseId IN :caseIDSet
          AND (cm.MilestoneType.Name = :IDRConstants.MILESTONE_STANDARD
          OR cm.MilestoneType.Name = :IDRConstants.MILESTONE_PRIORITY)
          AND completionDate = null
        LIMIT 1
      ];
    }
    for (CaseMilestone cm : cmsToUpdate) {
      cm.completionDate = system.now();
    }

    if (cmsToUpdate.size() > 0) {
      update cmsToUpdate;
    }
  }

  /**
   * @description assignTaskToCaseOwner is used to assign the tasks
   * created by entitlement process to case owner.
   * @param records List of task records from trigger
   * @param caseIds Set of case ids
   */
  private static void assignTaskToCaseOwner(
    List<Task> records,
    Set<Id> caseIds
  ) {
    Map<Id, Case> caseMap = new Map<ID, Case>();
    for (Case caseRecord : [
      SELECT Id, OwnerId
      FROM Case
      WHERE Id IN :caseIds
    ]) {
      caseMap.put(caseRecord.Id, caseRecord);
    }
    for (Task record : records) {
      if (caseMap.containsKey(record.WhatId)) {
        record.OwnerId = caseMap.get(record.WhatId).OwnerId;
      }
    }
  }

  /**
   * @description Update the tasks and milestones to reflect the values based on new date recieved.
   * @param records list of case record
   * @param oldMap Map of old case records
   */
  public static void updateIDRMilestoneTask(
    list<Case> records,
    Map<Id, SObject> oldMap
  ) {
    Map<Id, Case> caseMap = new Map<Id, Case>();
    for (case record : records) {
      Case oldRec = (Case) oldMap.get(record.id);
      // if the date recieved is changed after milestone has been applied
      // I.e Case is already created as complain or already identified as complaint.(isIDRComplaintType(oldRec))
      // then the tasks and milestone needs to be update to reflect this change
      if (
        IDRCaseActions.isIDRComplaintType(record) &&
        IDRCaseActions.isIDRComplaintType(oldRec) &&
        oldRec.IDR_Date_Received__c != record.IDR_Date_Received__c
      ) {
        caseMap.put(record.Id, record);
      }
    }
    List<task> idrTasks = new List<task>();
    if (task.sObjectType.getDescribe().isQueryable() && caseMap.size() > 0) {
      idrTasks = [
        SELECT Id, ActivityDate, whatId, Subject
        FROM Task
        WHERE
          whatId IN :caseMap.keySet()
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND IsClosed = false
          AND (Subject = :IDRConstants.TASK_SUBJECT_DAY5
          OR Subject = :IDRConstants.TASK_SUBJECT_DAY1)
      ];
    }
    for (task t : idrTasks) {
      t.ActivityDate = date.valueOf(
        calculateExpectedDue(t, caseMap.get(t.whatId))
      );
    }
    if (task.sObjectType.getDescribe().isUpdateable() && !idrTasks.isEmpty()) {
      update idrTasks;
    }
    List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
    if (
      CaseMilestone.sObjectType.getDescribe().isQueryable() &&
      caseMap.size() > 0
    ) {
      cmsToUpdate = [
        SELECT Id, StartDate, caseId
        FROM CaseMilestone cm
        WHERE caseId IN :caseMap.keySet() AND completionDate = null
      ];
    }
    for (CaseMilestone cm : cmsToUpdate) {
      cm.StartDate = caseMap.get(cm.caseId).IDR_Date_Received__c;
    }
    if (
      CaseMilestone.sObjectType.getDescribe().isUpdateable() &&
      !cmsToUpdate.isEmpty()
    ) {
      update cmsToUpdate;
    }
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
    if (!siTasks.isEmpty() && Task.sObjectType.getDescribe().isCreateable()) {
      insert siTasks;
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
}
