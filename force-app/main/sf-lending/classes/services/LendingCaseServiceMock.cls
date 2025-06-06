/**
 * @author Jaya Srivastava
 * @since Jan 2025
 * @description Mock service class for Lending Cases
 */
public with sharing class LendingCaseServiceMock extends LendingCaseService {
  /**
   * @description constructor which sets default code as succesful
   */
  public LendingCaseServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  private static final String SUBMIT_LOAN_AMOUNT_CHANGE_APPROVAL = getStaticResource(
    'mock_SubmitLoanAccountChangeApproval'
  );

  /**
   * @param caseRecord Case
   * @param requestBody LendingCaseRequestModel
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for Case Approve/Reject api
   */

  public override HttpCalloutResponse updateCaseStatusApproveReject(
    Case caseRecord,
    LendingCaseRequestModel requestBody
  ) {
    if (!preset) {
      response.body = LendingCaseServiceMock.SUBMIT_LOAN_AMOUNT_CHANGE_APPROVAL;
    }
    return response;
  }
}
