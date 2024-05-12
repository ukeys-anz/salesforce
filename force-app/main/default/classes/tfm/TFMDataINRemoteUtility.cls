/**
 * @description       : Controller class for TFMDataINListParentCard FlexCard
 * @author            : Anuj jain
 * @group             : TFM
 * @last modified on  : 03-22-2024
 **/
global with sharing class TFMDataINRemoteUtility implements omnistudio.VlocityOpenInterface, Callable {
  private static final String GETDATAINCONSENTSLISTAPI = 'getDataINConsentsListAPI';
  private static final String GETDATAINACCOUNTLISTAPI = 'getDataINAccountListAPI';
  private static final String EXPORTCONSENT = 'exportConsent';
  private static final String REVOKECONSENT = 'revokeConsent';
  private static final String TRANSFORMDATASCOPES = 'transformDataScopes';
  private static final String ISVALID = 'isValid';
  private static final String LABELCONSENT = 'consent';

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
    if (methodName.equals(GETDATAINCONSENTSLISTAPI)) {
      return getDataINConsentsListAPI(input, output, options);
    } else if (methodName.equals(GETDATAINACCOUNTLISTAPI)) {
      return getDataINAccountListAPI(input, output, options);
    } else if (methodName.equals(EXPORTCONSENT)) {
      return exportConsent(input, output, options);
    } else if (methodName.equals(REVOKECONSENT)) {
      return revokeConsent(input, output, options);
    } else if (methodName.equals(TRANSFORMDATASCOPES)) {
      return transformDataScopes(input, output, options);
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
  private boolean getDataINConsentsListAPI(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMDataINAPIRepository api = new TFMDataINAPIRepository();
    try {
      output.putAll(
        formOutputMap(
          api.getDataINConsentsListAPI(staffModel),
          TFMConstants.DATAINCONSENTLIST
        )
      );
    } catch (Exception e) {
      output.putAll(exceptionLoggerMethod(e));
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private boolean getDataINAccountListAPI(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    String consentIdValue = (String) input.get(TFMConstants.CONSENTIDSTRING);
    TFMDataINAPIRepository api = new TFMDataINAPIRepository();
    try {
      output.putAll(
        formOutputMap(
          api.getDataINAccountListAPI(staffModel, consentIdValue),
          TFMConstants.DATAINACCOUNTLIST
        )
      );
    } catch (Exception e) {
      output.putAll(exceptionLoggerMethod(e));
    }
    return true;
  }
  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for consent Account details outcomes
   */
  private Boolean exportConsent(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    String consentId = (String) input.get(TFMConstants.CONSENTID);
    String methodName = (String) input.get(TFMConstants.EXPORTMETHODNAME);
    TFMDataINAPIRepository api = new TFMDataINAPIRepository();
    try {
      output.putAll(
        formOutputMap(
          api.exportConsent(methodName, consentId, staffModel),
          TFMConstants.EXPORTRESPONSE
        )
      );
    } catch (Exception e) {
      output.putAll(exceptionLoggerMethod(e));
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for consent Account details outcomes
   */
  public Boolean revokeConsent(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMDataINAPIRepository api = new TFMDataINAPIRepository();
    String consentId = (String) input.get(TFMConstants.CONSENTID);
    try {
      output.putAll(
        formOutputMap(
          api.revokeConsent(consentId, staffModel),
          TFMConstants.REVOKERESPONSE
        )
      );
    } catch (Exception e) {
      output.putAll(exceptionLoggerMethod(e));
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns dataScopeMap
   */
  public static Boolean transformDataScopes(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, String> dataScopeMap = new Map<String, String>();
    String dataScopevalue = String.valueOf(
      input.get(TFMConstants.DATASCOPESVALUE)
    );
    if (String.isBlank(dataScopevalue)) {
      return false;
    }
    List<String> dataScopeValueList = dataScopevalue.subString(
        1,
        dataScopevalue.length() - 1
      )
      .split(TFMConstants.COMMA);
    for (String str : dataScopeValueList) {
      String tempStr = str.replaceAll(
        TFMConstants.DATASCOPEREPLACE,
        TFMConstants.EMPTY
      );
      dataScopeMap.put(
        tempStr.replace(TFMConstants.UNDERSCORE, TFMConstants.EMPTY),
        TFMConstants.LABELTRUE
      );
    }
    output.put(TFMConstants.DATASCOPEMAP, dataScopeMap);
    return true;
  }

  /**
   * @param response api response
   * @param mapKeyValue to add key in output map
   * @return `Map<String, Object>`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Map<String, Object> formOutputMap(
    HttpCalloutResponse response,
    String mapKeyValue
  ) {
    Map<String, Object> output = new Map<String, Object>();
    if (response.statusCode == 401 || response.statusCode == 403) {
      output.put(ISVALID, false);
      return output;
    }
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    if (mapKeyValue == TFMConstants.REVOKERESPONSE) {
      RevokeResponse responseWrappper = (RevokeResponse) JSON.deserialize(
        JSON.serialize(responseMap.get(LABELCONSENT)),
        RevokeResponse.class
      );
      output.put(TFMConstants.REVOKERESPONSE, responseWrappper.state);
    } else {
      output.put(mapKeyValue, responseMap);
    }
    output.put(TFMConstants.SHOWTOAST, true);
    output.put(ISVALID, true);
    return output;
  }
  /**
   * @param e exception from method
   * @return `Map<String, Object>`
   * @description logs error in log object
   */
  public static Map<String, Object> exceptionLoggerMethod(Exception e) {
    Map<String, Object> output = new Map<String, Object>();
    output.put(TFMConstants.SHOWTOAST, false);
    Logger.error(e.getMessage(), e);
    Logger.saveLog();
    return output;
  }

  /**
   * @description This is wrapper class for RevokeResponse
   * @name RevokeResponse
   * @author Shivraj Kadam
   */
  public class RevokeResponse {
    public String state;
  }
}
