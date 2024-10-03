/**
 * @author @ramvilas
 * @description Controller class for flexcard to show SOPIneligible reason
 * @since August 2024
 */
global with sharing class SOPIneligibilityController implements omnistudio.VlocityOpenInterface, Callable {
  private static final ResidentialLoanApplicationRepository LOAN_APPLICATION_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  /**
   * @param action String value of local method to invoke
   * @param args arg map that will contain input, output and options map
   * @return 'Object'
   * @description flex card invokeable method overridden by callable interface
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    return invokeMethod(action, input, output, options);
  }
  /**
   * @description method to invoke controller methods
   * @param methodName
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful exection
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    // check methodName
    if (methodName == 'getIneligibleReasons') {
      return getIneligibleReasons(inputMap, outMap, options);
    }
    return false;
  }

  /**
   * @description method to invoke getIneligibleReasons method
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful getIneligibleReasons exection
   */
  private Boolean getIneligibleReasons(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      SOPIneligibilityAPIRepository sopRepo = new SOPIneligibilityAPIRepository();
      String loanId = (String) inputMap.get('loanId');

      ResidentialLoanApplication loanRec = LOAN_APPLICATION_REPOSITORY.queryRLAById(
        loanId
      );
      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }
      SOPIneligibleModel sopModel = sopRepo.getSOP(
        loanRec.Account?.OCV_ID__c,
        loanRec.SOP_Id__c
      );
      if (sopModel == null) {
        return false;
      }

      outMap.put('object', sopModel);
      return true;
    } catch (Exception ex) {
      SOPIneligibleModel sopModel = new SOPIneligibleModel();
      sopModel.isError = true;
      outMap.put('object', sopModel);
      outMap.put('toast', ex.getMessage());
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
      return false;
    }
  }
}
