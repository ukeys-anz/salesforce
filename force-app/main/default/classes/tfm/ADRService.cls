/** 
@author Hinduja Upadhyay
* @since Aug 2024
* @description Service class for ADR 
* @group Service
*/
public with sharing virtual class ADRService extends Service {
  TFMCommonFunctionUtility commonFuncs = new TFMCommonFunctionUtility();
  /**
   * @param  staffModel StaffTokenRequestModel
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public virtual HttpCalloutResponse getADRRows(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_ADR_API,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param  staffModel StaffTokenRequestModel
   * @param  rspId rspId
   * @param  actionToPerform actionToPerform
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public virtual HttpCalloutResponse performADRAction(
    StaffTokenRequestModel staffModel,
    String rspId,
    String actionToPerform
  ) {
    String actionUrl =
      System.Label.MS_ADR_API +
      '/' +
      rspId +
      '/' +
      actionToPerform;
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    headers.put('Content-Length', '0');
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      actionUrl,
      HTTP_METHOD.HTTP_POST,
      headers,
      null
    );
    return response;
  }
}
