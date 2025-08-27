/**
 * @author       : Ankit Garg
 * @since        : Aug 2025
 * @description  : MLOpportunityContactRoleHandlerTest is the test class for MLOpportunityContactRoleTriggerHandler
 **/
@isTest
public class MLOpportunityContactRoleHandlerTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider oppActionRepoMock;
  static Lib_MockProvider ocrRepoMock;
  static Lib_MockProvider userMock;
  static Id oppId = Lib_FakeIdGenerator.getMockId(
    Schema.Opportunity.getSObjectType()
  );
  static Id contactId = Lib_FakeIdGenerator.getMockId(
    Schema.Contact.getSObjectType()
  );

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    oppActionRepoMock = Lib_MockProvider.forType(
      OpportunityActionsRepository.class
    );
    ocrRepoMock = Lib_MockProvider.forType(
      OpportunityContactRoleActionsRepository.class
    );
    userMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }
  static User testUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    FirstName = 'DummyMLUser'
  );

  @isTest
  static void testBeforeInsert() {
    registerMocks();
    //Parent Opportunity
    Opportunity oppRecord = getOpportunityRecord(oppId);
    // OCR record
    OpportunityContactRole ocrRecord = getOCR(oppRecord);
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocrRecord
    };
    // query records mocking
    oppActionRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ oppRecord }
    );
    ocrRepoMock.mock(
      'getOppContactRoleByContacts',
      new List<OpportunityContactRole>{ ocrRecord }
    );
    Test.startTest();
    MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
    handler.records = ocrRecords;
    handler.onBeforeInsert();
    Test.stopTest();
    //asserts
    Assert.areEqual(
      'Applicant',
      ocrRecords[0].Role,
      'Applicant value does not get set properly'
    );
  }

  @isTest
  static void testBeforeInsertError() {
    registerMocks();
    //Parent Opportunity Record
    Opportunity oppRecord = getOpportunityRecord(oppId);
    //OCR Record
    OpportunityContactRole ocrRecord = getOCR(oppRecord);
    //duplicate OCR record
    OpportunityContactRole ocrRecord2 = getOCR(oppRecord);
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocrRecord,
      ocrRecord2
    };
    // query records mocking
    oppActionRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ oppRecord }
    );
    ocrRepoMock.mock(
      'getOppContactRoleByContacts',
      new List<OpportunityContactRole>{ ocrRecord }
    );
    Test.startTest();
    MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
    handler.records = ocrRecords;
    handler.onBeforeInsert();
    Test.stopTest();
    //Asserts
    List<Database.Error> errors = ocrRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'record should not be valid!');
    Assert.areEqual(
      OpportunityContactRoleActions.DUPLICATE_OCR_ERROR,
      errors[0].getMessage(),
      'should throw duplicate Loanapp Reference Error!'
    );
    Assert.areEqual(
      StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,
      errors[0].getStatusCode(),
      'No Error found'
    );
  }

  @isTest
  static void testAfterInsert() {
    registerMocks();

    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    Territory__c territoryRecord = new Territory__c(
      Id = territoryId,
      Primary_Franchise_Owner__c = UserInfo.getUserId()
    );
    Opportunity oppRecord = getOpportunityWithTerritory(oppId, territoryRecord);
    oppRecord.Loanapp_Reference__c = 'MLCRM-100';
    OpportunityContactRole ocrRecord = getOCR(oppRecord);
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocrRecord
    };
    oppActionRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ oppRecord }
    );
    ocrRepoMock.mock(
      'getDetailedOCRRecords',
      new List<OpportunityContactRole>{ ocrRecord }
    );
    ocrRepoMock.mock(
      'getInsertedOCRs',
      new List<OpportunityContactRole>{ ocrRecord }
    );
    Test.startTest();
    MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
    handler.records = ocrRecords;
    handler.onAfterInsert();
    Test.stopTest();
    List<Opportunity_Contact_Role_Sync__c> ocrSyncList = (List<Opportunity_Contact_Role_Sync__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      ocrSyncList.size(),
      'There should be one Opportunity Role Sync inserted!'
    );
    Assert.areEqual(
      ocrRecord.Role,
      ocrSyncList[0].Role__c,
      'OCR Sync Role should match with OCR Role'
    );
    Assert.areEqual(
      oppRecord.Loanapp_Reference__c,
      ocrSyncList[0].OpportunityId__c,
      'OCR Sync External should match with OCR Opportunity Loanapp Reference Number'
    );
  }

  @isTest
  static void testBeforeUpdate() {
    registerMocks();
    //Parent Opportunity
    Opportunity oppRecord = getOpportunityRecord(oppId);
    // OCR record
    OpportunityContactRole ocrRecord = getOCR(oppRecord);
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocrRecord
    };
    //mocking old map
    Map<Id, OpportunityContactRole> oldMap = new Map<Id, OpportunityContactRole>{
      ocrRecord.Id => ocrRecord
    };
    // query records mocking
    oppActionRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ oppRecord }
    );
    ocrRepoMock.mock(
      'getOppContactRoleByContacts',
      new List<OpportunityContactRole>{ ocrRecord }
    );
    Test.startTest();
    MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
    handler.records = ocrRecords;
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();
    //asserts
    Assert.areEqual(
      'Applicant',
      ocrRecords[0].Role,
      'Applicant value does not get set properly'
    );
  }

  @isTest
  static void testAfterUpdate() {
    registerMocks();
    //Parent Opportunity Record
    Opportunity oppRecord = getOpportunityRecord(oppId);
    oppRecord.Loanapp_Reference__c = 'MLCRM-100';
    //OCR Record
    OpportunityContactRole ocrRecord = getOCR(oppRecord);
    ocrRecord.Role = 'Guarantor';
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocrRecord
    };
    //updated record
    OpportunityContactRole ocrOldRecord = getOCR(oppRecord);
    ocrOldRecord.Role = 'Applicant';

    Opportunity_Contact_Role_Sync__c ocrSync = new Opportunity_Contact_Role_Sync__c(
      OpportunityContactRoleId__c = ocrRecord.Id,
      Role__c = 'Applicant',
      Id = Lib_FakeIdGenerator.getMockId(
        Schema.Opportunity_Contact_Role_Sync__c.getSObjectType()
      )
    );
    oppActionRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ oppRecord }
    );
    oppActionRepoMock.mock(
      'getOCRSyncByOCRIds',
      new List<Opportunity_Contact_Role_Sync__c>{ ocrSync }
    );
    ocrRepoMock.mock(
      'getInsertedOCRs',
      new List<OpportunityContactRole>{ ocrRecord }
    );
    Map<Id, OpportunityContactRole> oldMap = new Map<Id, OpportunityContactRole>{
      ocrOldRecord.Id => ocrOldRecord
    };
    Test.startTest();
    MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
    handler.records = ocrRecords;
    handler.onAfterUpdate(oldMap);
    Test.stopTest();
    List<Opportunity_Contact_Role_Sync__c> ocrSyncList = (List<Opportunity_Contact_Role_Sync__c>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      'Guarantor',
      ocrSyncList[0].Role__c,
      'OCR sync Role should be update to  Guarantor'
    );
  }

  @isTest
  static void testBeforeDelete() {
    registerMocks();
    //Parent Opportunity
    Opportunity oppRecord = getOpportunityWithAccount(oppId);
    // OCR record
    OpportunityContactRole ocrRecord = getOCR(oppRecord);
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocrRecord
    };
    // query records mocking
    oppActionRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ oppRecord }
    );
    userMock.mock('checkProfile', false).mock('getUser', testUser);
    Test.startTest();
    MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
    handler.records = ocrRecords;
    handler.onBeforeDelete();
    Test.stopTest();
    //asserts
    Assert.areEqual(
      OpportunityContactRoleActions.INSUFFICIENT_ERROR_MESSAGE,
      ocrRecords[0].getErrors()[0].getMessage(),
      'Error message is not received while deleting the OCR'
    );
  }
  @isTest
  static void testAfterDelete() {
    registerMocks();
    //Parent Opportunity
    Opportunity oppRecord = getOpportunityWithAccount(oppId);
    // OCR record
    OpportunityContactRole ocrRecord = getOCR(oppRecord);
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocrRecord
    };
    // OCR Sync record
    Opportunity_Contact_Role_Sync__c ocrSync = new Opportunity_Contact_Role_Sync__c(
      Id = Lib_FakeIdGenerator.getMockId(
        Schema.Opportunity_Contact_Role_Sync__c.getSObjectType()
      ),
      ExternalId__c = 'MLCRM-1018_CAP-CIS_1001051598'
    );
    // query records mocking
    oppActionRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ oppRecord }
    );
    ocrRepoMock.mock(
      'getOpportunityContactRoleSyncRecords',
      new List<Opportunity_Contact_Role_Sync__c>{ ocrSync }
    );
    Test.startTest();
    MLOpportunityContactRoleTriggerHandler handler = new MLOpportunityContactRoleTriggerHandler();
    handler.records = ocrRecords;
    handler.onAfterDelete();
    Test.stopTest();
    //asserts
    List<Opportunity_Contact_Role_Sync__c> ocrSyncDelList = (List<Opportunity_Contact_Role_Sync__c>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.isTrue(
      ocrSyncDelList.size() == 1,
      'OCR sync record should be found to delete'
    );
    Assert.areEqual(
      ocrSync.Id,
      ocrSyncDelList[0].Id,
      'OCR Sync Record not deleted when OCR is deleted'
    );
  }

  static Opportunity getOpportunityRecord(Id oppId) {
    return new Opportunity(
      Id = oppId,
      Name = 'Test Opp ',
      StageName = 'Need Analysis',
      Customer_Needs__c = 'Asset Finance',
      Amount = 200,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      CloseDate = system.Today() + 10,
      Description = 'Test Opportunity',
      RecordTypeId = RTOpportunity.mlOpportunity,
      RecordType = new RecordType(DeveloperName = 'MLCRM_Opportunity'),
      Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
      Lead_Converted__c = false
    );
  }

  static Opportunity getOpportunityWithTerritory(
    Id oppId,
    Territory__c territoryRecord
  ) {
    return (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        Name = 'Test Opp ',
        StageName = 'Need Analysis',
        Customer_Needs__c = 'Asset Finance',
        Amount = 200,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        CloseDate = system.Today() + 10,
        Description = 'Test Opportunity',
        RecordTypeId = RTOpportunity.mlOpportunity,
        RecordType = new RecordType(DeveloperName = 'MLCRM_Opportunity'),
        Territory__c = territoryRecord.id,
        Lead_Converted__c = false
      ),
      new Map<String, Object>{ 'Territory__r' => territoryRecord }
    );
  }
  static Opportunity getOpportunityWithAccount(Id oppId) {
    Account cust = (Account) TestUtil.setFields(
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Account.getSObjectType()),
        FirstName = 'Test',
        LastName = 'Test',
        External_Id__c = 'CAP-CIS_4011643101',
        Name = 'Test Test',
        RecordTypeId = RTAccount.personAccount
      ),
      new Map<String, Object>{ 'PersonContactId' => contactId }
    );
    return (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        ContactId = contactId,
        AccountId = cust.Id,
        RecordTypeId = RTOpportunity.mlOpportunity
      ),
      new Map<String, Object>{ 'Account' => cust }
    );
  }
  static OpportunityContactRole getOCR(Opportunity opp) {
    return (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = Lib_FakeIdGenerator.getMockId(
          Schema.OpportunityContactRole.getSObjectType()
        ),
        OpportunityId = opp.Id,
        ContactId = contactId,
        Role = 'Applicant'
      ),
      new Map<String, Object>{
        'Opportunity' => opp,
        'ExternalId__c' => 'MLCRM-1018_CAP-CIS_1001051598'
      }
    );
  }
}
