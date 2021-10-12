/**
 * @author Olivier Saier
 * @since 03/2021
 * @description  ContentVersionTriggerHandler is the handler class for ContentVersion Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class ContentVersionTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public ContentVersionTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    for (ContentVersion record : (List<ContentVersion>) records) {
      CommonUtil.handleMasking(
        record,
        null,
        SObjectType.ContentVersion.FieldSets.IDR_Masked_Fields.getFields()
      );
      if (String.isBlank(record.UUID__c)) {
        record.UUID__c = CommonUtil.generateUUID();
      }
    }
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap Old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    for (ContentVersion record : (List<ContentVersion>) records) {
      ContentVersion oldRecord = (ContentVersion) oldMap.get(record.id);
      CommonUtil.handleMasking(
        record,
        oldRecord,
        SObjectType.ContentVersion.FieldSets.IDR_Masked_Fields.getFields()
      );
    }
  }
}
