/**
 * @author Shermal Warnakula
 * @since 09/2021
 * @description UI API implementation of the API service
 * @group Services
 */
public with sharing class UIAPIService extends Service {
  /**
   * @description fetches Picklist information from standard Salesforce UI API
   * @param endPoint the end point of the API callout
   * @return `HttpCalloutResponse` the api response
   */
  public override HttpCalloutResponse getPickListValueInfo(String endPoint) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('Content-Type', 'application/x-www-form-urlencoded');
    headers.put('Authorization', 'Bearer ' + UserInfo.getSessionId());

    HttpCalloutResponse response = calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }
}
