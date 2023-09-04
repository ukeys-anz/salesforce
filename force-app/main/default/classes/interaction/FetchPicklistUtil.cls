/**
 * @author Nagendra Singh
 * @since  06/2023
 * @description This class helps in fetching the dependent picklist values based on record types.
 */
public with sharing class FetchPicklistUtil {
  /**
   * @description populatePicklist retreives the picklist values for the given fieldname
   * @param input
   * @param outMap
   * @param options
   * @param fieldName
   * @param objectName
   */
  public static void populatePicklist(
    Map<String, Object> input,
    Map<String, Object> outMap,
    Map<String, Object> options,
    String fieldName,
    String objectName
  ) {
    List<Map<String, String>> controllingInfo = new List<Map<String, String>>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
      .get(fieldName)
      .getDescribe();
    List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
    for (Schema.PicklistEntry currControllingValue : controllingValues) {
      controllingInfo.add(
        new Map<String, String>{
          'name' => currControllingValue.getValue(),
          'value' => currControllingValue.getLabel()
        }
      );
    }
    outMap.put('options', controllingInfo);
  }

  /**
   * @description populateDependentPicklistValues retreives the picklist values for the given fieldname
   * @param inputMap
   * @param outMap
   * @param options
   * @param fieldName
   * @param fullPickListValue
   */
  public static void populateDependentPicklistValues(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options,
    String fieldName,
    Map<String, Object> fullPickListValue
  ) {
    Map<String, Map<String, String>> stringsByStringsByStrings = DependentPicklistController.getPicklistValues(
      fieldName,
      fullPickListValue
    );
    Map<String, List<Map<String, String>>> finalMap = new Map<String, List<Map<String, String>>>();
    for (String key : stringsByStringsByStrings.keySet()) {
      List<Map<String, String>> lstMap = new List<Map<String, String>>();
      Map<String, String> stringsByStrings = stringsByStringsByStrings.get(key);
      if (!stringsByStrings.isEmpty()) {
        for (String value : stringsByStrings.keySet()) {
          Map<String, String> mapOfLabelValue = new Map<String, String>();
          String label = stringsByStrings.get(value);
          mapOfLabelValue.put('value', value);
          mapOfLabelValue.put('name', label);
          lstMap.add(mapOfLabelValue);
        }
      }
      finalMap.put(key, lstMap);
    }
    outMap.put('dependency', finalMap);
  }
}
