/**
 * @description Mock implementation of UI API api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @author Shermal Warnakula
 * @since 09/2021
 * @group Services
 */
public with sharing class UIAPIServiceMock extends Service {
  @TestVisible
  private static final String PICKLIST_RESPONSE = '{\"controllerValues\":{\"About Us\":0,\"Cards\":1,\"Money\":2},\"defaultValue\":null,\"eTag\":\"7acf377aebdf734d453c3147b54exxxx\",\"url\":\"/services/data/v52.0/ui-api/object-info/Case/picklist-values/0122N000001oDnSQAU/Sub_Type__c\",\"values\":[{\"attributes\":null,\"label\":\"Savings Goals\",\"validFor\":[0],\"value\":\"Savings Goals\"},{\"attributes\":null,\"label\":\"About ANZ Plus\",\"validFor\":[1],\"value\":\"About ANZ Plus\"},{\"attributes\":null,\"label\":\"Privacy\",\"validFor\":[2],\"value\":\"Privacy\"},{\"attributes\":null,\"label\":\"ANZ branches\",\"validFor\":[0,1],\"value\":\"ANZ branches\"}]}';

  public override HttpCalloutResponse getPickListValueInfo(String endPoint) {
    if (response.statusCode == null) {
      response.statusCode = 200;
      response.body = UIAPIServiceMock.PICKLIST_RESPONSE;
      response.successful = true;
    }
    return response;
  }
}
