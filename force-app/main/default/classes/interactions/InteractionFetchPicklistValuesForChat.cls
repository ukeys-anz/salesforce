/**
 * @author Nagendra Singh
 * @since 06/2023
 * @description  InteractionFetchPicklistValuesForChat This class helps in fetching the dependent picklist values based on Message record types for Omniscript Lookup Fields.
 */
global class InteractionFetchPicklistValuesForChat implements omnistudio.VlocityOpenInterface, Callable {
  public static Map<String, Object> fullPickListValue = new Map<String, Object>();

  // Static block to initilize the picklist values
  static {
    fullPickListValue = (Map<String, Object>) Cache.Org.get(
      PicklistCache.class,
      'local.Utility' +
      '.' +
      GetHelpConstants.INTERACTION_MESSAGE_RT_ID
    );
  }

  /**
   * @description chat retreives the picklist values for the given fieldname
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
      if (methodName.equals('populateWhoForChat')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Interaction_Purpose__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateAuthMethodForChat')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Authentication_Method__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateActionTakenForChat')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Resolution__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateReferredToForChat')) {
        FetchPicklistUtil.populateDependentPicklistValues(
          inputMap,
          outMap,
          options,
          'Referred_To__c',
          fullPickListValue
        );
      } else if (methodName.equals('populateChannelForChat')) {
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
