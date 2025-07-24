/**
 * @author ramvilas
 * @since May 2025
 * @description mule implementation of the API service for Home Loan account
 * @group Services
 */

public with sharing virtual class HomeLoanHistoryService extends Service {
  private static final Lib_HttpCallout HTTP_CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @param ocvId customer id used to fetch list of loan changes
   * @param loanAccNumber param to get the list of loan changes
   * @return `HttpCalloutResponse` the api response
   * @description fetches list of loan changes from lex api
   */
  public virtual HttpCalloutResponse getListOfLoanAccountChanges(
    String ocvId,
    String loanAccNumber
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      String.format(
        Label.MS_Get_LoanChanges,
        new List<String>{ loanAccNumber }
      ),
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }
}
