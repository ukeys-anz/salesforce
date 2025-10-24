/**
 * @author Hrushikesh Pathak
 * @since 09/2025
 * @description Provider class that instantiates controller classes based on record type.
 */
public with sharing class SelectRecordsController {
  public static final Map<String, String> TEMPLATE_TYPE_MAP = new Map<String, String>{
    'Signing_Authority_Update' => 'SigningAuthorityUpdateController'
  };

  /**
   * @description Method to retrieve data
   * @param params Map<String, Object> to have multiple parameters
   * @return Map<String, Object> A list of financial accounts
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getRecords(Map<String, Object> params) {
    try {
      Type controllerType = Type.forName(
        TEMPLATE_TYPE_MAP.get((String) params.get('recordType'))
      );
      SelectRecordsWizard controller = (SelectRecordsWizard) Lib_InstanceProvider.forType(
        controllerType
      );
      return controller.getRecords(params);
    } catch (Exception e) {
      throw new AuraHandledException(
        'Something went wrong. Please contact the system administrator.' +
        e.getMessage()
      );
    }
  }

  /**
   * @description Method to retrieve data
   * @param params Map<String, Object> to have multiple parameters
   */
  @AuraEnabled
  public static void updateRecords(Map<String, Object> params) {
    try {
      Type controllerType = Type.forName(
        TEMPLATE_TYPE_MAP.get((String) params.get('recordType'))
      );
      SelectRecordsWizard controller = (SelectRecordsWizard) Lib_InstanceProvider.forType(
        controllerType
      );
      controller.updateRecords(params);
    } catch (Exception e) {
      throw new AuraHandledException(
        'Something went wrong. Please contact the system administrator.' +
        e.getMessage()
      );
    }
  }
}
