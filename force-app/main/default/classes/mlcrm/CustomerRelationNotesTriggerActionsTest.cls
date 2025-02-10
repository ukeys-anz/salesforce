/**
 * @author Ashish Kumar
 * @since 30 Aug 2023
 * @description CustomerRelationNotesTriggerActionsTest is the test class for CustomerRelationNotesTriggerActions Class functionality.
 */
@isTest
public class CustomerRelationNotesTriggerActionsTest {
  private static final String CUSTOME_RELATIONSHIP_JSON = '{"Newsletter__c":true, "Status__c":"Active", "Customer__r":{"Name":"TestName","Salutation":"Dr"}}';

  static Customer_Relationship__c createTestCustomerRelationship() {
    return (Customer_Relationship__c) JSON.deserialize(
      CUSTOME_RELATIONSHIP_JSON,
      Customer_Relationship__c.class
    );
  }
  static Lib_MockProvider accountActionsRepoMock;
  static Lib_MockProvider customerRelationshipRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    accountActionsRepoMock = Lib_MockProvider.forType(
      AccountActionsRepository.class
    );
    customerRelationshipRepoMock = Lib_MockProvider.forType(
      CustomerRelationshipsRepository.class
    );
  }

  @testSetup
  static void setup() {
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();

    // creating sample territory record
    System.runAs(mlBusinessAdminUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlBusinessAdminUser,
        true
      );

      Territory__Share objShare = new Territory__Share();
      objShare.parentId = lstOfTerritory[0].Id;
      objShare.accesslevel = 'Edit';
      objShare.userOrgroupid = mlUser.Id;
      insert objShare;
    }

    //update ml user record so that user trigger creates corresponding user territory record
    System.runAs(iiQUser) {
      Test.startTest();
      mlUser.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser.ML_Role__c = 'Loan Writer';
      update mlUser;
      Test.stopTest();
    }

    //Create Test customer relationship notes Records
    System.runAs(mlUser) {
      MLCRMTestDataFactory.createCustomerRelationNotes();
    }
  }

  @isTest
  static void testRelationshipNotesCreation() {
    user objUser = [
      SELECT Id
      FROM User
      WHERE
        LastName = 'MLCRM'
        AND FirstName LIKE 'BaseUser%'
        AND IsActive = TRUE
      LIMIT 1
    ];
    System.runAs(objUser) {
      List<Territory__c> lstOfTerritory = [SELECT Id FROM Territory__c LIMIT 1];
      List<Customer_Relationship__c> lstOfCustomerRelation = [
        SELECT Id, Territory__c
        FROM Customer_Relationship__c
      ];
      // asserting territory gets populated via trigger
      Assert.isTrue(
        lstOfCustomerRelation[0].Territory__c != null,
        'territory is not getting populated properly via trigger'
      );

      // asserting same territory gets assigned to customer relation record to which user is part of
      Assert.areEqual(
        lstOfTerritory[0].Id,
        lstOfCustomerRelation[0].Territory__c
      );
    }
  }
  /**
   * @description test method for updateCustomerName
   */
  @isTest
  public static void testUpdateCustomerName() {
    registerMocks();
    String accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accountId => new Account(
        Id = accountId,
        Name = 'TestName',
        Salutation = 'Dr'
      )
    };

    List<Customer_Relationship__c> lstOfSobject = new List<Customer_Relationship__c>();
    Customer_Relationship__c objSObject = new Customer_Relationship__c();
    objSObject.put('Newsletter__c', true);
    objSObject.put('Status__c', 'Active');
    objSObject.put('Customer__c', accountId);
    lstOfSobject.add(objSObject);
    Test.StartTest();
    accountActionsRepoMock.mock('getAccountByIds', mapOfAccount);
    CustomerRelationNotesTriggerActions.updateCustomerName(null, lstOfSobject);
    Test.StopTest();
    System.assertEquals(
      'Dr TestName',
      lstOfSobject[0].Customer_Name__c,
      'On creation or updation on Customer_Relationship__c object the Customer_Name__c field did not updated successfully'
    );
  }
  /**
   * @description test method for updateCustomerNameOnCustomerRelationship
   */
  @isTest
  public static void testUpdateCustomerNameOnCustomerRelationship() {
    registerMocks();
    String accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Test.StartTest();

    Customer_Relationship__c testCustomerRelationship = createTestCustomerRelationship();
    customerRelationshipRepoMock.mock(
      'getCustomerRelationshipByAccountIds',
      new List<Customer_Relationship__c>{ testCustomerRelationship }
    );
    CustomerRelationNotesTriggerActions.updateCustomerNameOnCustomerRelationship(
      new Set<Id>{ accountId }
    );
    Test.StopTest();

    List<Customer_Relationship__c> crUpdatedList = (List<Customer_Relationship__c>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    System.assertEquals(
      'Dr TestName',
      crUpdatedList[0].Customer_Name__c,
      'On updation of Account object the Customer_Name__c field on Customer_Relationship__c object is not updating successfully'
    );
  }
  /**
   * @description test method for getUpdatedCustomersIds
   */
  @isTest
  public static void testGetUpdatedCustomersIds() {
    registerMocks();
    String accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Account objAccount = new Account(
      Id = accountId,
      Salutation = 'Dr',
      FirstName = 'TestName',
      LastName = 'TestName',
      RecordTypeId = RTAccount.personAccount
    );

    Map<Id, Account> mapOfOldAcc = new Map<Id, Account>();
    Account objAcc = new Account();
    objAcc.put('Id', accountId);
    objAcc.put('Salutation', 'Dr');
    objAcc.put('FirstName', 'Test');
    objAcc.put('LastName', 'Name');
    objAcc.put('RecordTypeId', RTAccount.personAccount);
    mapOfOldAcc.put(accountId, objAcc);

    Test.StartTest();
    Customer_Relationship__c testCustomerRelationship = createTestCustomerRelationship();
    customerRelationshipRepoMock.mock(
      'getCustomerRelationshipByAccountIds',
      new List<Customer_Relationship__c>{ testCustomerRelationship }
    );
    CustomerRelationNotesTriggerActions.getUpdatedCustomersIds(
      mapOfOldAcc,
      new List<Account>{ objAccount }
    );
    Test.StopTest();

    List<Customer_Relationship__c> crUpdatedList = (List<Customer_Relationship__c>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    System.assertEquals(
      'Dr TestName',
      crUpdatedList[0].Customer_Name__c,
      'On updation of Account object the Customer_Name__c field on Customer_Relationship__c object is not updating successfully'
    );
  }
}
