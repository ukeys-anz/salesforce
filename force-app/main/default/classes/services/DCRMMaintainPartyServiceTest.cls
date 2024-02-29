/**
 * @author Ankit Garg
 * @since June 2023
 * @description test class for DCRMMaintainPartyService
 * @group Service
 */
@isTest
public with sharing class DCRMMaintainPartyServiceTest {
  @isTest
  static void testMaintainPartyService() {
    User mlUser = MLCRMTestDataFactory.getAdminUser();
    System.runAs(mlUser) {
      Test.setMock(HttpCalloutMock.class, new MockMaintainPartyCallout());

      Test.startTest();
      DCRMMaintainPartyService service = new DCRMMaintainPartyService();
      OCVRequestPayloadWrapper ocvRequest = getRequestRecord(mlUser.Id);
      HttpCalloutResponse response = service.maintainParty(ocvRequest);
      Test.stopTest();

      System.assertEquals(
        200,
        response.statusCode,
        'Expected response status code to be 200'
      );
    }
  }

  @isTest
  static void getRealService() {
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
      Test.startTest();
      Service serviceResult = (Service) ServiceProvider.getService(
        DCRMMaintainPartyService.class
      );
      Test.stopTest();
      System.assert(
        serviceResult instanceof DCRMMaintainPartyServiceMock,
        'Expected instance of DCRMMaintainPartyServiceMock'
      );
    }
  }

  @isTest
  static void dcrmMaintainPartyServiceMockTest() {
    User mlUser = MLCRMTestDataFactory.getAdminUser();
    System.runAs(mlUser) {
      Test.setMock(HttpCalloutMock.class, new MockMaintainPartyCallout());

      Test.startTest();
      DCRMMaintainPartyServiceMock service = new DCRMMaintainPartyServiceMock();
      OCVRequestPayloadWrapper ocvRequest = getRequestRecord(mlUser.Id);
      HttpCalloutResponse response = service.maintainParty(ocvRequest);
      Test.stopTest();

      System.assertEquals(
        200,
        response.statusCode,
        'Expected response status code to be 200'
      );
    }
  }

  class MockMaintainPartyCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_dcrmMaintainPartyModel'
      ];
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(sr.Body.toString());
      return res;
    }
  }
  /**
   * @description payload request to OCV
   * @name getRequestRecord
   * @param mlUserId User Id
   * @return ocvRequest as OCVRequestPayloadWrapper
   */
  static OCVRequestPayloadWrapper getRequestRecord(ID mlUserId) {
    OCVRequestPayloadWrapper ocvRequest = new OCVRequestPayloadWrapper();
    ocvRequest.strOwnerId = mlUserId;
    ocvRequest.isValidStreet = true;
    ocvRequest.strStreet = 'Street';
    ocvRequest.strCity = 'City';
    ocvRequest.strState = 'State';
    ocvRequest.strCountry = 'Country';
    ocvRequest.strPostalCode = '110050';
    ocvRequest.strMobilePhone = '+61512345678';
    ocvRequest.strHomePhone = '+61412345678';
    ocvRequest.strWorkPhone = '+61412345678';
    ocvRequest.strEmail = 'abc@ml.anz.com';
    ocvRequest.strSalutation = 'Mr';
    ocvRequest.strFirstName = 'FirstName';
    ocvRequest.strMiddleName = 'MiddleName';
    ocvRequest.strLastName = 'LastName';
    ocvRequest.strGender = 'F';
    ocvRequest.strRecordId = '';
    ocvRequest.strAdvertisingIndicator = 'Y';
    return ocvRequest;
  }
}
