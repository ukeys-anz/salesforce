/**
 * @author Batya Aisman Sufrin
 * @since Dec 2023
 * @description Service class for ConnectID
 * @group Services
 */
public with sharing class ConnectIDService extends Service {
  /**
   * @param ocvId ocv Id
   * @return `HttpCalloutResponse` the api response
   * @description fetches ListConsentHistory from Lighthouse through mule
   */
  public override HttpCalloutResponse getConsentHistoryList(String ocvId) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = ocvId;
    staffModel.anzTokenType = 'staffRqfCustomer';

    Map<String, String> headers = setCalloutCommonHeaders(staffModel);
    headers.put('Content-type', 'application/json');

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.LightHouse_Get_List_Consent_History,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
}
