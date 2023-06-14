/**
 * @author Nagendra Singh
 * @since 06/2023
 * @description  Omni logger class to log errors or info logs from omnistudio compoments
 */
global without sharing class OmniLogger implements Callable {
  /**
   * @description invokeMethod to handle insertion of logs from omnistudio.
   * @param methodName Method named to be called.
   * @param inputMap Input from omnistudio component as a key value pair.
   * @param outMap Output to be returned as a response to caller Omnicomponent.
   * @param options Options passed from omnistudio.
   * @return Object containing outMap, which can contain custom message and should return success as false and true based on logic.
   */
  global Object invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    Boolean success = true;
    String error = '';
    try {
      if (methodName == 'insertError') {
        insertError(inputMap, outMap, options);
      }
    } catch (Exception e) {
      error = e.getMessage() + ' StackTrace -> ' + e.getStackTraceString();
      success = false;
    }
    outMap.put('success', success);
    outMap.put('error', error);
    return success;
  }

  /**
   * @description insertError to handle insertion of error logs from omnistudio.
   * @param inputMap Input from omnistudio component as a key value pair.
   * @param outMap Output to be returned as a response to caller Omnicomponent.
   * @param options Options passed from omnistudio.
   */
  public void insertError(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    Logger.error('Error saving Interaction')
      .setPayloadForOmniStudio(JSON.serializePretty(inputMap));
    Logger.saveLog();
    outMap.put('outputFromIP', 'Error');
  }

  /**
   * @description Overriden method from Callable interface to invoke methods dynamically based on action passed.
   * @param action Dynamic method name to be called.
   * @param args Dynamic arguments to passed from omnistudio.
   * @return Object containing outMap, which can contain custom message and should return success as false and true based on logic.
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    return invokeMethod(action, input, output, options);
  }
}
