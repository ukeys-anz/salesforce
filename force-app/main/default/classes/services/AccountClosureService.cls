/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description fabric seal implementation of the API Service
 * @group Services
 */
public with sharing virtual class AccountClosureService extends Service {
   /**
   * @param ocvId ocvId of the customer to generate jwt token
   * @param accountDetailsForPrechecks required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description initiateAccountClosurePrechecks to Fabric Seal
   */
  public virtual HttpCalloutResponse initiateAccountClosurePreChecks(
    String ocvId,
    List<FabricSealRequestModel> accountDetailsForPrechecks
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('Content-Type', 'application/json');
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    return calloutService.makeRestCallout(
      Label.MS_Initiate_Account_Closure,
      HTTP_METHOD.HTTP_GET,
      headers,
      JSON.serialize(accountDetailsForPrechecks)
    );
  }
}