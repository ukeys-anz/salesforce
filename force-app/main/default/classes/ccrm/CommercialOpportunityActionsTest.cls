/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Test class for CommercialOpportunityActions
 **/

@isTest
public class CommercialOpportunityActionsTest {
  static Lib_MockProvider oppRepoMock;
  static void registerMocks() {
    oppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
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
  static void extractAccountIdsInsertTest() {
    //GIVEN list of Opportunity records
    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
      )
    };

    //WHEN calling a method
    Test.startTest();
    Set<Id> accountIdsSet = CommercialOpportunityActions.extractAccountIds(
      records,
      null
    );
    Test.stopTest();

    //THEN it should fetch 1 accountId
    Assert.areEqual(1, accountIdsSet.size(), 'Should fetch 1 accountId');
  }

  @isTest
  static void extractAccountIdsUpdateTest() {
    //GIVEN list of Opportunity records, old Map of Opportunity records
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
      )
    };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
      oppId => new Opportunity(
        Id = oppId,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
      )
    };

    //WHEN calling a method
    Test.startTest();
    Set<Id> accountIdsSet = CommercialOpportunityActions.extractAccountIds(
      records,
      oldMap
    );
    Test.stopTest();

    //THEN it should fetch 1 accountId
    Assert.areEqual(
      1,
      accountIdsSet.size(),
      'Should fetch 1 accountId on update'
    );
  }

  @isTest
  static void populateCLGAccountTest() {
    //GIVEN list of Opportunity records and map of Account-Account relations
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id relatedAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(Id = oppId, AccountId = relatedAccountId)
    };
    Map<Id, Account> accMap = new Map<Id, Account>{
      relatedAccountId => new Account(
        Id = relatedAccountId,
        RecordTypeId = RTAccount.businessAccount
      )
    };
    Map<Id, FinServ__AccountAccountRelation__c> accountToAARMap = new Map<Id, FinServ__AccountAccountRelation__c>{
      relatedAccountId => new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountId,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateCLGAccount(
      records,
      accMap,
      accountToAARMap
    );
    Test.stopTest();

    //THEN it should update CLG on Opp
    Assert.areEqual(
      clgAccountId,
      records[0].CLG__c,
      'Should update CLG Name on Opportunity'
    );
  }

  @isTest
  static void populateCLGTest() {
    registerMocks();
    //GIVEN list of Opportunity records and map of Account-Account relations
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

    Map<Id, Account> accMap = new Map<Id, Account>{
      relatedAccountIdNew => new Account(
        Id = relatedAccountIdNew,
        RecordTypeId = RTAccount.businessAccount
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
    oppRepoMock.mock('getAccountMap', accMap);
    oppRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityActions.populateCLG(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      clgAccountId,
      records[0].CLG__c,
      'Should update CLG Name on opportunity on updation'
    );
  }

  @isTest
  static void validateAFPBeforeOppCloseWithAFPTest() {
    List<Database.Error> errors;
    Database.Error error;
    registerMocks();

    String opportunityId = Lib_FakeIdGenerator.getMockId(
      Opportunity.SObjectType
    );
    String productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

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
      'getAFPRelatedToOpportunity',
      new List<ApplicationFormProduct>{
        new ApplicationFormProduct(
          Id = Lib_FakeIdGenerator.getMockId(
            ApplicationFormProduct.SObjectType
          ),
          Stage = 'Opportunity Identified',
          ProductId = productId,
          ApplicationForm = new ApplicationForm(
            Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType),
            OpportunityId = opportunityId
          )
        )
      }
    );

    oppRepoMock.mock(
      'getOppProductsForOpportunity',
      new List<OpportunityLineItem>{
        new OpportunityLineItem(
          Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
          OpportunityId = opportunityId,
          Product2Id = productId
        )
      }
    );
    Test.startTest();
    CommercialOpportunityActions.validateAFPBeforeOppClose(oppList, oldOppMap);
    Test.stopTest();

    errors = oppList[0].getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityHelper.CLOSE_AFP_FIRST_ERROR),
      'Validation error when opportunity is closed without closing AFPs'
    );
  }

  @isTest
  static void validateAFPBeforeOppCloseWithNoAFPTest() {
    List<Database.Error> errors;
    Database.Error error;
    registerMocks();

    String opportunityId = Lib_FakeIdGenerator.getMockId(
      Opportunity.SObjectType
    );
    String productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

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
      'getAFPRelatedToOpportunity',
      new List<ApplicationFormProduct>()
    );

    oppRepoMock.mock(
      'getOppProductsForOpportunity',
      new List<OpportunityLineItem>{
        new OpportunityLineItem(
          Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
          OpportunityId = opportunityId,
          Product2Id = productId
        )
      }
    );
    Test.startTest();
    CommercialOpportunityActions.validateAFPBeforeOppClose(oppList, oldOppMap);
    Test.stopTest();

    errors = oppList[0].getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Error on update');
    Assert.isTrue(
      error.getMessage().contains(CommercialOpportunityHelper.LAUNCH_APP_ERROR),
      'Validation error when opportunity is closed without app launch'
    );
  }
}
