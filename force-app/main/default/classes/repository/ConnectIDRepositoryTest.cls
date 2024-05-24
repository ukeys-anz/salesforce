/**
 * @author Batya Aisman Sufrin
 * @since Dec 2023
 * @description Test class for onnectIDRepository
 */
@isTest
public with sharing class ConnectIDRepositoryTest {
  @testSetup
  static void setup() 
  {

    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );

    insert acc;
  }

  /**
   * @description fetch invalid statement
   */
  @isTest
  static void testGetConsentHistoryListInvalidResponse() {
    Account acc = [
      SELECT OCV_ID__c
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(ConnectIDService.class);
    s.setCalloutResponse(res);
    Exception resultException;

    Test.startTest();
    ConnectIDRepository connectIdApi = new ConnectIDRepository();
    try {
      ConnectIDModel response = connectIdApi.getConsentHistoryList(
        acc.OCV_ID__c
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    Assert.areEqual(
      'exception occured',
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  /**
   * @description Mock exception response
   * @return HttpCalloutResponse
   */
  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('exception occured');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
