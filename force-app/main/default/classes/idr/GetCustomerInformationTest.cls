/**
 *
 * @author Pavan Kuamr Ananta
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description GetCustomerInformationTest is the test class to cover tests for {@link GetCustomerInformation}
 */

@isTest
private with sharing class GetCustomerInformationTest  {
  //Success response body
  private static final String SUCCESS_RESPONSE_BODY = '{"profile": {"firstname": "TestFirstName","lastname": "TestLastName","mobile": "TestMobile"}}';

  /**
   * @description testCustomerDataCalloutSuccess is to test success response including deserialising JSON to Map
   */

  @isTest
  static void testCustomerDataCalloutSuccess() {
    // Set mock callout class
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(200, SUCCESS_RESPONSE_BODY)
    );

    // Call method to test.
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock.
    Map<String, Object> info = GetCustomerInformation.getCustomerData(
      '12345',
      'CAP ID'
    );
    Map<String, Object> profile = (Map<String, Object>) info.get('profile');

    // Verify response received contains fake values
    System.assertEquals(
      'TestFirstName',
      profile.get('firstname'),
      'Matches the first name'
    );
  }

  /**
   * @description testCustomerDataWithBlankCapId is to make sure the data is returned as null when there is no CAP SIS ID
   */
  @isTest
  static void testCustomerDataWithBlankCapId() {
    Map<String, Object> info = GetCustomerInformation.getCustomerData('', '');
    System.assertEquals(
      new Map<String, Object>(),
      info,
      'Response matches empty object when CAP id is blank'
    );
  }

  /**
   * @description testCustomerDataCalloutException is to to test that call out exception is thrown and also logged into the application log when the exception happens.
   * The callout exception is thrown whenever the response status is anything other than 200 success.
   */
  @isTest
  static void testCustomerDataCalloutException() {
    // Set mock callout class
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(400, SUCCESS_RESPONSE_BODY)
    );
    // Start test to ensure the events are pushed by {@link Lib_SystemLog} when an exception happens
    Test.startTest();
    try {
      Map<String, Object> info = GetCustomerInformation.getCustomerData(
        '12345',
        'CAP ID'
      );
    } catch (Exception e) {
      System.Assert(
        e instanceof AuraHandledException,
        'When a status code is not 200 it throws callout exception'
      );
    }
    Test.stopTest();
  }

  /**
   * @description testCustomerDataGeneralException is to to test that if a General excption occurs other than {@link CalloutException}
   * the that error is thrown and also logged into the application log when the exception happens.
   * In this case we are generating {@link JSONException} as one of the excptions to test
   */
  @isTest
  static void testCustomerDataGeneralException() {
    // Set mock callout class
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(new JSONException('Test Exception'))
    );
    // Start test to ensure the events are pushed by {@link Lib_SystemLog} when an exception happens
    Test.startTest();
    try {
      Map<String, Object> info = GetCustomerInformation.getCustomerData(
        '12345',
        'CAP ID'
      );
    } catch (Exception e) {
      System.Assert(
        e.getMessage().equals('Test Exception'),
        'Exception thrown: ' + e.getMessage()
      );
    }
    Test.stopTest();
  }

  /**
   * @description testCustomerDataWithEmptyResponse is to to test if the callout was successful
   * however it returned empty response body or empty JSON
   */
  @isTest
  static void testCustomerDataWithEmptyResponse() {
    Map<String, Object> custInfo = new Map<String, Object>();
    // Set mock callout class: Empty JSON response test
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(200, '{}')
    );
    custInfo = GetCustomerInformation.getCustomerData('12345', 'CAP ID');
    System.assertEquals(
      new Map<String, Object>(),
      custInfo,
      'Matches empty object when empty response is returned'
    );
    // Set mock callout class: Empty response body test
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpMulesoftCallouts(200, null)
    );
    try {
      custInfo = GetCustomerInformation.getCustomerData('12345', 'CAP ID');
    } catch (Exception e) {
      System.assertEquals(
        new Map<String, Object>(),
        custInfo,
        'Matches empty object when response body is null'
      );
    }
  }
}
