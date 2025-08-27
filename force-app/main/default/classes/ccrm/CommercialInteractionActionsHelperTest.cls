/**
 * @author Advait Yermalkar
 * @since  07-02-2025
 * @description Test class for CommercialInteractionActionsHelper
 */
@isTest
private class CommercialInteractionActionsHelperTest {
  @isTest
  static void populateCLGForInteractionTest() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> records = new List<Interaction>{
      new Interaction(Id = intId, AccountId = accId)
    };
    Map<Id, Set<Id>> customerToCLGsMap = new Map<Id, Set<Id>>{
      accId => new Set<Id>{ clgId }
    };
    Map<Id, Account> accountMap = new Map<Id, Account>{};
    Test.startTest();
    CommercialInteractionActionsHelper.populateCLGForInteraction(
      records,
      customerToCLGsMap,
      accountMap
    );
    Test.stopTest();
    Assert.areEqual(
      clgId,
      records[0].CLGCustomer__c,
      'CLGCustomer__c should be set to related CLG'
    );
  }

  @isTest
  static void populateCLGForInteractionWhenCustomerIsCLGTest() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> records = new List<Interaction>{
      new Interaction(Id = intId, AccountId = accId)
    };
    Map<Id, Set<Id>> customerToCLGsMap = new Map<Id, Set<Id>>{};
    Map<Id, Account> accountMap = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.clgAccount)
    };
    Test.startTest();
    CommercialInteractionActionsHelper.populateCLGForInteraction(
      records,
      customerToCLGsMap,
      accountMap
    );
    Test.stopTest();
    Assert.areEqual(
      accId,
      records[0].CLGCustomer__c,
      'CLGCustomer__c should be set to AccountId if customer is CLG'
    );
  }

  @isTest
  static void validateCLGAccountsAgainstCustomerTest() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    Id invalidClgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Interaction> records = new List<Interaction>{
      new Interaction(
        Id = intId,
        AccountId = accId,
        CLGCustomer__c = invalidClgId
      )
    };
    Map<Id, Set<Id>> customerToCLGsMap = new Map<Id, Set<Id>>{
      accId => new Set<Id>{ clgId }
    };
    Test.startTest();
    CommercialInteractionActionsHelper.validateCLGAccountsAgainstCustomer(
      records,
      customerToCLGsMap
    );
    Test.stopTest();
    Assert.isTrue(
      records[0].hasErrors(),
      'Should add error for invalid CLG selection'
    );
  }

  @isTest
  static void validateCLGAccountsAgainstCustomerNoErrorTest() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    List<Interaction> records = new List<Interaction>{
      new Interaction(Id = intId, AccountId = accId, CLGCustomer__c = clgId)
    };
    Map<Id, Set<Id>> customerToCLGsMap = new Map<Id, Set<Id>>{
      accId => new Set<Id>{ clgId }
    };
    Test.startTest();
    CommercialInteractionActionsHelper.validateCLGAccountsAgainstCustomer(
      records,
      customerToCLGsMap
    );
    Test.stopTest();
    Assert.isTrue(
      !records[0].hasErrors(),
      'Should not add error for valid CLG selection'
    );
  }

  @IsTest
  static void testMapCustomerToCLGAccounts() {
    Id accountId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id accountId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        FinServ__Account__c = accountId1,
        FinServ__RelatedAccount__c = relatedAccountId1
      ),
      new FinServ__AccountAccountRelation__c(
        FinServ__Account__c = accountId1,
        FinServ__RelatedAccount__c = relatedAccountId2
      ),
      new FinServ__AccountAccountRelation__c(
        FinServ__Account__c = accountId2,
        FinServ__RelatedAccount__c = relatedAccountId1
      )
    };
    Test.startTest();
    Map<Id, Set<Id>> result = CommercialInteractionActionsHelper.mapCustomerToCLGAccounts(
      relations
    );
    Test.stopTest();

    Assert.isTrue(
      result.containsKey(accountId1),
      'Map should contain accountId1'
    );
    Assert.isTrue(
      result.containsKey(accountId2),
      'Map should contain accountId2'
    );

    Assert.areEqual(
      2,
      result.get(accountId1).size(),
      'accountId1 should have 2 related CLGs'
    );
    Assert.areEqual(
      1,
      result.get(accountId2).size(),
      'accountId2 should have 1 related CLG'
    );
  }

  @isTest
  static void updateCustomerOnInteractionTest() {
    Map<Id, Id> oppIdToCustomerIdMap;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Opportunity opp = new Opportunity(
      Id = oppId,
      Name = 'Test Opp',
      StageName = 'Opportunity Identified',
      RecordTypeId = CCRMConstants.CCRM_OPP_RT_ID,
      AccountId = accId
    );
    List<Interaction> intRec = new List<Interaction>{
      new Interaction(
        Name = 'Test Interaction',
        recordTypeId = CCRMConstants.INTERACTION_CCRM_RT_ID,
        Category__c = CCRMConstants.INTER_CAT_GENERAL,
        InteractionType = 'Call',
        StartTime = System.now(),
        Optional_Notes__c = 'Test Optional Notes'
      )
    };
    intRec[0].AccountId = null;
    intRec[0].Opportunity__c = oppId;
    oppIdToCustomerIdMap = new Map<Id, Id>{ oppId => accId };

    Test.startTest();
    CommercialInteractionActionsHelper.updateCustomerOnInteraction(
      intRec,
      oppIdToCustomerIdMap
    );
    Test.stopTest();

    System.assertEquals(accId, intRec[0].AccountId, 'No Account Found');
  }
}
