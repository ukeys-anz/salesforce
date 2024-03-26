/** 
@author Hinduja Upadhyay
* @since DEC 2023
* @description Service class for serach customer functionality 
* @group Service
*/
public with sharing virtual class TFMSearchCustomerService extends Service {
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
   * @return Boolean response stating action is valid or invalid
   * @description fetches staff JWT from mule api and get the valid profiles
   */
  public virtual HttpCalloutResponse searchCustAPI(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_SearchCustomer_API +
        +IDTYPEMAP.get(staffModel.idType) +
        staffModel.idValue,
      HTTP_METHOD.HTTP_GET,
      headers,
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
  public virtual HttpCalloutResponse getDeviceDetailsWithoutBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String deviceResourceId
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_GetDeviceWithoutBiometric.replace(
          '{userInternalId}',
          userInternalId
        )
        .replace('{deviceReferenceId}', deviceResourceId),
      HTTP_METHOD.HTTP_GET,
      headers,
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
  public virtual HttpCalloutResponse getDeviceDetailsWithBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String appCorrelationId
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_GetDeviceWithBiometric.replace(
          '{userInternalId}',
          userInternalId
        )
        .replace('{appCorrelationId}', appCorrelationId),
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param staffModel model class
   * @param accountId  accountId value of the joint account
   * @param emailEnabled joint account status
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public virtual HttpCalloutResponse getORModifyJointAccountNotificationAPI(
    StaffTokenRequestModel staffModel,
    String accountId,
    Boolean emailEnabled
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    if (!String.isBlank(accountId) && emailEnabled != null) {
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
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description gets the Customer's device details with biometrics
   */
  public virtual HttpCalloutResponse updatedisclosureStatus(
    String bsb,
    String accountNumber,
    Boolean enabled,
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
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
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description gets Joint Accounts List
   */
  public virtual HttpCalloutResponse getJointAccountPermissions(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
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
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description gets Consent list
   */
  public virtual HttpCalloutResponse getConsentsList(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_ForgeV2_Token' + System.Label.MS_ConsentList_API,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param  consentAccounts value of the joint account
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public virtual HttpCalloutResponse getConsentAccountList(
    StaffTokenRequestModel staffModel,
    String consentAccounts
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    headers.put('Content-Type', 'application/json');
    String payload = consentAccounts;
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_ForgeV2_Token' + System.Label.MS_consentMgmtAccountList,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );
    return response;
  }

  /**
   * @description method is setting common headers used in api callout
   * @param staffModel staff model
   * @return Map<String, String>
   */
  public Map<String, String> setCommonHeadersInMap(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCalloutCommonHeaders(staffModel);
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('x-anz-application-id', 'aegis-admin-portal');
    headers.put('traceparent', CommonUtil.generateTraceParent());
    return headers;
  }

  /**
   * @param consentId consentId pass as api param
   * @param fromTimestamp fromTimestamp pass as api param
   * @param toTimestamp toTimestamp pass as api param
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description gets Consent Data Sharing History
   */
  public virtual HttpCalloutResponse getConsentDataSharingHistory(
    String consentId,
    String fromTimestamp,
    String toTimestamp,
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_ForgeV2_Token' +
        System.Label.MS_ConsentsDataSharingHistory_API +
        consentId +
        '&from_timestamp=' +
        fromTimestamp +
        '&to_timestamp=' +
        toTimestamp,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @param arrangementId arrangementId of the record
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description it will hit the api to stop consent
   */
  public virtual HttpCalloutResponse revokeConsent(
    String arrangementId,
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    headers.put('Content-Type', 'application/json');
    String payload = '{"arrangementId":"' + arrangementId + '"}';
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_ForgeV2_Token' + System.Label.MS_Revoke_Consent,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );
    return response;
  }
}
