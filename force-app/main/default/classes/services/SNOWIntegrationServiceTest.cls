/**
 * @author Anuja Vats
 * @since April 2024
 * @description test class for SNOWIntegrationService
 * @group Service
 */
@isTest
public with sharing class SNOWIntegrationServiceTest {
  @isTest
  static void testGetRiskEventInformation() {
    Test.setMock(HttpCalloutMock.class, new MockCMOSGetSNOWInfoCallout());

    Test.startTest();
    SNOWIntegrationService serviceResult = new SNOWIntegrationService();
    HttpCalloutResponse response = serviceResult.getSNOWRiskEventInformation(
      '1234567890'
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response statusCode should be as expected.'
    );
  }

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      SNOWIntegrationService.class
    );
    Test.stopTest();
    System.assert(
      serviceResult instanceof SNOWIntegrationServiceMock,
      'Service should be instance of SNOWIntegrationServiceMock.'
    );
  }
  @isTest
  static void getBadService() {
    Exception resultException;
    Test.startTest();
    try {
      ServiceProvider.getService('xyz-service-test');
    } catch (Exception e) {
      resultException = e;
    }

    Test.stopTest();
    System.assertEquals(
      'No Service class found called [xyz-service-test]',
      resultException.getMessage(),
      'Error message should be as expected.'
    );
  }
  class MockCMOSGetSNOWInfoCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(SNOWIntegrationServiceMock.RISK_INFO_SUCCESS_RESPONSE);
      return res;
    }
  }
}
