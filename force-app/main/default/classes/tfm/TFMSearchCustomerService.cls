/** 
@author Hinduja Upadhyay
* @since DEC 2023
* @description Service class for serach customer functionality 
* @group Service
*/
public with sharing class TFMSearchCustomerService extends Service {
  private static final String AUTHORIZATION = 'Authorization';
  private static final String ISVALIDACTIONKEY = 'isValidAction';
  private static final String LABELFALSE = 'false';
  /**
   *
   * Map Enum Id Type to camel case values required by Forge endpoint
   */
  private static final Map<Service.IdType, String> IDTYPEMAP = new Map<Service.IdType, String>{
    Service.idType.OCVID => 'ocvId=',
    Service.idType.PERSONAID => 'personaId=',
    Service.idType.IDENTIFIER => 'identifier=',
    Service.idType.UUID => 'uuid='
  };
  /**
   * @param staffModel wrapper class having all the variables
   * @return headers
   * @description fetches staff JWT from mule api and get the valid profiles
   */
  public override Map<String, String> getValidStaffToken(
    StaffTokenRequestModel staffModel
  ) {
    String isValidAction = LABELFALSE;
    Map<String, String> headers = new Map<String, String>();
    String token;
    if (!Test.isRunningTest()) {
      try {
        headers = setCalloutCommonHeaders(staffModel);
        token = headers.get(AUTHORIZATION);
      } catch (Exception e) {
        return null;
      }
    } else {
      token = staffModel.headers.get(AUTHORIZATION);
    }
    isValidAction = TFMCheckADGroupAccessUtil.checkADGroupWithfunctionality(
      staffModel.action,
      token.substringAfter('')
    );
    headers.put(ISVALIDACTIONKEY, isValidAction);
    return headers;
  }

  /**
   * @param staffModel wrapper class having all the variables
   * @return Boolean response stating action is valid or invalid
   * @description fetches staff JWT from mule api and get the valid profiles
   */
  public override HttpCalloutResponse searchCustAPI(
    StaffTokenRequestModel staffModel
  ) {
    staffModel.headers.putAll(setCommonHeadersInMap());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_SearchCustomer_API +
        +IDTYPEMAP.get(staffModel.idType) +
        staffModel.idValue,
      HTTP_METHOD.HTTP_GET,
      staffModel.headers,
      null
    );
    return response;
  }
  /**
   * @param staffModel wrapper class having all the variables
   * @param userInternalId Internal User Id that we receive from SearchCustomer API
   * @param deviceResourceId AppCorrelation Id for the device
   * @return api response
   * @description gets the Customer's device details without biometrics
   */
  public override HttpCalloutResponse getDeviceDetailsWithoutBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String deviceResourceId
  ) {
    staffModel.headers.putAll(setCommonHeadersInMap());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_GetDeviceWithoutBiometric.replace(
          '{userInternalId}',
          userInternalId
        )
        .replace('{deviceReferenceId}', deviceResourceId),
      HTTP_METHOD.HTTP_GET,
      staffModel.headers,
      null
    );
    return response;
  }
  /**
   * @param staffModel wrapper class having all the variables
   * @param userInternalId Internal User Id that we receive from SearchCustomer API
   * @param appCorrelationId AppCorrelation Id for the device
   * @return api response
   * @description gets the Customer's device details without biometrics
   */
  public override HttpCalloutResponse getDeviceDetailsWithBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String appCorrelationId
  ) {
    staffModel.headers.putAll(setCommonHeadersInMap());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_GetDeviceWithBiometric.replace(
          '{userInternalId}',
          userInternalId
        )
        .replace('{appCorrelationId}', appCorrelationId),
      HTTP_METHOD.HTTP_GET,
      staffModel.headers,
      null
    );
    return response;
  }

  /**
   * @param headers headers to call api
   * @param accountId  accountId value of the joint account
   * @param emailEnabled joint account status
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public override HttpCalloutResponse getORModifyJointAccountNotificationAPI(
    map<string, string> headers,
    string accountId,
    boolean emailEnabled
  ) {
    headers.putAll(setCommonHeadersInMap());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    if (!string.isBlank(accountId) && emailEnabled != null) {
      headers.put('Content-Type', 'application/json');
      String payload =
        '{"account_id":"' +
        accountId +
        '","email_enabled":' +
        emailEnabled +
        '}';

      HttpCalloutResponse response = calloutService.makeRestCallout(
        System.Label.MS_JointNotificationSettingAPI,
        HTTP_METHOD.HTTP_POST,
        headers,
        payload
      );
      return response;
    } else {
      HttpCalloutResponse response = calloutService.makeRestCallout(
        System.Label.MS_JointNotificationSettingAPI,
        HTTP_METHOD.HTTP_GET,
        headers,
        null
      );
      return response;
    }
  }

  /**
   * @param bsb bsb value of the joint account
   * @param accountNumber joint account number
   * @param enabled disclosure status
   * @param headers headers to call api
   * @return HttpCalloutResponse response
   * @description gets the Customer's device details with biometrics
   */
  public override HttpCalloutResponse updatedisclosureStatus(
    String bsb,
    String accountNumber,
    Boolean enabled,
    Map<String, String> headers
  ) {
    headers.putAll(setCommonHeadersInMap());
    headers.put('Content-Type', 'application/json');
    String payload =
      '{"bsb":"' +
      bsb +
      '","account_number":"' +
      accountNumber +
      '","enabled":' +
      enabled +
      '}';

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Update_Disclosure_Status,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );

    return response;
  }

  /**
   * @param headers headers to call api
   * @return HttpCalloutResponse response
   * @description gets Joint Accounts List
   */
  public override HttpCalloutResponse getJointAccountPermissions(
    Map<String, String> headers
  ) {
    headers.putAll(setCommonHeadersInMap());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_GetJointAccountPermissions_API,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
  /**
   * @description method is setting common headers used in api callout
   * @return Map<String, String>
   */
  public static Map<String, String> setCommonHeadersInMap() {
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('x-anz-application-id', 'aegis-admin-portal');
    headers.put('traceparent', CommonUtil.generateTraceParent());
    return headers;
  }
}
