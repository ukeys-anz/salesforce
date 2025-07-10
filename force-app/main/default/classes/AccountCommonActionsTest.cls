/**
 * @author Batya Aisman Sufrin
 * @since 05/2025
 * @description tests for {@link AccountCommonActions}
 */
@isTest
private class AccountCommonActionsTest {
  static Date dob1 = Date.today();
  static Date dob2 = dob1.addDays(1);
  static Date dob3 = dob2.addDays(1);
  static Case caseWithCOBAndPid1 = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBAndPid(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_1,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_1,
    dob1
  );
  static Case caseWithCOBAndPid2 = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBAndPid(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_2,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_2,
    dob2
  );
  static Case caseWithCOBAndPid3 = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBAndPid(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_3,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_3,
    dob3
  );
  static Case caseWithCOBNoPid = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBNoPid(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_NO_PID,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_NO_PID
  );

  static CustomerOnboardingApplication__c cobWithPidAndCase1 = KYCQACustomerLinkingUtilTestHelper.constructCOBWithPidAndCase(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_1,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_1,
    dob1
  );
  static CustomerOnboardingApplication__c cobWithPidAndCase2 = KYCQACustomerLinkingUtilTestHelper.constructCOBWithPidAndCase(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_2,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_2,
    dob2
  );
  static CustomerOnboardingApplication__c cobWithPidAndCase3 = KYCQACustomerLinkingUtilTestHelper.constructCOBWithPidAndCase(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_3,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_3,
    dob3
  );
  // Different DOB to ensure no match
  static CustomerOnboardingApplication__c cobWithPidAndCase3DOBMismatch = KYCQACustomerLinkingUtilTestHelper.constructCOBWithPidAndCase(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_3,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_3,
    dob3.addDays(2)
  );
  static CustomerOnboardingApplication__c cobWithCaseNoPid = KYCQACustomerLinkingUtilTestHelper.constructCOBWithCaseNoPid(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_NO_PID,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_NO_PID
  );
  static CustomerOnboardingApplication__c cobWithPidNoCase = KYCQACustomerLinkingUtilTestHelper.constructCOBWithPidNoCase(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_NO_PID,
    KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_NO_PID,
    dob3.addDays(1)
  );

  static Account acc1 = KYCQACustomerLinkingUtilTestHelper.constructAccount(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_1,
    KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_1,
    dob1,
    true
  );
  static Account acc2 = KYCQACustomerLinkingUtilTestHelper.constructAccount(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_2,
    KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_2,
    dob2,
    true
  );
  static Account acc3 = KYCQACustomerLinkingUtilTestHelper.constructAccount(
    KYCQACustomerLinkingUtilTestHelper.OCV_ID_3,
    KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_3,
    dob3,
    true
  );

  static Lib_MockProvider kycQACustomerLinkingUtilRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    kycQACustomerLinkingUtilRepoMock = Lib_MockProvider.forType(
      KYCQACustomerLinkingUtilRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @IsTest
  static void testSetKYCQACase() {
    Map<Id, CustomerOnboardingApplication__c> cobsMap = new Map<Id, CustomerOnboardingApplication__c>{
      acc1.Id => cobWithPidAndCase1,
      acc2.Id => cobWithPidAndCase2
    };

    Test.startTest();
    List<Case> cases = AccountCommonActions.setKYCQACase(cobsMap);
    Test.stopTest();

    Assert.areEqual(2, cases.size(), 'Should return a case for each account');
    Assert.areEqual(
      acc1.Id,
      cases[0].AccountId,
      'Case should be linked to correct AccountId'
    );
    Assert.areEqual(
      acc2.Id,
      cases[1].AccountId,
      'Case should be linked to correct AccountId'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountNonANZPlus() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByMobileNumberAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2
      }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByOCVIdAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2
      }
    );

    acc1.ANZx_Customer__c = false;
    acc2.ANZx_Customer__c = false;

