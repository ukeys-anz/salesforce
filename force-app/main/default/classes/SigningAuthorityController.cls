/**
 * @author Hrushikesh
 * @since Dec 2023
 * @description Controller for Signing Authority Updates
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=2253292239
 */
global with sharing class SigningAuthorityController implements Callable {
  private static final String METHODNAME_UPDATE_SIGN_AUTH = 'updateSigningAutority';

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
    if (methodName.equalsIgnoreCase(METHODNAME_UPDATE_SIGN_AUTH)) {
      return updateSigningAutority(input, output, options);
    }
    return false;
  }

  /**
   * @description  The updateSigningAutority is the method to make the callout to Mulesoft to update the number of signature field
   * @param input arg for omnistudio IP
   * @param output arg for omnistudio IP
   * @param options arg for omnistudio IP
   * @return `AlterAccountSignModeModel` response of the api
   */
  @AuraEnabled
  public static Boolean updateSigningAutority(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String financialAccountNumber = (String) input.get('finAccountNumber');
    String signMode = (String) input.get('numberOfSign');
    String ocvId = (String) input.get('ocvId');
    String finAccountId = (String) input.get('finAccountId');
    AlterAccountSignModeModel apiResponse = new AlterAccountSignModeModel();
    try {
      SigningAuthorityRepository api = new SigningAuthorityRepository();
      apiResponse = api.updateSigningAutority(
        financialAccountNumber,
        Integer.valueOf(signMode),
        ocvId
      );

      output.put('httpCode', JSON.serialize(apiResponse.httpCode));
      output.put('isDefaultError', JSON.serialize(apiResponse.isDefaultError));
      output.put('status', JSON.serialize(apiResponse.status));

      String caseRecordId = (String) input.get('caseRecordId');
      SigningAuthorityUpdateActions.caseStatusUpdate(
        caseRecordId,
        apiResponse.httpCode == 200
      );
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
    }
    return true;
  }
}
