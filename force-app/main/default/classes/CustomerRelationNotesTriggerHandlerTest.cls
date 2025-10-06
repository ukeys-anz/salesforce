/**
 * @author Pragya Awasthi
 * @since 26 Aug 2025
 * @description CustomerRelationNotesTriggerHandlerTest is the test class for CustomerRelationNotesTriggerHandler
 */
@isTest
public class CustomerRelationNotesTriggerHandlerTest {
  static Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  static Id crId = Lib_FakeIdGenerator.getMockId(
    Customer_Relationship__c.SObjectType
  );
  static Id idTerritory = Lib_FakeIdGenerator.getMockId(
    Territory__c.SObjectType
  );
  static Id franchiseOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

  static Lib_MockProvider accountActionsRepoMock;
  static Lib_MockProvider customerRelationshipRepoMock;
  static void registerMocks() {
    accountActionsRepoMock = Lib_MockProvider.forType(
      AccountActionsRepository.class
    );
    customerRelationshipRepoMock = Lib_MockProvider.forType(
      CustomerRelationshipsRepository.class
    );
  }

  /**
   * @description Returns a mock Customer_Relationship__c record
   * @return A mock Customer_Relationship__c record
   */
  private static Customer_Relationship__c getCustomerRelationship() {
    return (Customer_Relationship__c) TestUtil.setFields(
      new Customer_Relationship__c(
        Id = crId,
        Customer__c = accountId,
        Newsletter__c = true,
        Status__c = 'Active',
        Territory__c = idTerritory,
        Relationship_To_Franchise__c = 'Primary'
      ),
      new Map<String, Object>{
        'Territory__r' => new Territory__c(
          Id = idTerritory,
          Primary_Franchise_Owner__c = UserInfo.getUserId()
        ),
        'Customer__r' => new Account(
          Id = accountId,
          Name = 'TestName',
          Salutation = 'Dr'
        )
      }
    );
  }

  /**
   * @description test method for BeforeInsert in Handler
   */
  @isTest
  static void testBeforeInsert() {
    //create related territory record
    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Primary_Franchise_Owner__c = franchiseOwnerId
    );
    registerMocks();
    //create related account
    String accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accountId => new Account(
        Id = accountId,
        Name = 'Sahil',
        Salutation = 'Dr'
      )
    };

    //create Customer Relationship record
    Customer_Relationship__c custRelRec = getCustomerRelationship();
    custRelRec.Territory__c = idTerritory;
    custRelRec.Notes__c = 'A sample text with Passport12345678';
    custRelRec.Customer__c = accountId;
    //mocking the data
    accountActionsRepoMock.mock('getAccountByIds', mapOfAccount);

    Test.startTest();
    CustomerRelationNotesTriggerHandler handler = new CustomerRelationNotesTriggerHandler();
    handler.records = new List<Customer_Relationship__c>{ custRelRec };
    handler.onBeforeInsert();
    Test.stopTest();

    //assert
    Assert.areEqual(
      'A sample text with Passport****5678',
      custRelRec.Notes__c,
      'Keyword entered in Notes should be masked'
    );
    Assert.areEqual(
      'Dr Sahil',
      custRelRec.Customer_Name__c,
      'Customer Name should be updated'
    );
    Assert.areEqual(
      terrRecord.Id,
      custRelRec.Territory__c,
      'Territory should be assigned for ML record'
    );
  }

  /**
   * @description test method for BeforeUpdate in Handler
   */
  @isTest
  static void testBeforeUpdate() {
    Customer_Relationship__c custRelRec = getCustomerRelationship();
    custRelRec.Territory__c = idTerritory;
    custRelRec.Notes__c = 'A sample text with PP12345678';

    Map<Id, Customer_Relationship__c> oldMap = new Map<Id, Customer_Relationship__c>{
      custRelRec.Id => custRelRec
    };

    Test.startTest();
    CustomerRelationNotesTriggerHandler handler = new CustomerRelationNotesTriggerHandler();
    handler.records = new List<Customer_Relationship__c>{ custRelRec };
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    Assert.areEqual(
      'A sample text with PP****5678',
      custRelRec.Notes__c,
      'Keyword entered in Notes should be masked'
    );
  }

  /**
   * @description test method for AfterInsert in Handler
   */
  @isTest
  public static void testAfterInsert() {
    registerMocks();
    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Primary_Franchise_Owner__c = franchiseOwnerId
    );

    Customer_Relationship__c custRelRec = getCustomerRelationship();
    custRelRec.Territory__c = idTerritory;

    customerRelationshipRepoMock.mock(
      'getCustomerRelationshipByCustomerIds',
      new List<Customer_Relationship__c>{ custRelRec }
    );
    customerRelationshipRepoMock.mock(
      'getTerritoriesbyPrimaryFranchiseOwnerIds',
      new Map<Id, Territory__c>{ idTerritory => terrRecord }
    );

    Test.StartTest();
    CustomerRelationNotesTriggerHandler handler = new CustomerRelationNotesTriggerHandler();
    handler.records = new List<Customer_Relationship__c>{ custRelRec };
    handler.onAfterInsert();
    Test.StopTest();

    Assert.areEqual(
      Label.Minimum_Primary_Notes_Error,
      custRelRec.getErrors()[0].getMessage(),
      'The first record created for a Franchise is not a Primary Contact'
    );
  }

  /**
   * @description test method for AfterInsert in Handler
   */
  @isTest
  public static void testAfterUpdate() {
    registerMocks();
    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Primary_Franchise_Owner__c = UserInfo.getUserId()
    );
    Territory__c terrRecord2 = new Territory__c(
      Id = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
      Primary_Franchise_Owner__c = UserInfo.getUserId()
    );

    Customer_Relationship__c custRelRec = getCustomerRelationship();
    Customer_Relationship__c oldCustRec = getCustomerRelationship();
    custRelRec.Territory__c = terrRecord2.Id;

    Map<Id, Customer_Relationship__c> oldMap = new Map<Id, Customer_Relationship__c>{
      oldCustRec.Id => oldCustRec
    };

    customerRelationshipRepoMock.mock(
      'getCustomerRelationshipByCustomerIds',
      new List<Customer_Relationship__c>{ custRelRec, custRelRec }
    );
    customerRelationshipRepoMock.mock(
      'getTerritoriesbyPrimaryFranchiseOwnerIds',
      new Map<Id, Territory__c>{
        idTerritory => terrRecord,
        terrRecord2.id => terrRecord2
      }
    );

    Test.StartTest();
    CustomerRelationNotesTriggerHandler handler = new CustomerRelationNotesTriggerHandler();
    handler.records = new List<Customer_Relationship__c>{ custRelRec };
    handler.onAfterUpdate(oldMap);
    Test.StopTest();

    Assert.areEqual(
      Label.Maximum_Primary_Notes_Error,
      custRelRec.getErrors()[0].getMessage(),
      'There can be only one primary relationship notes for franchise'
    );
  }
}
