/**
 * @author Adnan
 * @since  09/2021
 * @description Handler class for IDRPendCaseTaskRemindersBatch and for creating and sending task notifications
 */
public with sharing class IDRPendCaseTaskRemindersHandler {
  private static final List<String> PEND_TASK_REMINDER_WINDOW = Label.IDR_Window_For_Task_Reminders.split(
    ','
  );

  private static final List<String> PEND_TASK_REMINDER_WINDOW = Label.IDR_Window_For_Task_Reminders.split(
    ','
  );
  private static final IDRTaskActionsRepository TASK_REPOSITORY = (IDRTaskActionsRepository) Lib_InstanceProvider.forType(
    IDRTaskActionsRepository.class
  );
  @TestVisible
  private static final String PEND_TASK_REMINDER = 'Pend Case Task Reminder';

  /**
   * @description method for creating wrapper to send notifications
   * @param taskList list of task records that are used for creating wrapper
   * @return List<IDRBankerNotificationWrapper> returns the created wrapper
   */
  public static List<IDRBankerNotificationWrapper> createWrapper(
    List<Task> taskList
  ) {
    Set<Id> caseIds = ListUtil.getIds(taskList, Task.WhatId);
    Map<Id, Case> caseMap = new Map<Id, Case>(
      TASK_REPOSITORY.queryCases(caseIds)
    );
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();
    for (Task task : taskList) {
      Set<Id> recipientList = new Set<Id>{
        task.OwnerId,
        caseMap.get(task.WhatId).OwnerId
      };
      String msgBody = getPendTaskBody(
        Integer.valueOf(task.Due_in_Days__c),
        caseMap.get(task.WhatId).CaseNumber
      );
      if (String.isBlank(msgBody)) {
        continue;
      }
      IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
        task,
        new List<Id>(recipientList),
        PEND_TASK_REMINDER,
        msgBody,
        caseMap.get(task.WhatId)
      );
      wrapperList.add(wrapper);
    }
    return wrapperList;
  }

  /**
   * @description method for getting Pend Task Notification Body
   * @param taskDueDays number of days task is due in
   * @param relatedCaseNumber CaseNumber of related case
   * @return notification message body
   */
  private static String getPendTaskBody(
    Integer taskDueDays,
    String relatedCaseNumber
  ) {
    if (PEND_TASK_REMINDER_WINDOW.contains(String.valueOf(taskDueDays))) {
      return 'Pend Task for Case : ' +
        relatedCaseNumber +
        ' is due in ' +
        taskDueDays +
        ' Days.';
    }
    if (taskDueDays < 0) {
      return 'Pend Task for Case : ' + relatedCaseNumber + ' is Overdue.';
    }
    return '';
  }
}
