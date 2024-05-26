/** 
@author Hinduja Upadhyay
* @since April 2024
* @description Service class for serach customer functionality 
* @group Service
*/
public with sharing virtual class TFMAUFService extends Service {
  TFMCommonFunctionUtility commonFuncs = new TFMCommonFunctionUtility();
  /**
   * @param staffModel model to call staffJWT api
   * @param pinRefId credentials id
   * @param action action
   * @return HttpCalloutResponse response
   * @description send parameter to update Pin Status
   */
  public virtual HttpCalloutResponse updatePinStatus(
    StaffTokenRequestModel staffModel,
    String pinRefId,
    String action
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_AUF_API +
        staffModel.idValue +
        TFMConstants.API_CREDENTIALS +
        pinRefId,
      HTTP_METHOD.HTTP_PATCH,
      headers,
      setpayload(action.toLowerCase(), TFMConstants.STATUS_WITH_SMALL_S)
    );
    return response;
  }

  /**
  /**
   * @param staffModel model to call staffJWT api
   * @param action action
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public virtual HttpCalloutResponse updateStatus(
    StaffTokenRequestModel staffModel,
    String action
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_AUF_API + staffModel.idValue,
      HTTP_METHOD.HTTP_PATCH,
      headers,
      setpayload(action.toLowerCase(), TFMConstants.STATUS_WITH_SMALL_S)
    );
    return response;
  }

  /**
  /**
   * @param staffModel model to call staffJWT api
   * @param value of new mobile number
   * @return HttpCalloutResponse response
   * @description send parameter to update mobile number
   */
  public virtual HttpCalloutResponse updateMobileNumber(
    StaffTokenRequestModel staffModel,
    String value
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    headers.put('Content-Type', 'application/json');
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_AUF_API + staffModel.idValue,
      HTTP_METHOD.HTTP_PATCH,
      headers,
      setpayload(
        (TFMConstants.MOBILEPREFIX + value),
        TFMConstants.SECURITYMOBILE
      )
    );
    return response;
  }

  /**
  /**
   * @param staffModel model to call staffJWT api
   * @param value value of ocvid 
   * @return HttpCalloutResponse response
   * @description send parameter to update OCVID
   */
  public virtual HttpCalloutResponse updateOcvid(
    StaffTokenRequestModel staffModel,
    String value
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_AUF_API + staffModel.idValue,
      HTTP_METHOD.HTTP_PATCH,
      headers,
      setpayload(value, TFMConstants.AUF_OCV_ID)
    );
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param deviceResourceId resourceId of the device to be deregistered
   * @return HttpCalloutResponse response
   * @description api callout to deregister device
   */
  public virtual HttpCalloutResponse deregisterDevice(
    StaffTokenRequestModel staffModel,
    String deviceResourceId
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_AUF_API +
        staffModel.idValue +
        TFMConstants.API_CREDENTIALS +
        deviceResourceId,
      HTTP_METHOD.HTTP_DELETE,
      headers,
      null
    );
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param pin String value
   * @return HttpCalloutResponse response
   * @description send parameter to get Reset PIN link
   */
  public virtual HttpCalloutResponse resetPin(
    StaffTokenRequestModel staffModel,
    String pin
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_AUF_API +
        staffModel.idValue +
        TFMConstants.RESET_API_LINK,
      HTTP_METHOD.HTTP_PATCH,
      headers,
      setpayload(pin, TFMConstants.RESET_PIN_KEY)
    );
    return response;
  }

  /**
   * @param value value for action
   * @param field field to change
   * @return `String`
   * @description set payload that needs to send to api
   */
  public static String setpayload(String value, String field) {
    List<TFMAUFPayloadModel.TFMAUFPayload> payloadListWrapper = new List<TFMAUFPayloadModel.TFMAUFPayload>();
    TFMAUFPayloadModel.TFMAUFPayload model = new TFMAUFPayloadModel.TFMAUFPayload(
      field,
      TFMConstants.REPLACE,
      value
    );
    payloadListWrapper.add(model);
    if (field == TFMConstants.SECURITYMOBILE) {
      DateTime dt = DateTime.now();
      TFMAUFPayloadModel.TFMAUFPayload modelextr = new TFMAUFPayloadModel.TFMAUFPayload(
        TFMConstants.AUF_DATE_VARIABLE,
        TFMConstants.REPLACE,
        dt.format(TFMConstants.AUF_DATE_FORMAT)
      );
      payloadListWrapper.add(modelextr);
    }
    return JSON.serialize(payloadListWrapper);
  }
}
