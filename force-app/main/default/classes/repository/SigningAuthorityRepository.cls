/**
 * @author Hrushikesh
 * @since Dec 2023
 * @description AlterAccountSignMode API repository for all update number of signature callouts
 * @group Repository
 */
public with sharing class SigningAuthorityRepository extends RepositoryBase {
  private static final String DEFAULT_FAILURE_MESSAGE = 'Downstream system integration has failed. Please refresh and try again. If issue persists please contact your System Administrator raise an incident.';

  /**
   * @param financialAccountNumber financial account number
   * @param signMode sign mode of the account
   * @param ocvId required to make the callout to Mulesoft
   * @return `AlterAccountSignModeModel` response of the api
   * @description updateSigningAutority updates number of signature field
   */
  public AlterAccountSignModeModel updateSigningAutority(
    String financialAccountNumber,
    Integer signMode,
    String ocvId
  ) {
    AlterAccountSignModeModel responseWrapper = new AlterAccountSignModeModel();
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.updateSigningAutority(
      financialAccountNumber,
      signMode,
      ocvId
    );
    try {
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        responseWrapper.status = 'Success';
        responseWrapper.httpCode = response.statusCode;
      } else {
        if (responseWrapper.errors != null) {
          responseWrapper.errors = AlterAccountSignModeModel.parse(
            response.error.getMessage()
          );
          for (
            AlterAccountSignModeModel.Details detail : responseWrapper.errors.details
          ) {
            if (detail.isAnzError) {
              responseWrapper.httpCode = detail.errorCode;
              responseWrapper.message = detail.reason;
            }
          }
        }
        if (String.isBlank(String.valueOf(responseWrapper.httpCode))) {
          responseWrapper.httpCode = response.statusCode;
          responseWrapper.isDefaultError = true;
          responseWrapper.message = DEFAULT_FAILURE_MESSAGE;
        }
        responseWrapper.status = 'Error';
      }
      return responseWrapper;
    } catch (Exception e) {
      handleErrors(response, e, SigningAuthorityRepository.class);
      return null;
    }
  }
}
