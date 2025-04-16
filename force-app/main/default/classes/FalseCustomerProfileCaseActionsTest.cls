/**
 * @author Batya Aisman Sufrin
 * @since 03/2025
 * @description tests for {@link FalseCustomerProfileCaseActions}
 */
@isTest
private class FalseCustomerProfileCaseActionsTest {
  static final Faker FAKER = new Faker('AU');
  static final String PERSON_ACCOUNT_NAME_1 = 'Person Account 1';
  static final String PID_FIRST_NAME_1 = 'John';
  static final String PID_MIDDLE_NAME_1 = 'Michael';
  static final String PID_LAST_NAME_1 = 'Doe';
  static final String PID_FULL_NAME_1 = String.join(
    new List<String>{ PID_FIRST_NAME_1, PID_MIDDLE_NAME_1, PID_LAST_NAME_1 },
    ' '
  );

  static Id personAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  static Account personAcc = new Account(
    Id = personAccId,
    Name = PERSON_ACCOUNT_NAME_1,
    RecordTypeId = RTAccount.personAccount
  );

  static Case fcpCase = new Case(RecordTypeId = RTCase.falseCustomerProfile);

  static CustomerOnboardingApplication__c cobWithPID = (CustomerOnboardingApplication__c) TestUtil.setFields(
    new CustomerOnboardingApplication__c(
      Id = Lib_FakeIdGenerator.getMockId(
        CustomerOnboardingApplication__c.SObjectType
      )
    ),
    new Map<String, Object>{
      'COBPrimaryIDDocuments__r' => new List<COBPrimaryIDDocument__c>{
        new COBPrimaryIDDocument__c(
          FirstName__c = PID_FIRST_NAME_1,
          MiddleNames__c = PID_MIDDLE_NAME_1,
          LastName__c = PID_LAST_NAME_1
        )
      }
    }
  );

  static Lib_MockProvider fcpCaseRepoMock;

  static void registerMocks() {
    fcpCaseRepoMock = Lib_MockProvider.forType(
      FalseCustomerProfileCaseRepository.class
    );
  }

  @isTest
  static void testPopulateFalseCustomerProfileCaseBasedOnCOBNewCase() {
    // GIVEN: A new Case with a Valid Person Account and COB
    registerMocks();
    fcpCaseRepoMock.mock(
      'queryCobsWithPIDByIds',
      new List<CustomerOnboardingApplication__c>{ cobWithPID }
    );
    fcpCase.CustomerOnboardingApplication__c = cobWithPID.Id;
    fcpCase.AccountId = personAccId;

    // WHEN we populate the False Customer Profile Case
    Test.startTest();
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnCOB(
      new List<Case>{ fcpCase },
      new Map<Id, Case>{}
    );
    Test.stopTest();

    // THEN the Case fields should be populated
    Assert.areEqual(
      PID_FULL_NAME_1,
      fcpCase.Fraud_Onboarding_Customer_Name__c,
      'Case.Fraud_Onboarding_Customer_Name__c should be equal to PID Name.'
    );
  }

  @isTest
  static void testPopulateFalseCustomerProfileCaseBasedOnCOBUpdatedCase() {
    // GIVEN: An existing Case with a Valid Person Account and changed COB
    registerMocks();
    fcpCaseRepoMock.mock(
      'queryCobsWithPIDByIds',
      new List<CustomerOnboardingApplication__c>{ cobWithPID }
    );
    fcpCase.CustomerOnboardingApplication__c = cobWithPID.Id;
    fcpCase.AccountId = personAccId;

    // WHEN we populate the False Customer Profile Case
    Test.startTest();
    Case oldFcpCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.falseCustomerProfile
    );
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnCOB(
      new List<Case>{ fcpCase },
      new Map<Id, Case>{ oldFcpCase.Id => oldFcpCase }
    );
    Test.stopTest();

