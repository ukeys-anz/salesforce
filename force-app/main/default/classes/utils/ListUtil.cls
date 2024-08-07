/**
 * @author Tan Phan
 * @since 07/2024
 * @description Holds list-related utilities methods
 * @group Utils
 */
public inherited sharing class ListUtil {
  /**
   * @description Returns a set of Ids extracted from a list of SObjects based on a specified field.
   * @param records The list of SObjects from which to extract the Ids.
   * @param field The field on the SObject to extract the Ids from.
   * @return `Set<Id>` A set of Ids extracted from the specified field of the SObjects.
   */
  public static Set<Id> getIds(
    List<SObject> records,
    Schema.SObjectField field
  ) {
    Set<Id> ids = new Set<Id>();
    for (SObject record : records) {
      Id value = (Id) record.get(field);
      if (value != null) {
        ids.add(value);
      }
    }
    return ids;
  }

  /**
   * @description Returns a set of string values extracted from a list of SObjects based on a specified field.
   * @param records The list of SObjects from which to extract the values.
   * @param field The field on the SObject to extract the values from.
   * @return `Set<String>` A set of values extracted from the specified field of the SObjects.
   */
  public static Set<String> getStrings(
    List<SObject> records,
    Schema.SObjectField field
  ) {
    Set<String> values = new Set<String>();
    for (SObject record : records) {
      String value = String.valueOf(record.get(field));
      if (value != null) {
        values.add(value);
      }
    }
    return values;
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
    Schema.SObjectField field
  ) {
    Map<Id, SObject> recordMap = (Map<Id, SObject>) Type.forName(
        'Map<Id,' + field.getDescribe().getSObjectType() + '>'
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
    Schema.SObjectField field
  ) {
    Map<String, SObject> recordMap = (Map<String, SObject>) Type.forName(
        'Map<String,' + field.getDescribe().getSObjectType() + '>'
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
}
