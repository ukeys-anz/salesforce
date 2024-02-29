/**
 * @author Batya Aisman Sufrin
 * @since De  2023
 * @description Mock implementation of Lighthouse api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class ConnectIDServiceMock extends Service {
  /**
   * @description constructor which sets default code as successful
   */
  public ConnectIDServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final string LIST_CONSENT_HISTORY_RESPONSE = getStaticResource(
    'mock_ListConsentHistory'
  );

  /**
   * @param ocvId ocv Id
   * @return `HttpCalloutResponse` the api response
   * @description fetches ListConsentHistory from Lighthouse through mule
   */
  public override HttpCalloutResponse getConsentHistoryList(String ocvId) {
    if (!preset) {
      response.body = ConnectIDServiceMock.LIST_CONSENT_HISTORY_RESPONSE;
    }
    return response;
  }
}
