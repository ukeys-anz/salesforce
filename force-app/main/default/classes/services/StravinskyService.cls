/**
 * @author Paul Boyington
 * @since May 2022
 * @description Stravinsky implementation of the API service
 * @group Services
 */
public with sharing class StravinskyService extends Service {
  /**
   * @param ocvId customer id
   * @param packageId package id
   * @param checkingAccount the account number for the checking account
   * @param savingsAccount the account number for the savings account
   * @return HttpCalloutResponse
   * @description stravinsky package closure api
   */
  public override HttpCalloutResponse closePackage(
    String ocvId,
    String packageId,
    String checkingAccount,
    String savingsAccount
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    headers.put('x-span-id', UniqueIdUtil.generateSpanId());

    Map<String, String> callBody = new Map<String, String>{
      'packageId' => packageId,
      'closeDate' => String.valueOf(Date.today()),
      'accountNumberA1' => checkingAccount,
      'accountNumberS1' => savingsAccount
    };

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.ST_Close_Package,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(callBody)
    );

    return response;
  }
}
