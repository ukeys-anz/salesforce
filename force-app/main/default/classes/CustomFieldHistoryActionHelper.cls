/**
 * @description Custom Field History Actions Helper methods
 * @author Arpit Pittie
 * @since 12-04-2024
 * */
public with sharing class CustomFieldHistoryActionHelper {
  private static final String ID_FIELD = 'Id';
  private static final String NEW_VALUE_FIELD = 'New_Value__c';
  private static final String OLD_VALUE_FIELD = 'Old_Value__c';
  private static final String RECORD_ID_FIELD = 'Record_Id__c';
  private static final String FIELD_NAME_FIELD = 'Field_Name__c';
  private static final String OWNERID_FIELD = 'OwnerId';

  /**
   * @description To get the Custom Object History metadata for the given object
   * @param objectName Object Name whose Object History metadata is required
   * @return Custom_Dynamic_Object_History_Setting__mdt record
   */
  public static Custom_Dynamic_Object_History_Setting__mdt getObjectHistoryMetadata(
    String objectName
  ) {
    return Custom_Dynamic_Object_History_Setting__mdt.getInstance(objectName);
  }

  /**
   * @description To get the Custom Field History metadata for the given object metadata
   * @param objectMetadata Custom Object Metadata whose Field History metadata is required
   * @return List<Custom_Dynamic_Field_History_Setting__mdt> list of Custom_Dynamic_Field_History_Setting__mdt records
   */
  public static List<Custom_Dynamic_Field_History_Setting__mdt> getFieldHistoryMetadata(
    Custom_Dynamic_Object_History_Setting__mdt objectMetadata
  ) {
    return [
      SELECT Id, Field_Name__c
      FROM Custom_Dynamic_Field_History_Setting__mdt
      WHERE SObject_Name__c = :objectMetadata.Id
    ];
  }

  /**
   * @description To check if a custom field history is to be created or not for the given record and the fields
   * @param newList List of records with new value
   * @param oldMap Map of records with old value
   * @param objectType SObjectType whose records needs to be checked for Field History
   * @param objectHistory Custom Object History Metadata settings for tracking object history
   * @param fieldHistory Custom Field History Metadata settings for tracking field history for the given object
   * @return List<CustomFieldHistoryEvent__e> List of all the platform event where custom field history needs to be created
   */
  public static List<SObject> processCustomFieldHistory(
    List<SObject> newList,
    Map<Id, SObject> oldMap,
    SObjectType objectType,
    Custom_Dynamic_Object_History_Setting__mdt objectHistory,
    List<Custom_Dynamic_Field_History_Setting__mdt> fieldHistory
  ) {
    List<SObject> fieldHistoryList = new List<SObject>();
    String objectName = objectType.getDescribe().getName();

    for (SObject obj : newList) {
      SObject oldValue = oldMap.get(obj.Id);

      for (
        Custom_Dynamic_Field_History_Setting__mdt fieldValue : fieldHistory
      ) {
        SObjectField objectField = objectType.getDescribe()
          .fields.getMap()
          .get(fieldValue.Field_Name__c);

        if (RecordComparisonUtil.fieldWasChanged(obj, oldValue, objectField)) {
          fieldHistoryList.add(
            createCustomHistoryEvent(
              obj,
              oldValue,
              objectField,
              objectHistory.Table_Name__c
            )
          );
        }
      }
    }
    return fieldHistoryList;
  }

  /**
   * @description To create a platform event to publish for the Custom Field History
   * @param newValue New Value of the record
   * @param oldValue Old Value of the record
   * @param objectField Field details whose history is being tracked
   * @param objectName SObject Name where history needs to be inserted
   * @return SObject Custom Field Hisotry object instance based on objectName
   */
  public static SObject createCustomHistoryEvent(
    SObject newValue,
    SObject oldValue,
    SObjectField objectField,
    String objectName
  ) {
    SObjectField idField = newValue.getSObjectType()
      .getDescribe()
      .fields.getMap()
      .get(ID_FIELD);

    SObject fieldHistoryRecord = Schema.getGlobalDescribe()
      .get(objectName)
      .newSObject();
    fieldHistoryRecord.put(
      NEW_VALUE_FIELD,
      String.valueOf(newValue.get(objectField))
    );
    fieldHistoryRecord.put(
      OLD_VALUE_FIELD,
      String.valueOf(oldValue.get(objectField))
    );
    fieldHistoryRecord.put(
      RECORD_ID_FIELD,
      String.valueOf(newValue.get(idField))
    );
    fieldHistoryRecord.put(
      FIELD_NAME_FIELD,
      objectField.getDescribe().getName()
    );
    fieldHistoryRecord.put(OWNERID_FIELD, UserInfo.getUserId());

    return fieldHistoryRecord;
  }
}
