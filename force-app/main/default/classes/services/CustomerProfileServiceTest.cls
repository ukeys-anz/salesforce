/**
 * @author Adnan
 * @since Sep 2021
 * @description test class for CustomerProfileService
 * @group Service
 */
@isTest
public with sharing class CustomerProfileServiceTest {
  @isTest
  static void testGetCustomerInformation() {
    Test.setMock(HttpCalloutMock.class, new MockCMOSGetCustomerInfoCallout());

    Test.startTest();
    CustomerProfileService service = new CustomerProfileService();
    HttpCalloutResponse response = service.getCustomerInformation(
      '1234567890',
      'OCV'
    );
    Test.stopTest();

    System.assertEquals(201, response.statusCode);
  }

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      CustomerProfileService.class
    );
    Test.stopTest();
    System.assert(serviceResult instanceof CustomerProfileServiceMock);
  }

  @isTest
  static void getBadService() {
    Exception resultException;
    Test.startTest();
    try {
      ServiceProvider.getService('energy-innovation-1488');
    } catch (Exception e) {
      resultException = e;
    }

    Test.stopTest();
    System.assertEquals(
      'No Service class found called [energy-innovation-1488]',
      resultException.getMessage()
    );
  }

  class MockCMOSGetCustomerInfoCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(201);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(CustomerProfileServiceMock.CUSTOMER_INFO_SUCCESS_RESPONSE);

      return res;
    }
  }
}
