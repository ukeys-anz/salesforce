/**
 * @author Ashwin Mohan
 * @since 04/2025
 * @description OpportunityContactRoleSyncActionsTest is the test class for OpportunityContactRoleSyncActions & OpportunityContactRoleSyncActionsHelper.
 */
@isTest
public class OpportunityContactRoleSyncActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider ocrSyncRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    ocrSyncRepoMock = Lib_MockProvider.forType(OCRSyncActionsRepository.class);
  }

  @isTest
  static void testinsertOCRRecords() {
    registerMocks();
    Opportunity oppRec = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      Loanapp_Reference__c = 'APP-10000'
    );
    Account accRec = (Account) TestUtil.setFields(
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
        External_Id__c = 'CAP-CIS_1000000000'
      ),
      new Map<String, Object>{
        'PersonContactId' => Lib_FakeIdGenerator.getMockId(
          Contact.getSobjectType()
        )
      }
    );
    ocrSyncRepoMock.mock(
      'getOpportunityFromLoanAppRef',
      new List<Opportunity>{ oppRec }
    );
    ocrSyncRepoMock.mock('getCustomerFromCapId', new List<Account>{ accRec });
    Opportunity_Contact_Role_Sync__c record = getOCRSyncRecord();
    Test.startTest();
    OpportunityContactRoleSyncActions.insertOCRRecords(
      new List<Opportunity_Contact_Role_Sync__c>{ record }
    );
    Test.stopTest();
    List<OpportunityContactRole> ocrRecordsCreated = (List<OpportunityContactRole>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      oppRec.Id,
      ocrRecordsCreated[0].OpportunityId,
      'OCR Record not created with same details as OCR Sync'
    );
  }

  @isTest
  static void testUpdateOCRRecords() {
    registerMocks();
    Opportunity_Contact_Role_Sync__c record = getOCRSyncRecord();
    record.OpportunityContactRoleId__c = Lib_FakeIdGenerator.getMockId(
      OpportunityContactRole.getSobjectType()
    );
    Opportunity_Contact_Role_Sync__c oldRecord = record.clone(true, true);
    oldRecord.Role__c = 'Guarantor';
    Test.startTest();
    OpportunityContactRoleSyncActions.updateOCRRecords(
      new List<Opportunity_Contact_Role_Sync__c>{ record },
      new Map<Id, Opportunity_Contact_Role_Sync__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    List<OpportunityContactRole> ocrRecordsUpdated = (List<OpportunityContactRole>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      'Applicant',
      ocrRecordsUpdated[0].Role,
      'OCR Record not updated with Role as OCR Sync'
    );
  }

  @isTest
  static void testDeleteOCRRecords() {
    registerMocks();
    Opportunity_Contact_Role_Sync__c record = getOCRSyncRecord();
    record.OpportunityContactRoleId__c = Lib_FakeIdGenerator.getMockId(
      OpportunityContactRole.getSobjectType()
    );
    Test.startTest();
    OpportunityContactRoleSyncActions.deleteOCRRecords(
      new List<Opportunity_Contact_Role_Sync__c>{ record }
    );
    Test.stopTest();
    List<OpportunityContactRole> ocrRecordsDeleted = (List<OpportunityContactRole>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      record.OpportunityContactRoleId__c,
      ocrRecordsDeleted[0].Id,
      'OCR Record not deleted when OCR Sync is deleted'
    );
  }

  @isTest
  static void testPopulateOCRIdInOCRSync() {
    registerMocks();
    OpportunityContactRole ocrRecord = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = Lib_FakeIdGenerator.getMockId(
          OpportunityContactRole.getSobjectType()
        )
      ),
      new Map<String, Object>{
        'ExternalId__c' => 'APP-10000_CAP-CIS_1000000000'
      }
    );
    ocrSyncRepoMock.mock(
      'getOpportunityContactRoles',
      new List<OpportunityContactRole>{ ocrRecord }
    );
    Opportunity_Contact_Role_Sync__c record = getOCRSyncRecord();
    record.ExternalId__c = 'APP-10000_CAP-CIS_1000000000';
    Test.startTest();
    OpportunityContactRoleSyncActionsHelper.populateOCRIdInOCRSync(
      new Set<Id>{ ocrRecord.Id },
      new List<Opportunity_Contact_Role_Sync__c>{ record }
    );
    List<Opportunity_Contact_Role_Sync__c> ocrSynRecsUpdated = (List<Opportunity_Contact_Role_Sync__c>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Test.stopTest();
    Assert.areEqual(
      ocrRecord.Id,
      ocrSynRecsUpdated[0].OpportunityContactRoleId__c,
      'OCR Record Id is not populated in OCR Sync Record'
    );
  }

  // To cover OpportunityContactRoleSyncTrigger
  @isTest
  static void testInsertOCRSyncRecord() {
    registerMocks();
    Opportunity oppRec = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      Loanapp_Reference__c = 'APP-10000'
    );
    Account accRec = (Account) TestUtil.setFields(
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
        External_Id__c = 'CAP-CIS_1000000000'
      ),
      new Map<String, Object>{
        'PersonContactId' => Lib_FakeIdGenerator.getMockId(
          Contact.getSobjectType()
        )
      }
    );
    ocrSyncRepoMock.mock(
      'getOpportunityFromLoanAppRef',
      new List<Opportunity>{ oppRec }
    );
    ocrSyncRepoMock.mock('getCustomerFromCapId', new List<Account>{ accRec });
    Opportunity_Contact_Role_Sync__c ocrSyncRecord = new Opportunity_Contact_Role_Sync__c(
      ExternalId__c = 'APP-10000_CAP-CIS_1000000000',
      OpportunityId__c = 'APP-10000',
      ContactId__c = 'CAP-CIS_1000000000'
    );
    insert ocrSyncRecord;
    Assert.isNotNull(ocrSyncRecord.Id, 'OCR Sync record is not created');
  }

  static Opportunity_Contact_Role_Sync__c getOCRSyncRecord() {
    return new Opportunity_Contact_Role_Sync__c(
      Id = Lib_FakeIdGenerator.getMockId(
        Opportunity_Contact_Role_Sync__c.getSobjectType()
      ),
      OpportunityId__c = 'APP-10000',
      ContactId__c = 'CAP-CIS_1000000000',
      Role__c = 'Applicant'
    );
  }
}
