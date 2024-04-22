/**
 * @author Peter Charalambous
 * @since Mon Apr 15 2024
 * @description class to handle all settlement related task actions
 */

public with sharing class SettlementTaskActions {
  @TestVisible
  public static final Id SETTLEMENT_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Settlement_Task')
    .getRecordTypeId();

  /**
   * @description populate record id and fields if is settlement related task
   * @param records List of Task records
   */
  public static void handleSettlementTasks(List<Task> records) {
    for (Task record : records) {
      if (isRelatedToSettlement(record)) {
        record.RecordTypeId = SETTLEMENT_TASK_RT_ID;
      }
    }
  }

  /**
   * @description checks if the Task is related to a Settlement via WhatId
   * @param record Task record
   * @return `Boolean`
   */
  private static Boolean isRelatedToSettlement(Task record) {
    if (record.WhatId != null) {
      return ('Settlement__c'
        .equalsIgnoreCase(
          record.WhatId.getSobjectType().getDescribe().getName()
        ));
    }
    return false;
  }
}
