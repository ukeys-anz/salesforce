/**
 * @author Hinduja Upadhyay
 * @since May 2022
 * @description Mock implementation of TFMSearchCustomerServic api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class TFMAUFServiceMock extends TFMAUFService {
  /**
   * @description constructor which sets default status code and successful
   */
  public TFMAUFServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  @TestVisible
  public static final String AUTHENTICATION_ERROR_RESPONSE =
    '{' +
    '   \"error\": \"16 UNAUTHENTICATED: authentication failed\"' +
    '}';

  @TestVisible
  private static final String AUF_RESPONSE = Service.getStaticResource(
    'mock_AUFResponse'
  );
  @TestVisible
  private static final String AUF_ARCHIVEUSER_RESPONSE = Service.getStaticResource(
    'mock_AUFArchiveUser'
  );
  @TestVisible
  private static final String AUF_ARCHIVEUSERERROR_RESPONSE = Service.getStaticResource(
    'mock_AUFArchiveUserError'
  );

  /**
   * @param staffModel model to call staffJWT api
   * @param pinRefId credentials id
   * @param action action
   * @return api response
   * @description gets the Joint Accounts
   */
  public override HttpCalloutResponse updatePinStatus(
    StaffTokenRequestModel staffModel,
    String pinRefId,
    String action
  ) {
    if (!preset) {
      response.body = AUF_RESPONSE;
    }
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param action action
   * @return api response
   * @description gets the Joint Accounts
   */
  public override HttpCalloutResponse updateStatus(
    StaffTokenRequestModel staffModel,
    String action
  ) {
    if (!preset) {
      if (action == TFMConstants.ERROR) {
        response.body = AUF_ARCHIVEUSERERROR_RESPONSE;
      } else {
        response.body = AUF_ARCHIVEUSER_RESPONSE;
      }
    }
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param value of new mobile number
   * @return api response
   * @description gets the Joint Accounts
   */
  public override HttpCalloutResponse updateMobileNumber(
    StaffTokenRequestModel staffModel,
    String value
  ) {
    if (!preset) {
      response.body = AUF_RESPONSE;
    }
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param value of new mobile number
   * @return api response
   * @description gets the Joint Accounts
   */
  public override HttpCalloutResponse updateOcvid(
    StaffTokenRequestModel staffModel,
    String value
  ) {
    if (!preset) {
      response.body = AUF_RESPONSE;
    }
    return response;
  }
  /**
   * @param staffModel model to call staffJWT api
   * @param deviceResourceId resourceId of the device to be deregistered
   * @return HttpCalloutResponse response
   * @description api callout to deregister device
   */
  public override HttpCalloutResponse deregisterDevice(
    StaffTokenRequestModel staffModel,
    String deviceResourceId
  ) {
    if (!preset) {
      response.body = AUF_RESPONSE;
    }
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param pin String value
   * @return HttpCalloutResponse response
   * @description send parameter to get Reset PIN link
   */
  public override HttpCalloutResponse resetPin(
    StaffTokenRequestModel staffModel,
    String pin
  ) {
    if (!preset) {
      response.body = AUF_RESPONSE;
    }
    return response;
  }

  /**
   * @description mock response for callout
   * @return HttpCalloutResponse invalid response
   */
  @TestVisible
  private static HttpCalloutResponse setMockErrorResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = AUTHENTICATION_ERROR_RESPONSE;
    response.statusCode = 404;
    response.successful = false;
    response.error = new CalloutException(TFMConstants.SERVERERROR);
    return response;
  }
}
