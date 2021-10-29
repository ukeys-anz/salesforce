/**
 * @author Himabindu Nekkanti
 * @since  02/2021
 * @description IDRTaskActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 * @group IDR(Internal Dispute Resolution)
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
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

  @TestVisible
  private static final String SI_DUE_DATE_ERROR_MESSAGE = 'Only the case owner is allowed to edit the due date';

  public static Group siQueue = [
    SELECT id
    FROM group
    WHERE
      developername = :SI_QUEUE_DEVELOPER_NAME
      AND Type = :IDRConstants.QUEUE_TYPE
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
      record.Completed_Date__c = Date.today();
    }
    if (
      record.Type == IDRConstants.TASK_TYPE_PEND_CASE &&
      record.Subject != IDRConstants.SUBJECT_PEND_CASE_TASK
    ) {
      record.Subject = IDRConstants.SUBJECT_PEND_CASE_TASK;
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
        if (record.Subject.containsIgnoreCase(STOP_COLLECTIONS_SUBJECT)) {
          record.OwnerId = stopQueue.Id;
          record.ActivityDate = Date.today();
        } else if (
          record.Subject.containsIgnoreCase(START_COLLECTIONS_SUBJECT)
        ) {
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
    validateSIDueDate(records, oldMap);
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

    list<Task> oldTasks = new List<Task>();
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
          AND isClosed = FALSE
          AND (Subject = :IDRConstants.TASK_SUBJECT_DAY5
          OR Subject = :IDRConstants.TASK_SUBJECT_DAY1)
      ];
    }
    for (Task t : oldTasks) {
      t.Status = IDRConstants.TASK_STATUS_EXPIRED;
    }
    if (oldTasks.size() > 0) {
      if (
        Task.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.Task.fields.Status.isUpdateable()
      ) {
        update oldTasks;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRTaskActions',
          'closeOldIDRMaximumTimeTasks',
          'Not enough permissions to update Task.'
        );
      }
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
    if (caseIDSet.size() > 0) {
      if (CaseMilestone.sObjectType.getDescribe().isUpdateable()) {
        cmsToUpdate = [
          SELECT Id, CompletionDate
          FROM CaseMilestone cm
          WHERE
            caseId IN :caseIDSet
            AND (cm.MilestoneType.Name = :IDRConstants.MILESTONE_STANDARD
            OR cm.MilestoneType.Name = :IDRConstants.MILESTONE_PRIORITY)
            AND completionDate = NULL
          LIMIT 1
        ];
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRTaskActions',
          'closeMilestonesOfClosedTask',
          'Not enough permissions to update CaseMilestone.'
        );
      }
    }
    for (CaseMilestone cm : cmsToUpdate) {
      cm.CompletionDate = system.now();
    }

    if (cmsToUpdate.size() > 0) {
      if (
        CaseMilestone.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.CaseMilestone.fields.CompletionDate.isUpdateable()
      ) {
        update cmsToUpdate;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRTaskActions',
          'closeMilestonesOfClosedTask',
          'Not enough permissions to update CaseMilestone.'
        );
      }
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
    List<Task> idrTasks = new List<Task>();
    if (Task.sObjectType.getDescribe().isQueryable() && caseMap.size() > 0) {
      idrTasks = [
        SELECT Id, ActivityDate, whatId, Subject
        FROM Task
        WHERE
          whatId IN :caseMap.keySet()
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND IsClosed = FALSE
          AND (Subject = :IDRConstants.TASK_SUBJECT_DAY5
          OR Subject = :IDRConstants.TASK_SUBJECT_DAY1)
      ];
    }
    for (Task t : idrTasks) {
      t.ActivityDate = date.valueOf(
        calculateExpectedDue(t, caseMap.get(t.whatId))
      );
    }
    if (!idrTasks.isEmpty()) {
      if (
        Task.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.Task.fields.ActivityDate.isUpdateable()
      ) {
        update idrTasks;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRTaskActions',
          'updateIDRMilestoneTask',
          'Not enough permissions to update Task.'
        );
      }
    }
    List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
    if (
      CaseMilestone.sObjectType.getDescribe().isQueryable() &&
      caseMap.size() > 0
    ) {
      cmsToUpdate = [
        SELECT Id, StartDate, caseId
        FROM CaseMilestone cm
        WHERE caseId IN :caseMap.keySet() AND CompletionDate = NULL
      ];
    }
    for (CaseMilestone cm : cmsToUpdate) {
      cm.StartDate = caseMap.get(cm.caseId).IDR_Date_Received__c;
    }
    if (!cmsToUpdate.isEmpty()) {
      if (
        CaseMilestone.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.CaseMilestone.fields.StartDate.isUpdateable()
      ) {
        update cmsToUpdate;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRTaskActions',
          'updateIDRMilestoneTask',
          'Not enough permissions to update CaseMilestone.'
        );
      }
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
      IDRCaseActions.isIDRComplaintType(record) && //is it complaint?
      record.IDR_Is_Common__c == 'Yes' && //is case PSI
      FeatureManagement.checkPermission('IDR_Level_1') && //is user level 1 or higher?
      (oldRec == null ||
      (record.isEscalated != oldRec.isEscalated &&
      oldRec.isEscalated == true)) && //if case is updated, has it been escalated?
      ((oldRec == null &&
      record.isClosed == true) || //if case is created closed
      (oldRec != null &&
      oldRec.isClosed == false &&
      record.isClosed == true)) //if case is updated from non-closed to closed status
    ) {
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
      RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
      Type = IDRConstants.TASK_TYPE_SYSTEMIC_ISSUE,
      Priority = 'Normal',
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

  /**
   * @description close all the max IDR Timeframe task when case is closed
   * @param cases Set of case Ids
   */
  public static void closeMaxTimeFrameTasks(Set<Id> cases) {
    if (Task.sObjectType.getDescribe().isQueryable()) {
      List<Task> tasksToClose = [
        SELECT ID, Status
        FROM Task
        WHERE
          whatId IN :cases
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND isClosed = FALSE
      ];
      for (Task task : tasksToClose) {
        task.Status = IDRConstants.TASK_STATUS_COMPLETED;
      }
      if (
        Task.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.Task.fields.Status.isUpdateable()
      ) {
        update tasksToClose;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRTaskActions',
          'closeMaxTimeFrameTasks',
          'Not enough permissions to update Task.'
        );
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRTaskActions',
        'closeMaxTimeFrameTasks',
        'Not enough permissions to query Task.'
      );
    }
  }
}
