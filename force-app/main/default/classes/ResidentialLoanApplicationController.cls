/**
 * @author @fangl6(Lei Fang)
 * @description controller class for flexcard to show SOP
 * @since April 2023
 */
global with sharing class ResidentialLoanApplicationController implements omnistudio.VlocityOpenInterface, Callable {
  /**
   * @param action String value of local method to invoke
   * @param args arg map that will contain input, output and options map
   * @return `Object`
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
    if (methodName == 'getListAssets') {
      return getListAssets(inputMap, outMap, options);
    } else if (methodName == 'getSOP') {
      return getSOP(inputMap, outMap, options);
    }
    return false;
  }

  /**
   * @description method to invoke getListAssets method
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful getListAssets exection
   */
  private Boolean getListAssets(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      ResidentialLoanApplicationModel sopAssets = rlaRepo.getListAssets(
        loanRec[0]?.Account?.OCV_ID__c,
        loanRec[0]?.SOP_Id__c
      );

      //Reassign assets and liabilities to not show any closed
      sopAssets.assetsSummary.assets = sopAssets.assetsSummary.openAssets;
      sopAssets.liabilitiesSummary.liabilities = sopAssets.liabilitiesSummary.openLiabilities;

      outMap.put('object', JSON.deserializeUntyped(JSON.serialize(sopAssets)));
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  /**
   * @description method to invoke getSOP method
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful getSOP exection
   */
  private Boolean getSOP(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
    String loanId = (String) inputMap.get('loanId');
    List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(loanId);

    SOPModel response = rlaRepo.getSOP(
      loanRec[0]?.Account?.OCV_ID__c,
      loanRec[0]?.SOP_Id__c
    );
    SOPModel.Parties[] transformedParties = new List<SOPModel.Parties>();

    if (response.sop == null) {
      return false;
    }

    for (Object row : response.sop.parties) {
      Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(row)
      );
      obj.put(
        'soleIncomeEarner',
        (Boolean) obj.get('spouseEarnsIncome') == false ? 'Yes' : 'No'
      );
      obj.put('partyDependantsCount', response.sop.dependantsCount);

      transformedParties.add(
        (SOPModel.Parties) System.JSON.deserialize(
          JSON.serialize(obj),
          SOPModel.Parties.class
        )
      );
    }
    response.sop.parties = transformedParties;

    outMap.put('object', JSON.deserializeUntyped(JSON.serialize(response)));
    return true;
  }
}
