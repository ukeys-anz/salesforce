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
    CommercialInteractionActionsHelper.validateCLGAccountsAgainstCustomer(
      records,
      customerToCLGsMap
    );
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
    CommercialInteractionActionsHelper.validateCLGAccountsAgainstCustomer(
      records,
      customerToCLGsMap
    );
    Assert.isTrue(
      !records[0].hasErrors(),
      'Should not add error for valid CLG selection'
    );
  }

  @isTest
  static void getOppsIdsAssociatedWithInteractionsTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Set<Id> oppsIds = new Set<Id>();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Interaction> intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );

    Test.startTest();
    oppsIds = CommercialInteractionActionsHelper.getOppsIdsAssociatedWithInteractions(
      intRec,
      null
    );
    Test.stopTest();

    Assert.areEqual(1, oppsIds.size(), 'Size is not 1');
  }

  @isTest
  static void getOppsIdsAssociatedWithInteractionsWithOldMapTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Set<Id> oppsIds = new Set<Id>();
    List<Interaction> intRec;
    Map<Id, Interaction> oldMap;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id updatedOppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id intId = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
    intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      updatedOppId
    );
    intRec[0].AccountId = accId;
    intRec[0].Id = intId;
    oldMap = new Map<Id, Interaction>{
      intId => new Interaction(
        Id = intId,
        Opportunity__c = oppId,
        AccountId = accId
      )
    };

    Test.startTest();
    oppsIds = CommercialInteractionActionsHelper.getOppsIdsAssociatedWithInteractions(
      intRec,
      oldMap
    );
    Test.stopTest();

    Assert.areEqual(1, oppsIds.size(), 'Size is not 1');
  }

  @isTest
  static void updateInteractionNameTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    List<Interaction> intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intRec[0].Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);

    Interaction updatedInt = new Interaction(
      Id = intRec[0].Id,
      Name = 'Test Call',
      InteractionType = 'Email'
    );

    Test.startTest();
    CommercialInteractionActionsHelper.updateInteractionName(
      new List<Interaction>{ updatedInt },
      new Map<Id, Interaction>{ intRec[0].Id => intRec[0] }
    );
    Test.stopTest();

    Assert.isTrue(updatedInt.Name.contains('Email'), 'Name not updated');
  }

  @isTest
  static void getUpdatedNameOrChannelInteractionsTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Interaction> updatedInteractions;

    List<Interaction> intRec = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intRec[0].Id = (String) Lib_FakeIdGenerator.getMockId(
      Interaction.SObjectType
    );
    Interaction updatedInt = new Interaction(
      Id = intRec[0].Id,
      InteractionType = 'Email',
      Name = 'Test Interaction'
    );

    Test.startTest();
    updatedInteractions = CommercialInteractionActionsHelper.getUpdatedNameOrChannelInteractions(
      new List<Interaction>{ updatedInt },
      new Map<Id, Interaction>{ intRec[0].Id => intRec[0] }
    );
    Test.stopTest();

    Assert.areEqual(1, updatedInteractions.size(), 'No Interactions found');
  }
}
