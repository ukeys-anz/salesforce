/**
 * @author Anuja Vats
 * @since April 2024
 * @description test class for SNOWIntegrationService
 * @group Service 
 */
@isTest
public with sharing class SNOWIntegrationServiceTest {
  static Lib_MockProvider snowRepoMock;
  static void registerMocks() {
    snowRepoMock = Lib_MockProvider.forType(
      ServiceNowSettingRepository.class
    );
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
    registerMocks();
    List<ServiceNow_environment_settings__c> snowCustomSettings = createSnowEnvSettings(true);
    snowRepoMock.mock('getSnowEnvSettings', snowCustomSettings);
    Test.startTest();
    String snowUrl = SNOWIntegrationService.getEnvSettings();
    Test.stopTest();
    String expectedUrl = 'https://domainorg.com';
    Assert.areEqual(
      snowUrl,
      expectedUrl,
      'Domain url should have been fetched correctly'
    );
  }

  /**
   * @description test method to negative scenario where no matching environment setting is found
   */
  @isTest
  static void testBlankSnowUrl() {
    registerMocks();
    List<ServiceNow_environment_settings__c> snowCustomSettings = createSnowEnvSettings(false);
    snowRepoMock.mock('getSnowEnvSettings', snowCustomSettings);
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
   * @param isPositiveCase boolean value to determine if test is for positive or negative case
   * @return List of ServiceNow_environment_settings__c records
   */
  private static List<ServiceNow_environment_settings__c> createSnowEnvSettings(Boolean isPositiveCase) {
    List<ServiceNow_environment_settings__c> lSnowEnvSettings = new List<ServiceNow_environment_settings__c>();
    ServiceNow_environment_settings__c snowEnvSetting1 = new ServiceNow_environment_settings__c();

    String domainUrl = System.URL.getOrgDomainUrl().getHost().split('\\.')[0];
    snowEnvSetting1.Environment_name__c = isPositiveCase ? ','+domainUrl+',' : 'anz--domain';
    snowEnvSetting1.Url__c = 'https://domainorg.com';
    snowEnvSetting1.Id = Lib_FakeIdGenerator.getMockId(
      ServiceNow_environment_settings__c.SObjectType
    );
    lSnowEnvSettings.add(snowEnvSetting1);
    ServiceNow_environment_settings__c snowEnvSetting2 = new ServiceNow_environment_settings__c();
    snowEnvSetting2.Environment_name__c = 'randomDomain';
    snowEnvSetting2.Url__c = 'https://randomorg.com';
    snowEnvSetting2.Id = Lib_FakeIdGenerator.getMockId(
      ServiceNow_environment_settings__c.SObjectType
    );
    lSnowEnvSettings.add(snowEnvSetting2);
    return lSnowEnvSettings;
  }
}
