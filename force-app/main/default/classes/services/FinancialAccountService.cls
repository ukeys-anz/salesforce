/**
 * @author Arpit Pittie
 * @since Mon Sep 30 2024
 * @description service class for Financial Account API callouts
 */
public with sharing virtual class FinancialAccountService extends Service {
  /**
   * @param ocvId customer id used to fetch linked offset
   * @param loanAccNumber param to get the offset linked with financial account
   * @return `HttpCalloutResponse` the api response
   * @description fetches offset account from lex api
   */
  public virtual HttpCalloutResponse getOffsetAccounts(
    String ocvId,
    String loanAccNumber
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-type', 'application/json');
    String urlParam = String.isBlank(loanAccNumber) ? '-' : loanAccNumber;
    ViewOffsetRequest requestBody = new ViewOffsetRequest(urlParam);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Get_Linked_Offset.replace('{loanAccount}', urlParam),
      HTTP_METHOD.HTTP_GET,
      headers,
      Json.serialize(requestBody, true)
    );
    return response;
  }

  /**
   * @description  Wrapper class to build the request body
   *
   */
  public class ViewOffsetRequest {
    public String parent;
    /**
     * @description constructor with 1 parameter
     * @param urlParam to set request body
     */
    public ViewOffsetRequest(String urlParam) {
      this.parent = 'accounts/' + urlParam;
    }
  }
}
