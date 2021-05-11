/**
 * @author Shermal Warnakula
 * @since Feb 2021
 * @description Holds common util functions
 * @group Utils
 */
public with sharing class CommonUtil {
  /**
   * @description Get a picklist labels by values (API names).
   * @param field The picklist field, for example Case.Type
   * @return a map of picklist labels by values (example '11':'Other')
   */
  @TestVisible
  public static Map<String, String> getPicklistLabelsByValues(
    Schema.SobjectField field
  ) {
    Map<String, String> labelsByValues = new Map<String, String>();
    Schema.DescribeFieldResult fieldPicklist = field.getDescribe();
    Map<String, String> fieldMap = new Map<String, String>();
    for (Schema.PicklistEntry f : fieldPicklist.getPicklistValues()) {
      labelsByValues.put(f.getValue(), f.getLabel());
    }
    return labelsByValues;
  }

  /**
   * @description Get all the business hours
   * @return list of business hours
   */
  public static BusinessHours getBusinessHours() {
    if (BusinessHours.sObjectType.getDescribe().isQueryable()) {
      BusinessHours bh = [
        SELECT Id
        FROM BusinessHours
        WHERE Name = 'ANZx Case Business Hours'
        LIMIT 1
      ];
      return bh;
    }
    return null;
  }

  /**
   * @description getAvailableRecordTypeNamesForSObject(input) method is used to get available record types for a certain sobject.
   * This method will only return the record types that are available to the current user
   * @param sObjectTypeName the API name of the object whose record types we want to retrieve
   * @return Set<Id> list of record type Ids that are available to this user on this object.
   */
  @AuraEnabled
  public static List<Id> getAvailableRecordTypeIdsForSObject(
    String sObjectTypeName
  ) {
    Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectTypeName);
    List<Id> recordTypeIds = new List<Id>();
    for (RecordTypeInfo rti : sObj.getDescribe().getRecordTypeInfos()) {
      if (
        rti.isAvailable() && // Ignore the Master Record Type, whose Id always ends with 'AAA'.
        // We check the Id because Name can change depending on the user's language.
        !String.valueOf(rti.getRecordTypeId()).endsWith('AAA')
      ) {
        recordTypeIds.add(rti.getRecordTypeId());
      }
    }
    return recordTypeIds;
  }

  /**
   * @description Get a picklist label from it's value (API_Key).
   * This function differs from the `getPicklistLabelsByValues` as it returns
   * a single picklist value, not a map.
   * @param field The picklist field, for example Case.Type
   * @param picklistValue The picklist value, for example '2'
   * @return the picklist label, for example 'Advice'
   */
  @TestVisible
  public static String getSinglePicklistLabel(
    Schema.SobjectField field,
    String picklistValue
  ) {
    Schema.DescribeFieldResult fieldPicklist = field.getDescribe();
    Map<String, String> fieldMap = new Map<String, String>();
    for (Schema.PicklistEntry f : fieldPicklist.getPicklistValues()) {
      if (f.getValue() == picklistValue) {
        return f.getLabel();
      }
    }
    return '';
  }

  /**
   * @description handleMasking method is used to mask free text fields as we dont want to store e.g. card numbers in SF.
   * So, we mask the number and store only last 4 digits unmasked.
   * @param record The actual record from Trigger.new
   * @param oldRecord The actual record from Trigger.old, null if in a before insert trigger
   * @param fieldsToMask a list of fields from a field set, storing the data to be masked
   */
  public static void handleMasking(
    sObject record,
    sObject oldRecord,
    Schema.FieldSetMember[] fieldsToMask
  ) {
    for (Schema.FieldSetMember fsm : fieldsToMask) {
      String fieldName = fsm.getFieldPath();
      //System.debug(fieldName + ': ' + String.valueOf(fsm.getType()));
      if (
        (String.valueOf(fsm.getType()) == 'STRING' ||
        String.valueOf(fsm.getType()) == 'COMBOBOX' ||
        String.valueOf(fsm.getType()) == 'TEXTAREA') &&
        (oldRecord == null ||
        String.valueOf(record.get(fieldName)) !=
        String.valueOf(oldRecord.get(fieldName)))
      ) {
        record.put(
          fieldName,
          TextUtils.maskData((String) record.get(fieldName))
        );
      }
    }
  }
}
