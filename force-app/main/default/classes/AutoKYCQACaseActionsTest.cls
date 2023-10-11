@IsTest
public with sharing class AutoKYCQACaseActionsTest {
  private static final Faker FAKER = new Faker('AU');
  private static final String MOBILE1 = '61412121212';
  private static final String MOBILE2 = '61413131313';
  private static final String MOBILE3 = '61415151515';

  private static final List<String> COB_MATCHING_MOBILE_NUMBERS = new List<String>{
    MOBILE1,
    MOBILE2,
    MOBILE3
  };

  private static final List<String> CUSTOMER_MATCHING_MOBILE_NUMBERS = new List<String>{
    '+' + MOBILE1,
    '+' + MOBILE2,
    '+' + MOBILE3
  };

  private static final List<String> COB_NOT_MATCHING_MOBILE_NUMBERS = new List<String>{
    '61499999999',
    '61488888888'
  };

  private static final List<String> CUSTOMER_NOT_MATCHING_MOBILE_NUMBERS = new List<String>{
    '+61422222222',
    '+61433333333'
  };

  @TestSetup
  static void setup() {
    // Insert Account & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      // Create a FraudX User with 'FraudX Agent' role
      Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
      UserRole role = CommonUtil.getUserRoleByDevName('FraudX_Agent');
      User fraudXAgent = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'FraudXTest',
          'ProfileId' => profile.Id,
          'UserRoleId' => role.Id
        }
      );
      insert fraudXAgent;

      // Assign related PSs
      List<String> fraudXPSs = new List<String>{
        'Case_Read_Write_Fraud_Agent',
        'Customer_Read_Only',
        'Case_Read_Write_Customer_Onboarding'
      };
      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :fraudXPSs
      ];

      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(fraudXAgent.Id, ps.Id));
      }
      insert psaList;

      List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
      List<Account> personAccsWithMobile = new List<Account>();
      for (String mobileNumber : COB_MATCHING_MOBILE_NUMBERS) {
        cobApps.add(createCOBApp(mobileNumber));
      }

      for (String mobileNumber : CUSTOMER_MATCHING_MOBILE_NUMBERS) {
        personAccsWithMobile.add(createPersonAccount(mobileNumber));
      }

      //Add COB apps with not matching mobile Numbers
      for (String mobileNumber : COB_NOT_MATCHING_MOBILE_NUMBERS) {
        cobApps.add(createCOBApp(mobileNumber));
      }

      // Add person Accounts to be linked to cases with no COB
      List<Account> personAccountsForCasesWithNoCOB = new List<Account>();
      for (String mobileNumber : CUSTOMER_NOT_MATCHING_MOBILE_NUMBERS) {
        personAccountsForCasesWithNoCOB.add(createPersonAccount(mobileNumber));
      }

      personAccsWithMobile.addAll(personAccountsForCasesWithNoCOB);

      insert cobApps;
      insert personAccsWithMobile;

      List<Entitlement> entitlements = CommonUtil.addPersonAccountEntitlements(
        personAccsWithMobile,
        GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME,
        GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
      );
      insert entitlements;
    }
  }

  private static CustomerOnboardingApplication__c createCOBApp(
    String mobileNumber
  ) {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
      SecurityMobile__c = mobileNumber
    );

    return cobApp;
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [SELECT Id, SecurityMobile__c FROM CustomerOnboardingApplication__c];
  }

  private static Case createKYCQACase(Id cobAppId, Id caseOwnerId) {
    Case c = new Case(
      Status = GetHelpConstants.OPEN_STATUS,
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      CustomerOnboardingApplication__c = cobAppid,
      OwnerId = caseOwnerId
    );

    return c;
  }

  private static List<Case> getKYCQACases() {
    return [
      SELECT Id, AccountId, ContactId, ContactMobile, EntitlementId
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
    ];
  }

  private static List<Case> getCasesLinkedWithAccount() {
    return [
      SELECT Id, AccountId, ContactId, ContactMobile, EntitlementId
      FROM Case
      WHERE AccountId != NULL AND ContactId != NULL AND EntitlementId != NULL
    ];
  }

  private static List<Case> getCasesWithNoAccount() {
    return [SELECT Id, OwnerId FROM Case WHERE AccountId = NULL];
  }

  private static List<Case> getCasesWithAccountNoCOB() {
    return [
      SELECT Id, OwnerId
      FROM Case
      WHERE AccountId != NULL AND CustomerOnboardingApplication__c = NULL
    ];
  }

  private static Account createPersonAccount(String mobileNumber) {
    Account acc = new Account(
      FirstName = FAKER.person.firstName(),
      LastName = FAKER.person.lastName(),
      OCV_ID__c = FAKER.randomString(10),
      PersonMobilePhone = mobileNumber,
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );

    return acc;
  }

  private static List<Account> getPersonAccountByMobile(
    List<String> mobilePhones
  ) {
    return [SELECT Id FROM Account WHERE PersonMobilePhone IN :mobilePhones];
  }

  private static List<Case> createKYCQACases(Id caseOwnerId) {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();

    List<Case> kycQACases = new List<Case>();
    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      kycQACases.add(createKYCQACase(cobApp.Id, caseOwnerId));
    }

    insert kycQACases;
    return kycQACases;
  }

  private static List<Case> createKYCQACasesWithAccountNoCOB(Id caseOwnerId) {
    List<Account> accs = getPersonAccountByMobile(
      CUSTOMER_NOT_MATCHING_MOBILE_NUMBERS
    );

    List<Case> kycQACases = new List<Case>();
    for (Account acc : accs) {
      Case c = createKYCQACase(null, caseOwnerId);
      c.AccountId = acc.Id;
      kycQACases.add(c);
    }

    insert kycQACases;
    return kycQACases;
  }

  private static List<Case> createKYCQACasesWithAccountAndCOB(Id caseOwnerId) {
    List<Account> accs = getPersonAccountByMobile(
      CUSTOMER_MATCHING_MOBILE_NUMBERS
    );

    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();

    List<Case> kycQACases = new List<Case>();
    for (Integer i = 0; i < accs.size(); i++) {
      Case c = createKYCQACase(cobApps[i].id, caseOwnerId);
      c.AccountId = accs[i].Id;
      kycQACases.add(c);
    }

    insert kycQACases;
    return kycQACases;
  }

  @isTest
  static void testLinkKYCQACasesToAccountChangeOwnership() {
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACases(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change owner
    for (Case kycQACase : kycQACases) {
      kycQACase.OwnerId = usr.Id;
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will be linked with Matched Person Accounts
    List<Case> casesLinkedWithAccount = getCasesLinkedWithAccount();

    Assert.areEqual(
      COB_MATCHING_MOBILE_NUMBERS.size(),
      casesLinkedWithAccount.size(),
      'Should be ' +
      COB_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      COB_NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      COB_NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with no Matched Person Accounts'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountChangeDescription() {
    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACases(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change Description
    for (Case kycQACase : kycQACases) {
      kycQACase.Description = 'Test';
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will be linked with Matched Person Accounts
    List<Case> casesLinkedWithAccount = getCasesLinkedWithAccount();

    Assert.areEqual(
      COB_MATCHING_MOBILE_NUMBERS.size(),
      casesLinkedWithAccount.size(),
      'Should be ' +
      COB_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      COB_NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      COB_NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountNoCustomerCaseClosed() {
    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACases(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change Status to CLOSED
    for (Case kycQACase : kycQACases) {
      kycQACase.Status = GetHelpConstants.CLOSED_STATUS;
      kycQACase.Sub_Status__c = 'No Defect';
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will be linked with Matched Person Accounts
    List<Case> casesLinkedWithAccount = getCasesLinkedWithAccount();

    Assert.areEqual(
      COB_MATCHING_MOBILE_NUMBERS.size(),
      casesLinkedWithAccount.size(),
      'Should be ' +
      COB_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      COB_NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      COB_NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will be moved to Pending KYC QA - No Customer Queue
    for (Case c : casesWithNoAccount) {
      Assert.areEqual(
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        c.OwnerId,
        'KYC QA Cases should move to ' +
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id +
        'queue'
      );
    }
  }

  @isTest
  static void testLinkKYCQACasesToAccountNoCustomerChangeOwnerInNoCustomerQueue() {
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // GIVEN KYC Case in Pending KYC QA - No Customer Queue
    List<Case> kycQACases = createKYCQACases(
      AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id
    );

    // WHEN Attempt Changing owner
    for (Case kycQACase : kycQACases) {
      kycQACase.OwnerId = usr.Id;
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      COB_NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      COB_NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will remain in Pending KYC QA - No Customer Queue
    for (Case c : casesWithNoAccount) {
      Assert.areEqual(
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        c.OwnerId,
        'KYC QA Cases should remain in ' +
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id +
        'queue'
      );
    }
  }

  @isTest
  static void testLinkKYCQACasesToAccountWithCustomerCaseClosed() {
    User usr = TestUtil.getUserByFirstName('FraudXTest');
    // GIVEN KYC Case in Pending KYC QA Queue with Customer and no COB
    List<Case> kycQACases = createKYCQACasesWithAccountNoCOB(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change Status to CLOSED
    for (Case kycQACase : kycQACases) {
      kycQACase.OwnerId = usr.Id;
      kycQACase.Status = GetHelpConstants.CLOSED_STATUS;
      kycQACase.Sub_Status__c = 'No Defect';
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will not be re-linked
    List<Case> casesWithAccountNoCOB = getCasesWithAccountNoCOB();

    Assert.areEqual(
      CUSTOMER_NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithAccountNoCOB.size(),
      'Should be ' +
      CUSTOMER_NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will remain with the case owner that closed the case
    for (Case c : casesWithAccountNoCOB) {
      Assert.areEqual(
        usr.Id,
        c.OwnerId,
        'KYC QA Cases should remain with the case owner that closed the case: ' +
        usr.id
      );
    }
  }

  @isTest
  static void testValidateKYCQACasesInOpenedStatusChangeOwnerToNoCstomerQueue() {
    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACases(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change owner to Pending KYC QA - No Customer Queue
    for (Case kycQACase : kycQACases) {
      kycQACase.OwnerId = AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id;
    }

    // THEN KYC QA Cases should remain with the initial owner
    Test.startTest();
    try {
      update kycQACases;
      Assert.fail(
        'Open KYC QA case shouldn\'t be allowed to move to Pending KYC QA - No Customer Queue.'
      );
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage()
          .contains(AutoKYCQACaseActions.CANT_MOVE_NOT_CLOSED_CASE)
        ? true
        : false;
      Assert.isTrue(
        expectedExceptionThrown,
        'Error should have been set on OwnerId field'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testValidateKYCQACasesInClosedStatusWithLinkedCustomerChangeOwnerToNoCstomerQueue() {
    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACasesWithAccountAndCOB(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change owner to Pending KYC QA - No Customer Queue
    for (Case kycQACase : kycQACases) {
      kycQACase.OwnerId = AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id;
    }

    // THEN KYC QA Cases should remain with the initial owner
    Test.startTest();
    try {
      update kycQACases;
      Assert.fail(
        'Open KYC QA case shouldn\'t be allowed to move to Pending KYC QA - No Customer Queue.'
      );
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage()
          .contains(AutoKYCQACaseActions.CANT_MOVE_NOT_CLOSED_CASE)
        ? true
        : false;
      Assert.isTrue(
        expectedExceptionThrown,
        'Error should have been set on OwnerId field'
      );
    }
    Test.stopTest();
  }
}