    Test.startTest();
    AccountCommonActions.linkKYCQACasesToAccount(
      new List<Account>{ acc1, acc2 }
    );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> kycQACases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      0,
      kycQACases.size(),
      '0 records should have been passed on to the doUpdate method'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountANZPlusNoPid() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByMobileNumberAndDOB',
      new List<CustomerOnboardingApplication__c>{ cobWithCaseNoPid }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByOCVIdAndDOB',
      new List<CustomerOnboardingApplication__c>{ cobWithCaseNoPid }
    );

    Test.startTest();
    AccountCommonActions.linkKYCQACasesToAccount(new List<Account>{ acc1 });
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> kycQACases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      0,
      kycQACases.size(),
      '0 records should have been passed as on to the doUpdate method'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountANZPlusNoCase() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByMobileNumberAndDOB',
      new List<CustomerOnboardingApplication__c>{ cobWithPidNoCase }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByOCVIdAndDOB',
      new List<CustomerOnboardingApplication__c>{ cobWithPidNoCase }
    );

    Test.startTest();
    AccountCommonActions.linkKYCQACasesToAccount(new List<Account>{ acc1 });
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> kycQACases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      0,
      kycQACases.size(),
      '0 records should have been passed as on to the doUpdate method'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountANZPlusMatchMobileFirst() {
    registerMocks();
    // Different OCV ID to ensure no match
    cobWithPidAndCase1.OCVId__c =
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_1 + 'Dummy';
    // Using a dummy mobile to ensure no match
    cobWithPidAndCase2.SecurityMobile__c = KYCQACustomerLinkingUtilTestHelper.COB_DUMMY_MOBILE;
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByMobileNumberAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithPidAndCase3DOBMismatch
      }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByOCVIdAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithPidAndCase3DOBMismatch
      }
    );

    Test.startTest();
    AccountCommonActions.linkKYCQACasesToAccount(
      new List<Account>{ acc1, acc2, acc3 }
    );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> kycQACases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      2,
      kycQACases.size(),
      'There should be 2 KYC QA Cases created for ANZx Customers'
    );
    Assert.areEqual(
      acc1.Id,
      kycQACases[0].AccountId,
      'KYC QA Case should be linked to acc1'
    );
    Assert.areEqual(
      acc2.Id,
      kycQACases[1].AccountId,
      'KYC QA Case should be linked to acc2'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountANZPlusMatchOCVFirst() {
    registerMocks();
    // Different OCV ID to ensure no match
    cobWithPidAndCase1.SecurityMobile__c = KYCQACustomerLinkingUtilTestHelper.COB_DUMMY_MOBILE;
    // Using a dummy mobile to ensure no match
    cobWithPidAndCase2.OCVId__c =
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_2 + 'Dummy';
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByMobileNumberAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithPidAndCase3DOBMismatch
      }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByOCVIdAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithPidAndCase3DOBMismatch
      }
    );

    Test.startTest();
    AccountCommonActions.linkKYCQACasesToAccount(
      new List<Account>{ acc1, acc2, acc3 }
    );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> kycQACases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      2,
      kycQACases.size(),
      'There should be 2 KYC QA Cases created for ANZx Customers'
    );
    Assert.areEqual(
      acc2.Id,
      kycQACases[0].AccountId,
      'KYC QA Case should be linked to acc2'
    );
    Assert.areEqual(
      acc1.Id,
      kycQACases[1].AccountId,
      'KYC QA Case should be linked to acc1'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountANZPlusMatchAll() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByMobileNumberAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithPidAndCase3
      }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByOCVIdAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithPidAndCase3
      }
    );

    Account acc1 = KYCQACustomerLinkingUtilTestHelper.constructAccount(
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_1,
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_1,
      dob1,
      true
    );
    Account acc2 = KYCQACustomerLinkingUtilTestHelper.constructAccount(
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_2,
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_2,
      dob2,
      true
    );
    Account acc3 = KYCQACustomerLinkingUtilTestHelper.constructAccount(
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_3,
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_3,
      dob3,
      true
    );
    List<Account> accounts = new List<Account>{ acc1, acc2, acc3 };

    Test.startTest();
    AccountCommonActions.linkKYCQACasesToAccount(accounts);
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> kycQACases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      3,
      kycQACases.size(),
      'There should be 2 KYC QA Cases created for ANZx Customers'
    );
    Assert.areEqual(
      acc1.Id,
      kycQACases[0].AccountId,
      'KYC QA Case should be linked to acc1'
    );
    Assert.areEqual(
      kycQACases[1].AccountId,
      acc2.Id,
      'KYC QA Case should be linked to acc2'
    );
    Assert.areEqual(
      acc3.Id,
      kycQACases[2].AccountId,
      'KYC QA Case should be linked to acc3'
    );
  }
}
