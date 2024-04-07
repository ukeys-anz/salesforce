/**
 * @author Hinduja Upadhyay
 * @since DEC 2023
 * @description Search Customer API repository for to invoke Mule to get response
 * @group Repository
 */
public with sharing class TFMSearchCustomerAPIRepository extends RepositoryBase {
  /**
   * @param staffModel wrapper class having all the required inputs
   * @return TFMPersonDigitalIdentityModel model
   * @description fetches customer details
   */
  public TFMPersonDigitalIdentityModel searchCustAPI(
    StaffTokenRequestModel staffModel
  ) {
    TFMPersonDigitalIdentityModel model;
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
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
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
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
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
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
   * @param staffModel model to call staffJWT api
   * @param accountId  accountId value of the joint account
   * @param emailEnabled joint account status
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public HttpCalloutResponse getORModifyJointAccountNotificationAPI(
    StaffTokenRequestModel staffModel,
    string accountId,
    boolean emailEnabled
  ) {
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
    HttpCalloutResponse response = s.getORModifyJointAccountNotificationAPI(
      staffModel,
      accountId,
      emailEnabled
    );
    return checkResponse(response);
  }

  /**
   * @param bsb bsb value of the joint account
   * @param accountNumber joint account number
   * @param enabled disclosure status
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description gets the Customer's device details with biometrics
   */
  public HttpCalloutResponse updatedisclosureStatus(
    String bsb,
    String accountNumber,
    Boolean enabled,
    StaffTokenRequestModel staffModel
  ) {
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
    HttpCalloutResponse response = s.updatedisclosureStatus(
      bsb,
      accountNumber,
      enabled,
      staffModel
    );
    return checkResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description gets gets Joint Accounts List
   */
  public HttpCalloutResponse getJointAccountPermissions(
    StaffTokenRequestModel staffModel
  ) {
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
    HttpCalloutResponse response = s.getJointAccountPermissions(staffModel);
    return checkResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description get consent  List
   */
  public HttpCalloutResponse getConsentsList(
    StaffTokenRequestModel staffModel
  ) {
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
    HttpCalloutResponse response = s.getConsentsList(staffModel);
    return checkResponse(response);
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param consentAccounts  consentId value of the joint account
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public HttpCalloutResponse getConsentAccountList(
    StaffTokenRequestModel staffModel,
    string consentAccounts
  ) {
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
    HttpCalloutResponse response = s.getConsentAccountList(
      staffModel,
      consentAccounts
    );
    return checkResponse(response);
  }

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
    return checkResponse(response);
  }

  /**
   * @param arrangementId arrangementId of the record
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description it will hit the api to stop consent
   */
  public HttpCalloutResponse revokeConsent(
    String arrangementId,
    StaffTokenRequestModel staffModel
  ) {
    TFMSearchCustomerService s = (TFMSearchCustomerService) ServiceProvider.getService(
      TFMSearchCustomerService.class
    );
    HttpCalloutResponse response = s.revokeConsent(arrangementId, staffModel);
    return checkResponse(response);
  }
  /**
   * @param response HttpCalloutResponse
   * @return HttpCalloutResponse response
   * @description it will hit the api to stop consent
   */
  public HttpCalloutResponse checkResponse(HttpCalloutResponse response) {
    if (
      response.successful ||
      response.statusCode == 401 ||
      response.statusCode == 403
    ) {
      return response;
    } else {
      throw response.error;
    }
  }
}
