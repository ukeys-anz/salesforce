/**
 * @author cruzb
 * @since July 2023
 * @description creates `UUID_Log__Entry__c`
 * @group handler
 */
public with sharing class UUIDLogEventTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public UUIDLogEventTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to create the records
   */
  public override void onAfterInsert() {
    UUIDLogEventActions.processUUIDLogEvents((List<UUID_Log_Event__e>) records);
  }
}
