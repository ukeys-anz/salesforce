/**
 * @author Shermal Warnakula
 * @since  03/2021
 * @description GetHelpTaskActions is to handle all the GetHelp specific Task actions
 */
public with sharing class GetHelpTaskActions {
  // Call Log Task Record Type Id
  @TestVisible
  public static final Id CALL_LOG_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Call_Log')
    .getRecordTypeId();

  public static final Id COACH_NUDGE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Coach_Nudge')
    .getRecordTypeId();

  private static final CoachNudgeRepository COACH_NUDGE_REPOSITORY = (CoachNudgeRepository) Lib_InstanceProvider.forType(
    CoachNudgeRepository.class
  );

  @TestVisible
  public static final String TASK_SUBTYPE_CALL = 'Task';
  public static final String CALL_SID_IDENTIFIER = 'Call Sid: CA';
  public static final Integer CALL_SID_PREFIX_LENGTH = 10; // 'Call Sid: '
  public static final Integer CALL_SID_LENGTH = 34;
  public static final String TASK_STATUS_EXPIRED = 'Expired';
  public static final String TASK_SUB_STATUS_AUTO_CANCELLED = 'Auto cancelled';
  public static final String TASK_SUB_STATUS_CUSTOMER_CANCELLED = 'Customer cancelled';
  public static final String TASK_STATUS_NEW = 'New';
  public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
  public static final String TASK_STATUS_EXPIRED_ERROR_MESSAGE = 'Status Cannot be changed to \'Expired\' manually.';

  /**
   * @description beforeInsertActions is called onBeforeInsert. any logic that needs to be executed on before insert is executed from here
   * @param records The Task record list.
   */
  public static void beforeInsertActions(List<Task> records) {
    enrichOutboundCallLogs(records);
  }

  /**
   * @description Populates auto-created Outbound Voice Call Logs with more useful information to be consistent with Inbound Call Logs
   * @param taskRecs Task record list being inserted.
   */
  public static void enrichOutboundCallLogs(List<Task> taskRecs) {
    // Extract related Cases information
    Map<Id, Case> relatedCasesById = getRelatedCases(taskRecs);

    for (Task record : taskRecs) {
      if (isOutboundCallLog(record)) {
        // Set record type to 'Call Log'
        record.RecordTypeId = CALL_LOG_RT_ID;

        // Set TaskSubtype to 'Call'
        record.TaskSubtype = TASK_SUBTYPE_CALL;

        // Read Call SID from comments (description field) and add it on Voice Call SID field.
        record.Voice_Call_SID__c = extractCallSID(record.Description);

        // Append 'Comments' with information on 'Subject'
        record.Description += '\n' + record.Subject;

        if (isRelatedToCase(record)) {
          // Populate Case 'Issue Type' as 'Subject' on Call Log. If Type isn't available set Case Subject.
          record.Subject = String.isBlank(
              relatedCasesById.get(record.WhatId).Type
            )
            ? relatedCasesById.get(record.WhatId).Subject
            : CommonUtil.getSinglePicklistLabel(
                Case.Type,
                relatedCasesById.get(record.WhatId).Type
              );

          // Link the Call Log (Task) to customer (Account) if it is not linked already
          if (record.WhoId == null) {
            record.WhoId = relatedCasesById.get(record.WhatId).ContactId;
          }
        }
      }
    }
  }

  /**
   * @description get Cases information related to Tasks
   * @param taskRecs List of Task records
   * @return `Map<Id, Case>`
   */
  private static Map<Id, Case> getRelatedCases(List<Task> taskRecs) {
    List<Id> caseIds = new List<Id>();
    for (Task record : taskRecs) {
      if (isOutboundCallLog(record) && isRelatedToCase(record)) {
        caseIds.add(record.WhatId);
      }
    }
    return new Map<Id, Case>(
      [SELECT Id, Type, Subject, ContactId FROM Case WHERE Id IN :caseIds]
    );
  }

  /**
   * @description checks if the Call Log was outbound or not
   * @param taskRec Task record
   * @return `Boolean`
   */
  private static Boolean isOutboundCallLog(Task taskRec) {
    Boolean isOutboundCallLog = false;
    // identify only the auto-created Voice Call Logs related Outbound
    if (taskRec.CallType != null) {
      isOutboundCallLog = (taskRec.CallType == 'Outbound' &&
      taskRec.Type == 'outbound');
    }
    return isOutboundCallLog;
  }

  /**
   * @description checks if the Call Log was related to a Case via WhatId
   * @param taskRec Task record
   * @return `Boolean`
   */
  private static Boolean isRelatedToCase(Task taskRec) {
    Boolean isRelatedToCase = false;
    if (taskRec.WhatId != null) {
      isRelatedToCase = ('Case'
        .equalsIgnoreCase(
          taskRec.WhatId.getSobjectType().getDescribe().getName()
        ));
    }
    return isRelatedToCase;
  }

  /**
   * @description extracts and returns Twilio Call SID from comments
   * @param comments comments passed in from Twilio in Task description field
   * @return `String`
   */
  private static String extractCallSID(String comments) {
    String callSID = null;
    if (!String.isBlank(comments)) {
      Integer lableIndex = comments.indexOf(CALL_SID_IDENTIFIER, 0);
      if (lableIndex >= 0) {
        String voiceCallSID = comments.substring(
          lableIndex + CALL_SID_PREFIX_LENGTH,
          lableIndex + CALL_SID_PREFIX_LENGTH + CALL_SID_LENGTH
        );
        // Re-validate Voice Call SID length
        if (!voiceCallSID.containsWhitespace() && voiceCallSID.length() == 34) {
          callSID = voiceCallSID;
        }
      }
    }
    return callSID;
  }

  /**
   * @description publish task cloud event if criteria is satisfied.
   * @param records The Task record list.
   * @param oldMap oldmap of the task record
   */
  public static void checkAndPublishTaskCloudEvent(
    List<Task> records,
    Map<Id, SObject> oldMap
  ) {
    List<Task> coachNudgeRecords = GetHelpTaskActionHelper.filterCoachNudgeTasks(
      records
    );
    Set<Id> accountIds = GetHelpTaskActionHelper.getWhoIdFromTask(
      coachNudgeRecords
    );
    Map<ID, Account> accountMap = GetHelpTaskActionHelper.getAccountMap(
      accountIds
    );
    List<CloudEventModel> cloudEventModels = GetHelpTaskActionHelper.getCloudEventModelForCoachNudge(
      coachNudgeRecords,
      (Map<Id, Task>) oldMap,
      accountMap
    );
    CloudEventController.publishCloudEvents(cloudEventModels);
  }

  /**
   * @description beforeUpdateActions is called onBeforeUpdate. any logic that needs to be executed on before update is executed from here
   * @param records The Task record list.
   * @param oldMap The old map of task records.
   */
  public static void beforeUpdateActions(
    List<Task> records,
    Map<Id, Task> oldMap
  ) {
    if (
      !System.isScheduled() &&
      !PermissionUtils.hasPermissionSetGroupAssigned(
        GetHelpConstants.BUSINESS_ADMIN_PSG
      )
    ) {
      preventManualExpiry(records, oldMap);
    }
  }

  /**
   * @description preventManualExpiry prenevents users from changing the status manually to Expired
   * @param records The Task record list.
   * @param oldMap The old map of task records.
   */
  private static void preventManualExpiry(
    List<Task> records,
    Map<Id, Task> oldMap
  ) {
    Set<Id> taskRelatedRlaIds = fetchtaskRelatedRlaIds(records);
    Set<Id> setOfRlaIdsSkipValidationError = COACH_NUDGE_REPOSITORY.queryRLAIdsWithCancelledStatus(
      taskRelatedRlaIds
    );
    Set<Id> checkRecordTypeId = GetHelpConstants.taskRecordTypeIds;

    for (Task tsk : records) {
      Task oldTask = oldMap.get(tsk.Id);
      if (
        (checkRecordTypeId.contains(tsk.RecordTypeId)) &&
        RecordComparisonUtil.fieldWasChanged(tsk, oldTask, Task.Status) &&
        tsk.Status == TASK_STATUS_EXPIRED &&
        !setOfRlaIdsSkipValidationError.contains(tsk.WhatId)
      ) {
        tsk.addError(TASK_STATUS_EXPIRED_ERROR_MESSAGE);
      }
    }
  }

  /**
   * @description To fetch the RLA record is associated to the task record
   * @param records task record list.
   * @return Set<Id> residential loan application record ids associated to the task
   */
  @testVisible
  private static Set<Id> fetchtaskRelatedRlaIds(List<Task> records) {
    Set<Id> rlaIds = new Set<Id>();
    for (Task taskRecord : records) {
      if (taskRecord.WhatId == null) {
        continue;
      }
      if (
        taskRecord.WhatId.getSobjectType() ==
        ResidentialLoanApplication.getSObjectType()
      ) {
        rlaIds.add(taskRecord.WhatId);
      }
    }
    return rlaIds;
  }

  /**
   * @description checks if specific field was changed and applies masking if required
   * @param records task record list.
   * @param oldMap The old map of task records.
   */
  public static void applyRedaction(List<Task> records, Map<Id, Task> oldMap) {
    for (Task record : records) {
      if (
        isValidRecordType(record) &&
        RecordComparisonUtil.fieldWasChanged(
          record,
          oldMap.get(record.Id),
          Task.Description
        )
      ) {
        record.Description = TextUtils.maskDataAnzx(record.Description);
      }
    }
  }

  /**
   * @description checks if record type is valid
   * @param record task record
   * @return `Boolean`
   */
  private static Boolean isValidRecordType(Task record) {
    return record.RecordTypeId == COACH_NUDGE_RT_ID;
  }
}
