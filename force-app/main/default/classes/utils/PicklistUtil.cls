/**
 * @author Aidan
 * @since  09/2021
 * @description Util to get controlling picklist values for dependent picklists
 * @group Utility
 */
public class PicklistUtil {
  /**
   * @description Calls Org cache to retrieve picklist values
   * @param objectName object API name
   * @param picklistName picklist field API name
   * @return `Map<String, List<String>>` a map of dependent picklist value, to a list of controlling values
   */
  public static Map<String, List<String>> getCachedPicklistDependencyMap(
    String objectName,
    String picklistName
  ) {
    return (Map<String, List<String>>) Cache.Org.get(
      PicklistCache.class,
      'local.Utility.' +
      objectName +
      '-' +
      picklistName
    );
  }

  class PicklistCache implements Cache.CacheBuilder {
    /**
     * @description Cachebuilder inner class
     * @precondition Fired when the given value only is not yet cached
     * @param picklistKey picklist key in the map
     * @return `Map<String, List<String>>` a map of dependent picklist value, to a list of controlling values
     */
    public Object doLoad(String picklistKey) {
      String objectName = picklistKey.substringBefore('-');
      String picklistName = picklistKey.substringAfter('-');
      return PicklistUtil.getPicklistDependencyMap(objectName, picklistName);
    }
  }

  class PicklistInfo {
    String validFor;
  }

  /**
   * @description Fetches Schema.PicklistEntry for the relevant picklists, and call helper method
   * @precondition The given value only has one controlling value, if there are multiple then one will be assigned at random
   * @param objectName object API name
   * @param picklistName picklist field API name
   * @return `Map<String, List<String>>` a map of dependent picklist value, to a list of controlling values
   */
  @TestVisible
  private static Map<String, List<String>> getPicklistDependencyMap(
    String objectName,
    String picklistName
  ) {
    //prepare two lists of picklist entries, the controlling field and dependent field
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
    Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
    Schema.DescribeFieldResult dependentField = objectDescribe.fields.getMap()
      .get(picklistName)
      .getDescribe();
    List<Schema.PicklistEntry> dependentValues = dependentField.getPicklistValues();

    Schema.DescribeFieldResult controllingField = dependentField.getController()
      .getDescribe();
    List<Schema.PicklistEntry> controlValues = controllingField.getPicklistValues();

    return assignDependentValues(dependentValues, controlValues);
  }

  /**
   * @description Performs bitmap calculations to derive the value from the serialized apex object in memory
   * @param dependentValues list of picklist entry objects in the dependent field
   * @param controlValues list of picklist entry objects in the controlling field
   * @return `Map<String, List<String>>` a map of dependent picklist value, to a list of controlling values
   */
  private static Map<String, List<String>> assignDependentValues(
    List<Schema.PicklistEntry> dependentValues,
    List<Schema.PicklistEntry> controlValues
  ) {
    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    Map<String, List<String>> outputMap = new Map<String, List<String>>();

    for (Schema.PicklistEntry dependentValue : dependentValues) {
      String jsonString = JSON.serialize(dependentValue);

      PicklistInfo info = (PicklistInfo) JSON.deserialize(
        jsonString,
        PicklistInfo.class
      );
      List<String> base64chars = String.valueOf(info.validFor).split('');
      for (
        Integer index = 0;
        index < (controlValues != null ? controlValues.size() : 2);
        index++
      ) {
        Object controlValue = (controlValues == null
          ? (Object) (index == 1)
          : (Object) (controlValues[index].isActive()
              ? controlValues[index].getLabel()
              : null));
        Integer bitIndex = index / 6;
        if (bitIndex > base64chars.size() - 1) {
          break;
        }
        Integer bitShift = 5 - Math.mod(index, 6);
        if (
          controlValue == null ||
          (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0
        ) {
          continue;
        }
        // if the map contains the key, add the controlling value to the list, if it isn't add a new list
        if (outputMap.containsKey(dependentValue.getValue())) {
          outputMap.get(dependentValue.getValue()).add((String) controlValue);
        } else {
          outputMap.put(
            dependentValue.getValue(),
            new List<String>{ (String) controlValue }
          );
        }
      }
    }
    return outputMap;
  }
}