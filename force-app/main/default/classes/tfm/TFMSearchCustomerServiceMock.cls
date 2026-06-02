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

  /**
   * @param staffModel wrapper class having all the variables
   * @return Boolean response stating action is valid or invalid
   * @description fetches staff JWT from mule api and get the valid profiles
   */
  public override HttpCalloutResponse searchCustAPI(
    StaffTokenRequestModel staffModel
  ) {
    if (!preset) {
      response.body = Service.getStaticResource('mock_PersonDigitalIdentity');
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
      response.body = Service.getStaticResource(
        'mock_DeviceDetailsWithoutBiometric'
      );
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
      response.body = Service.getStaticResource(
        'mock_DeviceDetailsWithBiometric'
      );
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
      response.body = Service.getStaticResource(
        'mock_JointAccountPermissionsSample'
      );
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
      response.body = Service.getStaticResource(
        'mock_ModifyJointAccountSample'
      );
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
      response.body = Service.getStaticResource(
        'mock_EmailNotificationJointAccount'
      );
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
      response.body = extractConsentAccounts(consentAccounts);
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
      response.body = Service.getStaticResource('mock_ConsentsList');
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
      response.body = extractDataSharingHistory(consentId);
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

  /**
   * @description mock response for callout
   * @return HttpCalloutResponse invalid response
   */
  public static HttpCalloutResponse setMockErrorResponseForInsufficentAccess() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = AUTHENTICATION_ERROR_RESPONSE;
    response.statusCode = 401;
    response.successful = false;
    response.error = new CalloutException(
      TFMConstants.INSUFFICIENT_ACCESS_ERROR
    );
    return response;
  }

  /**
   * @description Extract matching accounts from mock_ConsentAccountList based on input
   * @param consentAccounts JSON string with consent_id and consent_accounts array
   * @return List of matching account objects
   */
  @TestVisible
  static String extractConsentAccounts(String consentAccounts) {
    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
      consentAccounts
    );
    List<Object> accounts = (List<Object>) data.get('consent_accounts');
    Set<String> requestedKeys = new Set<String>();
    for (Object accountObj : accounts) {
      Map<String, Object> account = (Map<String, Object>) accountObj;
      String key = account.get('bsb') + '-' + account.get('accountNumber');
      requestedKeys.add(key);
    }

    Map<String, Object> mockData = (Map<String, Object>) JSON.deserializeUntyped(
      Service.getStaticResource('mock_ConsentAccountList')
    );
    List<Object> allAccounts = (List<Object>) mockData.get('consentAccounts');
    for (Integer i = allAccounts.size() - 1; i >= 0; i--) {
      Map<String, Object> account = (Map<String, Object>) allAccounts[i];
      String key = account.get('bsb') + '-' + account.get('accountNumber');
      if (requestedKeys.contains(key) == false) {
        allAccounts.remove(i);
      }
    }

    return JSON.serialize(mockData);
  }

  /**
   * @description Extract matching data sharing history from mock based on consentId
   * @param consentId consent ID to lookup
   * @return matching mockResponse for the consent
   */
  @TestVisible
  static String extractDataSharingHistory(String consentId) {
    Map<String, Object> mockData = (Map<String, Object>) JSON.deserializeUntyped(
      Service.getStaticResource('mock_DataSharingHistory')
    );
    Map<String, Object> mockFor = (Map<String, Object>) mockData.get('mockFor');
    Map<String, Object> mockResponse = (Map<String, Object>) mockData.get(
      'mockResponse'
    );
    String responseKey = (String) mockFor.get(consentId);

    return JSON.serialize(mockResponse.get(responseKey));
  }
}
