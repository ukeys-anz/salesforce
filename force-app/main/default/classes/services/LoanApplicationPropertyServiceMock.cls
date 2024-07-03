/**
 * @author Peter Charalambous
 * @since Thu Jun 06 2024
 * @description Mock service class for Loan Property
 */

public with sharing class LoanApplicationPropertyServiceMock extends LoanApplicationPropertyService {
  /**
   * @description constructor which sets default code as successful
   */
  public LoanApplicationPropertyServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  /**
   * @param payload payload to send to API
   * @param ocvId ocv id of account
   * @param collateralAssessmentId collateral assessment id
   * @return `HttpCalloutResponse` the api response
   * @description reasses collateral assesment
   */
  public override HttpCalloutResponse reassessCollateralAssessment(
    String payload,
    String ocvId,
    String collateralAssessmentId
  ) {
    return response;
  }
}
