/**
 * @author Shivam Swaraj
 * @since  06/2023
 * @description This class helps in fetching the dependent picklist values based on record types for Omniscript Lookup Fields.
 */
global class InteractionFetchPicklistValues implements omnistudio.VlocityOpenInterface, Callable {
  public static Map<String, Object> fullPickListValue = new Map<String, Object>();

  // Static block to initilize the picklist values
  static {
    fullPickListValue = (Map<String, Object>) Cache.Org.get(
      PicklistCache.class,
      'local.Utility' +
      '.' +
      GetHelpConstants.INTERACTION_STORE_RT_ID
    );
  }

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
      if (methodName.equals('populateWhoForStore')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Interaction_Purpose__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateAuthMethodForStore')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Authentication_Method__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateActionTakenForStore')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Resolution__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateReferredToForStore')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Referred_To__c',
          fullPickListValue
        );
      }
    } catch (Exception objectException) {
      Logger.error('ERROR in Fetching Picklist Values: ', objectException);
      Logger.saveLog();
    }
    return success;
  }
}
