/**
 * @author Hrushikesh
 * @since July 2023
 * @description checks the permission user has to perform actions on flexcard
 */
global class PayToPermissionChecker implements Callable {
  private static final String CANCEL_CUSTOM_PERMISSION = 'ANZx_Cancel_PayTo_Agreements';
  private static final String VIEW_CUSTOM_PERMISSION = 'ANZx_View_PayTo_Agreements';
  private static final String SUSPEND_UNSUSPEND_CUSTOM_PERMISSION = 'ANZx_Suspend_Unsuspend_PayTo_Agreements';
  private static final String FRAUD_CANCEL_CUSTOM_PERMISSION = 'ANZx_Fraud_Cancel_PayTo_Agreements';
  private static final String METHODNAME_CHECK_PERMISSIONS = 'checkPermissions';

  /**
   * @param action beaviour of the method to exhibit
   * @param args arguments to be used by the specified action
   * @return method to be invoked
   * @description To dispatch actual method
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    return invokeMethod(action, input, output, options);
  }

  /**
   * @param methodName String value of local method to invoke
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description flex card invokeable method
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if (methodName.equals(METHODNAME_CHECK_PERMISSIONS)) {
      return checkPermissions(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description checks the permissions user has to perform action on flexcard
   */
  private boolean checkPermissions(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    output.put(
      'canCancel',
      FeatureManagement.checkPermission(CANCEL_CUSTOM_PERMISSION)
    );
    output.put(
      'canView',
      FeatureManagement.checkPermission(VIEW_CUSTOM_PERMISSION)
    );
    output.put(
      'canSuspendUnsuspend',
      FeatureManagement.checkPermission(SUSPEND_UNSUSPEND_CUSTOM_PERMISSION)
    );
    output.put(
      'canFraudCancel',
      FeatureManagement.checkPermission(FRAUD_CANCEL_CUSTOM_PERMISSION)
    );
    return true;
  }
}
