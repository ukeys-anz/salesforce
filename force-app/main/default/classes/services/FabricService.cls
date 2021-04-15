/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description fabric implementation of the API service
 */
public with sharing class FabricService extends Service {
  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @return `HttpCalloutResponse` the api response
   * @description fetches accounts and goals from the fabric API
   */
  public override HttpCalloutResponse getAccountsAndGoals(String ocvId) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setFabricCommonHeaders(ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_Accounts_Goals,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId customer id
   * @param accountNumber Account number for which we want to fetch the transactions
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `HttpCalloutResponse` the api response
   * @description fetches transaction history from the fabric API
   */
  public override HttpCalloutResponse getTransactionHistory(
    String ocvId,
    String accountNumber,
    String paramUrl
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setFabricCommonHeaders(ocvID, headers);

    String endPointParams = String.isNotBlank(paramUrl)
      ? paramUrl
      : '?account_number=' + accountNumber;

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Get_Transactions +
      endPointParams,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }
}
