/**
 * @author MLCRM Developer
 * @since 10/2024
 * @description OpportunityContactRoleActionsTest is the test class for OpportunityContactRoleAction Class functionality.
 */
@isTest
public class OpportunityContactRoleActionsTest {
  static Lib_MockProvider ocrRepoMock;
  static Lib_MockProvider oppRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static Lib_MockProvider userMock;
  static void registerMocks() {
    ocrRepoMock = Lib_MockProvider.forType(
      OpportunityContactRoleActionsRepository.class
    );
    oppRepoMock = Lib_MockProvider.forType(OpportunityActionsRepository.class);
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
    userMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }
  static User testUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    FirstName = 'DummyMLUser'
  );

  /**
   * @description test method for restrictApplicantDeletion
   */
  @isTest
  static void restrictApplicantDeletionTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newAccId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Account cust = (Account) TestUtil.setFields(
      new Account(
        Id = newAccId,
        FirstName = 'Test',
        LastName = 'Test',
        Salutation = 'Mrs',
        External_Id__c = 'CAP-CIS_4011643101',
        Name = 'Test Test',
        RecordTypeId = RTAccount.personAccount
      ),
      new Map<String, Object>{ 'PersonContactId' => newConId }
    );
    Opportunity opp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = newOppId,
        ContactId = newConId,
        AccountId = cust.Id,
        RecordTypeId = RTOpportunity.mlOpportunity
      ),
      new Map<String, Object>{ 'Account' => cust }
    );
    OpportunityContactRole ocr = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        OpportunityId = newOppId,
        ContactId = newConId,
        Role = 'Applicant'
      ),
      new Map<String, Object>{ 'Opportunity' => opp }
    );
    List<OpportunityContactRole> lstOfOldOppRole = new List<OpportunityContactRole>{
      ocr
    };
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    userMock.mock('checkProfile', false).mock('getUser', testUser);
    Test.startTest();
    OpportunityContactRoleActions.restrictApplicantDeletion(lstOfOldOppRole);
    Test.stopTest();
    Assert.areEqual(
      OpportunityContactRoleActions.INSUFFICIENT_ERROR_MESSAGE,
      lstOfOldOppRole[0].getErrors()[0].getMessage(),
      'Error message is not received while deleting the OCR'
    );
  }

  /**
   * @description test method for filterPrimaryApplicant
   */
  @isTest
  static void testFilterPrimaryApplicant() {
    Map<Id, Opportunity> mapOfOpp = new Map<Id, Opportunity>();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newAccId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Account cust = (Account) TestUtil.setFields(
      new Account(
        Id = newAccId,
        FirstName = 'Test',
        LastName = 'Test',
        Salutation = 'Mrs',
        External_Id__c = 'CAP-CIS_4011643101',
        Name = 'Test Test',
        RecordTypeId = RTAccount.personAccount
      ),
      new Map<String, Object>{ 'PersonContactId' => newConId }
    );

    Opportunity opp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = newOppId,
        ContactId = newConId,
        AccountId = cust.Id,
        recordTypeId = RTOpportunity.mlOpportunity,
        Name = 'Test',
        StageName = 'Needs Analysis',
        Amount = 5000,
        Customer_Needs__c = 'Asset Finance',
        CloseDate = Date.today() + 5
      ),
      new Map<String, Object>{ 'Account' => cust }
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    List<OpportunityContactRole> lstOfOldOppRole = new List<OpportunityContactRole>{
      ocr
    };
    mapOfOpp.put(opp.Id, opp);
    Test.startTest();
    List<OpportunityContactRole> lstOfOppRole = OpportunityContactRoleActions.filterPrimaryApplicant(
      lstOfOldOppRole,
      mapOfOpp
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfOppRole.size(),
      'Primary Applicant not filtered correctly'
    );
    Assert.areEqual(
      'Applicant',
      lstOfOppRole[0].Role,
      'Role is not Primary Applicant'
    );
  }

  /**
   * @description test method for preventing duplicate OCR.
   */
  @isTest
  static void preventDuplicateOpportunityContactRoleNegativeTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    ocrRepoMock.mock(
      'getOppContactRoleByContacts',
      new List<OpportunityContactRole>{ ocr }
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    Test.startTest();
    OpportunityContactRoleActions.preventDuplicateOpportunityContactRole(
      new List<OpportunityContactRole>{ ocr },
      null
    );
    Test.stopTest();
    Assert.isNull(
      ocr.Id,
      'duplicate OpportunityContactRole should not be inserted!'
    );
  }

  /**
   * @description test method for preventing duplicate OCR.
   */
  @isTest
  static void preventDuplicateOpportunityContactRoleTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    //duplicate OCR record
    OpportunityContactRole ocr2 = ocr;
    ocrRepoMock.mock(
      'getOppContactRoleByContacts',
      new List<OpportunityContactRole>{ ocr }
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    List<OpportunityContactRole> ocrRecords = new List<OpportunityContactRole>{
      ocr,
      ocr2
    };
    Test.startTest();
    OpportunityContactRoleActions.preventDuplicateOpportunityContactRole(
      ocrRecords,
      null
    );
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

  /**
   * @description test method to get parent opportunities.
   */
  @isTest
  static void getParentOpportunitiesTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    Test.startTest();
    List<Opportunity> result = OpportunityContactRoleActions.getParentOpportunities(
      new List<OpportunityContactRole>{ ocr }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.size(),
      'one parent opportunity should be returned!'
    );
    Assert.areEqual(
      opp.Id,
      result[0].Id,
      'parent opportunity is not ML Opportunity'
    );
  }

  /**
   * @description test method to get duplicate OCR keys.
   */
  @isTest
  static void getDuplicateContactKeysTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    ocrRepoMock.mock(
      'getOppContactRoleByContacts',
      new List<OpportunityContactRole>{ ocr }
    );
    Test.startTest();
    Set<String> duplicateSet = OpportunityContactRoleActions.getDuplicateContactKeys(
      new Set<Id>{ newConId }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      duplicateSet.size(),
      'one duplicate OCR should be returned!'
    );
    Assert.isTrue(
      duplicateSet.contains(ocr.OpportunityId + '-' + ocr.ContactId),
      'OCR list doesnt have any duplicate contact'
    );
  }

  /**
   * @description test method to defaultRoleForOppContactRole
   */
  @isTest
  static void getdefaultRoleForOppContactRole() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    Test.startTest();
    OpportunityContactRoleActions.defaultRoleForOppContactRole(
      new List<OpportunityContactRole>{ ocr }
    );
    Test.stopTest();
    Assert.areEqual(
      'Applicant',
      ocr.Role,
      'Applicant value does not get set properly'
    );
  }

  /**
   * @description test method for upsertOpportunityContactRoleSyncRecords
   */
  @isTest
  static void insertOpportunityContactRoleSyncRecordsTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    OpportunityContactRole ocrNew = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = Lib_FakeIdGenerator.getMockId(
          Schema.OpportunityContactRole.getSObjectType()
        ),
        OpportunityId = opp.Id,
        ContactId = newConId,
        Role = 'Guarantor'
      ),
      new Map<String, Object>{ 'Opportunity' => opp }
    );
    ocrRepoMock.mock(
      'getDetailedOCRRecords',
      new List<OpportunityContactRole>{ ocrNew }
    );

    Test.startTest();
    OpportunityContactRoleActions.insertOpportunityContactRoleSyncRecords(
      new List<OpportunityContactRole>{ ocrNew }
    );
    Test.stopTest();
    List<Opportunity_Contact_Role_Sync__c> ocrSyncList = (List<Opportunity_Contact_Role_Sync__c>) dmlMockProvider.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      ocrSyncList.size(),
      'There should be one Opportunity Role Sync inserted!'
    );
    Assert.areEqual(
      ocrNew.Id,
      ocrSyncList[0].OpportunityContactRoleId__c,
      'OCR Sync Record OpportunityContactRoleId__c should match with OCR Id'
    );
  }

  /**
   * @description test method for upsertOpportunityContactRoleSyncRecords
   */
  @isTest
  static void updateOpportunityContactRoleSyncRecordsTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Id newOCRId = Lib_FakeIdGenerator.getMockId(
      Schema.OpportunityContactRole.getSObjectType()
    );
    Id ocrSyncId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity_Contact_Role_Sync__c.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    OpportunityContactRole ocrNew = new OpportunityContactRole(
      Id = newOCRId,
      OpportunityId = opp.Id,
      ContactId = newConId,
      Role = 'Guarantor'
    );
    OpportunityContactRole ocrOld = new OpportunityContactRole(
      Id = ocrNew.Id,
      Role = 'Applicant'
    );
    Opportunity_Contact_Role_Sync__c ocrSync = new Opportunity_Contact_Role_Sync__c(
      OpportunityContactRoleId__c = ocrNew.Id,
      Role__c = 'Applicant',
      Id = ocrSyncId
    );
    oppRepoMock.mock(
      'getOCRSyncByOCRIds',
      new List<Opportunity_Contact_Role_Sync__c>{ ocrSync }
    );
    Test.startTest();
    OpportunityContactRoleActions.updateOpportunityContactRoleSyncRecords(
      new List<OpportunityContactRole>{ ocrNew },
      new Map<Id, OpportunityContactRole>{ ocrNew.Id => ocrOld }
    );
    Test.stopTest();
    List<Opportunity_Contact_Role_Sync__c> ocrSyncList = (List<Opportunity_Contact_Role_Sync__c>) dmlMockProvider.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      ocrSyncList.size(),
      'There should be one Opportunity Role Sync updated!'
    );
    Assert.areEqual(
      'Guarantor',
      ocrSyncList[0].Role__c,
      'OCR Sync Record should be updated to Guarantor'
    );
  }

  @isTest
  static void deleteOpportunityContactRoleSyncRecordsTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Id newOcrSyncId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity_Contact_Role_Sync__c.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    OpportunityContactRole ocrNew = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        OpportunityId = opp.Id,
        ContactId = newConId,
        Role = 'Guarantor'
      ),
      new Map<String, Object>{
        'ExternalId__c' => 'MLCRM-1018_CAP-CIS_1001051598'
      }
    );
    Opportunity_Contact_Role_Sync__c ocrSync = new Opportunity_Contact_Role_Sync__c(
      Id = newOcrSyncId,
      ExternalId__c = 'MLCRM-1018_CAP-CIS_1001051598'
    );
    ocrRepoMock.mock(
      'getOpportunityContactRoleSyncRecords',
      new List<Opportunity_Contact_Role_Sync__c>{ ocrSync }
    );
    Test.startTest();
    OpportunityContactRoleActions.deleteOpportunityContactRoleSyncRecords(
      new List<OpportunityContactRole>{ ocrNew }
    );
    Test.stopTest();
    List<Opportunity_Contact_Role_Sync__c> ocrSyncDelList = (List<Opportunity_Contact_Role_Sync__c>) dmlMockProvider.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      ocrSyncDelList.size(),
      'there should be 1 OCR Sync record deleted!'
    );
    Assert.areEqual(
      ocrSync.Id,
      ocrSyncDelList[0].Id,
      'OCR Sync Record not deleted when OCR is deleted'
    );
  }

  @isTest
  static void testCreateCustomerRelationshipRecords() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Id newOCRId = Lib_FakeIdGenerator.getMockId(
      Schema.OpportunityContactRole.getSObjectType()
    );
    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    Territory__c ter = new Territory__c(
      Id = territoryId,
      Primary_Franchise_Owner__c = UserInfo.getUserId()
    );
    Opportunity opp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        AccountId = Lib_FakeIdGenerator.getMockId(
          Schema.Account.getSObjectType()
        ),
        Id = newOppId,
        RecordTypeId = RTOpportunity.mlOpportunity,
        Lead_Converted__c = false,
        Territory__c = ter.Id
      ),
      new Map<String, Object>{ 'Territory__r' => ter }
    );
    OpportunityContactRole ocrNew = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = newOCRId,
        OpportunityId = opp.Id,
        ContactId = newConId,
        Role = 'Guarantor'
      ),
      new Map<String, Object>{ 'Opportunity' => opp }
    );

    ocrRepoMock.mock(
      'getInsertedOCRs',
      new List<OpportunityContactRole>{ ocrNew }
    );
    Test.startTest();
    OpportunityContactRoleActions.createCustomerRelationshipRecords(
      new List<OpportunityContactRole>{ ocrNew }
    );
    Test.stopTest();
    List<Customer_Relationship__c> crrList = (List<Customer_Relationship__c>) dmlMockProvider.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(1, crrList.size(), '1 CRR record should be inserted!');
    Assert.areEqual(
      territoryId,
      crrList[0].Territory__c,
      'territory should match with Opportunity territory'
    );
  }
}
