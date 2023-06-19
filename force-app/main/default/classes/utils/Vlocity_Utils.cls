/**
 * @author Laxmi
 * @since 04/2023
 * @description  To get the customer information and account numbers on OCV search
 */
global with sharing class Vlocity_Utils implements Callable {
  /**
   * @param methodName The method passed from Integration procedure
   * @param input The input from the Integration procedure
   * @param output The output to be passed to Integration procedure
   * @param options The additional parameters required
   * @return true is valid, false otherwise
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if ('getCustomerInfo'.equals(methodName)) {
      getCustomerInfo(input, output, options);
    } else if ('getKnownIssues'.equals(methodName)) {
      getKnownIssues(input, output, options);
    }
    return true;
  }

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
   * @description To get the customer Info
   * @param input The input from the Integration procedure
   * @param output The output to be passed to Integration procedure
   * @param options The additional parameters required
   */
  public void getCustomerInfo(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    try {
      String custId = String.valueOf(input.get('CustomerId'));
      String custIdentifier = (String) input.get('CustomerIdentifier');
      IDRAPIRepository idr = new IDRAPIRepository();
      IDRCustomerInformationModel result = idr.getCustomerInfo(
        custId,
        custIdentifier
      );
      System.debug('test ' + result);
      output.put('Response', JSON.serialize(result));
    } catch (Exception ex) {
      output.put('Response', '');
    }
  }

  /**
   * @description To get Known Issues field values
   * @param input The input from the Integration procedure
   * @param output The output to be passed to Integration procedure
   * @param options The additional parameters required
   */
  public void getKnownIssues(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    List<Known_Issues__c> knownIssuesList = IDRExpressComplaintController.getAllKnownIssues();
    output.put('KnownIssue', knownIssuesList);
  }
}
