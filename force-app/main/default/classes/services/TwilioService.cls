/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Twilio implementation of the API service
 * @group Services
 */
public with sharing class TwilioService extends Service {
  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @param endPoint the end point of the API callout
   * @return `HttpCalloutResponse` the api response
   * @description fetches chat channels (chat topics) from the Twilio API
   */
  public override HttpCalloutResponse fetchChatTopics(
    String ocvId,
    String endPoint
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }
}