    // THEN the Case fields should be populated
    Assert.areEqual(
      PID_FULL_NAME_1,
      fcpCase.Fraud_Onboarding_Customer_Name__c,
      'Case.Fraud_Onboarding_Customer_Name__c should be equal to PID Name.'
    );
  }

  @isTest
  static void testPopulateFalseCustomerProfileCaseBasedOnAccountNewCase() {
    // GIVEN: A new Case with a Valid Person Account and no COB
    registerMocks();
    fcpCaseRepoMock.mock('queryAccountsByIds', new List<Account>{ personAcc });
    fcpCase.CustomerOnboardingApplication__c = null;
    fcpCase.AccountId = personAccId;

    // WHEN we populate the False Customer Profile Case
    Test.startTest();
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnAccount(
      new List<Case>{ fcpCase },
      new Map<Id, Case>{}
    );
    Test.stopTest();

    // THEN the Case fields should be populated
    Assert.areEqual(
      PERSON_ACCOUNT_NAME_1,
      fcpCase.Fraud_Onboarding_Customer_Name__c,
      'Case.Fraud_Onboarding_Customer_Name__c should be equal to Account Name.'
    );
  }

  @isTest
  static void testPopulateFalseCustomerProfileCaseBasedOnAccountUpdatedCase() {
    // GIVEN: An existing Case with a changed Valid Person Account and no COB
    registerMocks();
    fcpCaseRepoMock.mock('queryAccountsByIds', new List<Account>{ personAcc });
    fcpCase.CustomerOnboardingApplication__c = null;
    fcpCase.AccountId = personAccId;

    // WHEN we populate the False Customer Profile Case
    Test.startTest();
    Case oldFcpCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.falseCustomerProfile
    );
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseBasedOnAccount(
      new List<Case>{ fcpCase },
      new Map<Id, Case>{ oldFcpCase.Id => oldFcpCase }
    );
    Test.stopTest();

    // THEN the Case fields should be populated
    Assert.areEqual(
      PERSON_ACCOUNT_NAME_1,
      fcpCase.Fraud_Onboarding_Customer_Name__c,
      'Case.Fraud_Onboarding_Customer_Name__c should be equal to Account Name.'
    );
  }

  @isTest
  static void testSetFraudOnboardingCustomerNameFromPID() {
    // GIVEN: A Case with COB
    fcpCase.CustomerOnboardingApplication__c = cobWithPID.Id;

    // WHEN we set the Fraud Onboarding Customer Name from the PID
    Test.startTest();
    FalseCustomerProfileCaseActions.setFraudOnboardingCustomerNameFromPID(
      new List<Case>{ fcpCase },
      new List<CustomerOnboardingApplication__c>{ cobWithPID }
    );
    Test.stopTest();

    // THEN the Fraud Onboarding Customer Name should be set to the PID name
    Assert.areEqual(
      PID_FULL_NAME_1,
      fcpCase.Fraud_Onboarding_Customer_Name__c,
      'Case.Fraud_Onboarding_Customer_Name__c should be set to the PID name.'
    );
  }

  @isTest
  static void testSetFraudOnboardingCustomerNameFromAccount() {
    // GIVEN: A Case with a Valid Person Account
    fcpCase.AccountId = personAccId;

    // WHEN we set the Fraud Onboarding Customer Name from the Account
    Test.startTest();
    FalseCustomerProfileCaseActions.setFraudOnboardingCustomerNameFromAccount(
      new List<Case>{ fcpCase },
      new List<Account>{ personAcc }
    );
    Test.stopTest();

    // THEN the Fraud Onboarding Customer Name should be set to the Person Account name
    Assert.areEqual(
      PERSON_ACCOUNT_NAME_1,
      fcpCase.Fraud_Onboarding_Customer_Name__c,
      'Case.Fraud_Onboarding_Customer_Name__c should be set to the Person Account name.'
    );
  }

  @isTest
  static void testPopulateFalseCustomerProfileCaseSubject() {
    // WHEN we populate the False Customer Profile Case Subject
    Test.startTest();
    FalseCustomerProfileCaseActions.populateFalseCustomerProfileCaseSubject(
      new List<Case>{ fcpCase }
    );
    Test.stopTest();
    // THEN the Case Subject should be 'False Onboarding'
    Assert.areEqual(
      FalseCustomerProfileCaseActions.FALSE_CUSTOMER_PROFILE_CASE_SUBJECT,
      fcpCase.Subject,
      'Case Subject should be ' +
      FalseCustomerProfileCaseActions.FALSE_CUSTOMER_PROFILE_CASE_SUBJECT
    );
  }
}
