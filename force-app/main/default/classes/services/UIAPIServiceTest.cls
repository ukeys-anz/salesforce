/**
 * @author Shermal Warnakula
 * @since Sep 2021
 * @description Test class for {@link UIAPIService}
 * @group Services
 */
@isTest
public inherited sharing class UIAPIServiceTest {
  @isTest
  static void testGetPickListValueInfo() {
    Test.setMock(HttpCalloutMock.class, new MockUIAPICallout());

    // GIVEN
    // a method wants to fetch picklist value information via UI API

    String endPoint =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/services/data/v52.0/ui-api/object-info/Case' +
      '/picklist-values/' +
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('General_Inquiry')
        .getRecordTypeId() +
      '/Sub_Type__c';

    // WHEN
    // getPickListValueInfo() method on UIAPIService is called with a valid endpoint parameter
    Test.startTest();
    UIAPIService service = new UIAPIService();
    HttpCalloutResponse response = service.getPickListValueInfo(endPoint);
    Test.stopTest();

    // THEN
    // a valid status code should be returned in the response without any failures
    System.assertEquals(
      201,
      response.statusCode,
      'Status code does not match.'
    );
  }

  @isTest
  static void testGetValidService() {
    // GIVEN
    // UIAPIService and UIAPIServiceMock service classes are implemented

    // WHEN
    // ServiceProvider.getService() is called in TEST context with 'UIAPIService.class' as the parameter
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      UIAPIService.class
    );
    Test.stopTest();

    // THEN
    // a valid instance of UIAPIServiceMock should be returned
    System.assert(
      serviceResult instanceof UIAPIServiceMock,
      'Invalid service returned.'
    );
  }

  class MockUIAPICallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(201);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(UIAPIServiceMock.PICKLIST_RESPONSE);

      return res;
    }
  }
}
