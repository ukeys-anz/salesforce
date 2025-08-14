/**
 * @author ramvilas
 * @since May 2025
 * @description Mock service class for Loan Application
 */
public with sharing class LoanApplicationServiceMock extends LoanApplicationService {
  /**
   * @description constructor which sets default code as succesful
   */
  public LoanApplicationServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  private static final String GET_LOANAPPLICATION = getStaticResource(
    'mock_GetLoanApplication'
  );
  private static final string CANCEL_LOAN_APP = getStaticResource(
    'mock_cancelHomeLoanApplication'
  );
  /**
   * @param ocvId String
   * @param loanAccNumber String
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for Get Loan Application  api
   */
  public override HttpCalloutResponse getLoanApplicationDetails(
    String ocvId,
    String loanAccNumber
  ) {
    if (!preset) {
      response.body = GET_LOANAPPLICATION;
    }
    return response;
  }

  /**
   * @param loanAppNumber Loan application Number
   * @param ocvId required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description cancel home loan application through mule
   */
  public override HttpCalloutResponse cancelResidentialLoanApp(
    String loanAppNumber,
    String ocvId
  ) {
    if (!preset) {
      response.body = CANCEL_LOAN_APP;
    }

    return response;
  }
}
