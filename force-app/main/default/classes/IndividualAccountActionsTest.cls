/**
 * @author Hitesh
 * @since 02/2024
 * @description Test class for IndividualAccountActions
 */
@isTest
public class IndividualAccountActionsTest {
  private static final String CUSTOMER_RELATIONSHIP_JSON = '{"Newsletter__c":true, "Status__c":"Active", "Relationship_To_Franchise__c":"Primary", "Customer__r":{"Id":"accountId", "Name":"TestName","Salutation":"Dr"}, "Territory__r":{"Id":"idTerritory"}, "Primary_Franchise_Owner__r":{"Id":"franchiseOwnerId"}}';
  static Customer_Relationship__c createTestCustomerRelationship() {
    return (Customer_Relationship__c) JSON.deserialize(
      CUSTOMER_RELATIONSHIP_JSON,
      Customer_Relationship__c.class
    );
  }
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider accountRepoMock;
  static Lib_MockProvider customerRelationshipRepoMock;
  static void registerMocks() {
    accountRepoMock = Lib_MockProvider.forType(AccountActionsRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    customerRelationshipRepoMock = Lib_MockProvider.forType(
      CustomerRelationshipsRepository.class
    );
  }

  /**
   * @description test method for revertShellProspectBillingAddress
   */
  @isTest
  static void testRevertShellProspectBillingAddressForMLUser() {
    Account record = new Account();
    record.BillingStreet = 'test Street';
    record.BillingCity = 'test City';
    record.BillingState = 'VIC';
    record.BillingPostalCode = '3000';
    record.BillingCountry = 'AUS';
    record.OCV_Event_Version__c = Integer.valueOf(
      Label.ShellProspectOCVEventVersion
    );
    record.RecordTypeId = RTAccount.personAccount;
    record.FinServ__Status__c = 'Prospect';
    Test.startTest();
    LeadConversionController.manualLeadConversionInitiated = true;
    IndividualAccountActions.revertShellProspectBillingAddress(
      new List<Account>{ record }
    );
    Test.stopTest();
    Assert.areEqual(
      'test Street',
      record.BillingStreet,
      'Shell prospect\'s Billing Address failed to clear for ML user'
    );
  }

  /**
   * @description test method for validateDateOfBirth
   */
  @isTest
  static void validateDateOfBirthTest() {
    Account record = new Account();
    record.RecordTypeId = RTAccount.personAccount;
    record.PersonBirthdate = System.TODAY();
    Test.startTest();
    IndividualAccountActions.validateDateOfBirth(new List<Account>{ record });
    Test.stopTest();
    List<Database.Error> errors = record.getErrors();
    Assert.areEqual(1, errors.size(), 'Birthdate is valid');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      Label.ML_DateOfBirth_ErrorMessage,
      error.getMessage(),
      'Date of Birth is in past'
    );
    Assert.areEqual(
      StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,
      error.getStatusCode(),
      'No Error found'
    );
  }

  @isTest
  static void testBlankBillingAddress() {
    Account record = new Account();
    record.BillingStreet = 'test Street';
    record.BillingCity = 'test City';
    record.BillingState = 'VIC';
    record.BillingPostalCode = '3000';
    record.BillingCountry = 'AUS';
    record.OCV_Event_Version__c = Integer.valueOf(
      Label.ShellProspectOCVEventVersion
    );
    record.RecordTypeId = RTAccount.personAccount;
    record.FinServ__Status__c = 'Prospect';

    List<Account> accounts = new List<Account>();
    accounts.add(record);

    Test.startTest();
    IndividualAccountActions.blankBillingAddress(accounts);
    Test.stopTest();

    Assert.areEqual(
      null,
      record.BillingStreet,
      'Billing Address is not blanked out'
    );
  }

  @isTest
  static void testhandleEmploymentTypeChange() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Account> records = new List<Account>{
      new Account(
        Id = accId,
        Name = 'Test Account',
        Employment_Type__c = 'Student',
        Employer_Name__c = 'ABC Employer',
        Self_Employed__c = 'N',
        RecordTypeId = RTAccount.personAccount
      )
    };
    Map<Id, Account> oldMap = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Name = 'Test Account',
        Employment_Type__c = 'Tailor',
        Employer_Name__c = 'ABC Employer',
        Self_Employed__c = 'N'
      )
    };
    accountRepoMock.mock('isCurrentUserML', true);
    Test.startTest();
    IndividualAccountActions.handleEmploymentTypeChange(records, oldMap);
    Test.stopTest();
    Assert.areEqual(
      null,
      records[0].Employer_Name__c,
      'Employer Name field is not changed to null'
    );
    Assert.areEqual(
      null,
      records[0].Self_Employed__c,
      'Self Employed field is not changed to null'
    );
  }

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
    IndividualAccountActions.getUpdatedCustomersIds(
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
}
