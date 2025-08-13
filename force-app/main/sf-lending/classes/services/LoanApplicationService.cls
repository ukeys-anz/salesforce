/**
 * @author ramvilas
 * @since May 2025
 * @description service class for Loan Application API callouts
 * @group Services
 */
public with sharing virtual class LoanApplicationService extends Service {
  private static final Lib_HttpCallout HTTP_CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @param ocvId customer id used to fetch loan details
   * @param loanAccNumber param to get the loan changes
   * @return `HttpCalloutResponse` the api response
   * @description fetches loan deatils from lex api
   */
  public virtual HttpCalloutResponse getLoanApplicationDetails(
    String ocvId,
    String loanAccNumber
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      String.format(
        Label.MS_Get_LoanAccount,
        new List<String>{ loanAccNumber }
      ),
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param loanAppNumber loan application number
   * @param ocvId ocv id of the customer account
   * @return `HttpCalloutResponse` the api response
   * @description cancelResidentialLoanApp cancels residential loan application
   */
  public virtual HttpCalloutResponse cancelResidentialLoanApp(
    String loanAppNumber,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');
    headers.put('Content-Length', '0');
    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      Label.MS_Cancel_Loan_Application.replace('{loanAppNum}', loanAppNumber),
      HTTP_METHOD.HTTP_POST,
      headers,
      null
    );
    return response;
  }
}
