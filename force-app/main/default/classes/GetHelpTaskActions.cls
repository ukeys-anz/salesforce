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

  @TestVisible
  public static final String TASK_SUBTYPE_CALL = 'Task';
  public static final String CALL_SID_IDENTIFIER = 'Call Sid: CA';
  public static final Integer CALL_SID_PREFIX_LENGTH = 10; // 'Call Sid: '
  public static final Integer CALL_SID_LENGTH = 34;

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
          lableIndex +
          CALL_SID_PREFIX_LENGTH +
          CALL_SID_LENGTH
        );
        // Re-validate Voice Call SID length
        if (!voiceCallSID.containsWhitespace() && voiceCallSID.length() == 34) {
          callSID = voiceCallSID;
        }
      }
    }
    return callSID;
  }
}
