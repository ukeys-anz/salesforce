/**
 * @author Shivraj Kadam
 * @since Nov 2023
 * @description Open Banking API repository for to invoke Mule to get response
 * @group Repository
 */
public with sharing class OpenBankingAPIRepository extends RepositoryBase {
  /**
   * @param consentId consentId pass as api param
   * @param fromTimestamp fromTimestamp pass as api param
   * @param toTimestamp toTimestamp pass as api param
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description gets Consent Data Sharing History
   */
  public HttpCalloutResponse getConsentDataSharingHistory(
    String consentId,
    String fromTimestamp,
    String toTimestamp,
    StaffTokenRequestModel staffModel
  ) {
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
    HttpCalloutResponse response = s.getConsentDataSharingHistory(
      consentId,
      fromTimestamp,
      toTimestamp,
      staffModel
    );
    return handleResponse(response);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return HttpCalloutResponse response
   * @description handle received response and either return the response or throw exception
   */
  public HttpCalloutResponse handleResponse(HttpCalloutResponse response) {
    List<Integer> insufficientAccessCodes = new List<Integer>{ 401, 403, 405 };
    if (insufficientAccessCodes.contains(response.statusCode)) {
      throw new InsufficientAccessException(response.error);
    }
    if (response.successful == false) {
      throw new ServerErrorException(response.error);
    }
    return response;
  }
  /**
   * @description custom exception
   */
  public class InsufficientAccessException extends Exception {
  }
  /**
   * @description custom exception
   */
  public class ServerErrorException extends Exception {
  }
}