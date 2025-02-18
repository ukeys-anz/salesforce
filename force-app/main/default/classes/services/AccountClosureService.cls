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
    List<AccountClosurePrecheckRequestModel> accountDetailsForPrechecks
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    headers.put('Content-Type', 'application/json');
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Lib_HttpCallout.RESTCalloutWrapper restWrapper = new Lib_HttpCallout.RESTCalloutWrapper();
    restWrapper.endpoint = Label.MS_Initiate_Account_Closure;
    restWrapper.method = HTTP_METHOD.HTTP_GET;
    restWrapper.headers = headers;
    restWrapper.requestBody = JSON.serialize(accountDetailsForPrechecks);
    restWrapper.timeout = 35000;
    return calloutService.makeRestCallout(restWrapper);
  }
}
