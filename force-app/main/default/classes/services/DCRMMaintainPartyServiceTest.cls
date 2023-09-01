/**
 * @author Ankit Garg
 * @since June 2023
 * @description test class for DCRMMaintainPartyService
 * @group Service
 */
@isTest
public with sharing class DCRMMaintainPartyServiceTest {
  @TestSetup
  static void setup() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlUser,
        true
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser.Id,
        lstOfTerritory[0].Id
      );
    }
    System.runAs(mlUser) {
      Lead leadRec = (Lead) FakerFactory.make(new FakerLeadFactory());
      leadRec.Is_Valid_Address__c = true;
      leadRec.Gender__c = 'M';
      leadRec.Home_Phone__c = '+61333333333';
      //leadRec.MobilePhone = '+61333333333';
      leadRec.Work_Phone__c = '+61333333333';
      insert leadRec;
    }
  }
  @isTest
  static void testMaintainPartyService() {
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
      Test.setMock(HttpCalloutMock.class, new MockMaintainPartyCallout());

      Test.startTest();
      DCRMMaintainPartyService service = new DCRMMaintainPartyService();
      Lead record = [SELECT id FROM Lead LIMIT 1];
      CCRMLeadConversion.LeadConversionWrapper leadWrapper = CCRMLeadConversion.getLeadRecordForConversion(
        record.id
      );
      record = leadWrapper.leadRecord;
      HttpCalloutResponse response = service.maintainParty(record);
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
    System.runAs(MLCRMTestDataFactory.createAdminUser()) {
      Test.setMock(HttpCalloutMock.class, new MockMaintainPartyCallout());

      Test.startTest();
      DCRMMaintainPartyServiceMock service = new DCRMMaintainPartyServiceMock();
      Lead record = [SELECT id FROM Lead LIMIT 1];
      CCRMLeadConversion.LeadConversionWrapper leadWrapper = CCRMLeadConversion.getLeadRecordForConversion(
        record.id
      );
      record = leadWrapper.leadRecord;
      HttpCalloutResponse response = service.maintainParty(record);
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
}
