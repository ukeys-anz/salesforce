/**
 * @author Ankit Garg
 * @since 20/July/2023
 * @description OpportunityActionsTest is the test class for OpportunityActions Class functionality.
 */
@isTest
public class OpportunityActionsTest {
  static Lib_MockProvider oppActoinRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider oppRepoMock;
  static Lib_MockProvider accRepoMock;
  static Lib_MockProvider ocrRepoMock;
  public static User ocvUser;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    oppActoinRepoMock = Lib_MockProvider.forType(
      OpportunityActionsRepository.class
    );
    oppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
    accRepoMock = Lib_MockProvider.forType(AccountActionsRepository.class);
    ocrRepoMock = Lib_MockProvider.forType(
      OpportunityContactRoleActionsRepository.class
    );
  }
  private static final String STAGE_CLOSED = 'Closed';
  private static final String STATUS_NEW = 'New';

  /**
   * @description test method for validateClosedOpportunity
   */
  @isTest
  static void testvalidateClosedOpportunity() {
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());
    String exceptionMsg = '';
    Opportunity updatedOpp = MLCRMTestDataFactory.createOpportunityRecords(
      1,
      new User(),
      accId,
      false
    )[0];
    updatedOpp.StageName = STAGE_CLOSED;
    updatedOpp.Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType());
    Opportunity oldOpportunity = MLCRMTestDataFactory.createOpportunityRecords(
      1,
      new User(),
      accId,
      false
    )[0];
    oldOpportunity.StageName = STATUS_NEW;
    oldOpportunity.Id = updatedOpp.Id;
    oldMap.put(oldOpportunity.Id, oldOpportunity);

    Test.startTest();
    try {
      OpportunityActions.validateClosedOpportunity(
        new List<Opportunity>{ updatedOpp },
        oldMap
      );
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      '',
      exceptionMsg,
      'validateClosedOpportunity is not returning correct output for ML Lead'
    );
  }

  /**
   * @description test method for CreateOppContactRoleForCustomer
   */
  @isTest
  static void testCreateOppContactRoleForCustomer() {
    registerMocks();
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.getSobjectType());
    Account acc = (Account) TestUtil.setFields(
      new Account(Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType())),
      new Map<String, Object>{ 'PersonContactId' => contactId }
    );
    oppActoinRepoMock.mock('getAccount', acc);
    String oppId = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType());
    String strRole = 'Applicant';
    Test.startTest();
    OpportunityActions.createOppContactRoleForCustomer(acc.Id, oppId, strRole);
    Test.stopTest();
    OpportunityContactRole ocrInserted = (OpportunityContactRole) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');
    Assert.isNotNull(ocrInserted, 'One OCR should be inserted!');
    Assert.areEqual(
      'Applicant',
      ocrInserted.Role,
      'OCR role should be Applicant'
    );
    Assert.areEqual(
      contactId,
      ocrInserted.ContactId,
      'OCR ContactId should match Customer PersonContactId'
    );
  }

  /**
   * @description test method for GetOpportunity
   */
  @isTest
  static void testGetOpportunity() {
    registerMocks();
    Opportunity opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      Name = 'Test Opp'
    );
    oppActoinRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    Test.startTest();
    List<Opportunity> oppList = OpportunityActions.getOpportunity(
      new Set<Id>{ opp.Id }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      oppList.size(),
      'getOpportunity is not working properly'
    );
    Assert.areEqual(
      'Test Opp',
      oppList.get(0).Name,
      'opportunity name should be Test Opp'
    );
  }

  /**
   * @description test method for SetRemainingRequestValues
   */
  @isTest
  static void testSetRemainingRequestValues() {
    OCVRequestPayloadWrapper record = new OCVRequestPayloadWrapper();
    record.strCity = 'Melbourne';
    Test.startTest();
    OCVRequestPayloadWrapper result = OpportunityActions.setRemainingRequestValues(
      record
    );
    Test.stopTest();
    Assert.areEqual(
      '',
      result.strCity,
      'setRemainingRequestValues is not assigning values correctly'
    );
    Assert.areEqual(
      '',
      result.strCountry,
      'setRemainingRequestValues is not assigning values correctly'
    );
  }

  /**
   * @description test method for prepareOpportunityContactRoles
   */
  @isTest
  static void testPrepareOpportunityContactRoles() {
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Map<Id, Account> mapOfAcc = new Map<Id, Account>();
    Opportunity oppRecord = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      accountid = accountId
    );
    List<Opportunity> newOppList = new List<Opportunity>{ oppRecord };

    Account objAcc = new Account();
    objAcc.put('OwnerId', idOwner);
    objAcc.put('Disclosure_Indicator__c', null);
    objAcc.put('Id', accountId);
    objAcc.put('RecordTypeId', RTAccount.personAccount);
    mapOfAcc.put(accountId, objAcc);
    objAcc = (Account) TestUtil.setFields(
      objAcc,
      new Map<String, Object>{ 'PersonContactId' => contactId }
    );
    mapOfAcc.put(accountId, objAcc);
    Test.startTest();
    List<OpportunityContactRole> lstOfOppRole = OpportunityActions.prepareOpportunityContactRoles(
      newOppList,
      mapOfAcc,
      null
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfOppRole.size(),
      'Failed to create opportunity contact role'
    );
    Assert.areEqual(
      'Applicant',
      lstOfOppRole[0].Role,
      'Role should be Applicant'
    );
    Assert.areEqual(
      contactId,
      lstOfOppRole[0].ContactId,
      'contact id should be customer PersonContactId'
    );
  }

  /**
   * @description test method for UpdateRoleForExistingOCR
   */
  @isTest
  static void testUpdateRoleForExistingOCR() {
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<String, OpportunityContactRole> mapOfOppContactRole = new Map<String, OpportunityContactRole>();
    Opportunity oppRecord = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      accountid = accountId
    );
    List<Opportunity> newOppList = new List<Opportunity>{ oppRecord };

    Account objAcc = new Account();
    objAcc.put('OwnerId', idOwner);
    objAcc.put('Disclosure_Indicator__c', null);
    objAcc.put('Id', accountId);
    objAcc.put('RecordTypeId', RTAccount.personAccount);

    OpportunityContactRole objOppRole = new OpportunityContactRole();
    objOppRole.put('Role', 'Guarantor');
    objOppRole.put('OpportunityId', oppRecord.Id);
    mapOfOppContactRole.put(
      String.valueOf(oppRecord.Id) + String.valueOf(accountId),
      objOppRole
    );
    Test.startTest();
    List<OpportunityContactRole> lstOfOppRole = OpportunityActions.updateRoleForExistingOCR(
      newOppList,
      mapOfOppContactRole
    );
    Test.stopTest();
    Assert.areEqual(
      'Applicant',
      lstOfOppRole[0].Role,
      'Failed to update opportunity contact role'
    );
  }

  /**
   * @description test method for prepareMapOfContactRoleByAccountId
   */
  @isTest
  static void testPrepareMapOfContactRoleByAccountId() {
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Opportunity oppRecord = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      accountid = accountId
    );

    Account objAcc = new Account();
    objAcc.put('OwnerId', idOwner);
    objAcc.put('Disclosure_Indicator__c', null);
    objAcc.put('Id', accountId);
    objAcc.put('RecordTypeId', RTAccount.personAccount);

    Contact contactRecord = new Contact(
      Id = contactId,
      LastName = 'Test',
      Email = 'testemailcontact@mail.com',
      MobilePhone = '99999999',
      AccountId = objAcc.Id
    );

    OpportunityContactRole objOppRole = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Role = 'Guarantor',
        OpportunityId = oppRecord.Id
      ),
      new Map<String, Object>{ 'Contact' => contactRecord }
    );
    List<OpportunityContactRole> newOppContactRoleList = new List<OpportunityContactRole>{
      objOppRole
    };
    Test.startTest();
    Map<String, OpportunityContactRole> mapOfOppContactRole = OpportunityActions.prepareMapOfContactRoleByAccountId(
      newOppContactRoleList
    );
    Test.stopTest();
    Assert.areEqual(
      'Guarantor',
      mapOfOppContactRole.get(
          String.valueOf(oppRecord.Id) + String.valueOf(objAcc.Id)
        )
        .Role,
      'Failed to form map of opportunity contact role'
    );
  }

  /**
   * @description test method for preventDuplicateLoanappReferenceNumber
   */
  @isTest
  static void preventDuplicateLoanappReferenceNumberTest() {
    registerMocks();
    Opportunity oppMl = new Opportunity(
      RecordTypeId = RTOpportunity.mlOpportunity,
      Loanapp_Reference__c = 'MLCRM-101'
    );
    oppActoinRepoMock.mock(
      'getOpportunityByLoanappReference',
      new List<Opportunity>{ oppMl }
    );
    Test.startTest();
    OpportunityActions.preventDuplicateLoanappReferenceNumber(
      new List<Opportunity>{ oppMl },
      null
    );
    Test.stopTest();
    List<Database.Error> errors = oppMl.getErrors();
    Assert.areEqual(1, errors.size(), 'record should not be valid!');
    Assert.areEqual(
      OpportunityActions.DUPLICATE_LAR_ERROR,
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
  static void testOpportunityOwnership() {
    registerMocks();
    String opportunityId = Lib_FakeIdGenerator.getMockId(
      Opportunity.SObjectType
    );
    String user1 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    String user2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    oppRepoMock.mock('getUserProfileId', QueryProfile.anzCCRMStandardUser.Id);
    Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{
      opportunityId => (new Opportunity(
        Id = opportunityId,
        OwnerId = user1,
        Opportunity_Owner__c = user1,
        recordTypeId = RTOpportunity.mlOpportunity
      ))
    };

    //WHEN update the Opportunity_Owner__c field on opportunity
    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = opportunityId,
        OwnerId = user1,
        Opportunity_Owner__c = user2,
        recordTypeId = RTOpportunity.mlOpportunity
      )
    };
    Test.startTest();
    OpportunityActions.transferOpportunityOwnership(oppList, oldOppMap);
    Test.stopTest();

    //THEN check if update the actual OwnerId field is updated
    Assert.areEqual(
      oppList[0].OwnerId,
      oppList[0].Opportunity_Owner__c,
      'Owner not updated'
    );
  }

  /**
   * @description test method for setHasCloseDateChanged
   */
  @isTest
  static void setHasCloseDateChangedTest() {
    registerMocks();
    Opportunity oppMl1 = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      CloseDate = System.today(),
      Has_Close_Date_Changed__c = false
    );
    Opportunity oppMl1Changed = new Opportunity(
      Id = oppMl1.Id,
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    Opportunity oppMl2 = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      CloseDate = System.today()
    );
    Opportunity oppMl2Changed = new Opportunity(
      Id = oppMl2.Id,
      RecordTypeId = RTOpportunity.mlOpportunity,
      CloseDate = System.today()
    );

    Test.startTest();
    OpportunityActions.setHasCloseDateChanged(
      new List<Opportunity>{ oppMl1, oppMl2 },
      new Map<Id, Opportunity>{
        oppMl1.Id => oppMl1Changed,
        oppMl2.Id => oppMl2Changed
      }
    );
    Test.stopTest();
    Assert.isTrue(
      oppMl1.Has_Close_Date_Changed__c,
      'setHasCloseDateChanged is not making Has_Close_Date_Changed__c to true'
    );
    Assert.isFalse(
      oppMl2.Has_Close_Date_Changed__c,
      'setHasCloseDateChanged is updating Has_Close_Date_Changed__c to true for wrong record'
    );
  }

  @isTest
  static void updateOCRSyncRecordsOnLARChangeTest() {
    registerMocks();
    Opportunity oppMl = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity
    );
    Opportunity oppMlChanged = new Opportunity(
      Id = oppMl.Id,
      RecordTypeId = RTOpportunity.mlOpportunity,
      Loanapp_Reference__c = 'MLCRM-102'
    );
    OpportunityContactRole ocr = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = Lib_FakeIdGenerator.getMockId(
          OpportunityContactRole.getSobjectType()
        ),
        OpportunityId = oppMl.Id
      ),
      new Map<String, Object>{ 'Opportunity' => oppMlChanged }
    );
    Opportunity_Contact_Role_Sync__c ocrSync = new Opportunity_Contact_Role_Sync__c(
      OpportunityContactRoleId__c = ocr.Id,
      ExternalId__c = '_CAP-CIS_2019212'
    );
    oppActoinRepoMock.mock(
      'getOpportunityContactRolesByOppIds',
      new List<OpportunityContactRole>{ ocr }
    );
    oppActoinRepoMock.mock(
      'getOCRSyncByOCRIds',
      new List<Opportunity_Contact_Role_Sync__c>{ ocrSync }
    );
    Test.startTest();
    OpportunityActions.updateOCRSyncRecordsOnLARChange(
      new List<Opportunity>{ oppMlChanged },
      new Map<Id, Opportunity>{ oppMlChanged.Id => oppMl }
    );
    Test.stopTest();
    List<Opportunity_Contact_Role_Sync__c> ocrSyncList = (List<Opportunity_Contact_Role_Sync__c>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      ocrSyncList.size(),
      'there should be 1 ocr sync updated'
    );
  }

  /**
   * @description test method for populateName
   */
  @isTest
  static void testpopulateName() {
    registerMocks();
    Opportunity opp = new Opportunity();
    opp.Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType());

    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    opp.Lead_Converted__c = true;
    opp.AccountId = accountId;

    Map<Id, Account> mapOfAcc = new Map<Id, Account>();
    Account objAcc = new Account();
    objAcc.Id = accountId;
    objAcc.Name = 'AccTest';
    mapOfAcc.put(accountId, objAcc);

    oppActoinRepoMock.mock('getAccountByIds', mapOfAcc);
    Test.startTest();
    OpportunityActions.populateName(new List<Opportunity>{ opp });
    Test.stopTest();
    Assert.areEqual('AccTest', opp.Name, 'Account name is opportunity name');
  }

  @isTest
  static void testCreateOpportunityContactRole() {
    registerMocks();
    Opportunity opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
      Lead_Converted__c = false
    );

    Account acc = (Account) TestUtil.setFields(
      new Account(Id = opp.AccountId),
      new Map<String, Object>{
        'PersonContactId' => Lib_FakeIdGenerator.getMockId(
          Contact.getSobjectType()
        )
      }
    );

    accRepoMock.mock('getAccountByIds', new Map<Id, Account>{ acc.Id => acc });

    Test.startTest();
    OpportunityActions.createOpportunityContactRole(
      new List<Opportunity>{ opp }
    );
    Test.stopTest();
    List<OpportunityContactRole> insertedOcrs = (List<OpportunityContactRole>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      insertedOcrs.size(),
      'OpportunityContactRole should be created'
    );
    Assert.areEqual(
      acc.PersonContactId,
      insertedOcrs[0].ContactId,
      'ContactId should be set to PersonContactId of Account'
    );
  }

  @isTest
  static void testUpdatePrimaryApplicantOnUpdate() {
    registerMocks();
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Account acc = (Account) TestUtil.setFields(
      new Account(Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType())),
      new Map<String, Object>{ 'PersonContactId' => contactId }
    );
    Account accNew = (Account) TestUtil.setFields(
      new Account(Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType())),
      new Map<String, Object>{
        'PersonContactId' => Lib_FakeIdGenerator.getMockId(
          Contact.getSobjectType()
        )
      }
    );
    Contact contactRecord = new Contact(
      Id = contactId,
      LastName = 'Test',
      Email = 'testemailcontact@mail.com',
      MobilePhone = '99999999',
      AccountId = acc.Id
    );
    Opportunity opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      AccountId = acc.Id
    );
    Opportunity oppNew = new Opportunity(Id = opp.Id, AccountId = accNew.Id);
    OpportunityContactRole objOppRole = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(Role = 'Guarantor', OpportunityId = opp.Id),
      new Map<String, Object>{ 'Contact' => contactRecord }
    );
    ocrRepoMock.mock(
      'getOppContactRole',
      new List<OpportunityContactRole>{ objOppRole }
    );
    accRepoMock.mock(
      'getAccountByIds',
      new Map<Id, Account>{ accNew.Id => accNew }
    );
    Test.startTest();
    OpportunityActions.updatePrimaryApplicantOnUpdate(
      new List<Opportunity>{ oppNew },
      new Map<Id, Opportunity>{ oppNew.Id => opp }
    );
    Test.stopTest();
    List<OpportunityContactRole> ocrUpsertedList = (List<OpportunityContactRole>) dmlRepoMock.getHistory(
        'doUpsert'
      )
      .getParam('records');
    Assert.areEqual(1, ocrUpsertedList.size(), '1 record should be upserted');
    Assert.areEqual(
      accNew.PersonContactId,
      ocrUpsertedList[0].ContactId,
      'OCR contactId should match with new account PersonContactId'
    );
  }

  /**
   * @description test method for createCustomerRelationshipRecords
   */
  @isTest
  static void testCreateCustomerRelationshipRecords() {
    registerMocks();
    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Territory__c.getSObjectType()
    );
    Opportunity oppMl = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Territory__c = territoryId,
      Lead_Converted__c = false
    );
    oppActoinRepoMock.mock(
      'getTerritories',
      new Map<Id, Territory__c>{
        oppMl.Territory__c => new Territory__c(
          Id = oppMl.Territory__c,
          Primary_Franchise_Owner__c = UserInfo.getUserId()
        )
      }
    );
    Test.startTest();
    OpportunityActions.createCustomerRelationshipRecords(
      new List<Opportunity>{ oppMl }
    );
    Test.stopTest();
    List<Customer_Relationship__c> crrsInserted = (List<Customer_Relationship__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      crrsInserted.size(),
      '1 customer relationship should be inserted!'
    );
    Assert.areEqual(
      territoryId,
      crrsInserted.get(0).Territory__c,
      'territory should match with opportunity territory!'
    );
  }

  /**
   * @description test method for testCreateCustomerRelationshipRecordsNegative
   */
  @isTest
  static void testCreateCustomerRelationshipRecordsNegative() {
    registerMocks();
    Opportunity oppMl = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Territory__c.getSObjectType()
      ),
      Lead_Converted__c = true
    );
    Test.startTest();
    OpportunityActions.createCustomerRelationshipRecords(
      new List<Opportunity>{ oppMl }
    );
    Test.stopTest();

    List<Customer_Relationship__c> crrsInserted = (List<Customer_Relationship__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      0,
      crrsInserted.size(),
      'no customer relationship should be inserted!'
    );
  }

  /**
   * @description test method for dedupeAndInsertCustomerRelationships
   */
  @isTest
  static void testDedupeAndInsertCustomerRelationships() {
    registerMocks();
    Opportunity oppMl = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSObjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Territory__c.getSObjectType()
      ),
      Lead_Converted__c = false
    );
    oppActoinRepoMock.mock(
      'getTerritories',
      new Map<Id, Territory__c>{
        oppMl.Territory__c => new Territory__c(
          Id = oppMl.Territory__c,
          Primary_Franchise_Owner__c = UserInfo.getUserId()
        )
      }
    );
    Test.startTest();
    OpportunityActions.dedupeAndInsertCustomerRelationships(
      new List<Opportunity>{ oppMl }
    );
    Test.stopTest();
    List<Customer_Relationship__c> crrsInserted = (List<Customer_Relationship__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      crrsInserted.size(),
      '1 customer relationship should be inserted!'
    );
    Assert.areEqual(
      oppMl.Territory__c,
      crrsInserted.get(0).Territory__c,
      '1 customer relationship should be inserted!'
    );
  }

  /**
   * @description test method for revertLostReasonDetails
   */
  @isTest
  static void revertLostReasonDetailsTest() {
    registerMocks();
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType());
    Opportunity oldOpp = new Opportunity(
      Id = oppId,
      StageName = 'Lost',
      Lost_Reason__c = 'Test Lost Reason',
      Lost_Reason_Detail__c = 'Test Reason Detail'
    );
    oldMap.put(oppId, oldOpp);

    Opportunity updatedOpp = new Opportunity(Id = oppId, StageName = 'Closed');

    Test.startTest();
    OpportunityActions.revertLostReasonDetails(
      new List<Opportunity>{ updatedOpp },
      oldMap
    );
    Test.stopTest();
    Assert.isNull(updatedOpp.Lost_Reason__c, 'Lost reason is not null');
    Assert.isNull(
      updatedOpp.Lost_Reason_Detail__c,
      'Lost reason detail is not null'
    );
  }
}
