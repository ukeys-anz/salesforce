/**
 * @author Peter Charalambous
 * @since Mon Apr 15 2024
 * @description class to handle all settlement related task actions
 */

public with sharing class SettlementTaskActions {
  public static final Id SETTLEMENT_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Settlement_Task')
    .getRecordTypeId();

  /**
   * @description populate record id and fields if is settlement related task
   * @param records List of Task records
   */
  public static void handleSettlementTasks(List<Task> records) {
    for (Task record : records) {
      record.RecordTypeId = SETTLEMENT_TASK_RT_ID;
    }
  }

  /**
   * @description checks if specific field was changed and applies masking if required
   * @param records task record list.
   * @param oldMap The old map of task records.
   */
  public static void applyRedaction(List<Task> records, Map<Id, Task> oldMap) {
    for (Task record : records) {
      if (
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
}
