/**
 * @author Boobalakrishnan Duraisamy
 * @since June 2022
 * @description test class for address service class
 * @group Service
 */
@isTest
public with sharing class CCRMValidateAddressServiceTest {
  @isTest
  static void testGetAddresses() {
    Test.setMock(HttpCalloutMock.class, new MockAddressService());

    Test.startTest();
    CCRMValidateAddressService service = new CCRMValidateAddressService();
    HttpCalloutResponse response = service.getAddresses('Melbourne');
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Status code of 200 should be returned'
    );
  }

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      CCRMValidateAddressService.class
    );
    Test.stopTest();
    System.assert(
      serviceResult instanceof CCRMValidateAddressServiceMock,
      'Invalid service returned.'
    );
  }

  class MockAddressService implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmQasSuccessResponse'
      ];

      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(sr.Body.toString());
      return res;
    }
  }
}
