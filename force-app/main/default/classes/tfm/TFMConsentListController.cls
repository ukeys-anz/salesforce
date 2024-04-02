/**
 * @description       : Controller class for TFMConsentsListParentCard FlexCard
 * @author            : Anuj jain
 * @group             : TFM
 * @last modified on  : 03-22-2024
 **/
global with sharing class TFMConsentListController implements omnistudio.VlocityOpenInterface, Callable {
  private static final String METHODNAMECONSENTLIST = 'getConsentsList';
  private static final String IPNAME = 'TFM_ProcessConsentListResponse';

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
    if (methodName.equals(METHODNAMECONSENTLIST)) {
      return getConsentsList(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Boolean getConsentsList(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    Map<String, Object> ipOutput = new Map<String, Object>();
    Map<String, Object> ipOptions = new Map<String, Object>();

    responseMap.put(
      TFMConstants.RECORDID,
      (String) input.get(TFMConstants.RECORDID)
    );

    ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(
      IPNAME,
      responseMap,
      ipOptions
    );

    output.put('output', ipOutput);
    return true;
  }
}