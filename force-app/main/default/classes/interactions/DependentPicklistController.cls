/**
 * @author Nagendra Singh
 * @since  06/2023
 * @description This class helps in fetching the dependent picklist values based on record types.
 */
public with sharing class DependentPicklistController {
  /**
   * @param fieldName transaction id
   * @param fullPickListValue
   * @return Map<String,List<String>> tokenized card number relating to the passed in transaction Id
   * @description getPicklistValues retrieves the tokenized card number
   */
  public static Map<String, Map<String, String>> getPicklistValues(
    String fieldName,
    Map<String, Object> fullPickListValue
  ) {
    return getValues(fieldName, fullPickListValue);
  }

  /**
   * @param fieldName transaction id
   * @param fullPickListValue
   * @return Map<String,List<String>> tokenized card number relating to the passed in transaction Id
   * @description getValues get picklist values based on the recordtypeId
   */
  public static Map<String, Map<String, String>> getValues(
    String fieldName,
    Map<String, Object> fullPickListValue
  ) {
    Map<String, Map<String, String>> mapControllingWithDependentList = new Map<String, Map<String, String>>();
    Map<Object, String> mapControllingValueWithIndex = new Map<Object, String>();
    Map<String, Map<String, String>> mapPicklistValues = new Map<String, Map<String, String>>();

    // Parse the response and build the dependent and controlling picklist values map
    Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(
      JSON.serialize(fullPickListValue.get(fieldName))
    );

    // Get all the controlling values from response
    if (root.containsKey('controllerValues')) {
      Map<String, Object> controllingValues = (Map<String, Object>) root.get(
        'controllerValues'
      );

      // Map of all the controlling values with their index
      for (String cValue : controllingValues.keySet()) {
        mapControllingValueWithIndex.put(controllingValues.get(cValue), cValue);
      }
    }

    if (!root.containsKey('values')) {
      return mapControllingWithDependentList;
    }

    List<Object> pValues = (List<Object>) root.get('values');
    for (Object pValue : pValues) {
      Map<String, String> result = new Map<String, String>();
      Map<String, Object> pValueMap = (Map<String, Object>) pValue;
      result.put(
        (String) pValueMap.get('value'),
        (String) pValueMap.get('label')
      );
      for (Object validfor : (List<Object>) pValueMap.get('validFor')) {
        //Map the dependent Values List with their Controlling Value
        if (mapControllingValueWithIndex.containsKey(validfor)) {
          if (
            !mapControllingWithDependentList.containsKey(
              mapControllingValueWithIndex.get(validfor)
            )
          ) {
            mapControllingWithDependentList.put(
              mapControllingValueWithIndex.get(validfor),
              new Map<String, String>()
            );
          }

          mapControllingWithDependentList.get(
              mapControllingValueWithIndex.get(validfor)
            )
            .putAll(result);
        }
      }
    }

    //Map all the controlling values
    for (String controllingFields : mapControllingValueWithIndex.values()) {
      //Map controllingFields which has no dependent values associated to it
      if (!mapPicklistValues.containsKey(controllingFields)) {
        mapPicklistValues.put(controllingFields, new Map<String, String>());
      }
      //Map controllingFields which has dependent values associated to it
      if (
        mapPicklistValues.containsKey(controllingFields) &&
        mapControllingWithDependentList.containsKey(controllingFields)
      ) {
        mapPicklistValues.get(controllingFields)
          .putAll(mapControllingWithDependentList.get(controllingFields));
      }
    }

    return mapPicklistValues;
  }
}
