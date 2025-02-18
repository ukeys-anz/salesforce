/**
 * @author MLCRM Developer
 * @since 10/2024
 * @description OpportunityContactRoleActionsTest is the test class for OpportunityContactRoleAction Class functionality.
 */
@isTest
public class OpportunityContactRoleActionsTest {
  /**
   * @description test method for filterPrimaryApplicant
   */
  private static final Id MLCRM_OPP_RTID = QueryRT.of(Opportunity.SObjectType)
    .getId('MLCRM_Opportunity');

  static Lib_MockProvider ocrRepoMock;
  static Lib_MockProvider oppRepoMock;
  static void registerMocks() {
    ocrRepoMock = Lib_MockProvider.forType(
      OpportunityContactRoleActionsRepository.class
    );
    oppRepoMock = Lib_MockProvider.forType(OpportunityActionsRepository.class);
  }

  @isTest
  static void testFilterPrimaryApplicant() {
    Id mlOpportunityRTId = QueryRT.of(Opportunity.SObjectType)
      .getId('MLCRM_Opportunity');
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
        RecordTypeId = QueryRT.of(Account.SObjectType).getId('PersonAccount')
      ),
      new Map<String, Object>{ 'PersonContactId' => newConId }
    );

    Opportunity opp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = newOppId,
        ContactId = newConId,
        AccountId = cust.Id,
        recordTypeId = mlOpportunityRTId,
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
    System.assertEquals(
      1,
      lstOfOppRole.size(),
      'Primary Applicant not filtered correctly'
    );
  }
  /**
   * @description test method for create OCR.
   * @Note : DML is needed in this method since we are writing trigger on OCR for first time and for trigger we need atleast 1% coverage.
   */
  @isTest
  static void testCreateOpportunityContactRole() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlUser,
        true
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser.Id,
        lstOfTerritory[0].id
      );
      Id mlOpportunityRTId = QueryRT.of(Opportunity.SObjectType)
        .getId('MLCRM_Opportunity');
      Account objAcc = new Account(
        FirstName = 'Test',
        LastName = 'Test',
        Salutation = 'Mrs',
        External_Id__c = 'CAP-CIS_4011643101',
        OCV_Id__c = '1234',
        RecordTypeId = QueryRT.of(Account.SObjectType).getId('PersonAccount')
      );
      insert objAcc;
      opportunity opp = new opportunity(
        AccountId = objAcc.Id,
        recordTypeId = mlOpportunityRTId,
        Name = 'Test',
        StageName = 'Needs Analysis',
        Amount = 5000,
        Customer_Needs__c = 'Asset Finance',
        CloseDate = Date.today() + 5
      );
      insert opp;
      OpportunityContactRole ocr = [
        SELECT Id
        FROM OpportunityContactRole
        LIMIT 1
      ];
      System.assertNotEquals(
        null,
        ocr.Id,
        'There is some issue while creating OCR record'
      );
    }
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
      RecordTypeId = MLCRM_OPP_RTID
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
   * @description test method to get filtered OCR records.
   */
  @isTest
  static void getFilteredMLOCRRecordsTest() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = MLCRM_OPP_RTID
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    ocrRepoMock.mock(
      'getOppContactRoleByContacts',
      new List<OpportunityContactRole>{ ocr }
    );
    Test.startTest();
    List<OpportunityContactRole> fList = OpportunityContactRoleActions.getFilteredMLOCRRecords(
      new List<OpportunityContactRole>{ ocr },
      null,
      new Map<Id, Opportunity>{ ocr.OpportunityId => opp }
    );
    Test.stopTest();
    Assert.areEqual(1, fList.size(), '1 OCR record should be returned!');
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
      RecordTypeId = MLCRM_OPP_RTID
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
  }

  /**
   * @description test method to defaultRoleForMlOppContactRole
   */
  @isTest
  static void getDefaultRoleForMlOppContactRole() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = MLCRM_OPP_RTID
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = newOppId,
      ContactId = newConId,
      Role = 'Applicant'
    );
    oppRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    Test.startTest();
    OpportunityContactRoleActions.defaultRoleForMlOppContactRole(
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
   * @description test method to getDefaultOCRRole
   */
  @isTest
  static void testDefaultOCRRole() {
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Opportunity opp = new Opportunity(
      Id = newOppId,
      RecordTypeId = MLCRM_OPP_RTID
    );
    OpportunityContactRole ocr = new OpportunityContactRole(
      OpportunityId = opp.Id,
      ContactId = newConId
    );
    Set<Id> mlOpptyIdSet = new Set<Id>{ newOppId };
    Test.startTest();
    OpportunityContactRoleActions.defaultOCRRole(
      mlOpptyIdSet,
      new List<OpportunityContactRole>{ ocr }
    );
    Test.stopTest();
    Assert.areEqual(
      'Applicant',
      ocr.Role,
      'Applicant value does not get set properly'
    );
  }
}
