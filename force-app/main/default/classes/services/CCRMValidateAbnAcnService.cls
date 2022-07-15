/**
 * @author Boobalakrishnan Duraisamy
 * @since Mar 2022
 * @description extended service class for CCRM abn acn service callout
 * @group Service
 */
public with sharing class CCRMValidateAbnAcnService extends Service {
  /**
   * @param calloutUrl ABN or ACN callout url
   * @param abnOrAcn number to be validated
   * @return HttpCalloutResponse
   * @description fetches ABN or ACN information
   */
  public override HttpCalloutResponse getAbnAcnInformation(
    String calloutUrl,
    String abnOrAcn
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    String endPoint = 'callout:SF_MS_CCRM' + calloutUrl + abnOrAcn;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
  }
}
