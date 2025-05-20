/**
 * @author Naman Garg
 * @since  Jan 2025
 * @description Service class for AMBIT Integration
 */
public with sharing virtual class CommercialAMBITService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );
  /**
   * @description makes rest callout to mule to AMBIT System
   * @param payload AMBIT payload.
   * @return HttpCalloutResponse response from mule
   */
  public virtual HttpCalloutResponse createAMBITQuote(
    CommercialAMBITRequestModel payload
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Content-type', 'application/json');
    return CALLOUT.makeRestCallout(
      Label.CommercialAMBITEndPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(payload)
    );
  }
}
