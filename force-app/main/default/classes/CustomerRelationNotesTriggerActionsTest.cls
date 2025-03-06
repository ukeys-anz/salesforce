/**
 * @author Ashish Kumar
 * @since 30 Aug 2023
 * @description CustomerRelationNotesTriggerActionsTest is the test class for CustomerRelationNotesTriggerActions Class functionality.
 */
@isTest
public class CustomerRelationNotesTriggerActionsTest {
  String accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
  Id franchiseOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
  private static final String CUSTOME_RELATIONSHIP_JSON = '{"Newsletter__c":true, "Status__c":"Active", "Relationship_To_Franchise__c":"Primary", "Customer__r":{"Id":"accountId", "Name":"TestName","Salutation":"Dr"}, "Territory__r":{"Id":"idTerritory"}, "Primary_Franchise_Owner__r":{"Id":"franchiseOwnerId"}}';

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

  /**
   * @description test method for trigger code coverage
   */
  @isTest
  static void testRelationshipNotesCreation() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    Territory__c terrRecord = new Territory__c(Name = 'Melbourne CBD (VIC)');
    System.runAs(MLCRMTestDataFactory.createMLBusinessAdminUser()) {
      terrRecord.Primary_Franchise_Owner__c = UserInfo.getUserId();
      insert terrRecord;
      Territory__Share objShare = new Territory__Share(
        ParentId = terrRecord.Id,
        AccessLevel = 'Edit',
        UserOrGroupId = mlUser.Id
      );
      insert objShare;
      User_Territory__c userTerrRecord = new User_Territory__c(
        User__c = mlUser.Id,
        Territory__c = terrRecord.id,
        ML_Role__c = 'Loan Writer',
        Status__c = 'Active'
      );
      insert userTerrRecord;
    }
    List<Customer_Relationship__c> lstOfCustRelRecord = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(Territory__c = terrRecord.Id)
    };
    System.runAs(mlUser) {
      insert lstOfCustRelRecord;
    }
    // asserting territory gets populated via trigger
    Assert.isTrue(
      lstOfCustRelRecord[0].Territory__c != null,
      'territory is not getting populated properly via trigger'
    );
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
    Customer_Relationship__c objSObject = new Customer_Relationship__c(
      Newsletter__c = true,
      Status__c = 'Active',
      Customer__c = accountId
    );
    lstOfSobject.add(objSObject);
    Test.StartTest();
    accountActionsRepoMock.mock('getAccountByIds', mapOfAccount);
    CustomerRelationNotesTriggerActions.updateCustomerName(null, lstOfSobject);
    Test.StopTest();
    Assert.areEqual(
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
    Assert.areEqual(
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
    Account objAcc = new Account(
      Id = accountId,
      Salutation = 'Dr',
      FirstName = 'Test',
      LastName = 'Name',
      RecordTypeId = RTAccount.personAccount
    );
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
    Assert.areEqual(
      'Dr TestName',
      crUpdatedList[0].Customer_Name__c,
      'On updation of Account object the Customer_Name__c field on Customer_Relationship__c object is not updating successfully'
    );
  }

  /**
   * @description test method for validatePrimaryRelationshipNotes
   */
  @isTest
  public static void testvalidatePrimaryRelationshipNotes() {
    registerMocks();
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id franchiseOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Primary_Franchise_Owner__c = franchiseOwnerId
    );

    Customer_Relationship__c testCustomerRelationship = createTestCustomerRelationship();
    testCustomerRelationship.Territory__c = idTerritory;

    customerRelationshipRepoMock.mock(
      'getCustomerRelationshipByCustomerIds',
      new List<Customer_Relationship__c>{ testCustomerRelationship }
    );
    customerRelationshipRepoMock.mock(
      'getTerritoriesbyPrimaryFranchiseOwnerIds',
      new Map<Id, Territory__c>{ idTerritory => terrRecord }
    );

    Test.StartTest();
    CustomerRelationNotesTriggerActions.validatePrimaryRelationshipNotes(
      null,
      new List<Customer_Relationship__c>{ testCustomerRelationship }
    );
    Test.StopTest();

    Assert.areEqual(
      Label.MLCRM_Minimum_Primary_Notes_Error,
      testCustomerRelationship.getErrors()[0].getMessage(),
      'The first record created for a Franchise is not a Primary Contact'
    );
  }

  /**
   * @description test method for getExistingCustomerRelationships
   */
  @isTest
  public static void testgetExistingCustomerRelationships() {
    registerMocks();
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id franchiseOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id custRelationshipId = Lib_FakeIdGenerator.getMockId(
      Customer_Relationship__c.SObjectType
    );

    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Primary_Franchise_Owner__c = franchiseOwnerId
    );

    List<SObject> lstOfSobject = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = custRelationshipId,
        Relationship_To_Franchise__c = 'Primary',
        Customer__c = accountId,
        Territory__r = terrRecord,
        Territory__c = idTerritory
      )
    };

    customerRelationshipRepoMock.mock(
      'getCustRelationshipIdofShellProspectAccount',
      lstOfSobject
    );

    Test.StartTest();
    CustomerRelationNotesTriggerActions.CustomerRelationshipCreator creatorObj = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
    Customer_Relationship__c custRelRecord = creatorObj.getExistingCustomerRelationships(
      accountId,
      lstOfSobject
    );
    Test.StopTest();
    Assert.areEqual(
      'Primary',
      custRelRecord.Relationship_To_Franchise__c,
      'Relationship to Franchise of existing Customer Relationship is not Primary'
    );
  }

  /**
   * @description test method for autoCustomerRelationshipCreation
   */
  @isTest
  public static void testautoCustomerRelationshipCreation() {
    registerMocks();
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);

    OCVRequestPayloadWrapper reqRecord = new OCVRequestPayloadWrapper();
    reqRecord.strMiddleName = 'Middle Name';

    Test.StartTest();
    CustomerRelationNotesTriggerActions.CustomerRelationshipCreator creatorObj = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
    Customer_Relationship__c custRelRecord = creatorObj.autoCustomerRelationshipCreation(
      accountId,
      reqRecord,
      idTerritory
    );
    Test.StopTest();

    Assert.areEqual(
      'Primary',
      custRelRecord.Relationship_To_Franchise__c,
      'Relationship to Franchise of Customer Relationship created is not Primary'
    );
  }

  /**
   * @description test method for createCustomerRelationship
   */
  @isTest
  public static void testcreateCustomerRelationship() {
    registerMocks();
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id franchiseOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);

    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Primary_Franchise_Owner__c = franchiseOwnerId
    );

    List<SObject> lstOfLead = new List<Lead>{
      new Lead(
        Territory__c = idTerritory,
        Territory__r = terrRecord,
        RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
        RecordType = new RecordType(DeveloperName = 'MLCRM_Lead')
      )
    };

    OCVRequestPayloadWrapper reqRecord = new OCVRequestPayloadWrapper();
    reqRecord.strMiddleName = 'Middle Name';
    reqRecord.strRecordId = String.valueOf(idLead);

    customerRelationshipRepoMock.mock(
      'getCustRelationshipIdofShellProspectAccount',
      new List<Customer_Relationship__c>()
    );

    customerRelationshipRepoMock.mock('getCRDetails', lstOfLead);

    Test.StartTest();
    CustomerRelationNotesTriggerActions.CustomerRelationshipCreator creatorObj = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
    creatorObj.createCustomerRelationship(accountId, reqRecord);
    Test.StopTest();
    Customer_Relationship__c relRecord = (Customer_Relationship__c) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');
    Assert.isNotNull(
      relRecord,
      'Customer Relationship record was not created successfully'
    );
  }
}
