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
    CommercialOpportunityActions.populateCLGAccount(records, accountToAARMap);
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
}
