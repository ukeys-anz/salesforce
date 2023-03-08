/**
 * @author Vidhya Raghavan
 * @since Dec 2022
 * @description mule implementation of the API service for Home Loan account
 * @group Services
 */

public with sharing class HomeLoanService extends Service {
  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @return `HttpCalloutResponse` the api response
   * @description fetches accounts and goals from the fabric API
   */

  public override HttpCalloutResponse getHomeLoanAccounts(String ocvId) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_HomeLoanAccountUrl,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

}
