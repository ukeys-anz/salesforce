/**
 * @author Boobalakrishnan Duraisamy
 * @since Mar 2022
 * @description test class for CCRMAPIRepository
 * @group Repository
 */
@isTest
public with sharing class CCRMAPIRepositoryTest {
  static Lib_MockProvider maintainPartyService;

  static void registerMocks() {
    maintainPartyService = Lib_MockProvider.forType(MaintainPartyService.class);
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
      Country = 'Country'
    );
    return leadRec;
  }

  @isTest
  static void testGetValidateAbn() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel getAbnInfo = apiRepo.validateAbn('11005357522');

    // Verify response received contains fake values
    System.assertEquals(
      'Active',
      getAbnInfo.AbnStatus,
      'Validate response should be Active'
    );
  }

  @isTest
  static void testGetValidateAcn() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel getAcnInfo = apiRepo.validateAcn('005357522');

    // Verify response received contains fake values
    System.assertEquals(
      '11005357522',
      getAcnInfo.Abn,
      'Validated ABN should be returned'
    );
  }

  @isTest
  static void testSearchPartyInfo() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    Lead record = new Lead();
    CCRMSearchPartyModel searchPartyInfo = apiRepo.searchPartyInfo(record);

    // Verify response received contains fake values
    System.assertEquals(
      '123456789',
      searchPartyInfo.certifiedResults[0].ocvId,
      'Expected ocvId to be 123456789'
    );
  }

  @isTest
  static void testCreatePartyInfo() {
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    Lead record = new Lead();
    CCRMCreatePartyModel createPartyInfo = apiRepo.createParty(record);

    // Verify response received contains fake values
    System.assertEquals(
      '1234567891',
      createPartyInfo.capcisId,
      'The returned capcisId does not match'
    );
  }

  @isTest
  static void testGetAddressesLWCV3Test() {
    CCRMValidateAddressModelV3 getAddressesLWC = CCRMAPIRepository.getAddressesLwcV3(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertEquals(
      6,
      getAddressesLWC.count,
      'address should score should return'
    );
  }

  @isTest
  static void testGetSelectedAddressLWC() {
    CCRMGetSelectedAddressModel getAddressesLWC = CCRMAPIRepository.getSelectedAddressLWC(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertEquals(
      'B',
      getAddressesLWC.addressType,
      'Select Address should return'
    );
  }

  @isTest
  static void testGetAddressesLwcV3() {
    CCRMValidateAddressModelV3 getAddressesLWC = CCRMAPIRepository.getAddressesLwcV3(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertNotEquals(
      null,
      getAddressesLWC.result[0].address,
      'address suggestions should return'
    );
  }

  @isTest
  static void testGetSelectedAddressLwcV3() {
    CCRMGetSelectedAddressModelV3 getAddressesLWC = CCRMAPIRepository.getSelectedAddressLwcV3(
      '005357522'
    );

    // Verify response received contains fake values
    System.assertNotEquals(
      null,
      getAddressesLWC.result,
      'address result should return'
    );
  }

  @isTest
  static void testvalidateManualAddressesV3LWC() {
    CCRMValidateManualAddressModel getAddressesLWC = MLCRMAPIRepository.validateManualAddressesV3LWC(
      'VIC',
      3000,
      'MELBOURNE'
    );

    // Verify response received contains fake values
    System.assertNotEquals(
      null,
      getAddressesLWC.result,
      'The Suburb, State and Postcode information provided is invalid. Please check the address entered and try again.'
    );
  }

  @IsTest
  static void testmaintainPartyOrganisationSuccess() {
    registerMocks();
    //GIVEN Lead record and request wrapper
    Lead leadRecord = getLeadRecord();
    CommercialLeadConversionHelper commercialLeadConvHelper = new CommercialLeadConversionHelper();
    OCVRequestPayloadWrapper ocvRequest = commercialLeadConvHelper.getRequestRecordOrganization(
      leadRecord
    );

    HttpCalloutResponse response = new MaintainPartyServiceMock()
      .maintainPartyOrganisation(null);

    maintainPartyService.mock('maintainPartyOrganisation', response);

    //WHEN calling a method
    MaintainPartyModel result = new CCRMAPIRepository()
      .maintainPartyOrganisation(ocvRequest);

    //THEN assert should return true
    Assert.isNotNull(result, 'Response not successful');
  }

  @IsTest
  static void testmaintainPartyOrganisationError() {
    registerMocks();
    //GIVEN  unsuccessful response, Opp rec
    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.body = '{"data": {"responseMessage" : "", "isSuccessful":false} }';
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');

    Lead leadRecord = getLeadRecord();
    CommercialLeadConversionHelper commercialLeadConvHelper = new CommercialLeadConversionHelper();
    OCVRequestPayloadWrapper ocvRequest = commercialLeadConvHelper.getRequestRecordOrganization(
      leadRecord
    );

    maintainPartyService.mock('maintainPartyOrganisation', errorResponse);
    Exception ex;

    //WHEN calling a method
    try {
      new CCRMAPIRepository().maintainPartyOrganisation(ocvRequest);
    } catch (Exception e) {
      ex = e;
    }

    //THEN assert should return true
    Assert.isTrue(
      ex instanceof System.CalloutException,
      'Exception should be thrown.'
    );
  }
}
