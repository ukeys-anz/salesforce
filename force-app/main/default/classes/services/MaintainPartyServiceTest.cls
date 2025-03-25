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
  static Lib_MockProvider userActionsRepoMock;

  static void registerMocks() {
    leadConversionRepositoryMock = Lib_MockProvider.forType(
      CommercialLeadConversionRepository.class
    );
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
    userActionsRepoMock = Lib_MockProvider.forType(UserActionsRepository.class);
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

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      MaintainPartyService.class
    );
    Test.stopTest();
    System.assert(
      serviceResult instanceof MaintainPartyServiceMock,
      'Expected instance of MaintainPartyServiceMock'
    );
  }

  @isTest
  static void maintainPartyServiceMockForIndividualTest() {
    Test.setMock(HttpCalloutMock.class, new MockMaintainPartyCallout());

    Test.startTest();
    MaintainPartyServiceMock service = new MaintainPartyServiceMock();
    OCVRequestPayloadWrapper ocvRequest = getRequestRecord(
      UserInfo.getUserId()
    );
    HttpCalloutResponse response = service.maintainPartyForIndividual(
      ocvRequest
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Expected response status code to be 200'
    );
  }

  @isTest
  static void maintainPartyServiceGetBodyTest() {
    Test.setMock(HttpCalloutMock.class, new MockMaintainPartyCallout());

    Test.startTest();
    OCVRequestPayloadWrapper ocvRequest = getRequestRecord(
      UserInfo.getUserId()
    );
    String requestBody = MaintainPartyIndividualModel.getBody(ocvRequest);
    Test.stopTest();
    System.assert(
      String.isNotBlank(requestBody),
      'Request Body is not retrieved.'
    );
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
