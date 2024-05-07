/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class TFMDataINServiceMock extends TFMDataINService {
  /**
   * @description constructor which sets default status code and successful
   */
  public TFMDataINServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  @TestVisible
  public static Boolean isError = false;
  @TestVisible
  public static Boolean throwExceptionResponse = false;
  @TestVisible
  public static final String AUTHENTICATION_ERROR_RESPONSE =
    '{' +
    '   \"error\": \"16 UNAUTHENTICATED: authentication failed\"' +
    '}';

  @TestVisible
  private static final String DATA_IN_CONSENT_LIST_API = Service.getStaticResource(
    'mock_DataInConsentListAPI'
  );
  @TestVisible
  private static final String DATA_IN_ACCOUNT_LIST_API = Service.getStaticResource(
    'mock_DataInAccountListAPI'
  );
  @TestVisible
  private static final String EXPORT_CONSENT = Service.getStaticResource(
    'mock_DataInExport_Consent'
  );
  @TestVisible
  private static final String EXPORT_DATA_COLLECTION = Service.getStaticResource(
    'mock_DataInExport_Data_Collection'
  );
  @TestVisible
  private static final String REVOKE_CONSENT = Service.getStaticResource(
    'mock_DataInRevokeConsent'
  );

  /**
   * @param staffModel wrapper class having all the variables
   * @return Boolean response stating action is valid or invalid
   * @description fetches staff JWT from mule api and get the valid profiles
   */
  public override HttpCalloutResponse getDataINConsentsListAPI(
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse(throwExceptionResponse);
    } else if (!preset) {
      response.body = DATA_IN_CONSENT_LIST_API;
    }
    return response;
  }

  /**
   * @param staffModel staffModel with data
   * @param consentIdValue consentId Value
   * @return HttpCalloutResponse api response
   * @description gets the Joint Accounts
   */
  public override HttpCalloutResponse getDataINAccountListAPI(
    StaffTokenRequestModel staffModel,
    string consentIdValue
  ) {
    if (isError) {
      response = setMockErrorResponse(throwExceptionResponse);
    } else if (!preset) {
      response.body = DATA_IN_ACCOUNT_LIST_API;
    }
    return response;
  }

  /**
   * @param methodName export methodName
   * @param consentId consentId value
   * @param staffModel staffModel to call api
   * @return HttpCalloutResponse api response
   * @description modify the Joint Accounts
   */
  public override HttpCalloutResponse exportConsent(
    String methodName,
    String consentId,
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse(throwExceptionResponse);
    } else if (!preset) {
      response.body = EXPORT_CONSENT;
    }
    return response;
  }

  /**
   * @param consentId consentId
   * @param staffModel staffModel with data
   * @return HttpCalloutResponse api response
   * @description modify the Joint Accounts
   */
  public override HttpCalloutResponse revokeConsent(
    String consentId,
    StaffTokenRequestModel staffModel
  ) {
    if (isError) {
      response = setMockErrorResponse(throwExceptionResponse);
    } else if (!preset) {
      response.body = REVOKE_CONSENT;
    }
    return response;
  }

  /**
   * @param throwExceptionResponse boolean value
   * @description mock response for callout
   * @return HttpCalloutResponse invalid response
   */
  public static HttpCalloutResponse setMockErrorResponse(
    Boolean throwExceptionResponse
  ) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    if (throwExceptionResponse) {
      response.error = new CalloutException(TFMConstants.SERVERERROR);
      throw response.error;
    }
    response.body = AUTHENTICATION_ERROR_RESPONSE;
    response.statusCode = 500;
    response.successful = false;
    response.error = new CalloutException(TFMConstants.SERVERERROR);
    return response;
  }
}
