/**
 * @author Jaya Srivastava
 * @since Jan 2025
 * @description API repository for Case Approve/Reject API callouts
 * @group Repository
 */
public with sharing class LendingCaseAPIRepository extends RepositoryBase {
  private static final LendingCaseService LENDING_CASE_SERVICE = (LendingCaseService) Lib_InstanceProvider.forType(
    LendingCaseService.class
  );
  /**
   * @param caseRecord Case
   * @param requestModel LendingCaseRequestModel
   * @description Make callout and get the response for Case Refinance Approve/Reject API callouts
   * @return `LendingCaseResponseModel` responseModel
   */
  public LendingCaseResponseModel updateCaseStatusApproveReject(
    Case caseRecord,
    LendingCaseRequestModel requestModel
  ) {
    HttpCalloutResponse response = LENDING_CASE_SERVICE.updateCaseStatusApproveReject(
      caseRecord,
      requestModel
    );
    return handleUpdateCaseStatusApproveRejectResponse(response);
  }
  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return LendingCaseResponseModel processed responseModel
   */
  private static LendingCaseResponseModel handleUpdateCaseStatusApproveRejectResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorUpdateCaseStatusApproveRejectException(response);
    }
    if (response.statusCode == 400) {
      throw new UserErrorUpdateCaseStatusApproveRejectException(response);
    }
    if (!response.successful) {
      throw new UnhandledUpdateCaseStatusApproveRejectException(response);
    }
    LendingCaseResponseModel responseModel = new LendingCaseResponseModel(
      response.successful,
      false
    );
    return responseModel;
  }

  /**
   * @description Exception class for ServerError on Update Case Status Approve/Reject API
   */
  public class ServerErrorUpdateCaseStatusApproveRejectException extends Exception {
    /**
     * @description Exception class for ServerError Update Case Status Approve/Reject API
     * @param response HttpCalloutResponse
     */
    public ServerErrorUpdateCaseStatusApproveRejectException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for UserError on Update Case Status Approve/Reject API
   */
  public class UserErrorUpdateCaseStatusApproveRejectException extends Exception {
    /**
     * @description Exception class for UserError Update Case Status Approve/Reject API
     * @param response HttpCalloutResponse
     */
    public UserErrorUpdateCaseStatusApproveRejectException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled Update Case Status Approve/Reject API callout
   */
  public class UnhandledUpdateCaseStatusApproveRejectException extends Exception {
    /**
     * @description Exception class for Unhandled Update Case Status Approve/Reject API
     * @param response HttpCalloutResponse
     */
    public UnhandledUpdateCaseStatusApproveRejectException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledUpdateCaseStatusApproveRejectException LendingCaseService: updateCaseStatusApproveReject',
          response.error
        )
        .save();
    }
  }
}
