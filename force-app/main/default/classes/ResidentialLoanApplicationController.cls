/**
 * @author @fangl6(Lei Fang)
 * @description controller class for flexcard to show SOP
 * @since April 2023
 */
global with sharing class ResidentialLoanApplicationController implements omnistudio.VlocityOpenInterface {
  /**
   * @description method to invoke getListAssets method
   * @param methodName
   * @param inputMap
   * @param outMap
   * @param options
   * @return getListAssets
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    // check methodName
    if (methodName == 'getListAssets') {
      return getListAssets(inputMap, outMap, options);
    }
    return false;
  }

  private Boolean getListAssets(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String sopId = (String) inputMap.get('SOP_Id__c');
      ResidentialLoanApplicationModel sopAssets = rlaRepo.getListAssets(sopId);
      outMap.put('object', JSON.deserializeUntyped(JSON.serialize(sopAssets)));
      return true;
    } catch (Exception e) {
      return false;
    }
  }
}
