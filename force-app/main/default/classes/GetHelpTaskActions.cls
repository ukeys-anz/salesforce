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
  public static final String TASK_SUBTYPE_CALL = 'Call';
  public static final String CONFERENCE_SID_IDENTIFIER = 'Sid: CF';
  public static final Integer CONFERENCE_SID_PREFIX_LENGTH = 5; // 'Sid: '
  public static final Integer CONFERENCE_SID_LENGTH = 34;

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
        record.Voice_Call_SID__c = extractConfCallSID(record.Description);

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
    // identify only the auto-created Voice Call Logs related Outbound
    return (taskRec.CallType == 'Outbound' && taskRec.Type == 'outbound');
  }

  /**
   * @description checks if the Call Log was related to a Case via WhatId
   * @param taskRec Task record
   * @return `Boolean`
   */
  private static Boolean isRelatedToCase(Task taskRec) {
    return ('Case'
      .equalsIgnoreCase(
        taskRec.WhatId.getSobjectType().getDescribe().getName()
      ));
  }

  /**
   * @description extracts and returns Twilio Conference SID from comments
   * @param comments comments passed in from Twilio in Task description field
   * @return `String`
   */
  private static String extractConfCallSID(String comments) {
    String conferenceSID = null;
    if (!String.isBlank(comments)) {
      Integer lableIndex = comments.indexOf(CONFERENCE_SID_IDENTIFIER, 0);
      if (lableIndex >= 0) {
        String voiceCallSID = comments.substring(
          lableIndex + CONFERENCE_SID_PREFIX_LENGTH,
          lableIndex +
          CONFERENCE_SID_PREFIX_LENGTH +
          CONFERENCE_SID_LENGTH
        );

        // Re-validate Voice Call Conference SID length
        if (!voiceCallSID.containsWhitespace() && voiceCallSID.length() == 34) {
          conferenceSID = voiceCallSID;
        }
      }
    }
    return conferenceSID;
  }
}
