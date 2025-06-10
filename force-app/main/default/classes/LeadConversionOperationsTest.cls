/**
 * @author MLCRM developer
 * @since 07/2024
 * @description Test class for LeadConversionActions
 */
@isTest
private class LeadConversionOperationsTest {
  static Lib_MockProvider leadConversionActionMock;
  static Lib_MockProvider a2zReviewRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    leadConversionActionMock = Lib_MockProvider.forType(
      LeadConversionActionsRepository.class
    );
    a2zReviewRepoMock = Lib_MockProvider.forType(A2ZReviewRepository.class);
  }

  /**
   * @description test method for convertLead
   */
  @isTest
  static void convertLeadTest() {
    registerMocks();
    LeadStatus leadStatusRecord = getMockLeadStatusData();
    leadConversionActionMock.mock('getLeadStatus', leadStatusRecord);
    leadConversionActionMock.mock(
      'getLeadTasks',
      new List<Task>{ getMockTaskRecordData() }
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Lead leadRecord = getMockLeadRecordDataWithCampaignMember(accountId);
    List<A_Z_Review__c> a2zReviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
        Customer__c = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Lead__c = leadRecord.id,
        Opportunity__c = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
      )
    };
    a2zReviewRepoMock.mock('fetchReviewsByLead', a2zReviewList);
    leadConversionActionMock.mock(
      'getContactList',
      new List<Contact>{ getMockContactData(true) }
    );
    leadConversionActionMock.mock('getLeadforOpportunityCreation', leadRecord);
    Test.startTest();
    LeadConversionOperations.convertLead(accountId, leadRecord);
    Test.stopTest();
    Assert.isFalse(
      leadConversionActionMock.getHistories('convertLeadRecord').isEmpty(),
      'convertLeadRecord should have been called.'
    );
  }

  /**
   * @description test method for setLeadSkipValidation
   */
  @isTest
  static void setLeadSkipValidationTest() {
    registerMocks();
    Lead leadRecord = getMockLeadRecordData(null);
    Test.startTest();
    LeadConversionOperations.setLeadSkipValidation(leadRecord);
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'Task update is not working properly'
    );
  }

  /**
   * @description test method for setTaskSkipValidation
   */
  @isTest
  static void setTaskSkipValidationTest() {
    registerMocks();
    List<Task> tasksList = new List<Task>{ getMockTaskRecordData() };
    Test.startTest();
    LeadConversionOperations.setTaskSkipValidation(tasksList);
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'Task update is not working properly'
    );
  }

  /**
   * @description test method for createOpportunities
   */
  @isTest
  static void createOpportunitiesTest() {
    registerMocks();
    LeadStatus leadStatusRecord = getMockLeadStatusData();
    leadConversionActionMock.mock('getLeadStatus', leadStatusRecord);
    CCRMLeadPlatformEventHelper.leadTask = new List<Task>{
      getMockTaskRecordData()
    };
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Lead leadRecord = getMockLeadRecordDataWithCampaignMember(accountId);
    leadConversionActionMock.mock('getLeadforOpportunityCreation', leadRecord);
    Test.startTest();
    LeadConversionOperations.createOpportunity(
      leadRecord,
      Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doInsert').isEmpty(),
      'create Opportunity is not working properly'
    );
  }

  /**
   * @description test method for dmlConvertLeadRecord
   */
  @isTest
  static void dmlConvertLeadRecordTest() {
    registerMocks();
    LeadStatus leadStatusRecord = getMockLeadStatusData();
    leadConversionActionMock.mock('getLeadStatus', leadStatusRecord);
    Test.startTest();
    LeadConversionOperations.dmlConvertLeadRecord(
      Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      idLead,
      Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    Test.stopTest();
    Assert.isFalse(
      leadConversionActionMock.getHistories('convertLeadRecord').isEmpty(),
      'convertLeadRecord should have been called.'
    );
  }

  /**
   * @description Returns a mock Database.LeadConvertResult record
   * @return A mock Database.LeadConvertResult record
   */
  private static Database.LeadConvertResult getMockLeadConvertResult() {
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

  /**
   * @description Returns a mock LeadStatus record
   * @return A mock LeadStatus record
   */
  private static LeadStatus getMockLeadStatusData() {
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
   * @description Returns a mock Lead record
   * @param accountid id of the account
   * @return A mock Lead  record
   */
  private static Lead getMockLeadRecordData(ID accountid) {
    return new Lead(
      Lead_Originator__c = 'Unica',
      RecordTypeId = RTLead.mlcrmLead,
      Id = idLead,
      Skip_Validations__c = '',
      FinServ__RelatedAccount__c = accountId,
      CAPCIS_ID__c = 'CAP-Test123'
    );
  }

  static Lead getMockLeadRecordDataWithCampaignMember(ID accountid) {
    Lead record = new Lead(
      FinServ__RelatedAccount__c = accountId,
      Id = idLead,
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
      Lead_Originator__c = 'Unica',
      Skip_Validations__c = '',
      CAPCIS_ID__c = 'CAP-Test123',
      RecordType = new RecordType(DeveloperName = 'MLCRM_Lead')
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

  /**
   * @description Returns a mock Task record
   * @return A mock Task  record
   */
  private static Task getMockTaskRecordData() {
    return new Task(
      id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      whoid = idLead,
      subject = 'Test Task',
      Skip_Validations__c = ''
    );
  }

  /**
   * @description Returns a mock Contact record
   * @param isPersonAccount to set if the record is Person Account contact
   * @return A mock Contact record
   */
  private static Contact getMockContactData(Boolean isPersonAccount) {
    return (Contact) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'id' => Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
          'isPersonAccount' => isPersonAccount
        }
      ),
      Contact.class
    );
  }

  /**
   * @description test method for getLeadIdForUnicaAdobeOnLC with ML Lead
   */
  @isTest
  static void getLeadIdForUnicaAdobeOnLCForMLTest() {
    Lead leadRecord = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = RTLead.mlcrmLead,
      Id = idLead
    );
    Test.startTest();
    ID leadId = LeadConversionOperations.getLeadIdForUnicaAdobeOnLC(leadRecord);
    Test.stopTest();
    Assert.areNotEqual(
      null,
      leadId,
      'getLeadForUnicaAdobeOnLCTest method failed to validate'
    );
  }

  /**
   * @description test method for getLeadIdForUnicaAdobeOnLC with Originator = MLCRM
   */
  @isTest
  static void getLeadIdForUnicaAdobeOnLCForMLOriginatorTest() {
    Lead leadRecord = new Lead(
      Lead_Originator__c = 'MLCRM',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = RTLead.mlcrmLead,
      Id = idLead
    );
    Test.startTest();
    ID leadId = LeadConversionOperations.getLeadIdForUnicaAdobeOnLC(leadRecord);
    Test.stopTest();
    Assert.areEqual(
      null,
      leadId,
      'getLeadIdForUnicaAdobeOnLCForMLOriginatorTest method failed to validate'
    );
  }

  /**
   * @description test method for getLeadIdForUnicaAdobeOnLC with CCRM Lead
   */
  @isTest
  static void getLeadIdForUnicaAdobeOnLCForCCRMTest() {
    Lead leadRecord = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      Id = idLead
    );
    Test.startTest();
    ID leadId = LeadConversionOperations.getLeadIdForUnicaAdobeOnLC(leadRecord);
    Test.stopTest();
    Assert.areNotEqual(
      null,
      leadId,
      'getLeadIdForUnicaAdobeOnLCForCCRMTest method failed to validate'
    );
  }

  /**
   * @description test method for isAutoMisMatchTaskRequired for ML Lead
   */
  @isTest
  static void isAutoMisMatchTaskRequiredForMLCRMTest() {
    Lead leadRecord = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = RTLead.mlcrmLead,
      Id = idLead
    );
    Test.startTest();
    Boolean autoMisMatchTaskRequired = LeadConversionOperations.isAutoMisMatchTaskRequired(
      leadRecord
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      autoMisMatchTaskRequired,
      'isAutoMisMatchTaskRequiredTest method failed to validate'
    );
  }

  /**
   * @description test method for isAutoMisMatchTaskRequired for CCRM lead
   */
  @isTest
  static void isAutoMisMatchTaskRequiredForCCRMTest() {
    Lead leadRecord = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      Entity_Type__c = 'Individual',
      Id = idLead
    );
    Test.startTest();
    Boolean autoMisMatchTaskRequired = LeadConversionOperations.isAutoMisMatchTaskRequired(
      leadRecord
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      autoMisMatchTaskRequired,
      'isAutoMisMatchTaskRequiredTest method failed to validate'
    );
  }

  /**
   * @description test method for getContactsToDelete
   */
  @isTest
  static void getContactsToDeleteTest() {
    Database.LeadConvertResult lcResult = getMockLeadConvertResult();
    Test.startTest();
    Set<ID> contactIds = LeadConversionOperations.getContactsToDelete(lcResult);
    Test.stopTest();
    Assert.areEqual(
      true,
      !contactIds.isEmpty(),
      'getContactsToDeleteTest method failed to validate'
    );
  }

  /**
   * @description test method for getMapOfAccountIdWithCCRMLead
   */
  @isTest
  static void getMapOfAccountIdWithCCRMLeadTest() {
    Lead leadRecord = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      Id = idLead
    );
    Database.LeadConvertResult lcResult = getMockLeadConvertResult();
    Test.startTest();
    Map<Id, Id> mapOfAccountIdWithLead = LeadConversionOperations.getMapOfAccountIdWithLeadforA2ZReview(
      lcResult,
      leadRecord
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      mapOfAccountIdWithLead.size(),
      'getMapOfAccountIdWithCCRMLeadTest method failed to validate'
    );
  }

  /**
   * @description test method for transferTasksToOpportunity
   */
  @isTest
  static void transferTasksToOpportunityTest() {
    registerMocks();
    List<Task> tasksList = new List<Task>{ getMockTaskRecordData() };
    Test.startTest();
    LeadConversionOperations.transferTasksToOpportunity(
      new Map<Id, Id>{
        idLead => Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
      },
      tasksList
    );
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'Task transder is not working properly'
    );
  }

  /**
   * @description test method for deleteAutoCreatedContacts for Person Account
   */
  @isTest
  static void deleteAutoCreatedPersonContactsTest() {
    registerMocks();
    List<Contact> contactlist = new List<Contact>{ getMockContactData(true) };
    leadConversionActionMock.mock('getContactList', contactlist);
    Test.startTest();
    LeadConversionOperations.deleteAutoCreatedContacts(
      new Set<Id>{ Lib_FakeIdGenerator.getMockId(Contact.SObjectType) }
    );
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doDelete').isEmpty(),
      'delete AutoCreatedContacts for Person Account is not working properly'
    );
  }

  /**
   * @description test method for deleteAutoCreatedContacts for Org Account
   */
  @isTest
  static void deleteAutoCreatedOrgContactsTest() {
    registerMocks();
    List<Contact> contactlist = new List<Contact>{ getMockContactData(false) };
    leadConversionActionMock.mock('getContactList', contactlist);
    Test.startTest();
    LeadConversionOperations.deleteAutoCreatedContacts(
      new Set<Id>{ Lib_FakeIdGenerator.getMockId(Contact.SObjectType) }
    );
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doDelete').isEmpty(),
      'delete AutoCreatedContacts is not working properly'
    );
  }

  /**
   * @description test method for transferA2ZReviewToOpportunity
   */
  @isTest
  static void transferA2ZReviewToOpportunityTest() {
    registerMocks();
    List<A_Z_Review__c> a2zReviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
        Customer__c = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Lead__c = idLead,
        Opportunity__c = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
      )
    };
    a2zReviewRepoMock.mock('fetchReviewsByLead', a2zReviewList);
    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>{
      idLead => Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
    };
    Map<Id, Id> mapOfAccountIdWithLeadId = new Map<Id, Id>{
      idLead => Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    };
    Test.startTest();
    LeadConversionOperations.transferA2ZReviewToOpportunity(
      mapOfAccountIdWithLeadId,
      mapOfOpportunityId
    );
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'transferA2ZReviewToOpportunity is not working properly'
    );
  }
}
