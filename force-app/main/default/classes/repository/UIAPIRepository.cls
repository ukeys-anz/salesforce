/**
 * @author Shermal Warnakula
 * @since  09/2021
 * @description UI API repository used to fetch Pick List values by Record Type
 * @group Repository
 */
public with sharing class UIAPIRepository extends RepositoryBase {
  /**
   * @description Get picklist values by Record Type Id.
   * @param objectName object API name
   * @param fieldApiName field API name
   * @param recordTypeId record type Id
   * @return `List<PicklistWrapper>` a list of PicklistWrapper instances
   */
  public List<PicklistWrapper> getPickListValuesByRecordType(
    string objectName,
    string fieldApiName,
    string recordTypeId
  ) {
    List<PicklistWrapper> picklistValuesList = new List<PicklistWrapper>();

    // Making an internal API callout to ui-api
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    String endpoint =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/services/data/v52.0/ui-api/object-info/' +
      objectName +
      '/picklist-values/' +
      recordTypeId +
      '/' +
      fieldApiName;

    getPickListValueInfo(endpoint, picklistValuesList);

    return picklistValuesList;
  }

  /**
   * @description fetches Picklist info from UI API, deserialized to a wrapper
   * @param endPoint the end point of the API callout
   * @param picklistValuesList a list of PicklistWrapper instances
   */
  private void getPickListValueInfo(
    String endPoint,
    List<PicklistWrapper> picklistValuesList
  ) {
    Service s = ServiceProvider.getService(UIAPIService.class);
    HttpCalloutResponse response = s.getPickListValueInfo(endPoint);
    if (response.successful) {
      try {
        // Deserialise JSON response
        Map<String, Object> respBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );

        // Generate response
        generateResponse(picklistValuesList, respBodyMap);
      } catch (Exception e) {
        handleErrors(null, e, UIAPIRepository.class);
      }
    } else {
      handleErrors(response, null, UIAPIRepository.class);
    }
  }

  /**
   * @description Get picklist values by Record Type Id.
   * @param picklistValuesList a list of PicklistWrapper instances
   * @param respBodyMap response body as a map
   */
  private void generateResponse(
    List<PicklistWrapper> picklistValuesList,
    Map<String, Object> respBodyMap
  ) {
    // Extracting controlling picklist field information (if available)
    Map<Integer, String> controllerValueByIndex = new Map<Integer, String>();
    Map<String, Object> controllerValuesMap = (Map<String, Object>) respBodyMap.get(
      'controllerValues'
    );
    if (controllerValuesMap != null && !controllerValuesMap.isEmpty()) {
      for (String controllerValue : controllerValuesMap.keySet()) {
        controllerValueByIndex.put(
          (Integer) controllerValuesMap.get(controllerValue),
          controllerValue
        );
      }
    }

    // Generate response
    for (Object valueObject : (List<Object>) respBodyMap.get('values')) {
      Map<String, Object> valueAtrributesMap = (Map<String, Object>) valueObject;

      PicklistWrapper plObj = new PicklistWrapper();
      plObj.value = (String) valueAtrributesMap.get('value');
      plObj.label = (String) valueAtrributesMap.get('label');

      // Adding controlling picklist information (if available)
      if (!controllerValueByIndex.isEmpty()) {
        List<String> controllingPLValues = new List<String>();
        for (
          Object controllerObj : (List<Object>) valueAtrributesMap.get(
            'validFor'
          )
        ) {
          controllingPLValues.add(
            controllerValueByIndex.get((Integer) controllerObj)
          );
        }
        plObj.controllingPLValues = controllingPLValues;
      }

      picklistValuesList.add(plObj);
    }
  }
}
