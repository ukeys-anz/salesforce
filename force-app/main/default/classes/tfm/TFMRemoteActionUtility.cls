/**
 * @description       : class contains method that is used in IP/OS to invoke OB-Data out functionality
 * @author            : Anuj jain
 * @group             : TFM
 * @last modified on  : 11-15-2024
 **/
global with sharing class TFMRemoteActionUtility implements omnistudio.VlocityOpenInterface, Callable {
  // Remote methods
  private static final String UPDATEDISCLOUSURESTATUS = 'updatedisclosureStatus';
  private static final String GETORMODIFYJOINTACCOUNTNOTIFICATIONAPI = 'getORModifyJointAccountNotificationAPI';
  private static final String GETJOINTACCOUNTPERMISSIONSLIST = 'getJointAccountPermissionsList';
  private static final String GETCONSENTACCOUNTLIST = 'getConsentAccountList';
  private static final String REVOKECONSENT = 'revokeConsent';
  private static final String GETCONSENTLIST = 'getConsentsList';
  private static final String CONSENTMANAGEMENTACTION = 'consentMgmtAccountList';
  private static final String GET_TRANSFORMED_DATASCOPES = 'getTransformedDataScopes';

  /**
   * @param action String value of local method to invoke
   * @param args arg Map that will contain input, output and options Map
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
    if (methodName.equals(GETORMODIFYJOINTACCOUNTNOTIFICATIONAPI)) {
      return getORModifyJointAccountNotificationAPI(input, output, options);
    } else if (methodName.equals(UPDATEDISCLOUSURESTATUS)) {
      return updatedisclosureStatus(input, output, options);
    } else if (methodName.equals(GETJOINTACCOUNTPERMISSIONSLIST)) {
      return getJointAccountPermissionsList(input, output, options);
    } else if (methodName.equals(REVOKECONSENT)) {
      return revokeConsent(input, output, options);
    } else if (methodName.equals(GETCONSENTACCOUNTLIST)) {
      return getConsentAccountList(input, output, options);
    } else if (methodName.equals(GETCONSENTLIST)) {
      return getConsentsList(input, output, options);
    } else if (methodName.equals(GET_TRANSFORMED_DATASCOPES)) {
      return getTransformedDataScopes(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  private boolean getORModifyJointAccountNotificationAPI(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String accountId = (String) input.get(TFMConstants.ACCOUNTID);
    Boolean emailEnabled = (boolean) input.get(TFMConstants.ENABLED);
    Map<String, Object> responseMap = new Map<String, Object>();
    StaffTokenRequestModel staffModel = setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = api.getORModifyJointAccountNotificationAPI(
        staffModel,
        accountId,
        emailEnabled
      );
      if (handleStatusCode(response.statusCode)) {
        output.put('isValid', false);
      } else {
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );
        output.put('jointAccNotifications', responseMap);
        output.put('showSuccessToast', true);
        output.put('isValid', true);
      }
    } catch (Exception e) {
      output.put('showSuccessToast', false);
      logError(e);
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for Joint Account Permission Details
   */
  private Boolean updatedisclosureStatus(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    String inputVar = (String) input.get(TFMConstants.ACCOUNTNUMBER);
    //input in format XXX XXXXXXX
    List<String> inputs = inputVar.split(' ');
    String accountNumber = inputs[1];
    String bsb = inputs[0];
    Boolean enabled = Boolean.valueOf((String) input.get(TFMConstants.ENABLED));
    StaffTokenRequestModel staffModel = setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    try {
      HttpCalloutResponse response = api.updatedisclosureStatus(
        bsb,
        accountNumber,
        enabled,
        staffModel
      );
      if (handleStatusCode(response.statusCode)) {
        output.put('isValid', false);
      } else {
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );
        output.put('responseMap', responseMap);
        output.put('showSuccessToast', true);
        output.put('isValid', true);
      }
    } catch (Exception e) {
      output.put('showSuccessToast', false);
      logError(e);
      return false;
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for Joint Account Permission Details
   */
  private boolean getJointAccountPermissionsList(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    StaffTokenRequestModel staffModel = setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = api.getJointAccountPermissions(staffModel);
      if (handleStatusCode(response.statusCode)) {
        output.put('isValid', false);
      } else {
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );
        output.put('getJointAccountPermissions', responseMap);
        output.put('isValid', true);
      }
    } catch (Exception e) {
      logError(e);
      return false;
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for Consent Account
   */
  private boolean getConsentAccountList(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    List<Object> consentAccountRecords = (List<Object>) JSON.deserializeUntyped(
      String.valueOf(input.get(TFMConstants.ACCOUNTS))
    );
    String consentId = (String) input.get(TFMConstants.CONSENTID);
    StaffTokenRequestModel staffModel = setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = api.getConsentAccountList(
        staffModel,
        setConsentAccountListJson(consentAccountRecords, consentId)
      );
      responseMap = (Map<String, Object>) JSON.deserializeUntyped(
        response.body
      );
      output.put('consentAccountList', responseMap);
    } catch (Exception e) {
      logError(e);
      return false;
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for Consent Account
   */
  private boolean getTransformedDataScopes(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    String dataScopevalue = String.valueOf(input.get('dataScope'));
    Map<String, String> dataScope = transformDataScopes(dataScopevalue);
    output.put('dataScope', dataScope);
    return true;
  }

  /**
   * @param consentAccountRecords list of Object
   * @param consentId consentId
   * @return `String`
   * @description returns api response when user revoke consent for data sharing
   */
  private String setConsentAccountListJson(
    List<Object> consentAccountRecords,
    String consentId
  ) {
    List<TFMConsentAccountWrapper.ConsentAccountsWrapper> consentAccountsWrapperList = new List<TFMConsentAccountWrapper.ConsentAccountsWrapper>();
    for (Object obj : consentAccountRecords) {
      Map<String, Object> resultMap = (Map<String, Object>) obj;
      TFMConsentAccountWrapper.ConsentAccountsWrapper consentAccountsWrapperObj = new TFMConsentAccountWrapper.ConsentAccountsWrapper(
        String.valueOf(resultMap.get(TFMConstants.BSB)),
        String.valueOf(resultMap.get(TFMConstants.ACCOUNTNUMBER))
      );
      consentAccountsWrapperList.add(consentAccountsWrapperObj);
    }
    TFMConsentAccountWrapper consentAccParents = new TFMConsentAccountWrapper(
      consentId,
      consentAccountsWrapperList
    );
    return JSON.serialize(consentAccParents);
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns api response when user revoke consent for data sharing
   */
  private boolean revokeConsent(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    StaffTokenRequestModel staffModel = setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    String arrangementId = (String) input.get(TFMConstants.ARRANGEMENTID);
    try {
      HttpCalloutResponse response = api.revokeConsent(
        arrangementId,
        staffModel
      );
      if (handleStatusCode(response.statusCode)) {
        output.put('isValid', false);
      } else {
        output.put('result', 'Success');
        output.put('isValid', true);
      }
    } catch (Exception e) {
      output.put('showSuccessToast', false);
      logError(e);
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for Joint Account Permission Details
   */
  private boolean getConsentsList(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();

    StaffTokenRequestModel staffModel = setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    try {
      HttpCalloutResponse response = api.getConsentsList(staffModel);
      if (handleStatusCode(response.statusCode)) {
        output.put('isValid', false);
      } else {
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );
        output.put('consentsList', responseMap);
        output.put('isValid', true);
        output.put(TFMConstants.SHOWTOAST, true);
      }
    } catch (Exception e) {
      output.put(TFMConstants.SHOWTOAST, false);
      logError(e);
      return false;
    }
    return true;
  }

  /**
   * @param input arg for omnistudio flex card
   * @return `Map<String, Object>`
   * @description returns ui options for Joint Account Permission Details
   */
  public static Map<String, Object> getConsentDataSharingHistory(
    Map<String, Object> input
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    StaffTokenRequestModel staffModel = setStaffModel(
      (String) input.get(TFMConstants.IDVALUE)
    );
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    HttpCalloutResponse response = api.getConsentDataSharingHistory(
      String.valueOf(input.get(TFMConstants.CONSENTIDSTRING)),
      String.valueOf(input.get(TFMConstants.ORGINALCREATETIMEVALUE)),
      String.valueOf(input.get(TFMConstants.ORIGINALEXPIRETIMEVALUE)),
      staffModel
    );
    if (handleStatusCode(response.statusCode)) {
      responseMap.put('isValid', false);
      return responseMap;
    }
    responseMap.put('isValid', true);
    responseMap.putAll(
      (Map<String, Object>) JSON.deserializeUntyped(response.body)
    );
    return responseMap;
  }

  /**
   * @param dataScope value for transformDataScopes
   * @return `dataScopeMap`
   * @description returns dataScopeMap
   */
  public static Map<String, String> transformDataScopes(String dataScope) {
    Map<String, String> dataScopeMap = new Map<String, String>();
    list<String> dataScopeValueList = dataScope.subString(
        1,
        dataScope.length() - 1
      )
      .split(',');
    for (String str : dataScopeValueList) {
      String tempStr = str.replaceAll('(\\s+)', '');
      dataScopeMap.put(tempStr.replace(':', '').replace('.', ''), 'true');
    }
    return dataScopeMap;
  }

  /**
   * @param idValue value for staffModel.idValue
   * @return `StaffTokenRequestModel`
   * @description set StaffTokenRequestModel class instance
   */
  public static StaffTokenRequestModel setStaffModel(String idValue) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = idValue;
    staffModel.anzTokenType = TFMConstants.ANZTOKENTYPE;
    return staffModel;
  }

  /**
   * @param statusCode value of statusCode
   * @return `Boolean`
   * @description return Map<String, Object> that sets isvalid to true or false
   */
  public static Boolean handleStatusCode(Integer statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return true;
    }
    return false;
  }
  /**
   * @param e Excption
   * @description log's error in logger
   */
  public static void logError(Exception e) {
    Logger.error(e.getMessage(), e);
    Logger.saveLog();
  }
}
