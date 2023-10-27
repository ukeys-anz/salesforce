/**
 * @author Arpit
 * @since August 2023
 * @description Mock implementation of mule api service for SOP service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class PayToFraudxServiceMock extends Service {
  /**
   * @description constructor which sets default code as successful
   */
  public PayToFraudxServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  private static final string MANDATE_CHANGE_STATUS_RESPONSE = getStaticResource(
    'mock_FraudXFailure'
  );

  /**
   * @param mandateId mandate Id
   * @param ocvId ocv Id
   * @param status status
   * @return `HttpCalloutResponse` the api response
   * @description changes the mandate status for fraudx through mule
   */
  public override HttpCalloutResponse changeMandateStatus(
    String mandateId,
    String ocvId,
    String status
  ) {
    if (!preset) {
      response.body = PayToFraudxServiceMock.MANDATE_CHANGE_STATUS_RESPONSE;
    }
    return response;
  }
}
