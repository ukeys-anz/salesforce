/**
 * @author Nagendra Singh
 * @since 06/2023
 * @description  InteractionFetchPicklistValuesForCall This class helps in fetching the dependent picklist values based on Call record types for Omniscript Lookup Fields.
 */
global class InteractionFetchPicklistValuesForCall implements omnistudio.VlocityOpenInterface, Callable {
  public static Map<String, Object> fullPickListValue = new Map<String, Object>();

  // Static block to initilize the picklist values
  static {
    fullPickListValue = (Map<String, Object>) Cache.Org.get(
      PicklistCache.class,
      'local.Utility' +
      '.' +
      GetHelpConstants.INTERACTION_GENERAL_RT_ID
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
      if (methodName.equals('populateWhoForCall')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Interaction_Purpose__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateAuthMethodForCall')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Authentication_Method__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateActionTakenForCall')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Resolution__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateReferredToForCall')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Referred_To__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateChannelForCall')) {
        FetchPicklistUtil.populatePicklist(
          inputMap,
          outMap,
          options,
          'InteractionType',
          'Interaction'
        );
      }
    } catch (Exception objectException) {
      Logger.error('ERROR in Fetching Picklist Values: ', objectException);
      Logger.saveLog();
    }
    return success;
  }
}
