/**
 * @author Adnan
 * @since Sep 2021
 * @description test class for IDRAPIRepository
 * @group Repository
 */
@isTest
public with sharing class IDRAPIRepositoryTest {
  @isTest
  static void testGetCustomerInfoLWC() {
    IDRCustomerInformationModel info = IDRAPIRepository.getCustomerInfoLWC(
      '12345',
      'CAP ID'
    );

    // Verify response received contains fake values
    System.assertEquals(
      'PATRICK ABBISOGNI',
      info.profile.firstName,
      'Matches the first name'
    );
  }

  @isTest
  static void testGetCustomerInfoLWCFailure() {
    HttpCalloutResponse res = getAPIFailureResponse();
    Service serv = ServiceProvider.getService(IDRCustomerProfileService.class);
    serv.setCalloutResponse(res);
    IDRAPIRepository repo = new IDRAPIRepository();
    Test.startTest();
    IDRCustomerInformationModel result = repo.getCustomerInfo(
        '12345',
        'CAP ID'
      );
    Test.stopTest();
    System.assertEquals(
      true,
      result.isOCVDown,
      'isOCVDown is true when OCV is down'
    );
    System.assertEquals(
      500,
      res.statusCode,
      'Status Code matches for Internal Server Error'
    );
    System.assertEquals(
      false,
      result.isCustomerNotFound,
      'isCustomerNotFound is false becuase OCV is down'
    );
  }

  @isTest
  static void testGetSNOWEventInfoLWCforValidId() {
    Test.startTest();
    SNOWIntegrationModel info = IDRAPIRepository.getSNOWEventInfoLWC(
      'IRE0073261'
    );
    Test.stopTest();
    // Verify response received contains fake values
    System.assertEquals(
      'IRE0073261',
      info.result[0].eventNumber,
      'Risk Event Id Matches'
    );
  }

  @isTest
  static void testServiceNowAPICallFailure() {
    HttpCalloutResponse res = getAPIFailureResponse();
    Service serv = ServiceProvider.getService(SNOWIntegrationService.class);
    serv.setCalloutResponse(res);
    IDRAPIRepository repo = new IDRAPIRepository();
    Exception calloutException;
    Test.startTest();
    try {
      repo.getSNOWEventInfo('IRE0073261');
    } catch (Exception e) {
      calloutException = e;
    }
    Test.stopTest();
    System.assertEquals(
      calloutException,
      res.error,
      'Exception should be same as actual response error'
    );
    System.assertEquals(
      500,
      res.statusCode,
      'Status Code matches for Internal Server Error'
    );
  }

  @isTest
  static void testCustomerNotFoundFailure() {
    HttpCalloutResponse res = getCustomerNotFoundResponse();
    Service serv = ServiceProvider.getService(IDRCustomerProfileService.class);
    serv.setCalloutResponse(res);
    IDRAPIRepository repo = new IDRAPIRepository();
    Test.startTest();
    IDRCustomerInformationModel result = repo.getCustomerInfo(
        '1231231234',
        'Customer/Business CAP ID'
      );
    Test.stopTest();
    System.assertEquals(
      422,
      res.statusCode,
      'Status Code matches for Customer Not Found error'
    );
    System.assertEquals(
      true,
      result.isCustomerNotFound,
      'isCustomerNotFound is true for Could not retrieve Customer Data'
    );
    System.assertEquals(
      false,
      result.isOCVDown,
      'isOCVDown is false for Could not retrieve Customer Data'
    );
  }
  
  private static HttpCalloutResponse getAPIFailureResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(
      '{"message":{"Internal Server Error"}}'
    );
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  private static HttpCalloutResponse getCustomerNotFoundResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(
      '{"message": "Could not retrieve Customer Data"}'
    );
    response.statusCode = 422;
    response.successful = false;
    return response;
  }
}
