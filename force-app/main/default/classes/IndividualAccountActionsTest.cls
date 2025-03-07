/**
 * @author Hitesh
 * @since 02/2024
 * @description Test class for IndividualAccountActions
 */
@isTest
public class IndividualAccountActionsTest {
  static Lib_MockProvider accountRepoMock;
  static void registerMocks() {
    accountRepoMock = Lib_MockProvider.forType(AccountActionsRepository.class);
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
      Label.DCRM_ShellProspectOCVEventVersion
    );
    record.RecordTypeId = RTAccount.personAccount;
    record.FinServ__Status__c = 'Prospect';
    Test.startTest();
    CCRMLeadConversionActions.manualLeadConversionInitiated = true;
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
      Label.DCRM_ShellProspectOCVEventVersion
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

  /**
   * @description test method for setErrorAndRetNonOrgMlRec for ML User
   */
  @isTest
  static void testSetErrorAndRetNonOrgMlRecForMLUser() {
    ID accountId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    ID accountId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    //GIVEN a Opportunity record
    Map<Id, Account> accMap = new Map<Id, Account>{
      accountId1 => (new Account(
        Id = accountId1,
        recordTypeId = RTAccount.businessAccount
      )),
      accountId2 => (new Account(
        Id = accountId2,
        recordTypeId = RTAccount.personAccount
      ))
    };
    Test.startTest();
    // Running as ML user -> Orgnastion Records will be removed\
    Assert.areEqual(
      IndividualAccountActions.setErrorAndRetNonOrgMlRec(
          accMap.values(),
          accMap
        )
        .size(),
      2,
      'setErrorAndRetNonOrgMlRec is not returing correct result for ml user'
    );
    Test.stopTest();
  }
  /**
   * @description test method for setErrorAndRetNonOrgMlRec for non ml user
   */
  @isTest
  static void testSetErrorAndRetNonOrgMlRecForCCRMUser() {
    ID accountId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    ID accountId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    //GIVEN a Opportunity record
    Map<Id, Account> accMap = new Map<Id, Account>{
      accountId1 => (new Account(
        Id = accountId1,
        recordTypeId = RTAccount.businessAccount
      )),
      accountId2 => (new Account(
        Id = accountId2,
        recordTypeId = RTAccount.personAccount
      ))
    };
    Test.startTest();
    // Running as non-ML user -> Orgnastion Records will be kept\
    Assert.areEqual(
      IndividualAccountActions.setErrorAndRetNonOrgMlRec(
          accMap.values(),
          accMap
        )
        .size(),
      2,
      'setErrorAndRetNonOrgMlRec is not returing correct result for non-ml user'
    );
    Test.stopTest();
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
}
