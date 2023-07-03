/**
 * @author Nagendra Singh
 * @since  06/2023
 * @description This class helps in fetching the dependent picklist values based on record types.
 */
public with sharing class DependentPicklistController {
  /**
   * @param objectName customer id
   * @param fieldName transaction id
   * @param recordTypeName transaction id
   * @return Map<String,List<String>> tokenized card number relating to the passed in transaction Id
   * @description getTokenizedCardNumber retrieves the tokenized card number
   */
  public static Map<String, Map<String, String>> getPicklistValues(
    String objectName,
    String fieldName,
    String recordTypeName
  ) {
    if (String.isBlank(objectName) || String.isBlank(fieldName)) {
      return null;
    }

    String recordTypeId;
    if (String.isNotBlank(recordTypeName)) {
      recordTypeId = Schema.getGlobalDescribe()
        .get(objectName)
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get(recordTypeName)
        .getRecordTypeId();
    } else {
      recordTypeId = Schema.getGlobalDescribe()
        .get(objectName)
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Master')
        .getRecordTypeId();
    }

    Map<String, Map<String, String>> mapPicklistValues = new Map<String, Map<String, String>>();

    mapPicklistValues = getValues(objectName, recordTypeId, fieldName);

    return mapPicklistValues;
  }

  /**
   * @param objectType customer id
   * @param recordTypeId transaction id
   * @param fieldName transaction id
   * @return Map<String,List<String>> tokenized card number relating to the passed in transaction Id
   * @description get picklist values based on the recordtypeId
   */
  public static Map<String, Map<String, String>> getValues(
    String objectType,
    String recordTypeId,
    String fieldName
  ) {
    String endpoint =
      'callout:Salesforce_Internal_API/' +
      objectType +
      '/picklist-values/' +
      recordTypeId +
      '/' +
      fieldName;

    // Create the endpoint dynamically for your org
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('Content-Type', 'application/json');
    HttpCalloutResponse res = calloutService.makeRestCallout(
      endpoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    Map<String, Map<String, String>> mapControllingWithDependentList = new Map<String, Map<String, String>>();
    Map<Object, String> mapControllingValueWithIndex = new Map<Object, String>();
    Map<String, Map<String, String>> mapPicklistValues = new Map<String, Map<String, String>>();

    // Parse the response and build the dependent and controlling picklist values map
    if (res.status == 'OK' && res.statusCode == 200) {
      Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(
        res.body
      );

      // Get all the controlling values from response
      if (root.containsKey('controllerValues')) {
        Map<String, Object> controllingValues = (Map<String, Object>) root.get(
          'controllerValues'
        );

        // Map of all the controlling values with their index
        for (String cValue : controllingValues.keySet()) {
          mapControllingValueWithIndex.put(
            controllingValues.get(cValue),
            cValue
          );
        }
      }

      if (!root.containsKey('values')) {
        return mapControllingWithDependentList;
      }

      // Get all the dependent values from the response returned with the Validfor attribute
      // Each bit in the bitmap indicates whether this dependent picklist value is "valid for" a corresponding controlling field value
      // The value in the validFor member is a Base64-encoded bitmap.
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
    } else {
      Logger.error(' Response Body For Error : ', res.body);
      Logger.saveLog();
    }

    return mapPicklistValues;
  }
}
