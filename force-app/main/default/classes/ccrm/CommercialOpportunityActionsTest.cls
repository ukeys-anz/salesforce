/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Test class for CommercialOpportunityActions
 **/

@isTest
public class CommercialOpportunityActionsTest {
  static Lib_MockProvider oppRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    oppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  @isTest
  static void testRestrictImagesInRichTextFields() {
    //GIVEN List of Opportunity Record
    List<Opportunity> opportunityList = new List<Opportunity>{
      new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
        Name = 'Sample Opportunity'
      )
    };

    //WHEN calling a restrictImagesInRichTextFields method
    Test.startTest();
    CommercialOpportunityActions.restrictImagesInRichTextFields(
      opportunityList,
      null
    );
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      opportunityList[0].hasErrors(),
      'Error while inserting Opportunity record with Image.'
    );
  }

  @isTest
  static void populateFieldsTest() {
    registerMocks();
    List<Database.Error> errors;
    Database.Error error;
    //GIVEN list of Opportunity records, old Map of Opportunity records
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oppId1 = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oppId2 = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oppId3 = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Account accRecord = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      FinServ__Status__c = 'Closed'
    );
    Account accRecord1 = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      FinServ__Status__c = 'Deceased'
    );
    Account accRecord2 = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      FinServ__Status__c = 'Unknown'
    );
    Account accRecord3 = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      FinServ__Status__c = 'Prospect'
    );
    Map<Id, Account> accMap = new Map<Id, Account>{
      accRecord.Id => accRecord,
      accRecord1.Id => accRecord1,
      accRecord2.Id => accRecord2,
      accRecord3.Id => accRecord3
    };
    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = accRecord.Id,
        Lead_Converted__c = false
      ),
      new Opportunity(
        Id = oppId1,
        AccountId = accRecord1.Id,
        Lead_Converted__c = false
      ),
      new Opportunity(
        Id = oppId2,
        AccountId = accRecord2.Id,
        Lead_Converted__c = false
      ),
      new Opportunity(
        Id = oppId3,
        AccountId = accRecord3.Id,
        Lead_Converted__c = false
      )
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(
        Id = oppId,
        AccountId = accRecord.Id,
        Lead_Converted__c = false
      ),
      oppId1 => new Opportunity(
        Id = oppId1,
        AccountId = accRecord1.Id,
        Lead_Converted__c = false
      ),
      oppId2 => new Opportunity(
        Id = oppId2,
        AccountId = accRecord2.Id,
        Lead_Converted__c = false
      ),
      oppId3 => new Opportunity(
        Id = oppId3,
        AccountId = accRecord3.Id,
        Lead_Converted__c = false
      )
    };
    oppRepoMock.mock('getClosedAccountMap', accMap);
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateFields(records, oldMap);
    Test.stopTest();

    //THEN it should fetch 1 accountId
    errors = records[0].getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityHelper.LEAD_PROCESS_FOR_PROSPECT_ERROR),
      'Validation error when opportunity is closed without app launch'
    );

    errors = records[1].getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityHelper.LEAD_PROCESS_FOR_PROSPECT_ERROR),
      'Validation error when opportunity is closed without app launch'
    );

    errors = records[2].getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityHelper.LEAD_PROCESS_FOR_PROSPECT_ERROR),
      'Validation error when opportunity is closed without app launch'
    );

    errors = records[3].getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityHelper.LEAD_PROCESS_FOR_PROSPECT_ERROR),
      'Validation error when opportunity is closed without app launch'
    );
  }

  @isTest
  static void validateCloseDateTest() {
    registerMocks();
    //GIVEN list of Opportunity records, old Map of Opportunity records
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Account accRecord = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount
    );
    //List<Opportunity> oppList = new List<Opportunity>(){};
    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = accRecord.Id,
        Name = 'Test',
        Lead_Converted__c = true,
        Has_Close_Date_Changed__c = false,
        CloseDate = Date.newInstance(2025, 6, 16)
      )
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(
        Id = oppId,
        Name = 'Test',
        AccountId = accRecord.Id,
        Lead_Converted__c = true,
        CloseDate = Date.newInstance(2025, 6, 14)
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.validateCloseDate(records, oldmap);
    Test.stopTest();

    Assert.areEqual(
      records[0].Has_Close_Date_Changed__c,
      true,
      'Close date is changed'
    );
  }

  @isTest
  static void validateCCRMOpportunityTest() {
    registerMocks();
    List<Database.Error> errors;
    Database.Error error;
    //GIVEN list of Opportunity records, old Map of Opportunity records
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Account accRecord = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount
    );
    //List<Opportunity> oppList = new List<Opportunity>(){};
    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = accRecord.Id,
        Name = 'Test',
        StageName = 'In Progress',
        LeadSource = 'Other'
      )
    };
    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper = new CommercialOpportunityActions.CCRMOpportunityWrapper();
    oppWrapper.filteredOpps = records;
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.validateCCRMOpportunity(oppWrapper, true);
    Test.stopTest();

    errors = records[0].getErrors();
    error = errors.get(0);
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityActions.OTHER_SOURCE_DETAIL_MANDATORY),
      'Validation error when opportunity is closed without app launch'
    );
  }

  @isTest
  static void getFilteredCCRMOppsInsertTest() {
    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test',
        StageName = 'In Progress',
        RecordTypeid = RTOpportunity.commercialOpportunity
      )
    };
    Test.startTest();
    oppWrapper = CommercialOpportunityActions.setOpportunityWrapper(
      oppList,
      new Map<Id, Opportunity>()
    );
    Test.stopTest();
    Assert.areEqual(1, oppWrapper.filteredOpps.size(), 'Size is not 1');
  }

  @isTest
  static void getFilteredCCRMOppsUpdateTest() {
    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test',
        StageName = 'New',
        RecordTypeid = RTOpportunity.commercialOpportunity
      )
    };

    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>{
      oppId => (new Opportunity(Id = oppId, StageName = 'In Progress'))
    };

    Test.startTest();
    oppWrapper = CommercialOpportunityActions.setOpportunityWrapper(
      oppList,
      oppMap
    );
    Test.stopTest();
    Assert.areEqual(1, oppWrapper.filteredOpps.size(), 'Size is not 1');
  }

  @isTest
  static void updateOpportunityNameOnUpdateTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    String longBankerName = 'A'.repeat(120);

    Opportunity mockOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Customer_Needs__c = 'Other',
        StageName = 'In Progress',
        RecordTypeid = RTOpportunity.commercialOpportunity,
        Name = longBankerName
      ),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );
    List<Opportunity> oppList = new List<Opportunity>{ mockOpp };

    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>{
      oppId => (new Opportunity(
        Id = oppId,
        Name = 'Purchasing Property Test',
        Customer_Needs__c = 'Other'
      ))
    };
    Test.startTest();
    CommercialOpportunityActions.updateOpportunityNameOnUpdate(oppList, oppMap);
    Test.stopTest();

    String expectedName = ('12345678 ' + longBankerName).left(120);

    Assert.areEqual(
      expectedName,
      oppList[0].Name,
      'Name should be truncated to 120 and exclude Customer Needs'
    );
    Assert.isFalse(
      oppList[0].Name.contains('Other'),
      'Commercial Opportunity name should not contain Customer Needs'
    );
  }

  @isTest
  static void updateOpportunityNameOnInsertTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Customer_Needs__c = 'Other',
        StageName = 'In Progress',
        RecordTypeid = RTOpportunity.commercialOpportunity,
        Lead_Converted__c = true,
        Name = 'test'
      )
    };

    Test.startTest();
    CommercialOpportunityActions.updateOpportunityNameOnInsert(oppList);
    Test.stopTest();
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"id":"5008r00000EhhODAAZ","success":true,"errors":[]}'
      )
    };

    dmlRepoMock.mock('doUpdate', saveResults);
    Assert.istrue(oppList[0].Name.contains('test'), 'Name should be present');
  }

  @isTest
  static void checkClosedStageFieldsOnAFPRelatedToOppTest() {
    List<Database.Error> errors;
    Database.Error error;
    registerMocks();

    String opportunityId = Lib_FakeIdGenerator.getMockId(
      Opportunity.SObjectType
    );
    oppRepoMock.mock('getUserProfileId', QueryProfile.anzCCRMStandardUser.Id);

    Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>{
      opportunityId => (new Opportunity(
        Id = opportunityId,
        RecordTypeId = RTOpportunity.commercialOpportunity,
        StageName = CommercialOpportunityActions.NEW_STAGE
      ))
    };

    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = opportunityId,
        RecordTypeId = RTOpportunity.commercialOpportunity,
        StageName = CommercialOpportunityActions.OPP_LOST
      )
    };

    oppRepoMock.mock(
      'getLostAFPRelatedToOpportunity',
      new List<ApplicationFormProduct>{
        new ApplicationFormProduct(
          Id = Lib_FakeIdGenerator.getMockId(
            ApplicationFormProduct.SObjectType
          ),
          Stage = CommercialOpportunityActions.OPP_LOST,
          Lost_reason__c = '',
          Lost_Reason_Detail__c = '',
          ApplicationForm = new ApplicationForm(
            Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType),
            OpportunityId = opportunityId
          )
        )
      }
    );

    Test.startTest();
    CommercialOpportunityActions.checkClosedStageFieldsOnAFPRelatedToOpp(
      oppList,
      oldOppMap
    );
    Test.stopTest();

    errors = oppList[0].getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityHelper.LOST_REASON_DETAIL_MISSING_AFP),
      'Opportunity updated successfully'
    );
  }

  @isTest
  static void testCheckIfSecondaryCustomerNeedsContainsCustomerNeeds() {
    Opportunity opp;
    Map<Id, Opportunity> oldMap;
    List<Database.Error> errors;
    Database.Error error;

    opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
      Customer_Needs__c = 'Commercial Lending',
      Secondary_Customer_Needs__c = 'Commercial Lending',
      RecordTypeId = RTOpportunity.commercialOpportunity
    );

    oldMap = new Map<Id, Opportunity>{
      opp.Id => new Opportunity(
        Id = opp.Id,
        Customer_Needs__c = 'Commercial Lending',
        RecordTypeId = RTOpportunity.commercialOpportunity
      )
    };

    Test.startTest();
    CommercialOpportunityActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
      new List<Opportunity>{ opp },
      oldMap
    );
    Test.stopTest();

    errors = opp.getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.areEqual(
      CommercialOpportunityActions.CUSTOMER_NEEDS_ERROR,
      error.getMessage(),
      'Opportunity validation executed'
    );
  }

  @isTest
  static void populateCLGOppTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountIdNew)
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(Id = oppId, AccountId = relatedAccountIdOld)
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdNew,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };
    oppRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    Map<Id, Account> accountMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);

    //userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateInfo(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      null,
      records[0].CLG_Name__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void populateCLGforCLGAccountTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountIdNew)
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(Id = oppId, AccountId = relatedAccountIdOld)
    };

    oppRepoMock.mock(
      'getAccountAccountRelations',
      new List<FinServ__AccountAccountRelation__c>()
    );

    Map<Id, Account> accountMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);
    userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateInfo(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      '1567',
      records[0].CLG_Id__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void validateCLGGetErrorTest() {
    String errorMessage = '';
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id noclgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = relatedAccountIdNew,
        CLG__c = noclgAccountId
      )
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(
        Id = oppId,
        AccountId = relatedAccountIdNew,
        CLG__c = clgAccountId
      )
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdOld,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };
    oppRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    Map<Id, Account> accountMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);
    userRepoMock.mock('checkProfile', true);

    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.validateAndPopulateInfo(records, oldMap);

    Test.stopTest();
    if (records[0].hasErrors()) {
      List<Database.Error> errors = records[0].getErrors();
      errorMessage = errors[0].getMessage();
    }
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      CommercialOpportunityHelper.SELECT_RELATED_CLG_ERROR,
      errorMessage,
      'Should give validation error to select a related CLG only'
    );
  }

  @isTest
  static void populateCLGforNonCLGAccountTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountIdNew)
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(Id = oppId, AccountId = relatedAccountIdOld)
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdNew,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(
          CLG__c = '1234',
          RecordTypeId = RTAccount.clgAccount
        )
      )
    };
    oppRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    Map<Id, Account> accountMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);
    userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateInfo(records, oldMap);
    Test.stopTest();
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      '1234',
      records[0].CLG_Id__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void populateNullCLGforOrgAccountTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountIdNew)
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(Id = oppId, AccountId = relatedAccountIdOld)
    };

    oppRepoMock.mock(
      'getAccountAccountRelations',
      new List<FinServ__AccountAccountRelation__c>()
    );

    Map<Id, Account> accountMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);
    userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateInfo(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.isNull(
      records[0].CLG_Id__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void populateNullCLGforMultiCLGAccountTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountIdNew)
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(Id = oppId, AccountId = relatedAccountIdOld)
    };
    FinServ__AccountAccountRelation__c aarFirst = new FinServ__AccountAccountRelation__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__AccountAccountRelation__c.SObjectType
      ),
      FinServ__Account__c = relatedAccountIdNew,
      FinServ__RelatedAccount__c = clgAccountId,
      FinServ__RelatedAccount__r = new Account(
        CLG__c = '1234',
        RecordTypeId = RTAccount.clgAccount
      )
    );
    FinServ__AccountAccountRelation__c aarSecond = new FinServ__AccountAccountRelation__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__AccountAccountRelation__c.SObjectType
      ),
      FinServ__Account__c = relatedAccountIdNew,
      FinServ__RelatedAccount__c = clgAccountId2,
      FinServ__RelatedAccount__r = new Account(
        CLG__c = '7890',
        RecordTypeId = RTAccount.clgAccount
      )
    );
    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>();
    accountAccountRelationList.add(aarFirst);
    accountAccountRelationList.add(aarSecond);
    oppRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    Map<Id, Account> accountMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);
    userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateInfo(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.isNull(
      records[0].CLG_Id__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void validateCLGTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id noclgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = relatedAccountIdNew,
        CLG__c = noclgAccountId
      )
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(
        Id = oppId,
        AccountId = relatedAccountIdOld,
        CLG__c = clgAccountId
      )
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdNew,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };
    oppRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    Map<Id, Account> accountMap = new Map<Id, Account>{
      noclgAccountId => new Account(
        Id = noclgAccountId,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);
    userRepoMock.mock('checkProfile', true);

    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.validateAndPopulateInfo(records, oldMap);
    Test.stopTest();
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.isNotNull(
      records[0].CLG__c,
      'Should update CLG Name on opportunity on updation with no validation error'
    );
  }

  @isTest
  static void validateCLGGetErrorTestNullCLG() {
    String errorMessage = '';
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id noclgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountIdNew)
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(
        Id = oppId,
        AccountId = relatedAccountIdNew,
        CLG__c = clgAccountId
      )
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdNew,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };
    oppRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    Map<Id, Account> accountMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    };
    oppRepoMock.mock('getAccountMap', accountMap);
    userRepoMock.mock('checkProfile', true);

    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.validateAndPopulateInfo(records, oldMap);

    Test.stopTest();
    if (records[0].hasErrors()) {
      List<Database.Error> errors = records[0].getErrors();
      errorMessage = errors[0].getMessage();
    }
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      CommercialOpportunityHelper.SELECT_ANY_CLG_ERROR,
      errorMessage,
      'Should give validation error to select any CLG'
    );
  }

  @isTest
  static void populateClgAccountTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id noclgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountIdNew)
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(Id = oppId, AccountId = relatedAccountIdOld)
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdNew,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };
    oppRepoMock.mock(
      'getAccountAccountRelationsForCLG',
      accountAccountRelationList
    );

    Map<Id, Account> accountMap = new Map<Id, Account>{
      noclgAccountId => new Account(
        Id = noclgAccountId,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    };
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateClgAccount(records, oldMap);
    Test.stopTest();
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.isNotNull(
      records[0].CLG__c,
      'Should update CLG Name on opportunity on updation with no validation error'
    );
  }

  @isTest
  static void mandatoryFieldAndSkipStageCheckTest() {
    registerMocks();
    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    String errorMessage;
    List<Opportunity> oppList = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = accountId,
        Name = 'Test',
        StageName = 'Opportunity Won',
        RecordTypeid = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(
        Id = oppId,
        AccountId = accountId,
        Name = 'Test',
        StageName = 'In Progress',
        RecordTypeid = RTOpportunity.commercialOpportunity,
        OwnerId = userId
      )
    };
    List<User> userList = new List<User>{
      new User(Id = userId, Commercial_Segment__c = 'SME')
    };

    List<Map<String, Object>> result = new List<Map<String, Object>>();

    Map<String, Object> taskmap = new Map<String, Object>{ 'WhatId' => oppId };
    List<Map<String, Object>> taskList = new List<Map<String, Object>>();
    taskList.add(taskmap);
    oppRepoMock.mock('getUsers', userList);
    oppRepoMock.mock('getOpenTasksOnClosedOpportunity', taskList);
    userRepoMock.mock('checkRole', false);
    Test.startTest();
    oppWrapper = CommercialOpportunityActions.setOpportunityWrapper(
      oppList,
      oldMap
    );
    CommercialOpportunityActions.mandatoryFieldAndSkipStageCheck(
      oppWrapper,
      oldMap,
      false
    );

    Test.stopTest();
    if (oppWrapper.closingOppoIdMap.get(oppId).hasErrors()) {
      List<Database.Error> errors = oppWrapper.closingOppoIdMap.get(oppId)
        .getErrors();
      errorMessage = errors[0].getMessage();
    }
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      System.Label.CCRM_OpenTasksOnOpportunityCloseError,
      errorMessage,
      'Should give validation error for open task'
    );
  }
}
