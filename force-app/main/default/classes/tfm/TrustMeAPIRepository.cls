/**
 * @author Shivraj Kadam
 * @since Feb 2025
 * @description TrustMe repository to invoke Mule to get response for Case Update
 * @group Repository
 */
public with sharing class TrustMeAPIRepository extends RepositoryBase {
  private static final TrustMeService TRUSTME_SERVICE = (TrustMeService) Lib_InstanceProvider.forType(
    TrustMeService.class
  );
  /**
   * @param caseUpdateDetails caseUpdateDetails
   * @description send parameter to update case status
   */
  public void updateCaseStatus(TrustMeCaseUpdateModel caseUpdateDetails) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = TFMConstants.ANZ_STAFF_TOKEN_TYPE;
    staffModel.realm = TFMConstants.ANZ_REALM_SYSTEM_VALUE;

    HttpCalloutResponse response = TRUSTME_SERVICE.updateCaseStatus(
      staffModel,
      caseUpdateDetails
    );
    handleResponse(response);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @description handle received response and either return the response or throw exception
   */
  public void handleResponse(HttpCalloutResponse response) {
    List<Integer> insufficientAccessCodes = new List<Integer>{ 401, 403, 405 };
    if (insufficientAccessCodes.contains(response.statusCode)) {
      throw new InsufficientAccessException(response.error);
    }
    if (response.successful == false) {
      throw new ServerErrorException(response.error);
    }
  }

  /**
   * @description custom exception
   */
  public class InsufficientAccessException extends Exception {
    /**
     * @description InsufficientAccessException
     * @param response response
     */
    public InsufficientAccessException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from Service',
          response.error
        )
        .save();
    }
  }
  /**
   * @description custom exception
   */
  public class ServerErrorException extends Exception {
    /**
     * @description ServerErrorException
     * @param response response
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from Service',
          response.error
        )
        .save();
    }
  }
}