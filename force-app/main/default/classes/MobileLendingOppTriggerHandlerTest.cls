/**
 * @author       : Ashwin Mohan
 * @since        : Aug 2025
 * @description  : MobileLendingOppTriggerHandlerTest is the test class for MobileLendingOpportunityTriggerHandler and also covers Opportunity Trigger
 **/
@isTest
public class MobileLendingOppTriggerHandlerTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider territoryRepoMock;
  static Lib_MockProvider oppActionRepoMock;
  static Lib_MockProvider accRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    territoryRepoMock = Lib_MockProvider.forType(
      TerritoryActionsRepository.class
    );
    oppActionRepoMock = Lib_MockProvider.forType(
      OpportunityActionsRepository.class
    );
    accRepoMock = Lib_MockProvider.forType(AccountActionsRepository.class);
  }

  @isTest
  static void testIsValidRecord() {
    Opportunity oppRecord = getOpportunityRecord();
    Test.startTest();
    MobileLendingOpportunityTriggerHandler handler = new MobileLendingOpportunityTriggerHandler();
    Boolean output = handler.isValidRecord(oppRecord);
    Test.stopTest();
    Assert.isTrue(output, 'Opportunity is not of MLCRM recordtype');
  }

  @istest
  static void testBeforeInsert() {
    registerMocks();
    Opportunity oppRecord = getOpportunityRecord();
    oppRecord.Loanapp_Reference__c = 'MLCRM-101';
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    oppActionRepoMock.mock('getOpportunityByLoanappReference', oppRecords);
    Test.startTest();
    MobileLendingOpportunityTriggerHandler handler = new MobileLendingOpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onBeforeInsert();
    Test.stopTest();
    Assert.areEqual(
      'Test Opportunity TAX Number ******7890 Credit Card Number **********1234 TFN Number *********4209',
      oppRecords[0].Description,
      'should redact Description field on insertion'
    );
  }

  @isTest
  static void testBeforeInsertError() {
    registerMocks();
    Opportunity oppRecord = getOpportunityRecord();
    oppRecord.Loanapp_Reference__c = 'MLCRM-101';
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    oppActionRepoMock.mock('getOpportunityByLoanappReference', oppRecords);
    Test.startTest();
    MobileLendingOpportunityTriggerHandler handler = new MobileLendingOpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onBeforeInsert();
    Test.stopTest();
    List<Database.Error> errors = oppRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'record should not be valid!');
    // Assert.areEqual(
    //   Label.ML_ValidateTerritoryChangeByNonMLUser,
    //   errors[0].getMessage(),
    //   'Error when Territory edited by non-ML User'
    // );
    Assert.areEqual(
      StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,
      errors[0].getStatusCode(),
      'No Error found'
    );
  }

  @isTest
  static void testAfterInsert() {
    registerMocks();
    Opportunity oppRecord = getOpportunityRecord();
    oppRecord.Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSObjectType());
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    account acc = (Account) TestUtil.setFields(
      new Account(Id = oppRecord.AccountId),
      new Map<String, Object>{
        'PersonContactId' => Lib_FakeIdGenerator.getMockId(
          Contact.getSobjectType()
        )
      }
    );
    accRepoMock.mock('getAccountByIds', new Map<Id, Account>{ acc.Id => acc });
    oppActionRepoMock.mock(
      'getTerritories',
      new Map<Id, Territory__c>{
        oppRecord.Territory__c => new Territory__c(
          Id = oppRecord.Territory__c,
          Primary_Franchise_Owner__c = UserInfo.getUserId()
        )
      }
    );
    territoryRepoMock.mock(
      'getTerritorySharingMetadata',
      new List<Territory_Based_Sharing_Config__mdt>{
        new Territory_Based_Sharing_Config__mdt(
          Active__c = true,
          Row_Cause__c = 'Manual',
          Sharing_Scope__c = 'Territory',
          Sharing_Object__c = 'OpportunityShare',
          Object_Name__c = 'Opportunity',
          Eligible_Record_Types__c = 'MLCRM_Opportunity',
          Territory_Field__c = 'Territory__c'
        )
      }
    );
    Test.startTest();
    MobileLendingOpportunityTriggerHandler handler = new MobileLendingOpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onAfterInsert();
    Test.stopTest();
    Territory_Base_Sharing_Event__e event = (Territory_Base_Sharing_Event__e) dmlRepoMock
      .getHistory('doPublish')
      .listOfArgs[0];
    Assert.areEqual(
      'Opportunity',
      event.Trigger_Object__c,
      'Event should contains info for Opportunity Sharing'
    );
    Assert.isTrue(
      event.Record_Ids__c.contains(oppRecord.Id),
      'Event should contains info for Opportunity Sharing'
    );
  }

  @istest
  static void testBeforeUpdate() {
    Opportunity oppRecord = getOpportunityRecord();
    oppRecord.Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSObjectType());
    oppRecord.Loanapp_Reference__c = 'MLCRM-101';
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppRecord.Id => oppRecord
    };
    Test.startTest();
    MobileLendingOpportunityTriggerHandler handler = new MobileLendingOpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();
    Assert.areEqual(
      'Test Opportunity TAX Number ******7890 Credit Card Number **********1234 TFN Number *********4209',
      oppRecords[0].Description,
      'should redact Description field on insertion'
    );
  }

  @isTest
  static void testBeforeUpdateError() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.getSObjectType());
    Opportunity oldOppRecord = getOpportunityRecord();
    oldOppRecord.Loanapp_Reference__c = 'MLCRM-100';
    Opportunity oppRecord = getOpportunityRecord();
    oppRecord.Id = oppId;
    oppRecord.Loanapp_Reference__c = 'MLCRM-101';
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => oldOppRecord
    };
    Account accRec = (Account) TestUtil.setFields(
      new Account(Id = oppRecord.AccountId),
      new Map<String, Object>{
        'PersonContactId' => Lib_FakeIdGenerator.getMockId(
          Contact.getSobjectType()
        )
      }
    );
    oppActionRepoMock.mock('getOpportunityByLoanappReference', oppRecords);
    accRepoMock.mock(
      'getAccountByIds',
      new Map<Id, Account>{ accRec.Id => accRec }
    );
    territoryRepoMock.mock(
      'getTerritorySharingMetadata',
      new List<Territory_Based_Sharing_Config__mdt>{
        new Territory_Based_Sharing_Config__mdt(
          Active__c = true,
          Row_Cause__c = 'Manual',
          Sharing_Scope__c = 'Territory',
          Sharing_Object__c = 'OpportunityShare',
          Object_Name__c = 'Opportunity',
          Eligible_Record_Types__c = 'MLCRM_Opportunity',
          Territory_Field__c = 'Territory__c'
        )
      }
    );
    Test.startTest();
    MobileLendingOpportunityTriggerHandler handler = new MobileLendingOpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();
    List<Database.Error> errors = oppRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'record should not be valid!');
    // Assert.areEqual(
    //   Label.ML_ValidateTerritoryChangeByNonMLUser,
    //   errors[0].getMessage(),
    //   'Error when Territory edited by non-ML User'
    // );
    Assert.areEqual(
      StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,
      errors[0].getStatusCode(),
      'No Error found'
    );
  }

  @isTest
  static void testAfterUpdate() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.getSObjectType());
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Opportunity oppRecord = getOpportunityRecord();
    oppRecord.Id = oppId;
    oppRecord.OwnerId = idOwner2;
    Opportunity oldOppRecord = getOpportunityRecord();
    oldOppRecord.Id = oppId;
    oldOppRecord.OwnerId = idOwner;
    List<Opportunity> oppRecords = new List<Opportunity>{ oppRecord };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oldOppRecord.Id => oldOppRecord
    };
    territoryRepoMock.mock(
      'getTerritorySharingMetadata',
      new List<Territory_Based_Sharing_Config__mdt>{
        new Territory_Based_Sharing_Config__mdt(
          Active__c = true,
          Row_Cause__c = 'Manual',
          Sharing_Scope__c = 'Territory',
          Sharing_Object__c = 'OpportunityShare',
          Object_Name__c = 'Opportunity',
          Eligible_Record_Types__c = 'MLCRM_Opportunity',
          Territory_Field__c = 'Territory__c'
        )
      }
    );
    oppActionRepoMock.mock(
      new Map<String, Object>{
        'getOpportunityContactRolesByOppIds' => new List<OpportunityContactRole>(),
        'getOCRSyncByOCRIds' => new List<Opportunity_Contact_Role_Sync__c>()
      }
    );
    Test.startTest();
    MobileLendingOpportunityTriggerHandler handler = new MobileLendingOpportunityTriggerHandler();
    handler.records = oppRecords;
    handler.onAfterUpdate(oldMap);
    Test.stopTest();
    List<OpportunityShare> shareRecord = (List<OpportunityShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      UserInfo.getUserId(),
      shareRecord[0].UserOrGroupId,
      'Record not shared with original owner'
    );
    Assert.isNotNull(
      dmlRepoMock.getHistory('doPublish'),
      'Territory Share Event is not published'
    );
    Territory_Base_Sharing_Event__e event = (Territory_Base_Sharing_Event__e) dmlRepoMock
      .getHistory('doPublish')
      .listOfArgs[0];
    Assert.areEqual(
      'Opportunity',
      event.Trigger_Object__c,
      'Event should contains info for Opportunity Sharing'
    );
    Assert.isTrue(
      event.Record_Ids__c.contains(oppId),
      'Event should contains info for Opportunity Sharing'
    );
  }

  static Opportunity getOpportunityRecord() {
    return new Opportunity(
      Name = 'Test Opp ',
      StageName = 'Need Analysis',
      Customer_Needs__c = 'Asset Finance',
      Amount = 200,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      CloseDate = system.Today() + 10,
      Description = 'Test Opportunity TAX Number 1234567890 Credit Card Number 12345678901234 TFN Number 0134024094209',
      RecordTypeId = RTOpportunity.mlOpportunity,
      RecordType = new RecordType(DeveloperName = 'MLCRM_Opportunity'),
      Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
      Lead_Converted__c = false
    );
  }
}
