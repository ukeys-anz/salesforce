/**
 * @author Hitesh Wasdani
 * @since  07/2024
 * @description Test class for LeadConversionHelper
 */
@isTest
public class LeadConversionHelperTest {
  static Lib_MockProvider leadConversionActionMock;
  static Lib_MockProvider dmlRepoMock;
  public static User ocvUser;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    leadConversionActionMock = Lib_MockProvider.forType(
      LeadConversionActionsRepository.class
    );
  }

  /**
   * @description test method for updateLeadWithMaintainPartyInfo
   */
  @isTest
  static void testUpdateLeadWithMaintainPartyInfo() {
    registerMocks();
    leadConversionActionMock.mock('isLeadCAPCISUpdatable', true);
    Lead leadRecord = new Lead(RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID);
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String capId = 'testCapId';
    Test.startTest();
    leadRecord = LeadConversionHelper.updateLeadWithMaintainPartyInfo(
      accId,
      capId,
      leadRecord
    );
    Test.stopTest();
    Assert.areEqual(
      CCRMConstants.CONVERT_LEAD,
      leadRecord.Skip_Validations__c,
      'Lead SkipValidation is not Correct'
    );
    Assert.areEqual(
      capId,
      leadRecord.CAPCIS_ID__c,
      'Lead CAPCIS_ID__c is not Correct'
    );
    Assert.areEqual(
      accId,
      leadRecord.FinServ__RelatedAccount__c,
      'Lead RelatedAccount is not Correct'
    );
  }

  /**
   * @description test method for updateLeadWithCapcisIdOrg
   */
  @isTest
  static void testUpdateLeadWithCapcisIdOrg() {
    registerMocks();
    leadConversionActionMock.mock('isLeadCAPCISUpdatable', true);
    Lead leadRecord = new Lead(RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID);
    CCRMCreatePartyModel response = new CCRMCreatePartyModel();
    response.capcisId = 'capId';
    response.customerId = 'CustomerId';
    response.customerName = 'CustomerName';
    Test.startTest();
    LeadConversionHelper.updateLeadWithCapcisIdOrg(leadRecord, response);
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'updateLeadWithCapcisIdOrg is not working properly'
    );
  }

  /**
   * @description test method for getCreatePartyInfo
   */
  @isTest
  static void testGetCreatePartyInfo() {
    CCRMCreatePartyModel response = new CCRMCreatePartyModel();
    response.capcisId = 'capId';
    response.customerId = 'CustomerId';
    response.customerName = 'CustomerName';
    Test.startTest();
    ShellProspectInfoWrapper shellProspectInfoInstance = LeadConversionHelper.getCreatePartyInfo(
      response
    );
    Test.stopTest();
    Assert.areEqual(
      response.capcisId,
      shellProspectInfoInstance.sourceSystemId,
      'shellProspect source system Id is not correct'
    );
    Assert.areEqual(
      CCRMConstants.SOURCE_SYSTEM_NAME,
      shellProspectInfoInstance.sourceSystemName,
      'shellProspect source system name is not correct'
    );
    Assert.areEqual(
      response.customerId,
      shellProspectInfoInstance.ocvId,
      'shellProspect CustomerId is not correct'
    );
    Assert.areEqual(
      response.customerName,
      shellProspectInfoInstance.name,
      'shellProspect CustomerName is not correct'
    );
  }

  /**
   * @description test method for getMaintainPartyInfo
   */
  @isTest
  static void testGetMaintainPartyInfoTest() {
    List<MaintainPartyModel.SourceSystems> srcSystemList = new List<MaintainPartyModel.SourceSystems>();
    MaintainPartyModel.SourceSystems srcSystem = new MaintainPartyModel.SourceSystems();
    srcSystem.sourceSystemId = '1212201901';
    srcSystem.sourceSystemName = 'CAP-CIS';
    srcSystemList.add(srcSystem);
    MaintainPartyModel response = new MaintainPartyModel();
    response.sourceSystems = srcSystemList;
    response.ocvId = 'ocvId';
    response.profileIds = new List<String>{
      'BusinessProfile1',
      'BusinessProfile2'
    };
    Test.startTest();
    ShellProspectInfoWrapper shellProspectInfoInstance = LeadConversionHelper.getMaintainPartyInfo(
      response
    );
    Test.stopTest();
    Assert.areEqual(
      response.ocvId,
      shellProspectInfoInstance.ocvId,
      'shellProspect OCVId is not correct'
    );
    Assert.areEqual(
      response.profileIds.size(),
      shellProspectInfoInstance.profileIds.size(),
      'shellProspect profileIds are not correct'
    );
    Assert.areEqual(
      '',
      shellProspectInfoInstance.name,
      'shellProspect name is not correct'
    );
    Assert.areEqual(
      srcSystem.sourceSystemName,
      shellProspectInfoInstance.sourceSystemName,
      'shellProspect name is not correct'
    );
    Assert.areEqual(
      srcSystem.sourceSystemId,
      shellProspectInfoInstance.sourceSystemId,
      'shellProspect Id is not correct'
    );
  }

  /**
   * @description test method for handleError
   */
  @isTest
  static void testHandleErrorTest() {
    String leadId = (String) Lib_FakeIdGenerator.getMockId(
      Lead.getSobjectType()
    );
    String exceptionMsg = '';
    Test.startTest();
    try {
      LeadConversionHelper.handleError('Error: Test Custom Exception', leadId);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      true,
      exceptionMsg.contains('Error: Test Custom Exception'),
      'handleError is not throwing correct exception'
    );
  }

  /**
   * @description test method for populateMaintainPartyDetails
   */
  @isTest
  static void testPopulateMaintainPartyDetails() {
    registerMocks();
    String accExternalId = 'testExtId';
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
      External_Id__c = accExternalId,
      Name = 'Test Account',
      CLG__c = 'testclg',
      FinServ__KYCStatus__c = 'Active'
    );
    leadConversionActionMock.mock('getAccountUsingExternalId', acc);
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Street = 'street',
      City = 'city',
      State = 'State',
      Country = 'Country',
      PostalCode = '12345'
    );
    ShellProspectInfoWrapper response = new ShellProspectInfoWrapper();
    response.sourceSystemId = '1212201901';
    response.sourceSystemName = 'CAP-CIS';
    response.ocvId = 'testOcvId';
    response.name = '';
    response.isIndividual = true;
    OCVRequestPayloadWrapper reqRecord = LeadConversionHelper.getRequestRecord(
      leadrecord
    );

    // Positive Scenario when Account exists with matching ExternalId
    Test.startTest();
    MaintainPartyInformationWrapper.MaintainPartyResult maintainPartyDetailsPositive = LeadConversionHelper.populateMaintainPartyDetails(
      accExternalId,
      response,
      reqRecord
    );
    Test.stopTest();
    Assert.areEqual(
      '',
      maintainPartyDetailsPositive.oppId,
      'Maintain Party oppId is not empty'
    );
    Assert.areEqual(
      false,
      maintainPartyDetailsPositive.isNewCustomer,
      'Maintain Party isNewCustomer is not False'
    );
    Assert.areEqual(
      false,
      maintainPartyDetailsPositive.retrievePartyRequired,
      'Maintain Party retrievePartyRequired is not False'
    );
  }
  /**
   * @description test method for populateMaintainPartyDetails
   */
  @isTest
  static void testPopulateMaintainPartyDetailsAsNegative() {
    ShellProspectInfoWrapper response = new ShellProspectInfoWrapper();
    OCVRequestPayloadWrapper reqRecord = new OCVRequestPayloadWrapper();
    // Negative Scenario when Account does not exists with matching ExternalId
    Test.startTest();
    MaintainPartyInformationWrapper.MaintainPartyResult maintainPartyDetailsNegative = LeadConversionHelper.populateMaintainPartyDetails(
      'test',
      response,
      reqRecord
    );
    Test.stopTest();
    Assert.areEqual(
      null,
      maintainPartyDetailsNegative.oppId,
      'Maintain Party oppId is not null when Account not exists'
    );
    Assert.areEqual(
      null,
      maintainPartyDetailsNegative.isNewCustomer,
      'Maintain Party isNewCustomer is not null when Account not exists'
    );
    Assert.areEqual(
      null,
      maintainPartyDetailsNegative.retrievePartyRequired,
      'Maintain Party retrievePartyRequired is not null when Account not exists'
    );
  }

  /**
   * @description test method for autoCreateShellProspect
   */
  @isTest
  static void testAutoCreateShellProspect() {
    registerMocks();
    User ocvIntegrationUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.getSobjectType()),
      FirstName = 'IntegrationUserOCV',
      Username = System.Label.OCVIntegrationUsername
    );
    leadConversionActionMock.mock('getOCVUser', ocvIntegrationUser);
    OCVRequestPayloadWrapper reqRecord = new OCVRequestPayloadWrapper();
    reqRecord.strFirstName = 'FN';
    reqRecord.strLastName = 'LN';
    List<MaintainPartyModel.SourceSystems> srcSystemList = new List<MaintainPartyModel.SourceSystems>();
    MaintainPartyModel.SourceSystems srcSystem = new MaintainPartyModel.SourceSystems();
    srcSystem.sourceSystemId = '1212201901';
    srcSystem.sourceSystemName = 'CAP-CIS';
    srcSystemList.add(srcSystem);
    MaintainPartyModel response = new MaintainPartyModel();
    response.sourceSystems = srcSystemList;
    response.ocvId = 'ocvId';
    Test.startTest();
    Account shellAcc = LeadConversionHelper.autoCreateShellProspect(
      reqRecord,
      response
    );
    Test.stopTest();
    Assert.areEqual(
      reqRecord.strFirstName,
      shellAcc.FirstName,
      'Shell Account first name is not correct'
    );
    Assert.areEqual(
      response.ocvId,
      shellAcc.OCV_ID__c,
      'Shell Account Ocv Id is not correct'
    );
  }

  /**
   * @description test method for autoCreateShellProspectForCCRM
   */
  @isTest
  static void testAutoCreateShellProspectForCCRM() {
    registerMocks();
    User ocvIntegrationUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.getSobjectType()),
      FirstName = 'IntegrationUserOCV',
      Username = System.Label.OCVIntegrationUsername
    );
    leadConversionActionMock.mock('getOCVUser', ocvIntegrationUser);
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Entity_Type__c = 'Individual'
    );
    CCRMCreatePartyModel response = new CCRMCreatePartyModel();
    response.capcisId = 'CAP-CIS-1212201901';
    response.customerId = 'CustomerOCVId';
    response.customerName = 'CustomerName';
    Test.startTest();
    Account shellAcc = LeadConversionHelper.autoCreateShellProspectForCCRM(
      leadrecord,
      response
    );
    Test.stopTest();
    Assert.areEqual(
      response.customerName,
      shellAcc.Name,
      'Shell Account first name is not correct'
    );
    Assert.areEqual(
      response.customerId,
      shellAcc.OCV_ID__c,
      'Shell Account Ocv Id is not correct'
    );
  }

  /**
   * @description test method for createShellProspect
   */
  @isTest
  static void testCreateShellProspect() {
    String recordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
    OCVRequestPayloadWrapper reqRecord = new OCVRequestPayloadWrapper();
    reqRecord.strFirstName = 'FN';
    reqRecord.strLastName = 'LN';
    reqRecord.strGender = 'M';
    reqRecord.strDateOfBirth = String.valueOf(System.today().addDays(-3000));
    ShellProspectInfoWrapper shellProspectInfoInstance = new ShellProspectInfoWrapper();
    shellProspectInfoInstance.sourceSystemId = '1212201901';
    shellProspectInfoInstance.sourceSystemName = 'CAP-CIS';
    shellProspectInfoInstance.ocvId = 'testOcvId';
    shellProspectInfoInstance.name = '';
    shellProspectInfoInstance.isIndividual = true;

    Test.startTest();
    Account shellAcc = LeadConversionHelper.createShellProspect(
      shellProspectInfoInstance,
      recordTypeId,
      reqRecord
    );
    Test.stopTest();
    Assert.areEqual(
      shellProspectInfoInstance.sourceSystemId,
      shellAcc.Source_System_ID__c,
      'Shell Account SourceSystemId is not correct'
    );
    Assert.areEqual(
      shellProspectInfoInstance.ocvId,
      shellAcc.OCV_ID__c,
      'Shell Account Ocv Id is not correct'
    );
    Assert.areEqual(
      shellProspectInfoInstance.sourceSystemName,
      shellAcc.Source_System_Name__c,
      'Shell Account SourceSystemName is not correct'
    );
  }

  /**
   * @description test method for getRequestRecord
   */
  @isTest
  static void testGetRequestRecord() {
    Lead leadRecord = new Lead();
    leadRecord.Email = 'sam@test.com';
    leadRecord.RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam';
    leadRecord.LastName = 'Jacob';
    Test.startTest();
    OCVRequestPayloadWrapper ocvWrapper = LeadConversionHelper.getRequestRecord(
      leadRecord
    );
    Test.stopTest();
    Assert.areEqual(
      leadRecord.Email,
      ocvWrapper.strEmail,
      'ocvWrapper firstName is not Correct'
    );
    Assert.areEqual(
      leadRecord.FirstName,
      ocvWrapper.strFirstName,
      'ocvWrapper email is not correct'
    );
  }

  /**
   * @description test method for getRequestRecordForRetrieveParty
   */
  @isTest
  static void testGetRequestRecordForRetrieveParty() {
    Account accountRecord = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
      OCV_ID__c = '1234546789',
      ownerId = null,
      Source_System_ID__c = '12345467891',
      Source_System_Name__c = 'CAP-CIS',
      External_Id__c = 'CAP-CIS_123454678911'
    );
    Test.startTest();
    OCVRetrievePartyPayloadWrapper ocvWrapper = LeadConversionHelper.getRequestRecordForRetrieveParty(
      accountRecord
    );
    Test.stopTest();
    Assert.areEqual(
      accountRecord.OCV_ID__c,
      ocvWrapper.ocvId,
      'ocvWrapper OCV ID is not Correct'
    );
    Assert.areEqual(
      accountRecord.Source_System_Name__c,
      ocvWrapper.sourceSystems[0].sourceSystemName,
      'ocvWrapper sourceSystemName is not correct'
    );
  }

  /**
   * @description test method for updateLead
   */
  @isTest
  static void testUpdateLead() {
    registerMocks();
    Lead leadRecord = new Lead();
    leadRecord.Id = (String) Lib_FakeIdGenerator.getMockId(
      Lead.getSobjectType()
    );
    leadRecord.Email = 'sam@test.com';
    leadRecord.RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam';
    leadRecord.LastName = 'Jacob';
    Test.startTest();
    LeadConversionHelper.updateLead(leadRecord);
    Test.stopTest();
    Assert.areEqual(
      false,
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'update lead is not working properly'
    );
  }

  /**
   * @description test method for GetMatchedCustomerInfo
   */
  @isTest
  static void testGetMatchedCustomerInfo() {
    OCVRequestPayloadWrapper record = new OCVRequestPayloadWrapper();
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    Account accountRecord = new Account(
      Id = accId,
      Name = 'Sam',
      CLG__c = 'clgValue'
    );
    ShellProspectInfoWrapper response = new ShellProspectInfoWrapper();
    response.sourceSystemId = '1223445';
    Test.startTest();
    MaintainPartyInformationWrapper.MaintainPartyInfo custInfo = LeadConversionHelper.getMatchedCustomerInfo(
      record,
      accountRecord,
      response
    );
    Test.stopTest();
    Assert.areEqual(accId, custInfo.Id, 'CustomerId is not mapped correctly');
    Assert.areEqual(
      response.sourceSystemId,
      custInfo.cpid,
      'cp Id is not mapped correctly'
    );
  }
}
