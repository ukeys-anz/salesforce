/**
 * @author Raman Gupta
 * @since March 2025
 * @description Service class for SOP Services
 * @group Services
 */
public with sharing virtual class SOPService extends Service {
  private static final Lib_HttpCallout HTTP_CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `HttpCalloutResponse` the api response
   * @description fetches customer information of sop from lex api through mule
   */
  public override HttpCalloutResponse getSOP(String ocvId, String sopId) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      System.Label.MS_Get_SOP + sopId,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @description update party callout
   * @param ocvId ocv id of the customer account
   * @param updateSOPAndPartyRequest post data of about you parties information
   * @param urlParameters parameters to retrieve customer information
   * @return `HttpCalloutResponse` the api response
   */
  public virtual HttpCalloutResponse updateSOPAndParty(
    String ocvId,
    SOPUpdateSOPAndPartyRequestModel updateSOPAndPartyRequest,
    List<String> urlParameters
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');
    String requestUrl = String.format(Label.MS_Update_SOP_Party, urlParameters);
    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      requestUrl,
      HTTP_METHOD.HTTP_PATCH,
      headers,
      JSON.serialize(updateSOPAndPartyRequest, true)
    );
    return response;
  }
}
