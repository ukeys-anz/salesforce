/**
 * @author       : Advait Yermalkar
 * @since        : 22-05-2024
 * @description  : Test Class for CommercialA2ZReviewActionHelper Class
 **/
@isTest
private class CommercialA2ZReviewActionHelperTest {
  @isTest
  static void testSetBusinessOwner() {
    // GIVEN individualAccountIds and records
    Id personAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id otherAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    Set<Id> individualIds = new Set<Id>{ personAccId };

    List<A_Z_Review__c> reviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(Customer__c = personAccId),
      new A_Z_Review__c(Customer__c = otherAccId)
    };

    // WHEN calling method
    Test.startTest();
    CommercialA2ZReviewActionHelper.setBusinessOwner(reviewList, individualIds);
    Test.stopTest();

    // THEN only the matching record is updated
    Assert.areEqual(
      'Yes',
      reviewList[0].Existing_Business_Owner__c,
      'Should mark Existing_Business_Owner__c as Yes'
    );
    Assert.areEqual(
      personAccId,
      reviewList[0].Business_Owner__c,
      'Business Owner should be set to Customer Id'
    );
    Assert.isNull(
      reviewList[0].Business_Contact__c,
      'Business Contact should be cleared'
    );
    Assert.isNull(
      reviewList[1].Business_Owner__c,
      'Non-individual customer should be skipped'
    );
  }

  @isTest
  static void testValidateAndPopulateCLGInfo() {
    // GIVEN A2Z record, account map, and CLG map
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
      Customer__c = orgId,
      CLGCustomer__c = clgId
    );

    Map<Id, Account> accMap = new Map<Id, Account>{
      clgId => new Account(Id = clgId, CLG__c = 'CLG123')
    };

    Map<Id, Set<Id>> accToClgMap = new Map<Id, Set<Id>>{
      orgId => new Set<Id>{ clgId }
    };

    List<A_Z_Review__c> records = new List<A_Z_Review__c>{ a2z };

    // WHEN calling method
    Test.startTest();
    CommercialA2ZReviewActionHelper.validateAndPopulateCLGInfo(
      records,
      accMap,
      accToClgMap
    );
    Test.stopTest();

    // THEN values should be copied from account
    Assert.areEqual(
      clgId,
      a2z.CLGCustomer__c,
      'CLGCustomer should remain unchanged'
    );
  }

  @isTest
  static void testValidateAndPopulateCLGInfoInvalidCLGSelected() {
    // GIVEN CLGCustomer selected that isn't related
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id unrelatedClgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
      Customer__c = orgId,
      CLGCustomer__c = unrelatedClgId
    );

    Map<Id, Account> accMap = new Map<Id, Account>();
    Map<Id, Set<Id>> accToClgMap = new Map<Id, Set<Id>>{
      orgId => new Set<Id>{ Lib_FakeIdGenerator.getMockId(Account.SObjectType) }
    };

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.validateAndPopulateCLGInfo(
      new List<A_Z_Review__c>{ a2z },
      accMap,
      accToClgMap
    );
    Test.stopTest();

    // THEN expect error
    Assert.isTrue(
      a2z.hasErrors(),
      'Should throw error for unrelated CLG customer'
    );
  }

  @isTest
  static void testValidateAndPopulateCLGInfoNoCLGSelectedButOptionsAvailable() {
    // GIVEN no CLG selected but options exist
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
      Customer__c = orgId
    );

    Map<Id, Set<Id>> accToClgMap = new Map<Id, Set<Id>>{
      orgId => new Set<Id>{ clgId }
    };

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.validateAndPopulateCLGInfo(
      new List<A_Z_Review__c>{ a2z },
      new Map<Id, Account>(),
      accToClgMap
    );
    Test.stopTest();

    // THEN expect error
    Assert.isTrue(
      a2z.hasErrors(),
      'Should throw error if no CLG selected but options exist'
    );
  }

  @isTest
  static void testPopulateClgInfoOnA2ZReviewWithSingleCLG() {
    // GIVEN
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(Customer__c = orgId);

    Account clgAccount = new Account(Id = clgId, CLG__c = 'CLG999');
    FinServ__AccountAccountRelation__c aar = new FinServ__AccountAccountRelation__c(
      FinServ__RelatedAccount__r = clgAccount
    );

    Map<Id, Account> accMap = new Map<Id, Account>{
      orgId => new Account(Id = orgId, RecordTypeId = RTAccount.businessAccount)
    };

    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accToAARMap = new Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>{
      orgId => new Map<Id, FinServ__AccountAccountRelation__c>{ clgId => aar }
    };

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.populateClgInfoOnA2ZReview(
      new List<A_Z_Review__c>{ a2z },
      accMap,
      accToAARMap
    );
    Test.stopTest();

    // THEN
    Assert.areEqual(
      clgId,
      a2z.CLGCustomer__c,
      'CLGCustomer__c should be populated'
    );
  }

  @isTest
  static void testPopulateClgInfoOnA2ZReviewNoCLGAvailable() {
    // GIVEN org with no related CLG
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(Customer__c = orgId);

    Map<Id, Account> accMap = new Map<Id, Account>{
      orgId => new Account(Id = orgId, RecordTypeId = RTAccount.businessAccount)
    };

    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accToAARMap = new Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>();

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.populateClgInfoOnA2ZReview(
      new List<A_Z_Review__c>{ a2z },
      accMap,
      accToAARMap
    );
    Test.stopTest();

    // THEN should clear values
    Assert.isNull(a2z.CLGCustomer__c, 'CLG should be nullified');
  }

  @isTest
  static void testSetValueFromAccount() {
    // GIVEN
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Account acc = new Account(Id = accId, CLG__c = 'CLG500');

    A_Z_Review__c a2z = new A_Z_Review__c();

    // WHEN
    CommercialA2ZReviewActionHelper.setValueFromAccount(a2z, acc);

    // THEN
    Assert.areEqual(accId, a2z.CLGCustomer__c, 'Should set CLGCustomer__c');
  }

  @isTest
  static void testSetValueFromAccountNullAccount() {
    // GIVEN
    A_Z_Review__c a2z = new A_Z_Review__c();

    // WHEN
    CommercialA2ZReviewActionHelper.setValueFromAccount(a2z, null);

    // THEN
    Assert.isNull(a2z.CLGCustomer__c, 'CLGCustomer__c should be null');
  }

  @isTest
  static void testValidateAndPopulateCLGInfoNoCLGAvailableButSelected() {
    // GIVEN: CLG selected, but no related CLGs available
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
      Customer__c = orgId,
      CLGCustomer__c = clgId
    );

    Map<Id, Account> accMap = new Map<Id, Account>();
    Map<Id, Set<Id>> accToClgMap = new Map<Id, Set<Id>>{
      orgId => new Set<Id>() // No related CLG
    };

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.validateAndPopulateCLGInfo(
      new List<A_Z_Review__c>{ a2z },
      accMap,
      accToClgMap
    );
    Test.stopTest();

    // THEN
    Assert.isTrue(
      a2z.hasErrors(),
      'Should show error when no CLG is available'
    );
  }

  @isTest
  static void testPopulateClgInfoOnA2ZReviewCustomerIsCLGNotInMap() {
    // GIVEN: Customer is a CLG Account, but not in relation map
    Id clgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(Customer__c = clgId);

    Account clgAccount = new Account(
      Id = clgId,
      RecordTypeId = RTAccount.clgAccount
    );

    Map<Id, Account> accMap = new Map<Id, Account>{ clgId => clgAccount };

    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accToAARMap = new Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>();
    // Note: clgId is NOT included in the relation map

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.populateClgInfoOnA2ZReview(
      new List<A_Z_Review__c>{ a2z },
      accMap,
      accToAARMap
    );
    Test.stopTest();

    // THEN
    Assert.areEqual(
      clgId,
      a2z.CLGCustomer__c,
      'CLGCustomer__c should be set directly when customer is CLG but not in map'
    );
  }

  @isTest
  static void testPopulateClgInfoOnA2ZReviewOrgNotInMap() {
    // GIVEN: Customer is org, no related CLGs
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(Customer__c = orgId);

    Account orgAccount = new Account(
      Id = orgId,
      RecordTypeId = RTAccount.businessAccount
    );

    Map<Id, Account> accMap = new Map<Id, Account>{ orgId => orgAccount };

    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accToAARMap = new Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>();
    // orgId is missing in map

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.populateClgInfoOnA2ZReview(
      new List<A_Z_Review__c>{ a2z },
      accMap,
      accToAARMap
    );
    Test.stopTest();

    // THEN
    Assert.isNull(
      a2z.CLGCustomer__c,
      'CLGCustomer__c should be nullified if no CLG relations exist'
    );
  }

  @isTest
  static void testPopulateClgInfoOnA2ZReviewMultipleCLGsPresent() {
    // GIVEN: org account has multiple CLGs (should not populate any CLG info)
    Id orgId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    A_Z_Review__c a2z = new A_Z_Review__c(Customer__c = orgId);

    Account orgAccount = new Account(
      Id = orgId,
      RecordTypeId = RTAccount.businessAccount
    );

    FinServ__AccountAccountRelation__c aar1 = new FinServ__AccountAccountRelation__c(
      FinServ__RelatedAccount__r = new Account(Id = clgId1)
    );
    FinServ__AccountAccountRelation__c aar2 = new FinServ__AccountAccountRelation__c(
      FinServ__RelatedAccount__r = new Account(Id = clgId2)
    );

    Map<Id, Account> accMap = new Map<Id, Account>{ orgId => orgAccount };

    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accToAARMap = new Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>{
      orgId => new Map<Id, FinServ__AccountAccountRelation__c>{
        clgId1 => aar1,
        clgId2 => aar2
      }
    };

    // WHEN
    Test.startTest();
    CommercialA2ZReviewActionHelper.populateClgInfoOnA2ZReview(
      new List<A_Z_Review__c>{ a2z },
      accMap,
      accToAARMap
    );
    Test.stopTest();

    // THEN: CLGCustomer__c should be null due to ambiguity (multiple CLGs)
    Assert.isNull(
      a2z.CLGCustomer__c,
      'CLGCustomer__c should be null if multiple CLG relations exist'
    );
  }
}
