/**
 * @description TaskTriggerHandler is the handler class for Task Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Shermal Warnakula, Boobalakrishnan Duraisamy
 * @since 03/2021
 */
public with sharing class TaskTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public TaskTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    IDRTaskActions.updateNotificationSubject(records);
    IDRTaskActions.beforeInsertActions(records);
    GetHelpTaskActions.beforeInsertActions(records);
    //Added for CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{
        CCRMConstants.CCRM_TASK_RT_ID,
        MLCRMConstants.MLCRM_TASK_RT_ID
      }
    );

    TextUtils.maskSObjectDataANZExtended(wrapperData.dcrmRecordList, 'Subject');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
  }
  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    IDRTaskActions.afterInsertActions(records);
  }
  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IDRTaskActions.updateNotificationSubject(records);
    IDRTaskActions.beforeUpdateActions(records, (Map<Id, Task>) oldMap);
    GetHelpTaskActions.beforeUpdateActions(records, (Map<Id, Task>) oldMap);
    //Added for CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{
        CCRMConstants.CCRM_TASK_RT_ID,
        MLCRMConstants.MLCRM_TASK_RT_ID
      }
    );

    TextUtils.maskSObjectDataANZExtended(wrapperData.dcrmRecordList, 'Subject');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
    GetHelpTaskActions.applyRedaction(records, (Map<Id, Task>) oldMap);
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    IDRTaskActions.afterUpdateActions(records);
    GetHelpTaskActions.checkAndPublishTaskCloudEvent(records, oldMap);

    // Make sure this line always execute as the last command of AfterUpdate
    CustomFieldHistoryAction.createFieldHistory(records, oldMap);
  }
  /**
   * @description onBeforeDelete to handle before delete trigger actions.
   */
  public override void onBeforeDelete() {
    IDRTaskActions.beforeDeleteActions(records);
  }
}
