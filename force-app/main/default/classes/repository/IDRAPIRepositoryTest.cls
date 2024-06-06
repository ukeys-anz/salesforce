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
      SNOWIntegrationModel result = repo.getSNOWEventInfo('IRE0073261');
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

  private static HttpCalloutResponse getAPIFailureResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(
      '{"message":{"Internal Server Error"}}'
    );
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
