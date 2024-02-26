/**
 * @author Batya Aisman Sufrin
 * @date September 2023
 * @description Test class for {@link AutoKYCQACaseActionsHelper}
 * @group ANZx
 * TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
 */
@isTest
public with sharing class AutoKYCQACaseActionsHelperTest {
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

  @TestSetup
  private static void makeData() {
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    List<Account> personAccounts = new List<Account>();

    for (String mobileNumber : COB_MATCHING_MOBILE_NUMBERS) {
      cobApps.add(createCOBApp(mobileNumber));
    }

    for (String mobileNumber : CUSTOMER_MATCHING_MOBILE_NUMBERS) {
      personAccounts.add(createPersonAccount(mobileNumber));
    }

    //Add COB apps with not matching mobile Numbers
    for (String mobileNumber : COB_NOT_MATCHING_MOBILE_NUMBERS) {
      cobApps.add(createCOBApp(mobileNumber));
    }

    insert cobApps;
    insert personAccounts;

    List<Entitlement> entitlements = CommonUtil.addPersonAccountEntitlements(
      personAccounts,
      GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME,
      GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
    );
    insert entitlements;

    List<Case> cases = new List<Case>();

    // KYC QA Cases
    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      cases.add(
        createCase(
          GetHelpConstants.OPEN_STATUS,
          GetHelpConstants.KYCQA_RT_ID,
          cobApp.Id
        )
      );
    }

    insert cases;
  }

  private static Case createCase(
    String status,
    String recordTypeId,
    Id cobAppId
  ) {
    Case c = new Case();
    c.Status = status;
    c.RecordTypeId = recordTypeId;
    c.CustomerOnboardingApplication__c = cobAppid;
    if (c.recordTypeId == GetHelpConstants.KYCQA_RT_ID) {
      c.OwnerId = COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id;
    }

    return c;
  }

  private static List<Case> getCases(String recordtype) {
    return [
      SELECT
        Id,
        Status,
        OwnerId,
        AccountId,
        ContactId,
        ContactMobile,
        EntitlementId,
        RecordTypeId
      FROM Case
      WHERE RecordTypeId = :recordtype
    ];
  }

  private static CustomerOnboardingApplication__c createCOBApp(
    String mobileNumber
  ) {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
      SecurityMobile__c = mobileNumber
    );

    return cobApp;
  }

  private static Account createPersonAccount(String mobileNumber) {
    Account acc = TestDataFactory.createPersonAccount(
      FAKER.randomString(10),
      false
    );
    acc.PersonMobilePhone = mobileNumber;
    return acc;
  }

  private static List<Account> getPersonAccounts() {
    return [
      SELECT Id, PersonContactId
      FROM Account
      WHERE RecordTypeId = :GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    ];
  }

  @isTest
  private static void testGetMobileByCaseId() {
    List<Case> cases = getCases(GetHelpConstants.KYCQA_RT_ID);

    Test.startTest();
    Map<String, String> mobileByCaseIdMap = AutoKYCQACaseActionsHelper.getMobileByCaseId(
      new Map<Id, Case>(cases).keySet()
    );
    Test.stopTest();

    Integer expectedCaseCount =
      COB_MATCHING_MOBILE_NUMBERS.size() +
      COB_NOT_MATCHING_MOBILE_NUMBERS.size();

    Assert.areEqual(
      expectedCaseCount,
      mobileByCaseIdMap.size(),
      'Should be ' +
        expectedCaseCount +
        ' KYC QA Cases by COB App Mobile numbers'
    );
  }

  @isTest
  private static void testGetMobileByCaseIdEmptyMap() {
    Map<String, String> mobileByCaseIdMap = AutoKYCQACaseActionsHelper.getMobileByCaseId(
      new Set<Id>()
    );

    Assert.isTrue(
      mobileByCaseIdMap.isEmpty(),
      'There should be an empty map of Mobile by Case Id.'
    );
  }

  @isTest
  private static void testGetAccountsByMobile() {
    Test.startTest();
    Map<String, Account> accountsByMobileMap = AutoKYCQACaseActionsHelper.getAccountsByMobile(
      CUSTOMER_MATCHING_MOBILE_NUMBERS
    );
    Test.stopTest();

    Assert.areEqual(
      CUSTOMER_MATCHING_MOBILE_NUMBERS.size(),
      accountsByMobileMap.size(),
      'Should be ' +
        CUSTOMER_MATCHING_MOBILE_NUMBERS.size() +
        ' Accounts matched by Mobile Numbers'
    );
  }

  @isTest
  private static void testGetAccountsByMobileEmptyMap() {
    Map<String, Account> accountByMobileMap = AutoKYCQACaseActionsHelper.getAccountsByMobile(
      new List<String>()
    );

    Assert.isTrue(
      accountByMobileMap.isEmpty(),
      'There should be an empty map of Mobile Phones and Account.'
    );
  }

  @isTest
  private static void testSetMatchingAccountFields() {
    List<Case> cases = getCases(GetHelpConstants.KYCQA_RT_ID);

    List<Account> personAccounts = getPersonAccounts();

    Set<Id> accIds = (new Map<Id, Account>(personAccounts)).keySet();

    Map<Id, Id> accountIdEntitlmentMap = GetHelpCaseActionsHelper.getEntitlements(
      accIds,
      GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
    );

    for (Case c : cases) {
      for (Account matchingAcc : personAccounts) {
        AutoKYCQACaseActionsHelper.setMatchingAccountFields(
          c,
          matchingAcc,
          accountIdEntitlmentMap.get(matchingAcc.Id)
        );

        Assert.areEqual(
          c.AccountId,
          matchingAcc.Id,
          'Case Account Id should be equal to Matching Account Id'
        );

        Assert.areEqual(
          c.ContactId,
          matchingAcc.PersonContactId,
          'Case Contact Id should be equal to Matching Account Person Contact Id'
        );

        Assert.areEqual(
          c.EntitlementId,
          accountIdEntitlmentMap.get(matchingAcc.Id),
          'Case Entitlement Id should be equal to Matching Account Entitlement Id'
        );
      }
    }
  }

  @isTest
  private static void testHandleKYCQACaseNoCustomerClosedStatus() {
    List<Case> oldCases = getCases(GetHelpConstants.KYCQA_RT_ID);

    for (Case oldCase : oldCases) {
      Case newCase = new Case();
      newCase.Status = GetHelpConstants.CLOSED_STATUS;
      AutoKYCQACaseActionsHelper.handleKYCQACaseNoCustomer(newCase, oldCase);

      Assert.areEqual(
        newCase.OwnerId,
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        'Case Owner Id should be equal to ' +
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id
      );
    }
  }

  @isTest
  private static void testHandleKYCQACaseNoCustomerRemainInNoCustomerQueue() {
    List<Case> oldCases = getCases(GetHelpConstants.KYCQA_RT_ID);

    for (Case oldCase : oldCases) {
      Case newCase = new Case();
      oldCase.OwnerId = AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id;
      AutoKYCQACaseActionsHelper.handleKYCQACaseNoCustomer(newCase, oldCase);

      Assert.areEqual(
        newCase.OwnerId,
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        'Case Owner Id should be equal to ' +
        AutoKYCQACaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id
      );
    }
  }

  @isTest
  private static void testGetKYCQACasesWithoutCustomer() {
    List<Case> cases = getCases(GetHelpConstants.KYCQA_RT_ID);

    List<Case> casesWithNoCustomer = AutoKYCQACaseActionsHelper.getKYCQACasesWithoutCustomer(
      cases
    );

    Assert.areEqual(
      COB_NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoCustomer.size(),
      'Should be ' +
        COB_NOT_MATCHING_MOBILE_NUMBERS.size() +
        ' KYC QA Cases by with No Customer'
    );
  }
}
