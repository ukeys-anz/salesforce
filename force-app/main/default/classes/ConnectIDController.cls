/**
 * @author ducnamle
 * @since Dev 2023
 * @description Controller for ConnectID flex card
 */
global with sharing class ConnectIDController implements omnistudio.VlocityOpenInterface, Callable {
  /**
   * @param action String value of local method to invoke
   * @param args arg map that will contain input, output and options map
   * @return `Object`
   * @description flex card invokeable method overridden by callable interface
   */
  global Object call(String action, Map<String, Object> args) {
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
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Boolean result = true;
    if (methodName.equals('getConnectIDs')) {
      return getConnectIDs(input, output, options);
    } else {
      result = false;
    }
    return result;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description get list of getConnectID
   */
  private static Boolean getConnectIDs(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String ocvId = (String) input.get('ocvId');
    ConnectIDModel response = new ConnectIDModel();

    try {
      ConnectIDRepository connectIdApi = new ConnectIDRepository();
      response = connectIdApi.getConsentHistoryList(ocvId);
    } catch (Exception ex) {
      response.hasError = true;
      Logger.error('Unable to get Consent History. ' + ex.getMessage(), ex);
      Logger.saveLog();
    }
    output.put('data', JSON.deserializeUntyped(JSON.serialize(response)));
    return true;
  }
}
