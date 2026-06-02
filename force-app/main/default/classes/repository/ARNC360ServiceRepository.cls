/**
 * @author Ayushi Gupta
 * @since  03/2026
 * @group Platform
 * @description ARNC360ServiceRepository class is responsible for making callouts to the ARNC360Service and handling the responses. It abstracts the callout logic and error handling for better maintainability and testability.
 */
public with sharing class ARNC360ServiceRepository extends RepositoryBase {
  /**
   * @param calloutRequest calloutRequest
   * @return `HttpCalloutResponse` HttpCalloutResponse
   * @description This method makes callout of cache related accounts
   */
  public HttpCalloutResponse makeCacheAccountCallout(
    ExternalObjectQueryBase.ExternalObjectCalloutRequestBase calloutRequest
  ) {
    ARNC360Service service = (ARNC360Service) ServiceProvider.getService(
      ARNC360Service.class
    );
    try {
      HttpCalloutResponse response = service.queryExternalData(calloutRequest);
      if (response.successful == true) {
        return response;
      }
      if (response.statusCode >= 500) {
        Logger.error(
          'Error - Status Code - ' + response.statusCode,
          response.error,
          Logger.Severity.HIGH
        );
        Logger.saveLog();
      }
      handleErrors(null, response.error, ARNC360ServiceRepository.class);
      throw response.error;
    } catch (Exception e) {
      handleErrors(null, e, ARNC360ServiceRepository.class);
      throw e;
    }
  }
}
