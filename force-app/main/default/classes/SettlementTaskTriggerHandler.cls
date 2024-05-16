/**
 * @author Peter Charalambous
 * @since Tue May 07 2024
 * @description trigger handler class for settlement related tasks
 */
public with sharing class SettlementTaskTriggerHandler extends Lib_TriggerHandler {
  Set<Id> recordTypeIdSet = new Set<Id>{
    SObjectType.Task.getRecordTypeInfosByDeveloperName()
      .get('Settlement_Task')
      .recordTypeId
  };

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public SettlementTaskTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    SettlementTaskActions.handleSettlementTasks(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    SettlementTaskActions.applyRedaction(records, (Map<Id, Task>) oldMap);
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Settlement records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Task settlementTask = (Task) record;
    if (settlementTask.recordTypeId == null && settlementTask.WhatId == null) {
      return false;
    }
    if (settlementTask.recordTypeId == null) {
      return ('Settlement__c'
        .equalsIgnoreCase(
          settlementTask.WhatId.getSobjectType().getDescribe().getName()
        ));
    }
    return recordTypeIdSet.contains(settlementTask.RecordTypeId);
  }
}
