/**
 * @author Shivam Swaraj
 * @since August 2024
 * @description fabric implementation of the API service
 * @group Services
 */
public with sharing virtual class VaultService extends Service {
  /**
   * @param ocvId ocvId of the customer to generate jwt token
   * @param cardNumberToBeDetokenizedRequest required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description retrieves the tokenized card number details
   */
  public virtual HttpCalloutResponse getFullCardNumberDetails(
    String ocvId,
    DetokenizationRequestModel cardNumberToBeDetokenizedRequest
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('Content-Type', 'application/json');
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Lib_HttpCalloutConfig libConfig = new Lib_HttpCalloutConfig();
    libConfig.setLogResponseBody(false);
    calloutService.setLogResponseBody(libConfig);
    return calloutService.makeRestCallout(
      Label.MS_Get_Full_Card_Number,
      HTTP_METHOD.HTTP_GET,
      headers,
      JSON.serialize(cardNumberToBeDetokenizedRequest)
    );
  }
}