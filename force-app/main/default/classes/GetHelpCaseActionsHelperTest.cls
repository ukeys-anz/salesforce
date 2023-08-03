/**
 * @author Batya Aisman Sufrin
 * @date February 2023
 * @description Test class for {@link GetHelpCaseAcctionsHelper}
 * @group ANZx
 */
@isTest
public with sharing class GetHelpCaseActionsHelperTest {
  private static final Faker FAKER = new Faker('AU');
  private static final List<String> COB_CLOSED_STATUSES = new List<String>{
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
    GetHelpConstants.COB_FAILED_OK_STATUS
  };

  private static final Integer COB_CASES_COUNT = COB_CLOSED_STATUSES.size();

  private static final String FAILED_REASON = 'Selfie fail - selfie image is not clear enough to match';

  private static final String EMPTY_FAILED_REASON = '';

  private static final List<String> COB_MOBILE_NUMBERS = new List<String>{
    '61412121212',
    '61413131313',
    '61415151515'
  };

  private static final List<String> CUSTOMER_MOBILE_NUMBERS = new List<String>{
    '+61412121212',
    '+61413131313',
    '+61415151515'
  };

  @TestSetup
  private static void makeData() {
    makeCOBData();
  }

  private static void makeCOBData() {
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    List<Account> personAccounts = new List<Account>();

    for (String mobileNumber : COB_MOBILE_NUMBERS) {
      cobApps.add(createCOBApp(mobileNumber));
    }

    for (String mobileNumber : CUSTOMER_MOBILE_NUMBERS) {
      personAccounts.add(createPersonAccount(mobileNumber));
    }

    //Add COB app with null mobile Number
    cobApps.add(createCOBApp(null));

    insert cobApps;
    insert personAccounts;

    List<Entitlement> entitlements = CommonUtil.addPersonAccountEntitlements(
      personAccounts,
      GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME,
      GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
    );
    insert entitlements;

    List<Case> cases = new List<Case>();

    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      // ID Ops Assistance Cases
      cases.add(
        createCase(
          GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
          GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
          null
        )
      );

      //Fraud Check Cases
      cases.add(
        createCase(
          COB_CLOSED_STATUSES[i],
          GetHelpConstants.FRAUD_CHECK_RT_ID,
          null
        )
      );
    }

    // KYC QA Cases
    for (Integer i = 0; i < cobApps.size(); i++) {
      cases.add(
        createCase(
          GetHelpConstants.OPEN_STATUS,
          GetHelpConstants.KYCQA_RT_ID,
          cobApps.get(i).Id
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
        EntitlementId
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

  private static List<Account> getPersonAccounts() {
    return [
      SELECT Id, PersonContactId
      FROM Account
      WHERE RecordTypeId = :GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    ];
  }

  @isTest
  private static void testIsStatusChanged() {
    Case oldRecord = createCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      null
    );

    Case newRecord = createCase(
      GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      null
    );

    Boolean isStatusChanged = GetHelpCaseActionsHelper.isStatusChanged(
      newRecord,
      oldRecord
    );

    Assert.isTrue(isStatusChanged);
  }

  @isTest
  private static void testGetCasesByIds() {
    List<Case> caseRecords = getCases(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Set<Id> caseIds = new Set<Id>();
    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      caseIds.add(caseRecords[i].Id);
    }

    Test.startTest();
    List<Case> casesByIds = GetHelpCaseActionsHelper.getCasesByIds(caseIds);
    Test.stopTest();

    Assert.areEqual(
      COB_CASES_COUNT,
      casesByIds.size(),
      'There should be ' +
      COB_CASES_COUNT +
      ' cases.'
    );
  }

  @isTest
  private static void testGetCasesByIdsEmptySet() {
    List<Case> casesByIds = GetHelpCaseActionsHelper.getCasesByIds(
      new Set<Id>()
    );

    Assert.isTrue(
      casesByIds.isEmpty(),
      'There should be an empty list of cases.'
    );
  }

  @isTest
  private static void testSetIDOpsCaseStatus() {
    Map<Id, Case> parentIdAndChildCasesMap = setFraudCheckStatuses();

    List<Case> updatedIdOpsCases = GetHelpCaseActionsHelper.setIDOpsCaseStatus(
      parentIdAndChildCasesMap
    );

    assert(updatedIdOpsCases);
  }

  private static Map<Id, Case> setFraudCheckStatuses() {
    List<Case> idOpsCases = getCases(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    List<Case> fraudCheckCases = getCases(GetHelpConstants.FRAUD_CHECK_RT_ID);

    Map<Id, Case> parentIdAndChildCasedMap = new Map<Id, Case>();

    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      Case idOpsCase = idOpsCases[i];
      Case fraudCheckCase = fraudCheckCases[i];

      fraudCheckCase.ParentId = idOpsCase.Id;
      fraudCheckCase.OnboardingVerificationFailedReason__c = fraudCheckCase.Status ==
        GetHelpConstants.COB_FAILED_OK_STATUS
        ? FAILED_REASON
        : EMPTY_FAILED_REASON;

      parentIdAndChildCasedMap.put(idOpsCase.Id, fraudCheckCase);
    }

    return parentIdAndChildCasedMap;
  }

  private static void assert(List<Case> updatedIdOpsCases) {
    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      Assert.areEqual(
        COB_CLOSED_STATUSES[i],
        updatedIdOpsCases[i].Status,
        'Status should be ' + COB_CLOSED_STATUSES[i]
      );

      if (COB_CLOSED_STATUSES[i] == GetHelpConstants.COB_FAILED_OK_STATUS) {
        Assert.areEqual(
          FAILED_REASON,
          updatedIdOpsCases[i].OnboardingVerificationFailedReason__c,
          'Failed reasons should be ' + FAILED_REASON
        );
      }
    }
  }

  @isTest
  private static void testSetIDOpsCaseStatusEmptyMap() {
    List<Case> updatedIdOpsCases = GetHelpCaseActionsHelper.setIDOpsCaseStatus(
      new Map<Id, Case>()
    );

    Assert.isTrue(
      updatedIdOpsCases.isEmpty(),
      'There should be an empty list of cases.'
    );
  }

  @isTest
  private static void testGetMobileByCaseId() {
    List<Case> cases = getCases(GetHelpConstants.KYCQA_RT_ID);

    Test.startTest();
    Map<String, String> mobileByCaseIdMap = GetHelpCaseActionsHelper.getMobileByCaseId(
      new Map<Id, Case>(cases).keySet()
    );
    Test.stopTest();

    Assert.areEqual(
      COB_MOBILE_NUMBERS.size() + 1,
      cases.size(),
      'Should be ' +
      (COB_MOBILE_NUMBERS.size() + 1) +
      '  KYC QA Cases total'
    );

    Assert.areEqual(
      COB_MOBILE_NUMBERS.size(),
      mobileByCaseIdMap.size(),
      'Should be ' +
      COB_MOBILE_NUMBERS.size() +
      ' KYC QA Cases by COB App Mobile numbers'
    );
  }

  @isTest
  private static void testGetMobileByCaseIdEmptyMap() {
    Map<String, String> mobileByCaseIdMap = GetHelpCaseActionsHelper.getMobileByCaseId(
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
    Map<String, Account> accountsByMobileMap = GetHelpCaseActionsHelper.getAccountsByMobile(
      CUSTOMER_MOBILE_NUMBERS
    );
    Test.stopTest();

    Assert.areEqual(
      CUSTOMER_MOBILE_NUMBERS.size(),
      accountsByMobileMap.size(),
      'Should be ' +
      CUSTOMER_MOBILE_NUMBERS.size() +
      ' Accounts matched by Mobile Numbers'
    );
  }

  @isTest
  private static void testGetAccountsByMobileEmptyMap() {
    Map<String, Account> accountByMobileMap = GetHelpCaseActionsHelper.getAccountsByMobile(
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
        GetHelpCaseActionsHelper.setMatchingAccountFields(
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
      GetHelpCaseActionsHelper.handleKYCQACaseNoCustomer(newCase, oldCase);

      Assert.areEqual(
        newCase.OwnerId,
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        'Case Owner Id should be equal to ' +
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id
      );
    }
  }

  @isTest
  private static void testHandleKYCQACaseNoCustomerRemainInNoCustomerQueue() {
    List<Case> oldCases = getCases(GetHelpConstants.KYCQA_RT_ID);

    for (Case oldCase : oldCases) {
      Case newCase = new Case();
      oldCase.OwnerId = GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id;
      GetHelpCaseActionsHelper.handleKYCQACaseNoCustomer(newCase, oldCase);

      Assert.areEqual(
        newCase.OwnerId,
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        'Case Owner Id should be equal to ' +
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id
      );
    }
  }
}
