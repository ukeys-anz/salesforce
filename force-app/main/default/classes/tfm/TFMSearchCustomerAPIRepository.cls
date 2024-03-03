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
   * @return TFMPersonDigitalIdentityModel model
   * @description fetches customer details
   */
  public TFMPersonDigitalIdentityModel searchCustAPI(
    StaffTokenRequestModel staffModel
  ) {
    TFMPersonDigitalIdentityModel model;
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    HttpCalloutResponse response = s.searchCustAPI(staffModel);
    if (!response.successful) {
      handleErrors(response, null, TFMSearchCustomerAPIRepository.class);
      return null;
    }
    model = TFMPersonDigitalIdentityModel.parse(response.body);
    return model;
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
    if (!response.successful) {
      handleErrors(response, null, TFMSearchCustomerAPIRepository.class);
      return null;
    }
    return response;
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
    if (!response.successful) {
      handleErrors(response, null, TFMSearchCustomerAPIRepository.class);
      return null;
    }
    return response;
  }

  /**
   * @param headers headers to call api
   * @param accountId  accountId value of the joint account
   * @param emailEnabled joint account status
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public HttpCalloutResponse getORModifyJointAccountNotificationAPI(
    map<string, string> headers,
    string accountId,
    boolean emailEnabled
  ) {
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    HttpCalloutResponse response = s.getORModifyJointAccountNotificationAPI(
      headers,
      accountId,
      emailEnabled
    );
    if (!response.successful) {
      handleErrors(response, null, TFMSearchCustomerAPIRepository.class);
      return null;
    }
    return response;
  }

  /**
   * @param bsb bsb value of the joint account
   * @param accountNumber joint account number
   * @param enabled disclosure status
   * @param headers headers to call api
   * @return HttpCalloutResponse response
   * @description gets the Customer's device details with biometrics
   */
  public HttpCalloutResponse updatedisclosureStatus(
    String bsb,
    String accountNumber,
    Boolean enabled,
    Map<String, String> headers
  ) {
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    HttpCalloutResponse response = s.updatedisclosureStatus(
      bsb,
      accountNumber,
      enabled,
      headers
    );
    if (!response.successful) {
      handleErrors(response, null, TFMSearchCustomerAPIRepository.class);
      return null;
    }
    return response;
  }

  /**
   * @param headers headers to call api
   * @return HttpCalloutResponse response
   * @description gets gets Joint Accounts List
   */
  public HttpCalloutResponse getJointAccountPermissions(
    Map<String, String> headers
  ) {
    Service s = ServiceProvider.getService(TFMSearchCustomerService.class);
    HttpCalloutResponse response = s.getJointAccountPermissions(headers);
    if (!response.successful) {
      handleErrors(response, null, TFMSearchCustomerAPIRepository.class);
      return null;
    }
    return response;
  }
}
