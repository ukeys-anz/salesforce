/**
 * @author Boobalakrishnan Duraisamy
 * @since Mar 2022
 * @description test class for CCRMValidateAbnAcnService
 * @group Service
 */
@isTest
public with sharing class CCRMValidateAbnAcnServiceTest {
  @isTest
  static void testValidateAbnAcnService() {
    Test.setMock(HttpCalloutMock.class, new MockAbnAcnCallout());

    Test.startTest();
    CCRMValidateAbnAcnService service = new CCRMValidateAbnAcnService();
    HttpCalloutResponse response = service.getAbnAcnInformation(
      Label.MS_Get_Abr_Abn,
      '11005357522'
    );
    Test.stopTest();

    System.assertEquals(200, response.statusCode);
  }

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      CCRMValidateAbnAcnService.class
    );
    Test.stopTest();
    System.assert(serviceResult instanceof CCRMValidateAbnAcnServiceMock);
  }

  class MockAbnAcnCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmAbnAcnModel'
      ];

      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(sr.Body.toString());
      return res;
    }
  }
}
