/**
 * @author Hinduja Upadhyay
 * @since Sep 2024
 * @description Mock implementation of ADRService api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class ADRServiceMock extends ADRService {
  /**
   * @description constructor which sets default status code and successful
   */
  public ADRServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  @TestVisible
  public static final String AUTHENTICATION_ERROR_RESPONSE =
    '{' +
    '   \"error\": \"16 UNAUTHENTICATED: authentication failed\"' +
    '}';

  @TestVisible
  private static final String ADR_RESPONSE = Service.getStaticResource(
    'mock_ADR_List'
  );

  @TestVisible
  private static final String ADR_ACTION_RESPONSE = Service.getStaticResource(
    'Mock_ADR_Action_Response'
  );
  /**
   * @param  staffModel StaffTokenRequestModel
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public override HttpCalloutResponse getADRRows(
    StaffTokenRequestModel staffModel
  ) {
    if (!preset) {
      response.body = ADR_RESPONSE;
    }
    return response;
  }

  /**
   * @param  staffModel StaffTokenRequestModel
   * @param rspId rspId
   * @param actionToPerform actionToPerform
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public override HttpCalloutResponse performADRAction(
    StaffTokenRequestModel staffModel,
    String rspId,
    String actionToPerform
  ) {
    if (!preset) {
      response.body = ADR_ACTION_RESPONSE;
    }
    return response;
  }

  /**
   * @description mock response for callout
   * @param statusCode statusCode
   * @return HttpCalloutResponse invalid response
   */
  @TestVisible
  private static HttpCalloutResponse setMockErrorResponse(Integer statusCode) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = AUTHENTICATION_ERROR_RESPONSE;
    response.statusCode = statusCode;
    response.successful = false;
    response.error = new CalloutException(TFMConstants.SERVERERROR);
    return response;
  }
}
