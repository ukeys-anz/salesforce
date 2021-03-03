/**
 * @author Shermal Warnakula
 * @since Feb 2021
 * @description Holds common util functions
 */
public with sharing class CommonUtils {
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
}
