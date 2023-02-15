/**
 * @author Himabindu Nekkanti
 * @since  02/2021
 * @description IDRTaskActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 * without sharing: used to perform system generated Tasks which is not accessible by the end user.
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDRCaseActionsTest, IDRTaskActionsTest, TaskTriggerHandlerTest
 * CyclomaticComplexity Suppressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public without sharing class IDRTaskActions {
  private static final String SI_QUEUE_DEVELOPER_NAME = 'Systemic_Issue_Team';

  private static final String STOP_COLLECTIONS_QUEUE_NAME = 'IDR_Stop_Collections';

  private static final String START_COLLECTIONS_QUEUE_NAME = 'IDR_Restart_Collections';

  @TestVisible
  private static final String STOP_COLLECTIONS_SUBJECT = 'STOP Collection';

  @TestVisible
  private static final String START_COLLECTIONS_SUBJECT = 'START Collection';
  public static final String NEW_FILE_SUBJECT = 'New File added by';

  public static final String IDR_TASK_SUBJECT = 'Please Review PSI';

  @TestVisible
  private static final String SI_DUE_DATE_ERROR_MESSAGE = 'Only the case owner is allowed to edit the due date';
  private static final String IDR_LEVEL_1 = 'IDR_Level_1';

  @TestVisible
  private static Map<Id, Case> caseMapGlobal;

  @TestVisible
  private static final String TASK_SUBJECT_DAY1_SEARCH =
    '%' +
    IDRConstants.TASK_SUBJECT_DAY1 +
    '%';
  private static final String TASK_SUBJECT_DAY5_SEARCH =
    '%' +
    IDRConstants.TASK_SUBJECT_DAY5 +
    '%';

  public static Group siQueue = [
    SELECT Id
    FROM Group
    WHERE
      DeveloperName = :SI_QUEUE_DEVELOPER_NAME
      AND Type = :IDRConstants.QUEUE_TYPE
  ];

  public static Group stopQueue = [
    SELECT Id
    FROM Group
    WHERE
      DeveloperName = :STOP_COLLECTIONS_QUEUE_NAME
      AND Type = :IDRCaseActions.QUEUE_TYPE
  ];

  public static Group startQueue = [
    SELECT Id
    FROM Group
    WHERE
      DeveloperName = :START_COLLECTIONS_QUEUE_NAME
      AND Type = :IDRCaseActions.QUEUE_TYPE
  ];

  public static Boolean siSystemDeletingAutoGenTask = false;

  /**
   * @description beforeInsertActions is called onBeforeInsert. any logic that needs to be executed on before insert is executed from here
   * @param records The Task record list.
   */

  public static void beforeInsertActions(List<Task> records) {
    for (Task record : records) {
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID ||
        record.RecordTypeId == IDRConstants.SI_TASK_RT_ID ||
        record.RecordTypeId == IDRConstants.IDR_TASK_RT_ID
      ) {
        if (
          record.Subject == null ||
          !record.Subject.containsIgnoreCase(NEW_FILE_SUBJECT)
        ) {
          CommonUtil.handleMasking(
            record,
            null,
            SObjectType.Task.fieldSets.IDR_Masked_Fields.getFields()
          );
        }
        populateFieldsOnTask(record, null);
      }
    }
    checkIDRMaximumTimeTasks(records);
    assignToCollectionsQueue(records);
    stampQueueName(records, null);
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
    if (
      record.RecordTypeId == IDRConstants.IDR_TASK_RT_ID &&
      record.ActivityDate == null
    ) {
      record.ActivityDate = Date.today().addDays(1);
    }
  }
  /**
   * @description create task records for complaint assignment / New file attached / New Email Attached / New comment on closed case.
   * @param records task record for insert
   */
  public static Void insertAssignmentTask(List<Task> records) {
    if (!records.isEmpty()) {
      IDRTaskActionHelper.insertAssignmentTask(records);
    }
  }
  /**
   * @description populate task fields for creating task after complaint assignment / New file attached / New Email Attached / New comment on closed case.
   * @param c case record from the trigger
   * @param subject of the task record
   * @return An instance of a Task
   */
  public static Task createAssignmentTask(Case c, String subject) {
    return new Task(
      RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
      OwnerId = c.OwnerId,
      WhatId = c.Id,
      Subject = subject,
      Status = 'Open',
      Priority = 'Normal',
      Type = 'Notification'
    );
  }
  /**
   * @description assignToCollectionQueue method is used to validate the collection task created by mulesoft and assign to respective collections queue
   * @param records The Task record list.
   */
  public static void assignToCollectionsQueue(List<Task> records) {
    for (Task record : records) {
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID &&
        record.Status == IDRConstants.OPEN_STATUS &&
        String.isNotBlank(record.Subject)
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
  public static void afterInsertActions(List<Task> records) {
    closeOldIDRMaximumTimeTasks(records);
  }
  /**
   * @description beforeUpdateActions is called onBeforeUpdate
   * @param records The Task record list.
   * @param oldMap Map of the old values of the records to process
   */
  public static void beforeUpdateActions(
    List<Task> records,
    Map<Id, Task> oldMap
  ) {
    for (Task record : records) {
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID ||
        record.RecordTypeId == IDRConstants.SI_TASK_RT_ID ||
        record.RecordTypeId == IDRConstants.IDR_TASK_RT_ID
      ) {
        Task oldRecord = (Task) oldMap.get(record.Id);
        CommonUtil.handleMasking(
          record,
          oldRecord,
          SObjectType.Task.fieldSets.IDR_Masked_Fields.getFields()
        );
        populateFieldsOnTask(record, oldRecord);
      }
    }
    stampQueueName(records, oldMap);
    validateSIDueDate(records, oldMap);
  }

  /**
   * @description beforeDeleteActions is called onBeforeDelete. any logic that needs to be executed on before Delete is executed from here
   * @param records The Task record list.
   */
  public static void beforeDeleteActions(List<Task> records) {
    restrictIDRTaskDelete(records);
  }

  /**
   * @description afterUpdateActions is called onAfterUpdate. any logic that needs to be executed on after Update is executed from here
   * @param records The Task record list.
   */
  public static void afterUpdateActions(List<Task> records) {
    closeMilestonesOfClosedTask(records);
  }
  /**
   * @description closeOldIDRMaximumTimeTasks will close out old IDR Task reminders against case when a new Task is created.
   * @param taskRecs The Task record list.
   */
  private static void closeOldIDRMaximumTimeTasks(List<Task> taskRecs) {
    Set<Id> currentTask = new Set<Id>();
    Map<Id, Id> caseTaskMap = new Map<Id, Id>();
    for (Task record : taskRecs) {
      if (record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID) {
        currentTask.add(record.Id);
        caseTaskMap.put(record.WhatId, record.Id);
      }
    }

    List<Task> oldTasks = new List<Task>();
    if (
      caseTaskMap.size() > 0 && Task.SObjectType.getDescribe().isQueryable()
    ) {
      oldTasks = [
        SELECT Id, Status, Subject
        FROM Task
        WHERE
          WhatId IN :caseTaskMap.keySet()
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND Id NOT IN :currentTask
          AND IsClosed = FALSE
          AND (Subject LIKE :TASK_SUBJECT_DAY5_SEARCH
          OR Subject LIKE :TASK_SUBJECT_DAY1_SEARCH)
      ];
    }
    for (Task t : oldTasks) {
      t.Status = IDRConstants.TASK_STATUS_EXPIRED;
    }
    if (oldTasks.size() > 0) {
      if (
        Task.SObjectType.getDescribe().isUpdateable() &&
        Schema.SObjectType.Task.fields.Status.isUpdateable()
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
   *1. since record type cannot be set from milestone , the appropriate Task record type will be set here.
   *2. Edge case scenarios: In the event case is created with a very old date received the milestone will create IDR tasks with wrong due date.
   *   we will recalculate and adjust the date to correct date here and also expire any unwanted tasks.
   * @param taskRecs The Task record list.
   */
  private static void checkIDRMaximumTimeTasks(List<Task> taskRecs) {
    List<Task> idrMaximumTimeTasks = new List<Task>();
    Map<Id, Id> taskCaseMap = new Map<Id, Id>();
    Map<Id, String> caseTaskMap = new Map<Id, String>();
    Set<Id> caseIds = new Set<Id>();
    for (Task record : taskRecs) {
      if (
        String.isNotEmpty(record.Subject) &&
        (record.Subject.contains(IDRConstants.TASK_SUBJECT_DAY5) ||
        record.Subject.contains(IDRConstants.TASK_SUBJECT_DAY1))
      ) {
        record.RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID;
        record.Type = IDRConstants.TASK_TYPE_NOTIFICATION;
        idrMaximumTimeTasks.add(record);
        taskCaseMap.put(record.Id, record.WhatId);
        caseIds.add(record.WhatId);
      }
      if (
        String.isNotEmpty(record.Subject) &&
        (record.Subject.contains(IDRConstants.TASK_AFCA_SUBJECT_DAY10) ||
        record.Subject.contains(IDRConstants.TASK_AFCA_SUBJECT_DAY1))
      ) {
        record.RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID;
        record.Type = IDRConstants.TASK_TYPE_NOTIFICATION;
        caseIds.add(record.WhatId);
      }
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID &&
        String.isNotEmpty(record.Subject) &&
        (!caseTaskMap.keySet().contains(record.WhatId) ||
        record.Subject.contains(IDRConstants.TASK_SUBJECT_DAY1))
      ) {
        caseTaskMap.put(record.WhatId, record.Subject);
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
    List<Task> idrMaximumTimeTasks,
    Map<Id, String> caseTaskMap
  ) {
    Map<Id, Case> caseMap = new Map<Id, Case>();
    List<Case> relatedCaseList = new List<Case>();
    if (
      Case.SObjectType.getDescribe().isQueryable() && caseTaskMap.size() > 0
    ) {
      if (caseMapGlobal == null || caseMapGlobal.size() == 0) {
        relatedCaseList = [
          SELECT Id, BusinessHoursId, IDR_Date_Received__c, Priority
          FROM Case
          WHERE Id IN :caseTaskMap.keySet()
        ];
      }
    }
    if (!relatedCaseList.isEmpty()) {
      for (Case c : relatedCaseList) {
        caseMap.put(c.Id, c);
      }
    } else {
      caseMap = new Map<Id, Case>(caseMapGlobal);
    }
    for (Task record : idrMaximumTimeTasks) {
      Datetime expectedDueDate = calculateExpectedDue(
        record,
        caseMap.get(record.WhatId)
      );

      if (expectedDueDate != null) {
        if (record.ActivityDate > Date.valueOf(expectedDueDate)) {
          record.ActivityDate = Date.valueOf(expectedDueDate);
        }

        if (record.Subject != caseTaskMap.get(record.WhatId)) {
          record.Status = IDRConstants.TASK_STATUS_EXPIRED;
        }
      }
    }
  }
  /**
   * @description calculateExpectedDue will calculate the what the due date must be for IDR Tasks.
   * @param record The Task record.
   * @param caseRec the case record that this task is related to.
   * @return datetime new datetime value that expected to be the due date based on the task and case parms.
   */
  public static Datetime calculateExpectedDue(Task record, Case caseRec) {
    Datetime expectedDueDate;
    if (caseRec == null) {
      return null;
    }
    if (
      record.Subject.contains(IDRConstants.TASK_SUBJECT_DAY5) &&
      caseRec.Priority == IDRConstants.TASK_STANDARD_PRIORITY
    ) {
      expectedDueDate = DateTimeUtils.addBusinessDays(
        caseRec.BusinessHoursId,
        caseRec.IDR_Date_Received__c,
        25
      );
    } else if (
      record.Subject.contains(IDRConstants.TASK_SUBJECT_DAY5) &&
      caseRec.Priority != IDRConstants.TASK_STANDARD_PRIORITY
    ) {
      expectedDueDate = DateTimeUtils.addBusinessDays(
        caseRec.BusinessHoursId,
        caseRec.IDR_Date_Received__c,
        16
      );
    } else if (
      record.Subject.contains(IDRConstants.TASK_SUBJECT_DAY1) &&
      caseRec.Priority == IDRConstants.TASK_STANDARD_PRIORITY
    ) {
      expectedDueDate = DateTimeUtils.addBusinessDays(
        caseRec.BusinessHoursId,
        caseRec.IDR_Date_Received__c,
        29
      );
    } else if (
      record.Subject.contains(IDRConstants.TASK_SUBJECT_DAY1) &&
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
   *               when the corresponding Tasks completed.
   *
   * @param taskRecs List of task records.
   */
  private static void closeMilestonesOfClosedTask(List<Task> taskRecs) {
    Set<Id> caseIDSet = new Set<Id>();
    for (Task t : taskRecs) {
      if (
        t.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID &&
        t.Status == 'Completed' &&
        (t.Subject.contains(IDRConstants.TASK_SUBJECT_DAY5) ||
        t.Subject.contains(IDRConstants.TASK_SUBJECT_DAY1))
      ) {
        caseIDSet.add(t.WhatId);
      }
    }
    List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
    if (caseIDSet.size() > 0) {
      if (CaseMilestone.SObjectType.getDescribe().isUpdateable()) {
        cmsToUpdate = [
          SELECT Id, CompletionDate
          FROM CaseMilestone cm
          WHERE
            CaseId IN :caseIDSet
            AND (cm.MilestoneType.Name = :IDRConstants.MILESTONE_STANDARD
            OR cm.MilestoneType.Name = :IDRConstants.MILESTONE_PRIORITY)
            AND CompletionDate = NULL
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
      cm.CompletionDate = System.now();
    }

    if (cmsToUpdate.size() > 0) {
      if (
        CaseMilestone.SObjectType.getDescribe().isUpdateable() &&
        Schema.SObjectType.CaseMilestone.fields.CompletionDate.isUpdateable()
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
    Map<Id, Case> caseMap = new Map<Id, Case>();
    if (caseMapGlobal == null || caseMapGlobal.size() > 0) {
      for (Case caseRecord : [
        SELECT Id, OwnerId
        FROM Case
        WHERE Id IN :caseIds
      ]) {
        caseMap.put(caseRecord.Id, caseRecord);
      }
    } else {
      caseMap = new Map<Id, Case>(caseMapGlobal);
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
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    Map<Id, Case> caseMap = new Map<Id, Case>();
    for (Case record : records) {
      Case oldRec = (Case) oldMap.get(record.Id);
      // if the date received is changed after milestone has been applied
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
    if (Task.SObjectType.getDescribe().isQueryable() && caseMap.size() > 0) {
      idrTasks = [
        SELECT Id, ActivityDate, WhatId, Subject
        FROM Task
        WHERE
          WhatId IN :caseMap.keySet()
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND IsClosed = FALSE
          AND (Subject LIKE :TASK_SUBJECT_DAY5_SEARCH
          OR Subject LIKE :TASK_SUBJECT_DAY1_SEARCH)
      ];
    }
    for (Task t : idrTasks) {
      t.ActivityDate = Date.valueOf(
        calculateExpectedDue(t, caseMap.get(t.WhatId))
      );
    }
    if (!idrTasks.isEmpty()) {
      if (
        Task.SObjectType.getDescribe().isUpdateable() &&
        Schema.SObjectType.Task.fields.ActivityDate.isUpdateable()
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
      CaseMilestone.SObjectType.getDescribe().isQueryable() &&
      caseMap.size() > 0
    ) {
      cmsToUpdate = [
        SELECT Id, StartDate, CaseId
        FROM CaseMilestone cm
        WHERE CaseId IN :caseMap.keySet() AND CompletionDate = NULL
      ];
    }
    for (CaseMilestone cm : cmsToUpdate) {
      cm.StartDate = caseMap.get(cm.CaseId).IDR_Date_Received__c;
    }
    if (!cmsToUpdate.isEmpty()) {
      if (
        CaseMilestone.SObjectType.getDescribe().isUpdateable() &&
        Schema.SObjectType.CaseMilestone.fields.StartDate.isUpdateable()
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
    Task[] existingTasks = new List<Task>();
    Set<Id> caseIds = new Set<Id>();
    Map<Id, Task> siCaseTasks = new Map<Id, Task>();

    for (Case record : records) {
      if (
        oldMap != null &&
        oldMap.containsKey(record.Id) &&
        IDRCaseActions.isIDRComplaintType(record) && //is it complaint?
        record.IDR_Is_Common__c == 'Yes' //is case PSI
      ) {
        caseIds.add(record.Id);
      }
    }
    if (!caseIds.isEmpty() && Task.SObjectType.getDescribe().isQueryable()) {
      existingTasks = [
        SELECT Id, Status, Subject, WhatId
        FROM Task
        WHERE
          WhatId IN :caseIds
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND Type = :IDRConstants.TASK_TYPE_SYSTEMIC_ISSUE
          AND Subject = :IDR_TASK_SUBJECT
      ];

      for (Task record : existingTasks) {
        siCaseTasks.put(record.WhatId, record);
      }
    }

    for (Case record : records) {
      Case oldRec;
      if (oldMap != null) {
        oldRec = (Case) oldMap.get(record.Id);
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
      if (validateCaseForPSITask(record, oldRec, siCaseTasks)) {
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
        Task.SObjectType.getDescribe().isCreateable() &&
        Schema.SObjectType.Task.fields.ActivityDate.isCreateable() &&
        Schema.SObjectType.Task.fields.IsReminderSet.isCreateable() &&
        Schema.SObjectType.Task.fields.OwnerId.isCreateable() &&
        Schema.SObjectType.Task.fields.RecordTypeId.isCreateable() &&
        Schema.SObjectType.Task.fields.Subject.isCreateable() &&
        Schema.SObjectType.Task.fields.WhatId.isCreateable()
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
   * @param siCaseTasks store existing SI task on a case
   * @return Boolean returns true or false based on validation
   */
  private static Boolean validateCaseForPSITask(
    Case record,
    Case oldRec,
    Map<Id, Task> siCaseTasks
  ) {
    if (
      IDRCaseActions.isIDRComplaintType(record) && //is it complaint?
      record.IDR_Is_Common__c == 'Yes' && //is case PSI
      FeatureManagement.checkPermission(IDR_LEVEL_1) && //is user level 1 or higher?
      record.IsClosed &&
      (oldRec ==
      null || //if case is created closed
      (oldRec.Status != record.Status &&
      (!(siCaseTasks.containsKey(record.Id)))) || // Status is changing from non-closed to closed status means when L1 or higher is closing this case,
      //This could be a Reopen to closure scenario therefore make sure another task is not created.
      oldRec.IDR_Is_Common__c != record.IDR_Is_Common__c) // when case is already closed and L1 updates PSI flag to yes
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
      ReminderDateTime = (Datetime) (activityDate - 2)
    );
  }

  /**
   * @description validate SI Task due date and throw error if the due date is updated by anyone who is not the case owner
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values
   */
  private static void validateSIDueDate(
    List<Task> records,
    Map<Id, Task> oldMap
  ) {
    Set<Id> caseIds = new Set<Id>();
    List<Task> siTasks = new List<Task>();
    Map<Id, Id> caseOwnerMap = new Map<Id, Id>();

    for (Task record : records) {
      Task oldRec = (Task) oldMap.get(record.Id);
      if (
        record.RecordTypeId == IDRConstants.SI_TASK_RT_ID &&
        record.ActivityDate != oldRec.ActivityDate &&
        oldRec.ActivityDate != null
      ) {
        caseIds.add(record.WhatId);
        siTasks.add(record);
      }
    }
    if (Case.SObjectType.getDescribe().isQueryable()) {
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
    if (Task.SObjectType.getDescribe().isQueryable()) {
      List<Task> tasksToClose = [
        SELECT Id, Status
        FROM Task
        WHERE
          WhatId IN :cases
          AND RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
          AND IsClosed = FALSE
          AND Type = 'Notification'
      ];
      for (Task task : tasksToClose) {
        task.Status = IDRConstants.TASK_STATUS_COMPLETED;
      }
      if (
        Task.SObjectType.getDescribe().isUpdateable() &&
        Schema.SObjectType.Task.fields.Status.isUpdateable()
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

  /**
   * @description method to insert collection tasks and handle errors
   * @param collectionTaskList List of collection tasks
   */
  public static void insertSystemTasks(List<Task> collectionTaskList) {
    List<Database.SaveResult> results = Database.insert(
      collectionTaskList,
      false
    );
    Logger.error('', results);
    Logger.saveLog();
  }

  /**
   * @description checks if the owner is Queue or not and then stamps the Queue Name to the Queue field.
   * Once the task owner accepts the case we lose the track of Queue, and hence the explicit field
   * @param lstNewTasks task list in current context
   * @param  mpOldTasks old map of the tasks in current context
   */
  private static void stampQueueName(
    List<Task> lstNewTasks,
    Map<Id, Task> mpOldTasks
  ) {
    Set<Id> stQueueIds = new Set<Id>();

    Task oOldTask;
    for (Task oTask : lstNewTasks) {
      if (oTask.OwnerId.getSobjectType() == Group.SObjectType) {
        if (
          mpOldTasks == null ||
          (oOldTask = mpOldTasks.get(oTask.Id)) == null ||
          oTask.OwnerId != oOldTask.OwnerId
        ) {
          stQueueIds.add(oTask.OwnerId);
        }
      }
    }

    if (!stQueueIds.isEmpty()) {
      Map<Id, Group> mpId2Group = new Map<Id, Group>(
        [SELECT Id, Name FROM Group WHERE Id IN :stQueueIds]
      );

      for (Task oTask : lstNewTasks) {
        if (mpId2Group.containsKey(oTask.OwnerId)) {
          oTask.Queue__c = mpId2Group.get(oTask.OwnerId).Name;
        }
      }
    }
  }

  /**
   * @description updates the Subject field on IDR Response due in 5 days Task record and IDR Response due in 1 day Task record to include Case Id and Customer Name.
   * @param records List of collection Tasks.
   */

  public static void updateNotificationSubject(List<Task> records) {
    Set<Id> caseIds = new Set<Id>();
    for (Task record : records) {
      caseIds.add(record.WhatId);
    }
    if (caseMapGlobal == null || caseMapGlobal.size() == 0) {
      caseMapGlobal = new Map<Id, Case>(
        [
          SELECT
            Id,
            CaseNumber,
            IDR_NC_First_Name__c,
            IDR_NC_Last_Name__c,
            OwnerId,
            BusinessHoursId,
            IDR_Date_Received__c,
            Priority
          FROM Case
          WHERE Id IN :caseIds
        ]
      );
    }
    for (Task record : records) {
      Case caseObj = caseMapGlobal.get(record.WhatId);
      if (
        String.isNotEmpty(record.Subject) &&
        (record.Subject == IDRConstants.TASK_SUBJECT_DAY5 ||
        record.Subject == IDRConstants.TASK_SUBJECT_DAY1 ||
        record.Subject == IDRConstants.TASK_AFCA_SUBJECT_DAY10 ||
        record.Subject == IDRConstants.TASK_AFCA_SUBJECT_DAY1) &&
        caseObj != null
      ) {
        String customerName = '';
        if (caseObj.IDR_NC_First_Name__c != null) {
          customerName = caseObj.IDR_NC_First_Name__c + ' ';
        }
        if (caseObj.IDR_NC_Last_Name__c != null) {
          customerName = customerName + caseObj.IDR_NC_Last_Name__c;
        }
        record.Subject = record.Subject + ' | ' + caseObj.CaseNumber;
        if (customerName != '') {
          record.Subject =
            record.Subject +
            ' | Customer Name : ' +
            customerName;
        }
      }
    }
  }

  /**
   * @description restrictIDRTaskDelete check if user is able to delete IDR task records (in particular auto-generated IDR tasks), throws error if user is ineligible to delete IDR task
   * @param records the task records being checked to see if its eligible for deletion
   */
  public static void restrictIDRTaskDelete(List<Task> records) {
    for (Task t : records) {
      if (isIDRTaskType(t)) {
        if (!validateIDRTaskForDelete(t)) {
          t.addError(
            'Error: This task is automatically generated and cannot be deleted in CMOS'
          );
        }
      }
    }
  }

  /**
   * @description validateIDRTaskForDelete logic to check if user is able to delete task record (in particular auto-generated IDR tasks)
   * @param t the task record being checked to see if its eligible for deletion
   * @return `Boolean` True if the the record type is eligible for deletion, false otherwise
   */
  public static Boolean validateIDRTaskForDelete(Task t) {
    if (t.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID) {
      return false;
    } else if (t.RecordTypeId == IDRConstants.IDR_TASK_RT_ID) {
      if (FeatureManagement.checkPermission('IDR_Level_1')) {
        return true;
      }
    } else if (t.RecordTypeId == IDRConstants.SI_TASK_RT_ID) {
      if (t.Subject.contains('Monitor Issue') && !siSystemDeletingAutoGenTask) {
        return false;
      } else {
        if (FeatureManagement.checkPermission('IDR_SI')) {
          return true;
        }
      }
    }
    return true;
  }

  /**
   * @description isIDRTaskType check if record type is of IDR type.
   * As this Trigger will be used across various teams we identify task record based on IDR record Type.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of IDR type false otherwise.
   */
  public static Boolean isIDRTaskType(Task record) {
    if (
      record.RecordTypeId == IDRConstants.IDR_TASK_RT_ID ||
      record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID ||
      record.RecordTypeId == IDRConstants.SI_TASK_RT_ID
    ) {
      return true;
    }
    return false;
  }
}
