/**
 * @author Arpit
 * @since July 2023
 * @description Mock implementation of mule api service for SOP service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class PayToServiceMock extends Service {
  /**
   * @description constructor which sets default code as successful
   */
  public PayToServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  private static final string MANDATE_LIST_RESPONSE = getStaticResource(
    'mock_MandateList'
  );
  private static final string MANDATE_CANCEL_RESPONSE = getStaticResource(
    'mock_CancelMandate'
  );

  /**
   * @param ocvId ocv Id
   * @param status status
   * @param pageNumber page number of the list to fetch
   * @return `HttpCalloutResponse` the api response
   * @description fetches Mandate List from fabric api through mule
   */
  public override HttpCalloutResponse getMandateList(
    String ocvId,
    Integer status,
    Integer pageNumber
  ) {
    if (!preset) {
      response.body = PayToServiceMock.MANDATE_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param mandateId mandate Id
   * @param ocvId ocv Id
   * @param status status
   * @return `HttpCalloutResponse` the api response
   * @description cancels Mandate from fabric api through mule
   */
  public override HttpCalloutResponse changeMandateStatus(
    String mandateId,
    String ocvId,
    String status
  ) {
    if (!preset) {
      response.body = PayToServiceMock.MANDATE_CANCEL_RESPONSE;
    }
    return response;
  }
}
