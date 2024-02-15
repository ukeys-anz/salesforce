/**
 * @author Hinduja Upadhyay
 * @since DEC 2023
 * @description Search Customer API repository for to invoke Mule to get response
 * @group Repository
 */
public with sharing class TFMSearchCustomerAPIRepository extends RepositoryBase {
  /**
   * @param staffModel wrapper class having all the variables
   * @return headers
   * @description to get StaffJWT token
   */
  public Map<String, String> getValidStaffToken(
    StaffTokenRequestModel staffModel
  ) {
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    try {
      Map<String, String> headers = s.getValidStaffToken(staffModel);
      if (headers != null || !headers.isEmpty()) {
        return headers;
      }
      return headers;
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * @param staffModel wrapper class having all the required inputs
   * @return HttpCalloutResponse response
   * @description fetches customer details
   */
  public HttpCalloutResponse searchCustAPI(StaffTokenRequestModel staffModel) {
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    HttpCalloutResponse response = s.searchCustAPI(staffModel);
    try {
      if (response.successful == false) {
        throw response.error;
      }
      return response;
    } catch (Exception e) {
      handleErrors(response, e, TFMSearchCustomerAPIRepository.class);
      return null;
    }
  }
  /**
   * @param staffModel wrapper class having all the required inputs
   * @param userInternalId Internal User Id that we receive from SearchCustomer API
   * @param deviceResourceId AppCorrelation Id for the device
   * @return HttpCalloutResponse response
   * @description gets the Customer's device details without biometrics
   */
  public HttpCalloutResponse getDeviceDetailsWithoutBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String deviceResourceId
  ) {
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    HttpCalloutResponse response = s.getDeviceDetailsWithoutBiometric(
      staffModel,
      userInternalId,
      deviceResourceId
    );
    try {
      if (response.successful == false) {
        throw response.error;
      }
      return response;
    } catch (Exception e) {
      handleErrors(response, e, TFMSearchCustomerAPIRepository.class);
      return null;
    }
  }
  /**
   * @param staffModel wrapper class having all the required inputs
   * @param userInternalId Internal User Id that we receive from SearchCustomer API
   * @param appCorrelationId AppCorrelation Id for the device
   * @return HttpCalloutResponse response
   * @description gets the Customer's device details with biometrics
   */
  public HttpCalloutResponse getDeviceDetailsWithBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String appCorrelationId
  ) {
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    HttpCalloutResponse response = s.getDeviceDetailsWithBiometric(
      staffModel,
      userInternalId,
      appCorrelationId
    );
    try {
      if (response.successful == false) {
        throw response.error;
      }
      return response;
    } catch (Exception e) {
      handleErrors(response, e, TFMSearchCustomerAPIRepository.class);
      return null;
    }
  }
}
