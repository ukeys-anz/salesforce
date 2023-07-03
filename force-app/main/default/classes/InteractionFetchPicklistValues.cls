/**
 * @author Shivam Swaraj
 * @since  06/2023
 * @description This class helps in fetching the dependent picklist values based on record types for Omniscript Lookup Fields.
 */
global class InteractionFetchPicklistValues implements omnistudio.VlocityOpenInterface, Callable {
  /**
   * @description call retreives the picklist values for the given fieldname
   * @param action
   * @param args
   * @return return object to send back to omniscript
   */
  global Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    return invokeMethod(action, input, output, options);
  }

  /**
   * @description used to get the picklist field values
   * @param methodName
   * @param inputMap
   * @param outMap
   * @param options
   * @return return object to send back to omniscript
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    Boolean success = true;
    try {
      if (methodName.equals('populateWhoForCall')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Interaction_Purpose__c',
          'General'
        );
      } else if (methodName.equals('populateWhoForStore')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Interaction_Purpose__c',
          'Store'
        );
      } else if (methodName.equals('populateAuthMethodForStore')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Authentication_Method__c',
          'Store'
        );
      } else if (methodName.equals('populateAuthMethodForCall')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Authentication_Method__c',
          'General'
        );
      } else if (methodName.equals('populateActionTakenForStore')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Resolution__c',
          'Store'
        );
      } else if (methodName.equals('populateActionTakenForCall')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Resolution__c',
          'General'
        );
      } else if (methodName.equals('populateReferredToForStore')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Referred_To__c',
          'Store'
        );
      } else if (methodName.equals('populateReferredToForCall')) {
        populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Referred_To__c',
          'General'
        );
      } else if (methodName.equals('populateChannelForCall')) {
        populatePicklist(inputMap, outMap, options, 'InteractionType');
      }
    } catch (Exception objectException) {
      Logger.error('ERROR in Fetching Picklist Values: ', objectException);
      Logger.saveLog();
    }
    return success;
  }

  /**
   * @description method to access Issue type picklist values
   * @param input input map
   * @param outMap output map
   * @param options
   * @param fieldName name of picklist field
   */
  private void populatePicklist(
    Map<String, Object> input,
    Map<String, Object> outMap,
    Map<String, Object> options,
    String fieldName
  ) {
    String objectName = 'Interaction';
    String controllingField = fieldName;
    List<Map<String, String>> controllingInfo = new List<Map<String, String>>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
      .get(controllingField)
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
   * @description retreives the picklist values for the given fieldname
   * @param inputMap
   * @param outMap
   * @param options
   * @param fieldName
   * @param recordTypeDeveloperName
   */
  private void populateDependentPicklistValues(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options,
    String fieldName,
    String recordTypeDeveloperName
  ) {
    Map<String, Map<String, String>> stringsByStringsByStrings = DependentPicklistController.getPicklistValues(
      'Interaction',
      fieldName,
      recordTypeDeveloperName
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
