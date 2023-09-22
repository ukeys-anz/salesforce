/**
 * @author cruzb
 * @since July 2023
 * @description UUIDLogEventActions handles actions related to `UUID_Log_Entry__c` records
 */
public with sharing class UUIDLogEventActions {
  /**
   * @param records List of UUID_Log_Event__e
   * @description Processes UUID log events and create UUID log entry
   */
  public static void processUUIDLogEvents(List<UUID_Log_Event__e> records) {
    if (Schema.SObjectType.UUID_Log_Entry__c.isCreateable()) {
      List<UUID_Log_Entry__c> uuidList = new List<UUID_Log_Entry__c>();
      for (UUID_Log_Event__e eventRecord : records) {
        uuidList.add(
          new UUID_Log_Entry__c(
            Hash_Payload__c = eventRecord.Hash_Payload__c,
            Reference_Id__c = eventRecord.Reference_Id__c,
            Status__c = eventRecord.Status__c,
            Type__c = eventRecord.Type__c,
            UUID__c = eventRecord.UUID__c
          )
        );
      }
      insert uuidList;
    }
  }
}
