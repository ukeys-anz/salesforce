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
      headers = setCalloutCommonHeaders(staffModel);
      if (headers != null || !headers.isEmpty()) {
        token = headers.get(AUTHORIZATION);
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
    staffModel.headers.put('client_id', '{!$Credential.Username}');
    staffModel.headers.put('client_secret', '{!$Credential.Password}');
    staffModel.headers.put('x-correlation-id', CommonUtil.generateUUID());
    staffModel.headers.put('x-anz-application-id', 'aegis-admin-portal');
    staffModel.headers.put('traceparent', CommonUtil.generateTraceParent());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_ForgeV2_Token' +
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
    staffModel.headers.put('client_id', '{!$Credential.Username}');
    staffModel.headers.put('client_secret', '{!$Credential.Password}');
    staffModel.headers.put('x-correlation-id', CommonUtil.generateUUID());
    staffModel.headers.put('x-anz-application-id', 'aegis-admin-portal');
    staffModel.headers.put('traceparent', CommonUtil.generateTraceParent());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_ForgeV2_Token' +
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
    staffModel.headers.put('client_id', '{!$Credential.Username}');
    staffModel.headers.put('client_secret', '{!$Credential.Password}');
    staffModel.headers.put('x-correlation-id', CommonUtil.generateUUID());
    staffModel.headers.put('x-anz-application-id', 'aegis-admin-portal');
    staffModel.headers.put('traceparent', CommonUtil.generateTraceParent());
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_ForgeV2_Token' +
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
}
