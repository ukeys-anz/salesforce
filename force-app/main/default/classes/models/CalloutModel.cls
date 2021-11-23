/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description base class for JSON <-> Apex Type de/serializations
 * @group Models
 */
public virtual class CalloutModel {
  /**
   * @description JSON keys that need to be replaced, as they are Apex reserved keywords. For example, 'currency', 'integer', 'public'
   */
  private static final Map<String, String> RESERVED_KEY_MAPPINGS = new Map<String, String>{
    'currency' => 'currencyCode',
    'id_token' => 'idToken',
    'access_token' => 'accessToken',
    'refresh_token' => 'refreshToken',
    'expires_in' => 'expiresIn',
    'expires_on' => 'expiresOn',
    'number' => 'transactionAccountNumber',
    'date' => 'transactionDate',
    '_links' => 'links',
    'set' => 'category_set'
  };

  /**
   * @param obj the apex object being serialized to JSON
   * @return `String` JSON string
   * @description serialization of an Object, leaving nulls by default
   */
  public String serialize(Object obj) {
    return serialize(obj, false);
  }

  /**
   * @param obj the apex object being serialized to JSON
   * @param suppressNulls if true, nulls are removed
   * @return `String` JSON string
   * @description serialization of an Object, with reserved keyword replacement
   */
  public static String serialize(Object obj, Boolean suppressNulls) {
    String retString = JSON.serialize(obj, suppressNulls);

    //inverts the reserved word map to revert the keyword replacement and build the original json
    Map<String, String> flippedMap = new Map<String, String>();
    for (String key : RESERVED_KEY_MAPPINGS.keySet()) {
      flippedMap.put(RESERVED_KEY_MAPPINGS.get(key), key);
    }

    retString = transformString(retString, flippedMap);
    return retString;
  }

  /**
   * @param jsonString the string to convert to Object
   * @param type the type of Object to create
   * @return `Object` deserialized Object
   * @description takes an input JSON string and Apex type, replaces reserved keys, and provides an Object
   */
  public static Object deserialize(String jsonString, System.Type type) {
    jsonString = transformString(jsonString, RESERVED_KEY_MAPPINGS);
    //deserializeStrict is not being used to reduce fragility - if API adds properties to the response,
    //they will be thrown away instead of breaking the callout
    return JSON.deserialize(jsonString, type);
  }

  /**
   * @param s input string
   * @param mapKeys keys to replace
   * @return `String` string with values replaced
   * @description
   */
  private static String transformString(String s, Map<String, String> mapKeys) {
    if (mapKeys == null) {
      return s;
    }
    return replaceAll(s, mapKeys);
  }

  /**
   * @param s the JSON string to replace
   * @param fromToMap key values of string replacements, the from value is replaced with the corresponding to value
   * @return `String` the manipulated string
   * @description replaces all occurrences of keys in the supplied map, in an input string, with the corresponding value
   */
  private static String replaceAll(String s, Map<String, String> fromToMap) {
    for (String key : fromToMap.keySet()) {
      s = s.replaceAll('"' + key + '"(\\ )*:', '"' + fromToMap.get(key) + '":');
    }
    return s;
  }
}
