/**
 * @author       : Advait Yermalkar
 * @since        : 02-07-2025
 * @description  : Test class for CommercialLeadConversionHelper class
 **/
@isTest
public with sharing class CommercialLeadConversionHelperTest {
  static Lib_MockProvider leadConversionRepoMock;

  //Setup
  static void registerMocks() {
    leadConversionRepoMock = Lib_MockProvider.forType(
      CommercialLeadConversionRepository.class
    );
  }

  static Lead getReqLeadRecord() {
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

  static CommercialLeadConversionHelper.ShellProspectInfoWrapper createShellProspectInfoWrapper() {
    List<String> profileIdList = new List<String>();
    profileIdList.add('123123123');
    CommercialLeadConversionHelper.ShellProspectInfoWrapper wrapperDetailsAsResponse = new CommercialLeadConversionHelper.ShellProspectInfoWrapper();
    wrapperDetailsAsResponse.sourceSystemName = 'CAP';
    wrapperDetailsAsResponse.sourceSystemId = 'CAP-12345';
    wrapperDetailsAsResponse.ocvId = '1234123';
    wrapperDetailsAsResponse.profileIds = profileIdList;
    wrapperDetailsAsResponse.name = 'John Doe';
    wrapperDetailsAsResponse.isIndividual = true;
    return wrapperDetailsAsResponse;
  }

  //Tests

  @isTest
  static void getShellProspectRecordTest() {
    // GIVEN
    CommercialLeadConversionHelper.ShellProspectInfoWrapper shellProspWrapper = createShellProspectInfoWrapper();
    Lead leadRecord = getReqLeadRecord();
    OCVRequestPayloadWrapper ocvRequest = new CommercialLeadConversionHelper()
      .getRequestRecordOrganization(leadRecord);
    User user = new User(Id = Lib_FakeIdGenerator.getMockId(User.SobjectType));
    CommercialLeadConversionHelper.ocvUser = user;

    // WHEN
    Test.startTest();
    Account newShellProspect = new CommercialLeadConversionHelper()
      .getShellProspectRecord(shellProspWrapper, ocvRequest);

    Test.stopTest();

    // THEN
    Assert.isNotNull(
      newShellProspect,
      'Issue in creating Shell Prospect Record'
    );
    Assert.areEqual(
      user.id,
      newShellProspect.ownerId,
      'Issue in creating Shell Prospect Record. Owner field Mismatch'
    );
  }

  @isTest
  static void getRequestRecordOrganizationTest() {
    // GIVEN Lead Record
    Lead leadRecord = getReqLeadRecord();
    CommercialLeadConversionHelper mainClass = new CommercialLeadConversionHelper();

    // WHEN calling the method
    Test.startTest();
    OCVRequestPayloadWrapper request = mainClass.getRequestRecordOrganization(
      leadRecord
    );
    Test.stopTest();

    // THEN
    Assert.isNotNull(request, 'Issue in creating OCV request Wrapper');
  }

  @isTest
  static void getShellProspectInfoWrapperTest() {
    // GIVEN DCRMMaintainPartyModel & OCVRequestPayloadWrapper
    DCRMMaintainPartyModel response = DCRMMaintainPartyModel.parse(
      new MaintainPartyServiceMock()
        .maintainPartyOrganisation(null)
        .body.toString()
    );
    Lead leadRecord = getReqLeadRecord();
    OCVRequestPayloadWrapper reqRecord = new CommercialLeadConversionHelper()
      .getRequestRecordOrganization(leadRecord);

    // WHEN calling the method
    Test.startTest();
    CommercialLeadConversionHelper.ShellProspectInfoWrapper shellProspectWrapper = new CommercialLeadConversionHelper()
      .getShellProspectInfoWrapper(response, reqRecord);
    Test.stopTest();

    // THEN
    Assert.isNotNull(
      shellProspectWrapper,
      'Issue in creating shellProspectWrapper'
    );
  }

  @IsTest
  static void setMaintainPartyInfoWrapperTest() {
    registerMocks();
    // GIVEN
    Lead leadRecord = getReqLeadRecord();
    String externalId = 'ABC123';

    OCVRequestPayloadWrapper reqRecord = new CommercialLeadConversionHelper()
      .getRequestRecordOrganization(leadRecord);
    DCRMMaintainPartyModel response = DCRMMaintainPartyModel.parse(
      new MaintainPartyServiceMock()
        .maintainPartyOrganisation(null)
        .body.toString()
    );
    CommercialLeadConversionHelper.ShellProspectInfoWrapper shellProspectWrapper = new CommercialLeadConversionHelper()
      .getShellProspectInfoWrapper(response, reqRecord);

    //Mocking
    Account accountInstance = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      External_Id__c = 'ABC123', // Example External Id
      Name = 'Sample Account', // Example Name
      FinServ__KYCStatus__c = 'KYC Passed', // Example KYC Status
      CLG__c = 'CLG01' // Example CLG
    );

    leadConversionRepoMock.mock('getAccountUsingExternalId', accountInstance);

    // WHEN
    Test.startTest();
    MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainPartyWrapper = new CommercialLeadConversionHelper()
      .setMaintainPartyInfoWrapper(externalId, shellProspectWrapper, reqRecord);
    Test.stopTest();

    // THEN
    Assert.isNotNull(
      maintainPartyWrapper.matchedResults,
      'Issue in creating maintainPartyWrapper'
    );
    Assert.areEqual(
      leadRecord.PostalCode,
      maintainPartyWrapper.matchedResults[0].postCode,
      'Issue in creating maintainPartyWrapper : postCode Not Matching'
    );
  }
}
