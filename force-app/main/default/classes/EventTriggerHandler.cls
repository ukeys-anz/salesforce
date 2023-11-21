/**
 * @description EventTriggerHandler is the handler class for Event Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Shivraj Kadam
 * @since 09/2023
 */
public with sharing class EventTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public EventTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    //Added for CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{ MLCRMConstants.ML_EVENT_RT_ID }
    );

    TextUtils.maskSObjectDataANZExtended(wrapperData.dcrmRecordList, 'Subject');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Location'
    );
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //Added for CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{ MLCRMConstants.ML_EVENT_RT_ID }
    );

    TextUtils.maskSObjectDataANZExtended(wrapperData.dcrmRecordList, 'Subject');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Location'
    );
  }
}
