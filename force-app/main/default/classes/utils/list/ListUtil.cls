/**
 * @author Tan Phan
 * @since 07/2024
 * @description Holds list-related utilities methods
 * @group Utils
 */
public inherited sharing class ListUtil {
  private static final Type TYPE_STRING = String.class;
  private static final Map<SoapType, Type> MAP_FIELD_TYPE = new Map<SoapType, Type>{
    SoapType.ID => Id.class,
    SoapType.INTEGER => Integer.class,
    SoapType.BOOLEAN => Boolean.class,
    SoapType.DATE => Date.class,
    SoapType.DATETIME => Datetime.class,
    SoapType.DOUBLE => Decimal.class,
    SoapType.STRING => String.class,
    SoapType.TIME => Time.class
  };

  //#region HELPERS
  /**
   * @description Converts an object or an iterable collection of objects into a set.
   *  - If the input value is not iterable, it will be added as a single element to the set.
   *  - If the input value is iterable, each element will be added to the set.
   * @param value The object or iterable collection of objects to convert to a set. Can be any `primitive` type, `List`, or `Set`.
   * @return A set containing the elements from the input value.
   */
  public static Set<Object> toSet(Object value) {
    if (value == null || (value instanceof Iterable<Object>) == false) {
      return new Set<Object>{ value };
    }
    Set<Object> values = new Set<Object>();
    for (Object val : (Iterable<Object>) value) {
      values.add(val);
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
    SoapType fieldType = field.getDescribe().SoapType;
    if (MAP_FIELD_TYPE.containsKey(fieldType)) {
      return MAP_FIELD_TYPE.get(fieldType);
    }
    throw new IllegalArgumentException('Unsupported field type: ' + fieldType);
  }
  //#endregion

  //#region FIELD SELECTORS
  /**
   * @description Returns a set of Ids extracted from a list of SObjects based on a specified field.
   * @param records The list of SObjects from which to extract the Ids.
   * @param field The field on the SObject to extract the Ids from.
   * @return `Set<Id>` A set of Ids extracted from the specified field of the SObjects.
   */
  public static Set<Id> getIds(List<SObject> records, SObjectField field) {
    return (Set<Id>) getUniques(records, field.toString(), Id.class);
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
    return (Set<String>) getUniques(records, field.toString(), String.class);
  }

  /**
   * @description Returns a Set of unique values from the given records based on the specified field and field type.
   * @param records The list of records.
   * @param field The field to get unique values from.
   * @return `Set<T>` A Set of unique values.
   */
  public static Object getUniques(List<SObject> records, SObjectField field) {
    return getUniques(records, field.toString(), getPrimitiveType(field));
  }

  /**
   * @description Returns a list of unique values from the given records based on the specified field and field type.
   * @param records The list of records.
   * @param field The field to get unique values from.
   * @param fieldType The type of the field.
   * @return `Set<T>` A list of unique values.
   */
  public static Object getUniques(
    List<Object> records,
    String field,
    Type fieldType
  ) {
    return mapByGeneric(records, field, fieldType).keySet();
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
    return getValues(records, field.toString(), getPrimitiveType(field));
  }

  /**
   * @description Retrieves the values of a specific field from a list of GenericObject.
   * @param records The list of GenericObject.
   * @param field The field to retrieve values from.
   * @param fieldType The primitive data type of the field.
   *  - If set to String, non-string values are converted to String
   *  - If set to non-string, and the field is not of the specified type, exception will be thrown
   * @return A list of values from the specified field.
   */
  public static List<Object> getValues(
    List<Object> records,
    String field,
    Type fieldType
  ) {
    ObjectHandler handler = ObjectHandler.of(records);
    List<Object> values = (List<Object>) Type.forName('List<' + fieldType + '>')
      .newInstance();
    for (Object record : records) {
      Object value = handler.get(record, field);
      if (value != null) {
        values.add(value);
      }
    }
    return values;
  }
  //#endregion

  //#region MAP BY FIELD
  /**
   * @description Maps the given records based on the specified field and field type.
   * @param records The list of records.
   * @param field The field to map by.
   * @return `Map<T, Object>` A map of records mapped by the field value.
   * @usage Map<Id, Case> accountIdToCase = (Map<Id, Case) mapBy(cases, Case.AccountId);
   */
  public static Object mapBy(List<SObject> records, SObjectField field) {
    return mapBy(records, field.toString(), getPrimitiveType(field));
  }

  /**
   * @description Maps the given records based on the specified field and field type.
   * @param records The list of records.
   * @param field The field to map by.
   * @param fieldType The type of the field.
   * @return `Map<T, Object>` A map of records mapped by the field value.
   */
  public static Object mapBy(
    List<Object> records,
    String field,
    Type fieldType
  ) {
    return mapByGeneric(records, field, fieldType).toMap();
  }

  private static GenericMap mapByGeneric(
    List<Object> records,
    String field,
    Type fieldType
  ) {
    ObjectHandler handler = ObjectHandler.of(records);
    GenericMap output = GenericMap.of(fieldType, handler.itemType);
    for (Object record : records) {
      Object key = handler.get(record, field);
      if (key != null) {
        output.put(key, record);
      }
    }
    return output;
  }
  //#endregion

  //#region GROUP BY
  /**
   * @description Groups the given records based on the specified field and field type.
   * @param records The list of records.
   * @param field The field to group by.
   * @return `Map<T, List<Object>>` A map of records grouped by the field value.
   * @usage Map<Id, List<Case>> accountIdToCases = (Map<Id, List<Case>>) groupBy(cases, Case.AccountId);
   */
  public static Object groupBy(List<SObject> records, SObjectField field) {
    return groupBy(records, field.toString(), getPrimitiveType(field));
  }

  /**
   * @description Groups the given records based on the specified field and field type.
   * @param records The list of records.
   * @param field The field to group by.
   * @param fieldType The type of the field.
   * @return `Map<T, List<Object>>` A map of records grouped by the field value.
   */
  public static Object groupBy(
    List<Object> records,
    String field,
    Type fieldType
  ) {
    ObjectHandler handler = ObjectHandler.of(records);
    GenericMap output = GenericMap.of(
      fieldType,
      Type.forName('List<' + handler.itemType + '>')
    );
    for (Object record : records) {
      Object key = handler.get(record, field);
      if (key == null) {
        continue;
      }
      if (output.containsKey(key) == false) {
        output.put(key, handler.emptyList);
      }
      ((List<Object>) output.get(key)).add(record);
    }
    return output.toMap();
  }
  //#endregion

  //#region FILTERS
  /**
   * @description Creates a FilterBuilder instance to build filters for a list of GenericObject records.
   * @param records The list of GenericObject records to filter.
   * @return A FilterBuilder instance.
   */
  public static GenericFilterBuilder filter(List<GenericObject> records) {
    return new GenericFilterBuilder(records);
  }

  /**
   * @description Constructs a new FilterBuilder object with the given list of records.
   * @param records The list of SObjects to be filtered.
   * @return A new FilterBuilder instance.
   */
  public static SObjectFilterBuilder filter(List<SObject> records) {
    return filter(records, null);
  }

  /**
   * @description Constructs a new FilterBuilder object with the given list of records and old map.
   * @param records The list of SObjects to be filtered.
   * @param oldMap The map of old SObjects.
   * @return A new FilterBuilder instance.
   */
  public static SObjectFilterBuilder filter(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    return new SObjectFilterBuilder(new GenericFilterBuilder(records), oldMap);
  }
  //#endregion

  /**
   * @description Sets the value of a field for a list of SObjects.
   * @param records The list of SObjects.
   * @param field The field to set.
   * @param value The value to set the field to.
   * @return The updated list of SObjects.
   */
  public static List<SObject> setField(
    List<SObject> records,
    SObjectField field,
    Object value
  ) {
    for (SObject record : records) {
      record.put(field, value);
    }
    return records;
  }

  /**
   * @description Sets the value of multiple fields for a list of SObjects.
   * @param records The list of SObjects.
   * @param fields The set of fields to set.
   * @param value The value to set the fields to.
   * @return The updated list of SObjects.
   */
  public static List<SObject> setField(
    List<SObject> records,
    Set<SObjectField> fields,
    Object value
  ) {
    for (SObjectField field : fields) {
      setField(records, field, value);
    }
    return records;
  }

  /**
   * @description Sets the value of fields based on a map of field-value pairs for a list of SObjects.
   * @param records The list of SObjects.
   * @param mapValues The map of field-value pairs.
   * @return The updated list of SObjects.
   */
  public static List<SObject> setField(
    List<SObject> records,
    Map<SObjectField, Object> mapValues
  ) {
    for (SObjectField field : mapValues.keySet()) {
      setField(records, field, mapValues.get(field));
    }
    return records;
  }

  /**
   * @description Sets the value of a field for a list of SObjects if the field is null.
   * @param records The list of SObjects.
   * @param field The field to set.
   * @param value The value to set the field to.
   * @return The updated list of SObjects.
   */
  public static List<SObject> setFieldIfNull(
    List<SObject> records,
    SObjectField field,
    Object value
  ) {
    for (SObject record : records) {
      if (record.get(field) == null) {
        record.put(field, value);
      }
    }
    return records;
  }

  /**
   * @description Sets the value of multiple fields for a list of SObjects if the fields are null.
   * @param records The list of SObjects.
   * @param fields The set of fields to set.
   * @param value The value to set the fields to.
   * @return The updated list of SObjects.
   */
  public static List<SObject> setFieldIfNull(
    List<SObject> records,
    Set<SObjectField> fields,
    Object value
  ) {
    for (SObjectField field : fields) {
      setFieldIfNull(records, field, value);
    }
    return records;
  }

  /**
   * @description Sets the value of fields based on a map of field-value pairs for a list of SObjects if the fields are null.
   * @param records The list of SObjects.
   * @param mapValues The map of field-value pairs.
   * @return The updated list of SObjects.
   */
  public static List<SObject> setFieldIfNull(
    List<SObject> records,
    Map<SObjectField, Object> mapValues
  ) {
    for (SObjectField field : mapValues.keySet()) {
      setFieldIfNull(records, field, mapValues.get(field));
    }
    return records;
  }
}
