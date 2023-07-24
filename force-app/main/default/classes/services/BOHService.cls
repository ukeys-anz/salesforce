/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description Service class for residential loan application
 * @group Services
 */
public with sharing class BOHService extends Service {
  public static final String FLEXCARDDATETIMEDISPLAYFORMAT = 'd MMMM y | K:mm a';

  /**
   * @param sopId sop id to retrieve customer savings and asset
   * @return `HttpCalloutResponse` the api response
   * @description fetches customer savings and assets of sop from lex api through mule
   * ===========
   * curl command in dev: grpcurl -H "Authorization: Bearer ${TOKEN}" -d '{"sop_id":"0626ba39-aeb9-4ebb-a275-01bf15aeb8d1"}' sop-service.lex-dev.apps-dev.x.gcpnp.anz:443 lex.service.sop.v1beta1.SopService/ListAssets
   * ===========
   */
  //
  public override HttpCalloutResponse getListAssets(String sopId) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.SOPID, sopId, headers); //to-do: add new enum IdType: SOPID

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:FAKE_FLEX_ENDPOINT', // + Label.MS_Get_SOPListAssets, to-do: create endpoint and url
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @description Converts the salesforce datetime into FLEXCARDDATETIMEDISPLAYFORMAT
   * @param dt Input datetime to format.
   * @return `String` formatted string in required format.
   */
  public static string getFormatedDate(DateTime dt) {
    return dt != null ? dt.format(FLEXCARDDATETIMEDISPLAYFORMAT) : null;
  }
}
