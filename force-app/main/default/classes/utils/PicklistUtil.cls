/**
 * @author Aidan
 * @since  09/2021
 * @description Util to get controlling picklist values for dependent picklists
 * @group Utility
 */
public class PicklistUtil {

  private static PicklistCache getCachedPicklist(
    String objectName,
    String picklistName
  ) {
    if ( Test.isRunningTest()) {
      return (new PicklistUtil.PicklistCache()).doLoad(
      objectName + '-' + picklistName);
    }
    return ((PicklistCache) Cache.Org.get(
      PicklistCache.class,
      'local.Utility.' +
      objectName +
      '-' +
      picklistName +
      '-picklist'
    ));
  }
  /**
   * @description Calls Org cache to retrieve picklist values arranged From Child to Parent
   * @param objectName object API name
   * @param picklistName picklist field API name
   * @return `Map<String, List<String>>` a map of dependent picklist value, to a list of controlling values
   */
  public static Map<String, List<String>> getCachedPicklistParentMap(
    String objectName,
    String picklistName
  ) {
    return getCachedPicklist(objectName, picklistName).getParentList();
  }

  /**
   * @description Calls Org cache to retrieve picklist values arranged from Parent to Child
   * @param objectName object API name
   * @param picklistName picklist field API name
   * @return `Map<String, List<String>>` a map of controlling picklist value, to a list of dependent values
   */
  public static Map<String, List<Map<String,String>>> getCachedOmniPicklistMap(
    String objectName,
    String picklistName
  ) {
    return getCachedPicklist(objectName, picklistName).getOmniChildList();
  }

  /**
  * @description cacheable PicklistEntry class
  */
  class PicklistEntryCacheable {
    public String label;
    public String value;

    /**
     * @description Constructor
     * @param peSelf PicklistEntry object to be cached
     */
    public PicklistEntryCacheable(PicklistEntry peSelf) {
      this.label = peSelf.getLabel();
      this.value = peSelf.getValue();
    }
  }
  /**
   * @description class to gather PickListEntry and Children together.
   */
  class PicklistDependency {
    public PicklistEntryCacheable self;
    public List<PicklistEntryCacheable> controlling;

    /**
     * @description Constructor
     * @param self Reference to the PicklistEntry this picklistDependency represents
     */
    public PicklistDependency(PicklistEntry self) {
      this.self = new PicklistEntryCacheable(self);
      this.controlling = new List<PicklistEntryCacheable>();
    }
  }

  /**
   * @description Cachable picklist collection
   */
  public class PicklistCache implements Cache.CacheBuilder {
    // Single Map of Children to Parent values
    private Map<String, PicklistDependency> mpChild2Parent;

    /**
     * @description Child to Parent structure of key and values only
     * @return Map of child values to list of parent values
     */
    public Map<String, List<String>> getParentList() {
      // return relationship between child picklist values and parent
      Map<String, List<String>> parentList = new Map<String, List<String>>();
      List<String> lstValues;
      for (String strChild : mpChild2Parent.keySet()) {
        if ((lstValues = parentList.get(strChild)) == null) {
          lstValues = new List<String>();
          parentList.put(strChild, lstValues);
        }
        for (PicklistEntryCacheable peParent : mpChild2Parent.get(strChild).controlling) {
          lstValues.add(peParent.value);
        }
      }
      return parentList;
    }

    /**
     * @description Interpretation of mpChild2Parent usable by Omni callers
     * @return Map of parent values to list of key/values pairs for children
     */
    public Map<String, List<Map<String,String>>> getOmniChildList() {
      // Return a Parent to Child list in Omni format
      Map<String, List<Map<String, String>>> omniChildList = new Map<String, List<Map<String, String>>>();
      PicklistDependency pdChild;
      List<Map<String, String>> lstValues;
      for (String strChild : mpChild2Parent.keySet()) {
        pdChild = mpChild2Parent.get(strChild);
        for (PicklistEntryCacheable peParent : pdChild.controlling) {
          if ((lstValues = omniChildList.get(peParent.value)) == null) {
            lstValues = new List<Map<String, String>>();
            omniChildList.put(peParent.value, lstValues);
          }
          lstValues.add(new Map<String, String>{
          'name' => pdChild.self.value,
          'value' => pdChild.self.label
          });
        }
      }
      return omniChildList;
    }

    /**
     * @description CacheBuilder inner class
     * @precondition Fired when the given value only is not yet cached
     * @param picklistKey picklist key in the map
     * @return `Map<String, List<String>>` a map of dependent picklist value, to a list of controlling values
     */
    public PicklistCache doLoad(String picklistKey) {
      System.debug('doLoad');
      String objectName = picklistKey.split('-')[0];
      String picklistName = picklistKey.split('-')[1];
      mpChild2Parent = PicklistUtil.getPicklistDependencyMap(objectName, picklistName);
      System.debug('this: ' + JSON.serialize(this));
      return this;
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

  private static Map<String, PicklistDependency> getPicklistDependencyMap(
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
  private static Map<String, PicklistDependency> assignDependentValues(
    List<Schema.PicklistEntry> dependentValues,
    List<Schema.PicklistEntry> controlValues
  ) {
    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    Map<String, PicklistDependency> outputMap = new Map<String, PicklistDependency>();
    PicklistDependency pdDependency;

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
        PicklistEntry controlValue = (controlValues == null
          ? null
          : (controlValues[index].isActive()
              ? controlValues[index]
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
        // if the map contains the dependent value, add the controlling value to the list, if it isn't add a new list
        if ((pdDependency = outputMap.get(dependentValue.getValue())) == null) {
          pdDependency = new PicklistDependency((PicklistEntry) dependentValue);
          outputMap.put(dependentValue.getValue(), pdDependency);
        }
        pdDependency.controlling.add(new PicklistEntryCacheable(controlValue));
      }
    }
    return outputMap;
  }
}
