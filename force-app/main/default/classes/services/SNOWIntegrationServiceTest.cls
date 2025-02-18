/**
 * @author Anuja Vats
 * @since April 2024
 * @description test class for SNOWIntegrationService
 * @group Service
 */
@isTest
public with sharing class SNOWIntegrationServiceTest {
  /**
   * @description Setup common test data
   */
  @testSetup
  public static void setup() {
    List<ServiceNow_environment_settings__c> lSettings = createSnowEnvSettings();
    insert lSettings;
  }

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
      'Response statusCode for success should be as 200.'
    );
    System.assertEquals(
      '{ "result": [ { "number": "IRE0073261", "event_type": "1"} ] }',
      response.body,
      'Response Matched'
    );
  }
  @isTest
  static void testSNOWServiceBadResponse() {
    Test.setMock(
      HttpCalloutMock.class,
      new MockCMOSGetSNOWInfoCalloutFailure()
    );
    Test.startTest();
    SNOWIntegrationService serviceResult = new SNOWIntegrationService();
    HttpCalloutResponse response = serviceResult.getSNOWRiskEventInformation(
      '1234'
    );
    Test.stopTest();
    System.assertEquals(
      401,
      response.statusCode,
      'Response statusCode for failure should be as expected.'
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
  private class MockCMOSGetSNOWInfoCallout implements HttpCalloutMock {
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

  private class MockCMOSGetSNOWInfoCalloutFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout Unauthorised Response
     * @param req incoming request
     * @return HTTPResponse Expected Unauthorised response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(401);
      res.setBody('{"message" : "User Not Authenticated"}');
      return res;
    }
  }

  /**
   * @description test method to fetch snow instance url
   */
  @isTest
  static void testSnowUrl() {
    Test.startTest();
    String snowUrl = SNOWIntegrationService.getEnvSettings();
    Test.stopTest();
    String expectedUrl = 'https://domainorg.com';
    Assert.areEqual(
      expectedUrl,
      snowUrl,
      'Domain url should have been fetched correctly'
    );
  }

  /**
   * @description test method to negative scenario where no matching environment setting is found
   */
  @isTest
  static void testBlankSnowUrl() {
    ServiceNow_environment_settings__c settingRecord = [
      SELECT Id
      FROM ServiceNow_environment_settings__c
      WHERE Name = 'Dev'
      LIMIT 1
    ];
    delete settingRecord;
    Test.startTest();
    String snowUrl = SNOWIntegrationService.getEnvSettings();
    Test.stopTest();
    String expectedUrl = '';
    Assert.areEqual(
      expectedUrl,
      snowUrl,
      'Blank string should be returned when no matching environment setting is found'
    );
  }
  /**
   * @description private method to create ServiceNow_environment_settings__c records for test data
   */
  private static List<ServiceNow_environment_settings__c> createSnowEnvSettings() {
    List<ServiceNow_environment_settings__c> lSettings = new List<ServiceNow_environment_settings__c>();
    ServiceNow_environment_settings__c snowEnvSettings1 = new ServiceNow_environment_settings__c();
    String domainUrl = System.URL.getOrgDomainUrl().getHost().split('\\.')[0];
    snowEnvSettings1.Name = 'Dev';
    snowEnvSettings1.Environment_name__c = ',' + domainUrl + ',';
    snowEnvSettings1.Url__c = 'https://domainorg.com';
    lSettings.add(snowEnvSettings1);
    ServiceNow_environment_settings__c snowEnvSettings2 = new ServiceNow_environment_settings__c();
    snowEnvSettings2.Name = 'UAT';
    snowEnvSettings2.Environment_name__c = 'anz--uatorg';
    snowEnvSettings2.Url__c = 'https://anzuatorg.com';
    lSettings.add(snowEnvSettings2);

    return lSettings;
  }
}
