/**
 * @author Ashwin Mohan
 * @since 02/2025
 * @description  To test LeadConversion Controller
 */
@isTest
public class LeadConversionControllerTest {
  static Lib_MockProvider leadConversionActionMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider customerRelationshipRepoMock;
  static Lib_MockProvider accountActionsRepoMock;
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    leadConversionActionMock = Lib_MockProvider.forType(
      LeadConversionActionsRepository.class
    );
    customerRelationshipRepoMock = Lib_MockProvider.forType(
      CustomerRelationshipsRepository.class
    );
    accountActionsRepoMock = Lib_MockProvider.forType(
      AccountActionsRepository.class
    );
  }

  @isTest
  static void testGetLeadRecordForConversion() {
    registerMocks();
    Lead record = getMockLead('MLCRM_Lead');
    leadConversionActionMock.mock('getLeadRecordForConversion', record);
    Test.startTest();
    LeadConversionController.LeadConversionWrapper wrapper = LeadConversionController.getLeadRecordForConversion(
      record.Id
    );
    Test.stopTest();
    Assert.areEqual(
      'isIndividual',
      wrapper.relatedAccountType,
      'Related Account Type is not correct'
    );
    Assert.areEqual(
      record.Id,
      wrapper.leadRecord.Id,
      'Lead Record is not mapped in wrapper'
    );
  }

  @isTest
  static void testSearchPartyInfoLWC() {
    registerMocks();
    Lead record = getMockLead('MLCRM_Lead');
    leadConversionActionMock.mock(
      'getAccountUsingExternalIds',
      new List<Account>{ getMockAccount() }
    );
    Test.startTest();
    CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper wrapper = LeadConversionController.searchPartyInfoLWC(
      record
    );
    Test.stopTest();
    Assert.areEqual(
      'R5271',
      wrapper.probableAndCertifiedResults[0].cpid,
      'CPID is not matched'
    );
  }

  @isTest
  static void testCreatePartyLWC() {
    registerMocks();
    leadConversionActionMock.mock('isLeadCAPCISUpdatable', true);
    leadConversionActionMock.mock(
      'getOCVUser',
      new User(
        Id = Lib_FakeIdGenerator.getMockId(User.getSobjectType()),
        FirstName = 'IntegrationUserOCV',
        Username = System.Label.OCVIntegrationUsername
      )
    );
    Lead record = getMockLead('MLCRM_Lead');
    Test.startTest();
    String exMessage;
    try {
      LeadConversionController.createPartyLWC(record);
    } catch (Exception ex) {
      exMessage = ex.getMessage();
    }
    Test.stopTest();
    Lead updatedLeads = (Lead) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.areEqual(
      '1234567891',
      updatedLeads.CAPCIS_ID__c,
      'CAP-CIS id is not updated for the lead'
    );
  }

  /**
   * @description test method for ValidateAccountWithNotNullAccount
   */
  @isTest
  static void testValidateAccountWithNotNullAccount() {
    String exceptionMsg = '';
    Test.startTest();
    try {
      LeadConversionController.validateAccount(new Account(), new Lead());
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Assert.areEqual(
      '',
      exceptionMsg,
      'validateAccount is throwing exception for non-null account'
    );
    Test.stopTest();
  }

  /**
   * @description test method for ValidateAccountWithNullAccount
   */
  @isTest
  static void testValidateAccountWithNullAccount() {
    String exceptionMsg = '';
    Lead leadRec = new Lead();
    leadRec.id = (String) Lib_FakeIdGenerator.getMockId(Lead.getSobjectType());
    Test.startTest();
    try {
      LeadConversionController.validateAccount(null, leadRec);
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Assert.areNotEqual(
      '',
      exceptionMsg,
      'validateAccount is not throwing exception for null account'
    );
    Test.stopTest();
  }

  /**
   * @description test method for ValidateResponseWithNullCustomer
   */
  @isTest
  static void testValidateResponseWithNullCustomer() {
    MaintainPartyModel model = new MaintainPartyModel();
    model.newCustomer = null;
    String exceptionMsg = '';
    Lead leadRec = new Lead();
    leadRec.id = (String) Lib_FakeIdGenerator.getMockId(Lead.getSobjectType());
    Test.startTest();
    try {
      LeadConversionController.validateResponse(model, leadRec);
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Assert.areNotEqual(
      '',
      exceptionMsg,
      'validateResponse is not throwing exception empty new customer'
    );
    Test.stopTest();
  }

  /**
   * @description test method for ValidateResponseWithNullOcv
   */
  @isTest
  static void testValidateResponseWithNullOcv() {
    MaintainPartyModel model = new MaintainPartyModel();
    model.newCustomer = '1234';
    model.ocvId = null;
    String exceptionMsg = '';
    Lead leadRec = new Lead();
    leadRec.id = (String) Lib_FakeIdGenerator.getMockId(Lead.getSobjectType());
    Test.startTest();
    try {
      LeadConversionController.validateResponse(model, leadRec);
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Assert.areNotEqual(
      '',
      exceptionMsg,
      'validateResponse is not throwing exception empty ocvId'
    );
    Test.stopTest();
  }

  /**
   * @description test method for ValidateResponseWithData
   */
  @isTest
  static void testValidateResponseWithData() {
    MaintainPartyModel model = new MaintainPartyModel();
    model.newCustomer = '1234';
    model.ocvId = '5678';
    String exceptionMsg = '';
    Lead leadRec = new Lead();
    leadRec.id = (String) Lib_FakeIdGenerator.getMockId(Lead.getSobjectType());
    Test.startTest();
    try {
      LeadConversionController.validateResponse(model, leadRec);
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Assert.areEqual(
      '',
      exceptionMsg,
      'validateResponse is throwing unwanted exception'
    );
    Test.stopTest();
  }

  /**
   * @description test method for GetExternalId
   */
  @isTest
  static void testGetExternalId() {
    ShellProspectInfoWrapper infoWrapper = new ShellProspectInfoWrapper();
    infoWrapper.sourceSystemName = 'CAP-SIS';
    infoWrapper.sourceSystemId = '123456';
    Test.startTest();
    LeadConversionController.getExternalId(infoWrapper);
    Test.stopTest();
    Assert.areEqual(
      infoWrapper.sourceSystemName + '_' + infoWrapper.sourceSystemId,
      LeadConversionController.getExternalId(infoWrapper),
      'GetExternalId is not returning correct value'
    );
  }

  /**
   * @description test method for IsLeadMisMatchCustomer
   */
  @isTest
  static void testIsLeadMisMatchCustomer() {
    registerMocks();
    Lead leadRec = getMockLead('MLCRM_Lead');
    leadConversionActionMock.mock('getLeadsWithCustomerDetails', leadRec);
    Test.startTest();
    String missmatchedFields = LeadConversionController.isLeadMisMatchCustomer(
      leadRec.Id
    );
    Test.stopTest();

    Assert.isTrue(
      missmatchedFields.contains('Work Phone'),
      'Mismatch in Work Phone'
    );
    Assert.isTrue(
      missmatchedFields.contains('Home Phone'),
      'Mismatch in Home Phone'
    );
  }

  /**
   * @description test method for ConvertLeadWithMatchedParty
   */
  @isTest
  static void testConvertLeadWithMatchedParty() {
    registerMocks();
    Account acc = new Account();
    acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    acc.Source_System_ID__c = '12345467891';
    acc.External_Id__c = 'CAP-CIS_123454678911';
    Lead leadRec = new Lead();
    leadRec.Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    leadRec.LastName = 'Test Lead';
    leadRec.RecordTypeId = RTLead.mlcrmLead;
    try {
      LeadConversionController.convertLeadWithMatchedParty(
        (string) acc.Id,
        acc.Source_System_ID__c,
        leadRec
      );
    } catch (Exception e) {
      Assert.areEqual(
        true,
        e.getMessage().contains('Script-thrown exception'),
        'testConvertLeadWithMatchedParty method is not working properly'
      );
    }
  }

  /**
   * @description test method for ConvertLeadWithMatchedPartyWithNullAcc
   */
  @isTest
  static void testConvertLeadWithMatchedPartyWithNullAcc() {
    String exceptionMsg = '';
    try {
      LeadConversionController.convertLeadWithMatchedParty(
        null,
        '12345467891',
        new Lead()
      );
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Assert.areNotEqual(
      '',
      exceptionMsg,
      'testConvertLeadWithMatchedParty is not working properly when accId is empty'
    );
  }

  /**
   * @description test method for ConvertLeadWithMatchedPartyWithNullAcc
   */
  @isTest
  static void testConvertLeadWithMatchedPartyWithNullCpid() {
    String exceptionMsg = '';
    String accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    try {
      LeadConversionController.convertLeadWithMatchedParty(
        accId,
        '',
        new Lead()
      );
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Assert.areNotEqual(
      '',
      exceptionMsg,
      'testConvertLeadWithMatchedParty is not working properly when cpId is empty'
    );
  }

  static Lead getMockLead(String recordType) {
    Lead record = new Lead(
      FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
        Schema.Account.getSObjectType()
      ),
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      FirstName = 'test',
      MiddleName = 'test',
      LastName = 'test',
      Email = 'test@gmail.com',
      Is_Valid_Address__c = true,
      Gender__c = 'M',
      Home_Phone__c = '+61533333333',
      MobilePhone = '+61533333333',
      Work_Phone__c = '+61533333333',
      Street = 'Str 123',
      City = 'City 123',
      Country = 'Australia',
      State = 'State 123',
      PostalCode = '123',
      Entity_Type__c = 'Individual',
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Schema.Territory__c.getSObjectType()
      ),
      RecordTypeId = RTLead.mlcrmLead,
      ConvertedOpportunity = new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType())
      ),
      AdvertisingIndicator__c = true,
      RecordType = new RecordType(DeveloperName = recordType),
      FinServ__RelatedAccount__r = getMockAccount()
    );
    return (Lead) TestUtil.setFields(
      record,
      new Map<String, Object>{
        'CampaignMembers' => new List<CampaignMember>{
          new CampaignMember(
            CampaignId = Lib_FakeIdGenerator.getMockId(
              Schema.Campaign.getSObjectType()
            )
          )
        }
      }
    );
  }

  static Account getMockAccount() {
    return new Account(
      FirstName = 'test',
      MiddleName = 'test',
      LastName = 'test',
      Advertising_Indicator__c = 'Y',
      OCV_Event_Version__c = 1,
      RecordType = new RecordType(DeveloperName = 'PersonAccount'),
      External_Id__c = 'CAP-CIS_12345467891',
      FinServ__KYCStatus__c = 'PC'
    );
  }

  static Database.LeadConvertResult getMockLeadConvertResult(Id idLead) {
    return (Database.LeadConvertResult) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'accountid' => Lib_FakeIdGenerator.getMockId(Account.SObjectType),
          'contactid' => Lib_FakeIdGenerator.getMockId(contact.SObjectType),
          'leadid' => idLead,
          'opportunityid' => Lib_FakeIdGenerator.getMockId(
            Opportunity.SObjectType
          ),
          'success' => true
        }
      ),
      Database.LeadConvertResult.class
    );
  }

  static LeadStatus getMockLeadStatusData() {
    return (LeadStatus) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'MasterLabel' => 'Converted',
          'IsConverted' => true
        }
      ),
      LeadStatus.class
    );
  }

  /**
   * @description test method for ConvertLeadWithMatchedParty
   */
  @isTest
  static void testRetrieveParty() {
    registerMocks();
    Account acc = new Account();
    acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    acc.Source_System_ID__c = '12345467891';
    acc.External_Id__c = 'CAP-CIS_123454678911';
    accountActionsRepoMock.mock('getCurrentAccountById', acc);
    LeadConversionController.retrieveParty((string) acc.Id);
    System.assert(true, 'retrieveParty executed without exceptions');
  }

  @isTest
  static void testConvertLeadNTB() {
    registerMocks();
    leadConversionActionMock.mock('isLeadCAPCISUpdatable', true);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id franchiseOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id custRelationshipId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );

    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Primary_Franchise_Owner__c = franchiseOwnerId
    );

    List<Customer_Relationship__c> lstOfSobject = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = custRelationshipId,
        Relationship_To_Franchise__c = 'Primary',
        Customer__c = accountId,
        Territory__r = terrRecord,
        Territory__c = idTerritory
      )
    };
    Lead record = getMockLead('MLCRM_Lead');
    leadConversionActionMock.mock(
      'getOCVUser',
      new User(
        Id = Lib_FakeIdGenerator.getMockId(User.getSobjectType()),
        FirstName = 'IntegrationUserOCV',
        Username = System.Label.OCVIntegrationUsername
      )
    );
    customerRelationshipRepoMock.mock(
      'getCRDetails',
      new List<Customer_Relationship__c>{ lstOfSobject[0] }
    );
    customerRelationshipRepoMock.mock(
      'getCustRelationshipIdofShellProspectAccount',
      lstOfSobject
    );

    Test.startTest();
    MaintainPartyInformationWrapper.MaintainPartyResult wrapper = LeadConversionController.convertLeadNTB(
      record
    );
    Assert.areEqual(
      wrapper.isNewCustomer,
      false,
      'ConvertLeadNTB not able to convert new lead properly'
    );
    Test.stopTest();
  }
}
