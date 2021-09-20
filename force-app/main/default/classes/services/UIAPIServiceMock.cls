/**
 * @description Mock implementation of UI API api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @author Shermal Warnakula
 * @since 09/2021
 * @group Services
 */
public with sharing class UIAPIServiceMock extends Service {
  @TestVisible
  private static final String PICKLIST_RESPONSE = getStaticResource(
    'mock_uiAPIPicklist'
  );
  public override HttpCalloutResponse getPickListValueInfo(String endPoint) {
    if (response.statusCode == null) {
      response.statusCode = 200;
      response.body = UIAPIServiceMock.PICKLIST_RESPONSE;
      response.successful = true;
    }
    return response;
  }
}
