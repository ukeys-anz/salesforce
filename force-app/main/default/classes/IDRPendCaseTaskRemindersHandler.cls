/**
 * @author Adnan
 * @since  09/2021
 * @description Handler class for IDRPendCaseTaskRemindersBatch and for creating and sending task notifications
 */
public with sharing class IDRPendCaseTaskRemindersHandler {
  /**
   * @description method for creating wrapper to send notifications
   * @param taskList list of task records that are used for creating wrapper
   * @return List<IDRBankerNotificationWrapper> returns the created wrapper
   */
  public static List<IDRBankerNotificationWrapper> createWrapper(
    List<Task> taskList
  ) {
    List<Id> caseIdList = new List<Id>();
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();

    List<String> windowForTaskReminders = Label.IDR_Window_For_Task_Reminders.split(
      ','
    );
    for (Task t : taskList) {
      caseIdList.add(t.WhatId);
    }
    Map<Id, Case> caseMap = IDRPendCaseTaskRemindersHelper.getCasesHelper(
      caseIdList
    );
    for (Task t : taskList) {
      Set<Id> recipientList = new Set<Id>();
      String msgBody;
      if (
        windowForTaskReminders.contains(
          String.valueOf(Integer.valueOf(t.Due_in_Days__c))
        )
      ) {
        recipientList.add(t.OwnerId);
        recipientList.add(caseMap.get(t.WhatId)?.OwnerId);
        if (Integer.valueOf(t.Due_in_Days__c) == 1) {
          recipientList.add(((User) caseMap.get(t.WhatId)?.Owner)?.ManagerId);
        }
        msgBody =
          'Pend Task for Case : ' +
          caseMap.get(t.WhatId)?.CaseNumber +
          ' is due in ' +
          Integer.valueOf(t.Due_in_Days__c) +
          ' Days.';
      } else if (t.Due_in_Days__c < 0) {
        recipientList.add(((User) caseMap.get(t.WhatId)?.Owner)?.ManagerId);
        msgBody =
          'Pend Task for Case : ' +
          caseMap.get(t.WhatId)?.CaseNumber +
          ' is Overdue.';
      }
      recipientList.remove(null);
      IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
        t,
        new List<Id>(recipientList),
        'Pend Case Task Reminder',
        msgBody,
        caseMap.get(t.WhatId)
      );
      wrapperList.add(wrapper);
    }
    return wrapperList;
  }
}
