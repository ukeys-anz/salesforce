public with sharing class IDRPendCaseTaskRemindersBatch implements Database.Batchable<sObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Date windowFromToday = Date.today()
      .addDays(Integer.valueOf(Label.IDR_Max_Window_For_Task_Reminders));
    return Database.getQueryLocator(
      'SELECT Id, ActivityDate, OwnerId, WhatId, Subject ' +
      //'TypeOf What WHEN Case THEN OwnerId END '+ //Polymorphic relatioship in batch query is not working, however it is working in normal SOQL and Database.query
      'FROM Task ' +
      'WHERE Type = \'Pend Case\' AND WhatId != null AND ActivityDate <=: windowFromToday AND Owner.Type = \'User\''
    );
  }

  public void execute(Database.BatchableContext bc, List<Task> taskScope) {
    IDRPendCaseTaskRemindersHandler.createWrapper(taskScope);
  }

  public void finish(Database.BatchableContext bc) {
  }
}
