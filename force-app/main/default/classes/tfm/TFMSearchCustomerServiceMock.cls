/**
 * @author Hinduja Upadhyay
 * @since May 2022
 * @description Mock implementation of TFMSearchCustomerServic api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class TFMSearchCustomerServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public TFMSearchCustomerServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

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
  /**
   * @param staffModel wrapper class having all the variables
   * @return headers
   * @description to get StaffJWT token
   */
  public override Map<String, String> getValidStaffToken(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    if (!preset) {
      headers.put('Token', AuthServiceTest.IDTESTVALUE);
    }
    return headers;
  }
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
      response.body = PERSON_IDENTITY_ROWS_JSON;
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
      response.body = PERSON_IDENTITY_ROWS_JSON;
    }
    return response;
  }

  /**
   * @param headers headers with data
   * @return api response
   * @description gets the Joint Accounts
   */
  public override HttpCalloutResponse getJointAccountPermissions(
    Map<String, String> headers
  ) {
    if (!preset) {
      response.body = JOINT_ACCOUNT_PERMISSIONS_LIST;
    }
    return response;
  }

  /**
   * @param bsb bsb value of the joint account
   * @param accountNumber joint account number
   * @param enabled disclosure status
   * @param headers headers to call api
   * @return api response
   * @description modify the Joint Accounts
   */
  public override HttpCalloutResponse updatedisclosureStatus(
    String bsb,
    String accountNumber,
    Boolean enabled,
    Map<String, String> headers
  ) {
    if (!preset) {
      response.body = MODIFY_ACCOUNT_PERMISSIONS;
    }
    return response;
  }

  /**
   * @param headers headers with data
   * @param accountId  accountId value of the joint account
   * @param emailEnabled joint account status
   * @return api response
   * @description modify the Joint Accounts
   */
  public override HttpCalloutResponse getORModifyJointAccountNotificationAPI(
    Map<String, String> headers,
    String accountId,
    Boolean emailEnabled
  ) {
    if (!preset) {
      response.body = EMAIL_JOINT_ACCOUNT_NOTIFICATION;
    }
    return response;
  }
}
