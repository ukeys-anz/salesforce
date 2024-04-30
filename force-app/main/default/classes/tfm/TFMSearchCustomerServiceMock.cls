/**
 * @author Hinduja Upadhyay
 * @since May 2022
 * @description Mock implementation of TFMSearchCustomerServic api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class TFMSearchCustomerServiceMock extends TFMSearchCustomerService {
  /**
   * @description constructor which sets default status code and successful
   */
  public TFMSearchCustomerServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  @TestVisible
  public static Boolean isError = false;
  @TestVisible
  public static final String AUTHENTICATION_ERROR_RESPONSE =
    '{' +
    '   \"error\": \"16 UNAUTHENTICATED: authentication failed\"' +
    '}';

  @TestVisible
  private static final String PERSON_IDENTITY_ROWS_JSON = Service.getStaticResource(
    'mock_PersonDigitalIdentity'
  );
  @TestVisible
  private static final String DEVICE_DETAILS_WITHOUT_BIOMETRIC = Service.getStaticResource(
    'mock_DeviceDetailsWithoutBiometric'
  );
  @TestVisible
  private static final String DEVICE_DETAILS_WITH_BIOMETRIC = Service.getStaticResource(
    'mock_DeviceDetailsWithBiometric'
  );
  @TestVisible
  private static final String JOINT_ACCOUNT_PERMISSIONS_LIST = Service.getStaticResource(
    'mock_JointAccountPermissionsSample'
  );
  @TestVisible
  private static final String MODIFY_ACCOUNT_PERMISSIONS = Service.getStaticResource(
    'mock_ModifyJointAccountSample'
  );
  @TestVisible
  private static final String EMAIL_JOINT_ACCOUNT_NOTIFICATION = Service.getStaticResource(
    'mock_EmailNotificationJointAccount'
  );
  @TestVisible
  private static final String GET_CONSENT_ACCOUNT_LIST = Service.getStaticResource(
    'mock_ConsentAccountList'
  );
  @TestVisible
  private static final String GET_CONSENTS_LIST = Service.getStaticResource(
    'mock_ConsentsList'
  );
  @TestVisible
  private static final String GET_DATASHARING_HISTORY = Service.getStaticResource(
    'mock_DataSharingHistory'
  );

  /**
   * @param staffModel wrapper class having all the variables
   * @return Boolean response stating action is valid or invalid
   * @description fetches staff JWT from mule api and get the valid profiles
   */
  public override HttpCalloutResponse searchCustAPI(
    StaffTokenRequestModel staffModel
  ) {
    if (!preset) {
      response.body = PERSON_IDENTITY_ROWS_JSON;
    }
    return response;
  }
  /**
   * @param staffModel wrapper class having all the variables
   * @param userInternalId Internal User Id that we receive from SearchCustomer API
   * @param deviceResourceId AppCorrelation Id for the device
   * @return api response
   * @description gets the Customer's device details without biometrics
   */
  public override HttpCalloutResponse getDeviceDetailsWithoutBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String deviceResourceId
  ) {
    if (!preset) {
      response.body = DEVICE_DETAILS_WITHOUT_BIOMETRIC;
    }
    return response;
  }
  /**
   * @param staffModel wrapper class having all the variables
   * @param userInternalId Internal User Id that we receive from SearchCustomer API
   * @param appCorrelationId AppCorrelation Id for the device
   * @return api response
   * @description gets the Customer's device details without biometrics
   */
  public override HttpCalloutResponse getDeviceDetailsWithBiometric(
    StaffTokenRequestModel staffModel,
    String userInternalId,
    String appCorrelationId
  ) {
    if (!preset) {
      response.body = DEVICE_DETAILS_WITH_BIOMETRIC;
    }
    return response;
  }

  /**
   * @param staffModel staffModel with data
   * @return api response
   * @description gets the Joint Accounts
   */
  public override HttpCalloutResponse getJointAccountPermissions(
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse();
    } else if (!preset) {
      response.body = JOINT_ACCOUNT_PERMISSIONS_LIST;
    }
    return response;
  }

  /**
   * @param bsb bsb value of the joint account
   * @param accountNumber joint account number
   * @param enabled disclosure status
   * @param staffModel staffModel to call api
   * @return api response
   * @description modify the Joint Accounts
   */
  public override HttpCalloutResponse updatedisclosureStatus(
    String bsb,
    String accountNumber,
    Boolean enabled,
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse();
    } else if (!preset) {
      response.body = MODIFY_ACCOUNT_PERMISSIONS;
    }
    return response;
  }

  /**
   * @param staffModel staffModel with data
   * @param accountId  accountId value of the joint account
   * @param emailEnabled joint account status
   * @return api response
   * @description modify the Joint Accounts
   */
  public override HttpCalloutResponse getORModifyJointAccountNotificationAPI(
    StaffTokenRequestModel staffModel,
    String accountId,
    Boolean emailEnabled
  ) {
    if (isError) {
      response = setMockErrorResponse();
    } else if (!preset) {
      response.body = EMAIL_JOINT_ACCOUNT_NOTIFICATION;
    }
    return response;
  }
  /**
   * @param arrangementId arrangementId of the record
   * @param staffModel staffModel to call api
   * @return HttpCalloutResponse response
   * @description it will hit the api to stop consent
   */
  public override HttpCalloutResponse revokeConsent(
    String arrangementId,
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse();
    } else if (!preset) {
      Test.setMock(HttpCalloutMock.class, new MockRevokeService());
    }
    return response;
  }

  /**
   * @param staffModel staffModel to call api
   * @param  consentAccounts value of the joint account
   * @return HttpCalloutResponse response
   * @description get and modify the joint account notifications
   */
  public override HttpCalloutResponse getConsentAccountList(
    StaffTokenRequestModel staffModel,
    string consentAccounts
  ) {
    if (isError) {
      response = setMockErrorResponse();
    } else if (!preset) {
      response.body = GET_CONSENT_ACCOUNT_LIST;
    }
    return response;
  }

  /**
   * @param staffModel staffModel with data
   * @return api response
   * @description gets the Get Consents List
   */
  public override HttpCalloutResponse getConsentsList(
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse();
    } else if (!preset) {
      response.body = GET_CONSENTS_LIST;
    }
    return response;
  }

  /**
   * @param consentId consentId pass as api param
   * @param fromTimestamp fromTimestamp pass as api param
   * @param toTimestamp toTimestamp pass as api param
   * @param staffModel staffModel with data
   * @return api response
   * @description gets the Data Sharing History
   */
  public override HttpCalloutResponse getConsentDataSharingHistory(
    String consentId,
    String fromTimestamp,
    String toTimestamp,
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse();
    } else if (!preset) {
      response.body = GET_DATASHARING_HISTORY;
    }
    return response;
  }

  class MockRevokeService implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  /**
   * @description mock response for callout
   * @return HttpCalloutResponse invalid response
   */
  public static HttpCalloutResponse setMockErrorResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = AUTHENTICATION_ERROR_RESPONSE;
    response.statusCode = 500;
    response.successful = false;
    response.error = new CalloutException(TFMConstants.SERVERERROR);
    return response;
  }
}
