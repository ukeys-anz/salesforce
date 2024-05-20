/**
 * @description Custom Field History Actions
 * @author Arpit Pittie
 * @since 12-04-2024
 * */
public with sharing class CustomFieldHistoryAction {
  /**
   * @description To check if the field history needs to be created or not and then publish the event to create field history
   * @param newList List of records with new value
   * @param oldMap Map of records with old value
   */
  public static void createFieldHistory(
    List<SObject> newList,
    Map<Id, SObject> oldMap
  ) {
    SObjectType objectType = newList.get(0).getSObjectType();
    String objectName = objectType.getDescribe().getName();

    Custom_Dynamic_Object_History_Setting__mdt historyObject = CustomFieldHistoryActionHelper.getObjectHistoryMetadata(
      objectName
    );
    if (historyObject == null) {
      return;
    }

    List<Custom_Dynamic_Field_History_Setting__mdt> fieldHistory = CustomFieldHistoryActionHelper.getFieldHistoryMetadata(
      historyObject
    );
    if (fieldHistory.isEmpty()) {
      return;
    }

    List<SObject> fieldHistoryToInsertList = CustomFieldHistoryActionHelper.processCustomFieldHistory(
      newList,
      oldMap,
      objectType,
      historyObject,
      fieldHistory
    );

    DMLUtil.insertRecords(
      fieldHistoryToInsertList,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
  }
}
