/**
 * @author Tan Phan
 * @since 07/2024
 * @description Holds list-related utilities methods
 * @group Utils
 */
public inherited sharing class ListUtil {
  //#region HELPERS
  private static Map<DisplayType, Type> mapFieldType {
    get {
      return mapFieldType ??
        (mapFieldType = new Map<DisplayType, Type>{
          DisplayType.ID => Id.class,
          DisplayType.REFERENCE => Id.class,
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
   * @description Returns the primitive data type of the given SObject field.
   * @param field The SObject field for which to determine the primitive type.
   * @return The primitive type of the field.
   */
  @TestVisible
  private static Type getPrimitiveType(SObjectField field) {
    return mapFieldType.get(field.getDescribe().Type) ?? String.class;
  }

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
   * @description Creates a new list of the same SObject type as the input list.
   * @param records The input list of SObjects.
   * @return A new list of the same SObject type as the input list.
   */
  private static List<SObject> createListOfSameType(List<SObject> records) {
    return (List<SObject>) Type.forName(
        'List<' + records.getSObjectType() + '>'
      )
      .newInstance();
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
  private static List<Object> getValues(
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
  //#endregion

  //#region MAP BY FIELD
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
  //#endregion

  //#region FILTERS
  /**
   * @description Constructs a new FilterBuilder object with the given list of records.
   * @param records The list of SObjects to be filtered.
   * @return A new FilterBuilder instance.
   */
  public static FilterBuilder filter(List<SObject> records) {
    return filter(records, null);
  }

  /**
   * @description Constructs a new FilterBuilder object with the given list of records and old map.
   * @param records The list of SObjects to be filtered.
   * @param oldMap The map of old SObjects.
   * @return A new FilterBuilder instance.
   */
  public static FilterBuilder filter(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    FilterBuilder builder = new FilterBuilder();
    builder.records = records ?? new List<SObject>();
    builder.oldMap = oldMap ?? new Map<Id, SObject>();
    return builder;
  }

  /**
   * @description A utility class for filtering lists of SObjects.
   */
  public class FilterBuilder {
    private List<SObject> records;
    private Map<Id, SObject> oldMap;

    private FilterBuilder() {
    }

    /**
     * @description Return the internal list of records.
     * @return A List<SObject> containing the records.
     */
    public List<SObject> toList() {
      return this.records;
    }

    /**
     * @description Filter records with no DML errors.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder noError() {
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        if (record.hasErrors() == false) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with specified field value contains a given string as sub-string.
     * @param field The field to filter on.
     * @param subString The value to filter for.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder contains(SObjectField field, String subString) {
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        String fieldValue = String.valueOf(record.get(field));
        if (fieldValue?.contains(subString) == true) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description FilterBuilder records with specified field changed.
     * @param field The field to check for changes.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder changed(SObjectField field) {
      if (this.oldMap.isEmpty()) {
        return this;
      }
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        SObject oldRecord = this.oldMap.get(record.Id);
        if (oldRecord == null || record.get(field) != oldRecord.get(field)) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with specified field updated to a given value or list/set of values
     * @param field The field to filter on.
     * @param valueOrCollection The value(s) to filter for. Can be any `primitive` type, `List`, or `Set`.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder changedTo(
      SObjectField field,
      Object valueOrCollection
    ) {
      if (this.oldMap.isEmpty()) {
        return this;
      }
      Set<Object> newValues = toSet(valueOrCollection);
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        Object fieldValue = record.get(field);
        if (
          newValues.contains(fieldValue) &&
          this.oldMap.get(record.Id)?.get(field) != fieldValue
        ) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with specified field value equals to a given value or list/set of values
     * @param field The field to filter on.
     * @param valueOrCollection The value(s) to filter for. Can be any `primitive` type, `List`, or `Set`.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder equals(SObjectField field, Object valueOrCollection) {
      Set<Object> newValues = toSet(valueOrCollection);
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        Object fieldValue = record.get(field);
        if (newValues.contains(fieldValue)) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with specified field value not equals to a given value or list/set of values
     * @param field The field to filter on.
     * @param valueOrCollection The value(s) to filter for. Can be any `primitive` type, `List`, or `Set`.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder notEquals(
      SObjectField field,
      Object valueOrCollection
    ) {
      Set<Object> newValues = toSet(valueOrCollection);
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        Object fieldValue = record.get(field);
        if (newValues.contains(fieldValue) == false) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with specified field has value.
     * @param field The field to filter on.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder isNull(SObjectField field) {
      return this.equals(field, null);
    }

    /**
     * @description Filter records with specified field has value.
     * @param field The field to filter on.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder isNotNull(SObjectField field) {
      return this.notEquals(field, null);
    }

    /**
     * @description Filter records with all specified fields have values.
     * @param fields The fields to filter on.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder allNotNull(Set<SObjectField> fields) {
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        Boolean isValid = true;
        for (SObjectField field : fields) {
          if (record.get(field) == null) {
            isValid = false;
            break;
          }
        }
        if (isValid) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with any fields equals to a given value or list/set of values
     * @param fields The field to compare against.
     * @param valueOrCollection The values to compare with the field.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder anyEqual(
      Set<SObjectField> fields,
      Object valueOrCollection
    ) {
      Set<Object> newValues = toSet(valueOrCollection);
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        for (SObjectField field : fields) {
          Object fieldValue = record.get(field);
          if (newValues.contains(fieldValue)) {
            output.add(record);
            break;
          }
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with any fields equals to a given value or list/set of values
     * @param fields The field to compare against.
     * @param valueOrCollection The values to compare with the field.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder allEqual(
      Set<SObjectField> fields,
      Object valueOrCollection
    ) {
      Set<Object> newValues = toSet(valueOrCollection);
      List<SObject> output = createListOfSameType(this.records);
      for (SObject record : this.records) {
        Boolean isValid = true;
        for (SObjectField field : fields) {
          Object fieldValue = record.get(field);
          if (newValues.contains(fieldValue) == false) {
            isValid = false;
            break;
          }
        }
        if (isValid) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }

    /**
     * @description Filter records with old field value equals to a given value or list/set of values
     * @param field The field to filter on.
     * @param valueOrCollection The set of values to filter for. Can be any `primitive` type, `List`, or `Set`.
     * @return The updated FilterBuilder instance.
     */
    public FilterBuilder oldEquals(
      SObjectField field,
      Object valueOrCollection
    ) {
      List<SObject> output = createListOfSameType(this.records);
      if (this.oldMap.isEmpty()) {
        this.records = output;
        return this;
      }
      Set<Object> oldValues = toSet(valueOrCollection);
      for (SObject record : this.records) {
        SObject oldRecord = this.oldMap.get(record.Id);
        if (oldRecord != null && oldValues.contains(oldRecord.get(field))) {
          output.add(record);
        }
      }
      this.records = output;
      return this;
    }
  }
  //#endregion
}
