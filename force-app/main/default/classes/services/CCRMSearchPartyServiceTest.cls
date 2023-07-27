/**
 * @author Boobalakrishnan Duraisamy
 * @since June 2022
 * @description test class for CCRMSearchPartyService
 * @group Service
 */
@isTest
public with sharing class CCRMSearchPartyServiceTest {
  @isTest
  static void testSearchPartyService() {
    Test.setMock(HttpCalloutMock.class, new MockSearchPartyCallout());

    Test.startTest();
    CCRMSearchPartyService service = new CCRMSearchPartyService();
    Lead record = new Lead();
    HttpCalloutResponse response = service.searchPartyInfo(record);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Expected response status code to be 200'
    );
  }

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      CCRMSearchPartyService.class
    );
    Test.stopTest();
    System.assert(
      serviceResult instanceof CCRMSearchPartyServiceMock,
      'Expected instance of CCRMSearchPartyServiceMock'
    );
  }

  class MockSearchPartyCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmSearchPartyModel'
      ];
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(sr.Body.toString());
      return res;
    }
  }
}
