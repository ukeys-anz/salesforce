/**
 * @author Nagendra Singh
 * @since  March 2024
 * @description This class is to provide methods for comparing old and new records.
 * @group Utils
 */
public class RecordComparisonUtil {
  /**
   * @description Checks if all specified fields have changed between the old and new records.
   *
   * @param newRecord The updated record.
   * @param oldRecord The original record before updates.
   * @param fields    The set of fields to check for changes.
   * @return Boolean  True if all fields were changed; otherwise, false.
   */
  public static Boolean allFieldsWereChanged(
    SObject newRecord,
    SObject oldRecord,
    Set<SObjectField> fields
  ) {
    for (SObjectField field : fields) {
      if (newRecord.get(field) == oldRecord.get(field)) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description Checks if all specified fields have changed between the old and new records
   * and are not null in the new record.
   *
   * @param newRecord The updated record.
   * @param oldRecord The original record before updates.
   * @param fields    The set of fields to check for changes and not null values.
   * @return Boolean  True if all fields were changed and not null; otherwise, false.
   */
  public static Boolean allFieldsWereChangedAndNotEqualNull(
    SObject newRecord,
    SObject oldRecord,
    Set<SObjectField> fields
  ) {
    for (SObjectField field : fields) {
      if (
        newRecord.get(field) == oldRecord.get(field) &&
        newRecord.get(field) != null
      ) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description Checks if at least one of the specified fields has changed between the old
   * and new records.
   *
   * @param newRecord The updated record.
   * @param oldRecord The original record before updates.
   * @param fields    The set of fields to check for any change.
   * @return Boolean  True if at least one field was changed; otherwise, false.
   */
  public static Boolean atLeastOneFieldWasChanged(
    SObject newRecord,
    SObject oldRecord,
    Set<SObjectField> fields
  ) {
    for (SObjectField field : fields) {
      if (newRecord.get(field) != oldRecord.get(field)) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description Checks if at least one of the specified fields has changed between the old
   * and new records and is not null in the new record.
   *
   * @param newRecord The updated record.
   * @param oldRecord The original record before updates.
   * @param fields    The set of fields to check for changes and not null values.
   * @return Boolean  True if at least one field was changed and is not null; otherwise, false.
   */
  public static Boolean atLeastOneFieldWasChangedAndNotEqualNull(
    SObject newRecord,
    SObject oldRecord,
    Set<SObjectField> fields
  ) {
    for (SObjectField field : fields) {
      if (
        newRecord.get(field) != oldRecord.get(field) &&
        newRecord.get(field) != null
      ) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description Checks if a specific field has changed between the old and new records.
   *
   * @param newRecord The updated record.
   * @param oldRecord The original record before updates.
   * @param field     The field to check for a change.
   * @return Boolean  True if the field was changed; otherwise, false.
   */
  public static Boolean fieldWasChanged(
    SObject newRecord,
    SObject oldRecord,
    SObjectField field
  ) {
    return newRecord.get(field) != oldRecord.get(field);
  }

  /**
   * @description Checks if a specific field has changed between the old and new records
   * and is not null in the new record.
   *
   * @param newRecord The updated record.
   * @param oldRecord The original record before updates.
   * @param field     The field to check for a change and not null value.
   * @return Boolean  True if the field was changed and is not null; otherwise, false.
   */
  public static Boolean fieldWasChangedAndNotEqualNull(
    SObject newRecord,
    SObject oldRecord,
    SObjectField field
  ) {
    return newRecord.get(field) != oldRecord.get(field) &&
      newRecord.get(field) != null;
  }

  /**
   * @description Checks if two fields contains the same value or not
   *
   * @param record The updated record.
   * @param field  Field
   * @param fieldToCompareWith  Field to compare
   * @param obj  Sobject name of field
   * @return Boolean  True if the fields contain the same value otherwise, false.
   */
  public static Boolean picklistContainSameValue(
    SObject record,
    SObjectField field,
    SObjectField fieldToCompareWith,
    SObjectType obj
  ) {
    String fieldName = String.valueOf(field);
    DescribeSObjectResult objResult = obj.getDescribe();
    Schema.DisplayType dataType = objResult.fields
      .getMap()
      .get(fieldName)
      .getDescribe()
      .getType();

    if (String.valueOf(dataType) == 'MULTIPICKLIST') {
      return String.isNotEmpty(String.valueOf(record.get(field))) &&
        String.valueOf(record.get(field))
          .contains(String.valueOf(record.get(fieldToCompareWith)));
    }
    return false;
  }
  /**
   * @description Checks if a specific field from the provided set of fields has changed between the old and new records
   * and is not null in the new record.
   *
   * @param newRecord The updated record.
   * @param oldRecord The original record before updates.
   * @param fields    Set of fields which we need to check for a change and not null value.
   * @return field    return the field that was changed and is not null; otherwise, null.
   */
  public static List<SObjectField> detectWhichFieldWasChangedAndNotEqualNull(
    SObject newRecord,
    SObject oldRecord,
    Set<SObjectField> fields
  ) {
    List<SObjectField> changedFields = new List<SObjectField>();
    for (SObjectField field : fields) {
      if (fieldWasChangedAndNotEqualNull(newRecord, oldRecord, field)) {
        changedFields.add(field);
      }
    }
    return changedFields;
  }

  /**
   * @description This method returns the list of SObject records for which any of the mentioned field is modified.
   *
   * @param newRecords The updated record.
   * @param oldRecords The original record before updates.
   * @param fieldsToMonitor Set of fields which we need to check for a change and not null value.
   * @return returns the list of sobject records for which fields are changes
   */
  public static List<SObject> getRecordsWithChangedFields(
    List<SObject> newRecords,
    Map<Id, SObject> oldRecords,
    Set<Schema.SObjectField> fieldsToMonitor
  ) {
    List<SObject> changedRecords = new List<SObject>();

    for (SObject record : newRecords) {
      SObject oldRecord = oldRecords.get(record.Id);

      if (oldRecord != null) {
        for (Schema.SObjectField field : fieldsToMonitor) {
          if (record.get(field) != oldRecord.get(field)) {
            changedRecords.add(record);
            break;
          }
        }
      }
    }
    return changedRecords;
  }
}
