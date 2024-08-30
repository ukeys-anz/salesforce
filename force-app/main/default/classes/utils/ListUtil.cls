/**
 * @author Tan Phan
 * @since 07/2024
 * @description Holds list-related utilities methods
 * @group Utils
 */
public inherited sharing class ListUtil {
  private static Map<DisplayType, Type> mapFieldType {
    get {
      return mapFieldType ??
        (mapFieldType = new Map<DisplayType, Type>{
          DisplayType.ID => Id.class,
          DisplayType.BOOLEAN => Boolean.class,
          DisplayType.INTEGER => Integer.class,
          DisplayType.DOUBLE => Double.class,
          DisplayType.LONG => Long.class,
          DisplayType.CURRENCY => Decimal.class,
          DisplayType.DATE => Date.class,
          DisplayType.TIME => Time.class,
          DisplayType.DATETIME => DateTime.class
        });
    }
    set;
  }

  /**
   * @description Returns a set of Ids extracted from a list of SObjects based on a specified field.
   * @param records The list of SObjects from which to extract the Ids.
   * @param field The field on the SObject to extract the Ids from.
   * @return `Set<Id>` A set of Ids extracted from the specified field of the SObjects.
   */
  public static Set<Id> getIds(List<SObject> records, SObjectField field) {
    return new Set<Id>((List<Id>) getValues(records, field, Id.class));
  }

  /**
   * @description Returns a set of string values extracted from a list of SObjects based on a specified field.
   * @param records The list of SObjects from which to extract the values.
   * @param field The field on the SObject to extract the values from.
   * @return `Set<String>` A set of values extracted from the specified field of the SObjects.
   */
  public static Set<String> getStrings(
    List<SObject> records,
    SObjectField field
  ) {
    return new Set<String>(
      (List<String>) getValues(records, field, String.class)
    );
  }

  /**
   * @description Retrieves the values of a specific field from a list of SObjects.
   * @param records The list of SObjects.
   * @param field The field to retrieve values from.
   * @return A list of values from the specified field.
   */
  public static List<Object> getValues(
    List<SObject> records,
    SObjectField field
  ) {
    return getValues(records, field, getPrimitiveType(field));
  }

  /**
   * @description Retrieves the values of a specific field from a list of SObjects.
   * @param records The list of SObjects.
   * @param field The field to retrieve values from.
   * @param dataType The primitive data type of the field.
   *  - If set to String, non-string values are converted to String
   *  - If set to non-string, and the field is not of the specified type, exception will be thrown
   * @return A list of values from the specified field.
   */
  public static List<Object> getValues(
    List<SObject> records,
    SObjectField field,
    Type dataType
  ) {
    List<Object> values = (List<Object>) Type.forName('List<' + dataType + '>')
      .newInstance();
    Type stringType = String.class;
    for (SObject record : records) {
      Object value = record.get(field);
      String valueString = String.valueOf(value);
      if (String.isBlank(valueString)) {
        continue;
      }
      if (dataType == stringType) {
        value = valueString;
      }
      values.add(value);
    }
    return values;
  }

  /**
   * @description Returns the primitive data type of the given SObject field.
   * @param field The SObject field for which to determine the primitive type.
   * @return The primitive type of the field.
   */
  @TestVisible
  private static Type getPrimitiveType(SObjectField field) {
    DescribeFieldResult fieldInfo = field.getDescribe();
    if (!fieldInfo.getReferenceTo().isEmpty()) {
      return Id.class;
    }
    return mapFieldType.get(fieldInfo.Type) ?? String.class;
  }

  /**
   * @description Build a map of records with specified ID field as key (lookup, master-detail etc.) .
   *   - If multiple record have the same field value, only last one will be included in the map.
   * @param records The list of SObjects from which to retrieve the records.
   * @param field The field used to create the map.
   * @return `Map<Id, SObject>` A map of records with the specified field as the key and the record as the value.
   */
  public static Map<Id, SObject> mapById(
    List<SObject> records,
    SObjectField field
  ) {
    Map<Id, SObject> recordMap = (Map<Id, SObject>) Type.forName(
        'Map<Id,' + records.getSObjectType() + '>'
      )
      .newInstance();
    for (SObject record : records) {
      Id value = (Id) record.get(field);
      if (value != null) {
        recordMap.put(value, record);
      }
    }
    return recordMap;
  }

  /**
   * @description Build a map of records with specified string field as key (other field types are converted to string) .
   *   - If multiple record have the same field value, only last one will be included in the map.
   * @param records The list of SObjects from which to retrieve the records.
   * @param field The field used to create the map.
   * @return `Map<String, SObject>` A map of records with the specified field as the key and the record as the value.
   */
  public static Map<String, SObject> mapByString(
    List<SObject> records,
    SObjectField field
  ) {
    Map<String, SObject> recordMap = (Map<String, SObject>) Type.forName(
        'Map<String,' + records.getSObjectType() + '>'
      )
      .newInstance();
    for (SObject record : records) {
      String value = String.valueOf(record.get(field));
      if (value != null) {
        recordMap.put(value, record);
      }
    }
    return recordMap;
  }

  /**
   * @description Filters out SObjects with errors from a given list of SObjects.
   * @param records The list of SObjects to filter.
   * @return A new list containing only the SObjects without errors.
   */
  public static List<SObject> filterNoError(List<SObject> records) {
    List<SObject> validRecords = (List<SObject>) Type.forName(
        'List<' + records.getSObjectType() + '>'
      )
      .newInstance();
    for (SObject record : records) {
      if (record.hasErrors() == false) {
        validRecords.add(record);
      }
    }
    return validRecords;
  }
}
