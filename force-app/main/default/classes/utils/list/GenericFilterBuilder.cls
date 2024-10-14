/**
 * @description A utility class for filtering lists of records.
 */
public class GenericFilterBuilder {
  public List<Object> records;

  /**
   * @description Represents a GenericFilterBuilder class that provides a handler for working with object.
   */
  public ObjectHandler handler {
    get {
      return handler ?? (handler = ObjectHandler.of(this.records));
    }
    private set;
  }

  /**
   * @description Constructs a new instance of the GenericFilterBuilder class.
   * @param records The list of records to filter.
   */
  public GenericFilterBuilder(List<Object> records) {
    this.records = records;
  }

  /**
   * @description Return the internal list of records.
   * @return `List<Object>` The current list of records.
   */
  public List<Object> toList() {
    return this.records;
  }

  /**
   * @description Filter records with specified field value contains a given string as sub-string.
   * @param field The field to filter on.
   * @param subString The value to filter for.
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder contains(String field, String subString) {
    List<Object> output = this.handler.emptyList;
    for (Object record : this.records) {
      String fieldValue = String.valueOf(this.handler.get(record, field));
      if (fieldValue?.contains(subString) == true) {
        output.add(record);
      }
    }
    this.records = output;
    return this;
  }
  /**
   * @description Filter records with specified field value not contains a given string as sub-string.
   * @param field The field to filter on.
   * @param subString The value to filter for.
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder notContains(String field, String subString) {
    List<Object> output = this.handler.emptyList;
    for (Object record : this.records) {
      String fieldValue = String.valueOf(this.handler.get(record, field));
      if (fieldValue == null || fieldValue.contains(subString) == false) {
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
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder equals(String field, Object valueOrCollection) {
    Set<Object> newValues = ListUtil.toSet(valueOrCollection);
    List<Object> output = this.handler.emptyList;
    for (Object record : this.records) {
      Object fieldValue = this.handler.get(record, field);
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
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder notEquals(
    String field,
    Object valueOrCollection
  ) {
    Set<Object> newValues = ListUtil.toSet(valueOrCollection);
    List<Object> output = this.handler.emptyList;
    for (Object record : this.records) {
      Object fieldValue = this.handler.get(record, field);
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
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder isNull(String field) {
    return this.equals(field, null);
  }

  /**
   * @description Filter records with specified field has value.
   * @param field The field to filter on.
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder isNotNull(String field) {
    return this.notEquals(field, null);
  }

  /**
   * @description Filter records with all specified fields have values.
   * @param fields The fields to filter on.
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder allNotNull(Set<String> fields) {
    List<Object> output = this.handler.emptyList;
    for (Object record : this.records) {
      Boolean isValid = true;
      for (String field : fields) {
        if (this.handler.get(record, field) == null) {
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
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder anyEqual(
    Set<String> fields,
    Object valueOrCollection
  ) {
    Set<Object> newValues = ListUtil.toSet(valueOrCollection);
    List<Object> output = this.handler.emptyList;
    for (Object record : this.records) {
      for (String field : fields) {
        Object fieldValue = this.handler.get(record, field);
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
   * @return The updated GenericFilterBuilder instance.
   */
  public GenericFilterBuilder allEqual(
    Set<String> fields,
    Object valueOrCollection
  ) {
    Set<Object> newValues = ListUtil.toSet(valueOrCollection);
    List<Object> output = this.handler.emptyList;
    for (Object record : this.records) {
      Boolean isValid = true;
      for (String field : fields) {
        Object fieldValue = this.handler.get(record, field);
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
}