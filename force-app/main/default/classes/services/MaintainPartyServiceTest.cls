/**
 * @author Mildeep Pahwa
 * @since Feb 2025
 * @description test class for MaintainPartyService
 * @group Service
 */
@isTest
public with sharing class MaintainPartyServiceTest {
  static Lib_MockProvider leadConversionRepositoryMock;
  static Lib_MockProvider calloutMock;

  static void registerMocks() {
    leadConversionRepositoryMock = Lib_MockProvider.forType(
      CommercialLeadConversionRepository.class
    );
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
  }

  static Lead getLeadRecord() {
    Industry__c industryRec = new Industry__c(
      Id = Lib_FakeIdGenerator.getMockId(Industry__c.SObjectType),
      Code__c = '0011'
    );
    Lead leadRec = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      Entity_Type__c = '04',
      Industry__r = industryRec,
      Company = 'ABC',
      Email = 'abc@ml.anz.com',
      Work_Phone__c = '+61412345378',
      MobilePhone = '+61412345378',
      FirstName = 'John',
      LastName = 'Doe',
      Title__c = 'Mr',
      ABN__c = '11111111111',
      Is_Valid_Address__c = true,
      Street = 'Street',
      City = 'City',
      State = 'State',
      PostalCode = '110050',
      Country = 'Country',
      ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    return leadRec;
  }

  @isTest
  static void testMaintainPartyService() {
    registerMocks();

    // GIVEN Lead Record
    Lead leadRecord = getLeadRecord();
    User leadOwner = new User(Id = leadRecord.ownerId, Lan_Id__c = 'testLanId');
    leadConversionRepositoryMock.mock('getLeadOwnerLanId', leadOwner);
    CommercialLeadConversionHelper commercialLeadConvHelper = new CommercialLeadConversionHelper();

    //WHEN calling a method
    Test.startTest();
    OCVRequestPayloadWrapper ocvRequest = commercialLeadConvHelper.getRequestRecordOrganization(
      leadRecord
    );
    new MaintainPartyService().maintainPartyOrganisation(ocvRequest);
    Test.stopTest();

    //THEN it should make a callout
    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
  }

  @isTest
  static void maintainPartyServiceMockTest() {
    //WHEN Calling a method
    Test.startTest();
    HttpCalloutResponse response = new MaintainPartyServiceMock()
      .maintainPartyOrganisation(null);
    Test.stopTest();

    //THEN it should return a successful response
    Assert.isTrue(response.successful, 'Response should be successful');
  }
}
