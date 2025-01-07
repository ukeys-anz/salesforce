/**
 * @description A utility class for filtering lists of SObjects.
 */
public class SObjectFilterBuilder {
  private Map<Id, SObject> oldMap;
  private GenericFilterBuilder base;

  /**
   * @description Constructs a new instance of SObjectFilterBuilder.
   * @param base The GenericFilterBuilder instance.
   * @param oldMap The map of old SObject records.
   */
  public SObjectFilterBuilder(
    GenericFilterBuilder base,
    Map<Id, SObject> oldMap
  ) {
    this.base = base;
    this.oldMap = oldMap ?? new Map<Id, SObject>();
  }

  /**
   * @description Converts a Set of SObjectField objects to a Set of String field names.
   * @param fields The Set of SObjectField objects to convert.
   * @return A Set of String field names.
   */
  private Set<String> toSetString(Set<SObjectField> fields) {
    Set<String> fieldNames = new Set<String>();
    for (SObjectField field : fields) {
      fieldNames.add(field.toString());
    }
    return fieldNames;
  }

  /**
   * @description Converts the records in the collection to a list of SObjects.
   * @return A list of SObjects representing the records in the collection.
   */
  public List<SObject> toList() {
    return (List<SObject>) base.records;
  }

  /**
   * @description Filter records with no DML errors.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder noError() {
    List<Object> output = base.handler.emptyList;
    for (SObject record : this.toList()) {
      if (record.hasErrors() == false) {
        output.add(record);
      }
    }
    base.records = output;
    return this;
  }

  /**
   * @description Filter records with specified field value contains a given string as sub-string.
   * @param field The field to filter on.
   * @param subString The value to filter for.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder contains(SObjectField field, String subString) {
    base.contains(field.toString(), subString);
    return this;
  }
  /**
   * @description Filter records with specified field value not contains a given string as sub-string.
   * @param field The field to filter on.
   * @param subString The value to filter for.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder notContains(
    SObjectField field,
    String subString
  ) {
    base.notContains(field.toString(), subString);
    return this;
  }

  /**
   * @description Filter records with specified field changed.
   * @param field The field to check for changes.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder changed(SObjectField field) {
    if (this.oldMap.isEmpty()) {
      return this;
    }
    List<Object> output = base.handler.emptyList;
    for (SObject record : this.toList()) {
      SObject oldRecord = this.oldMap.get(record.Id);
      if (oldRecord == null || record.get(field) != oldRecord.get(field)) {
        output.add(record);
      }
    }
    base.records = output;
    return this;
  }

  /**
   * @description Filter records with specified field updated to a given value or list/set of values
   * @param field The field to filter on.
   * @param valueOrCollection The value(s) to filter for. Can be any `primitive` type, `List`, or `Set`.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder changedTo(
    SObjectField field,
    Object valueOrCollection
  ) {
    if (this.oldMap.isEmpty()) {
      return this;
    }
    Set<Object> newValues = ListUtil.toSet(valueOrCollection);
    List<Object> output = base.handler.emptyList;
    for (SObject record : this.toList()) {
      Object fieldValue = record.get(field);
      if (
        newValues.contains(fieldValue) &&
        this.oldMap.get(record.Id)?.get(field) != fieldValue
      ) {
        output.add(record);
      }
    }
    base.records = output;
    return this;
  }

  /**
   * @description Filter records with List of fields whose values changed.
   * @param fields The se fields to check for changes.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder anyChanged(Set<SObjectField> fields) {
    if (this.oldMap.isEmpty()) {
      return this;
    }
    List<Object> output = base.handler.emptyList;
    Set<String> fieldValues = this.toSetString(fields);
    for (SObject record : this.toList()) {
      for (String field : fieldValues) {
        SObject oldRecord = this.oldMap.get(record.Id);
        if (oldRecord == null || record.get(field) != oldRecord.get(field)) {
          output.add(record);
          break;
        }
      }
    }
    base.records = output;
    return this;
  }

  /**
   * @description Filter records with specified field value equals to a given value or list/set of values
   * @param field The field to filter on.
   * @param valueOrCollection The value(s) to filter for. Can be any `primitive` type, `List`, or `Set`.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder equals(
    SObjectField field,
    Object valueOrCollection
  ) {
    base.equals(field.toString(), valueOrCollection);
    return this;
  }

  /**
   * @description Filter records with specified field value not equals to a given value or list/set of values
   * @param field The field to filter on.
   * @param valueOrCollection The value(s) to filter for. Can be any `primitive` type, `List`, or `Set`.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder notEquals(
    SObjectField field,
    Object valueOrCollection
  ) {
    base.notEquals(field.toString(), valueOrCollection);
    return this;
  }

  /**
   * @description Filter records with specified field has value.
   * @param field The field to filter on.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder isNull(SObjectField field) {
    base.equals(field.toString(), null);
    return this;
  }

  /**
   * @description Filter records with specified field has value.
   * @param field The field to filter on.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder isNotNull(SObjectField field) {
    base.notEquals(field.toString(), null);
    return this;
  }

  /**
   * @description Filter records with all specified fields have values.
   * @param fields The fields to filter on.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder allNotNull(Set<SObjectField> fields) {
    base.allNotNull(this.toSetString(fields));
    return this;
  }

  /**
   * @description Filter records with any fields equals to a given value or list/set of values
   * @param fields The field to compare against.
   * @param valueOrCollection The values to compare with the field.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder anyEqual(
    Set<SObjectField> fields,
    Object valueOrCollection
  ) {
    base.anyEqual(this.toSetString(fields), valueOrCollection);
    return this;
  }

  /**
   * @description Filter records with any fields equals to a given value or list/set of values
   * @param fields The field to compare against.
   * @param valueOrCollection The values to compare with the field.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder allEqual(
    Set<SObjectField> fields,
    Object valueOrCollection
  ) {
    base.allEqual(this.toSetString(fields), valueOrCollection);
    return this;
  }

  /**
   * @description Filter records with old field value equals to a given value or list/set of values
   * @param field The field to filter on.
   * @param valueOrCollection The set of values to filter for. Can be any `primitive` type, `List`, or `Set`.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder oldEquals(
    SObjectField field,
    Object valueOrCollection
  ) {
    List<Object> output = base.handler.emptyList;
    if (this.oldMap.isEmpty()) {
      base.records = output;
      return this;
    }
    Set<Object> oldValues = ListUtil.toSet(valueOrCollection);
    for (SObject record : this.toList()) {
      SObject oldRecord = this.oldMap.get(record.Id);
      if (
        oldRecord != null &&
        oldValues.contains(oldRecord.get(field)) == true
      ) {
        output.add(record);
      }
    }
    base.records = output;
    return this;
  }

  /**
   * @description Filter records with old field value not equals to a given value or list/set of values
   * @param field The field to filter on.
   * @param valueOrCollection The set of values to filter for. Can be any `primitive` type, `List`, or `Set`.
   * @return The updated SObjectFilterBuilder instance.
   */
  public SObjectFilterBuilder oldNotEquals(
    SObjectField field,
    Object valueOrCollection
  ) {
    if (this.oldMap.isEmpty()) {
      return this;
    }
    List<Object> output = base.handler.emptyList;
    Set<Object> oldValues = ListUtil.toSet(valueOrCollection);
    for (SObject record : this.toList()) {
      SObject oldRecord = this.oldMap.get(record.Id);
      if (
        oldRecord == null ||
        oldValues.contains(oldRecord.get(field)) == false
      ) {
        output.add(record);
      }
    }
    base.records = output;
    return this;
  }
}
