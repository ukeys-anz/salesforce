/**
 * @description       :
 * @author            : Anuj jain
 * @group             :
 * @last modified on  : 02-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
global with sharing class TFMRemoteActionUtility implements omnistudio.VlocityOpenInterface, Callable {
  private static final string COL_HEADER_BSB = 'bsb';
  private static final string COL_HEADER_DISPLAYNAME = 'displayName';
  private static final string COL_HEADER_ACCOUNTNUMBER = 'accountNumber';
  private static final string COL_HEADER_CLOSED = 'closed';
  private static final string COL_HEADER_JOINTACCOUNT = 'jointAccount';
  private static final string COL_HEADER_STATE = 'state';
  private static final string COL_HEADER_ACCOUNTNAME = 'accountName';
  private static final string COL_HEADER_ACCOUNTSTATUS = 'accountStatus';
  private static final string COL_HEADER_ACCOUNTTYPE = 'accountType';
  private static final string COL_HEADER_SHARINGSTATUS = 'sharingStatus';
  private static final String ANZTOKENTYPE = 'staffRqfCustomer';
  private static final String ISVALIDACTION = 'isValidAction';
  private static final String LABELTRUE = 'true';
  private static final String IDVALUE = 'IDValue';
  private static final String ACCOUNTID = 'accountId';
  private static final String ENABLED = 'enabled';
  private static final String ACCOUNTS = 'accounts';
  private static final String CONSENTID = 'consentId';
  private static final String ARRANGEMENTID = 'arrangementId';

  // Remote methods
  private static final String UPDATEDISCLOUSURESTATUS = 'updatedisclosureStatus';
  private static final String GETORMODIFYJOINTACCOUNTNOTIFICATIONAPI = 'getORModifyJointAccountNotificationAPI';
  private static final String GETJOINTACCOUNTPERMISSIONSLIST = 'getJointAccountPermissionsList';
  private static final String GETCONSENTACCOUNTLIST = 'getConsentAccountList';
  private static final String REVOKECONSENT = 'revokeConsent';
  private static final String JOINTACCOUNTNOTIFICATION = 'JointAccountNotification';
  private static final String JOINTACCOUNTACTION = 'JointAccountPermissions';
  private static final String FROMANZPLUSACTION = 'FromANZPlus';
  private static final String GETCONSENTLIST = 'getConsentsList';
  private static final String CONSENTMANAGEMENTACTION = 'consentMgmtAccountList';

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
    if (methodName.equals(GETORMODIFYJOINTACCOUNTNOTIFICATIONAPI)) {
      return getORModifyJointAccountNotificationAPI(input, output, options);
    } else if (methodName.equals(UPDATEDISCLOUSURESTATUS)) {
      return updatedisclosureStatus(input, output, options);
    } else if (methodName.equals(GETJOINTACCOUNTPERMISSIONSLIST)) {
      return getJointAccountPermissionsList(input, output, options);
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
    string accountId = (string) input.get(ACCOUNTID);
    boolean emailEnabled = (boolean) input.get(ENABLED);
    Map<String, String> headers = new Map<String, String>();
    map<string, object> responseMap = new Map<string, object>();
    string action;
    if (!string.isBlank(accountId) && emailEnabled != null) {
      action = JOINTACCOUNTACTION;
    } else {
      action = JOINTACCOUNTNOTIFICATION;
    }
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    headers = setCommonStaffTokenRequest(
      (String) input.get(IDVALUE),
      action,
      api
    );
    String isValid;
    if (Test.isRunningTest()) {
      isValid = LABELTRUE;
    } else {
      isValid = headers.get(ISVALIDACTION);
    }
    if (headers != null && isValid == LABELTRUE) {
      //removing valid action from header
      headers.remove(ISVALIDACTION);
      HttpCalloutResponse response = api.getORModifyJointAccountNotificationAPI(
        headers,
        accountId,
        emailEnabled
      );

      if (response != null) {
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          response.body
        );
        output.put('jointAccNotifications', responseMap);
        output.put('showSuccessToast', true);
        output.put('isValid', isValid);
        return true;
      } else {
        output.put('showSuccessToast', false);
      }
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description returns ui options for Joint Account Permission Details
   */
  private boolean updatedisclosureStatus(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    Map<String, String> headers = new Map<String, String>();
    Map<String, Object> jsonResp = new Map<String, Object>();
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    headers = setCommonStaffTokenRequest(
      (String) input.get(IDVALUE),
      JOINTACCOUNTACTION,
      api
    );
    String inputVar = (string) input.get(COL_HEADER_ACCOUNTNUMBER);
    List<String> inputs = inputVar.split(' ');
    String accountNumber = inputs[1];
    String bsb = inputs[0];
    Boolean enabled = Boolean.valueOf((String) input.get(ENABLED));
    String isValid;
    if (Test.isRunningTest()) {
      isValid = LABELTRUE;
    } else {
      isValid = headers.get(ISVALIDACTION);
    }
    if (headers != null && isValid == LABELTRUE) {
      //removing valid action from header
      headers.remove(ISVALIDACTION);
      HttpCalloutResponse response = api.updatedisclosureStatus(
        bsb,
        accountNumber,
        enabled,
        headers
      );
      responseMap = (Map<String, Object>) JSON.deserializeUntyped(
        response.body
      );
      output.put('responseMap', responseMap);
      output.put('isValid', isValid);
      return true;
    }
    return false;
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
    Map<string, object> responseMap = new Map<string, object>();
    Map<String, String> headers = new Map<String, String>();
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    headers = setCommonStaffTokenRequest(
      (String) input.get(IDVALUE),
      JOINTACCOUNTACTION,
      api
    );
    String isValid;
    if (Test.isRunningTest()) {
      isValid = LABELTRUE;
    } else {
      isValid = headers.get(ISVALIDACTION);
    }
    if (headers != null && isValid == LABELTRUE) {
      //removing valid action from header
      headers.remove(ISVALIDACTION);
      HttpCalloutResponse response = api.getJointAccountPermissions(headers);

      responseMap = (Map<String, Object>) JSON.deserializeUntyped(
        response.body
      );
      output.put('getJointAccountPermissions', responseMap);
      output.put('isValid', isValid);
      return true;
    }
    return false;
  }
  /**
   * @param idValue value for staffModel.idValue
   * @param action value  forstaffModel.action
   * @param api TFMSearchCustomerAPIRepository instance
   * @return `map<string,string>`
   * @description returns ui options for Joint Account Permission Details
   */
  public static map<string, string> setCommonStaffTokenRequest(
    string idValue,
    string action,
    TFMSearchCustomerAPIRepository api
  ) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    Map<String, String> headers = new Map<String, String>();
    staffModel.headers = headers;
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = idValue;
    staffModel.anzTokenType = ANZTOKENTYPE;
    staffModel.action = action;
    headers = api.getValidStaffToken(staffModel);
    return headers;
  }
}
