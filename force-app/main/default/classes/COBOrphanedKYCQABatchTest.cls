/**
 * @author shawg2
 * @since January 2024
 * @description Test COBOrphanedKYCQABatch class
 */

@IsTest
private class COBOrphanedKYCQABatchTest {
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
    Map<Id, Account> accsMap = new Map<Id, Account>{
      caseWithCOBAndPid1.CustomerOnboardingApplication__c => acc1,
      caseWithCOBAndPid2.CustomerOnboardingApplication__c => acc2
    };

    Test.startTest();
    COBOrphanedKYCQABatch.setKYCQACase(
      new List<Case>{ caseWithCOBAndPid1, caseWithCOBAndPid2 },
      accsMap
    );
    Test.stopTest();

    Assert.areEqual(
      acc1.Id,
      caseWithCOBAndPid1.AccountId,
      'AccountId for Case with COB and PID 1 should match Account 1'
    );
    Assert.areEqual(
      acc2.Id,
      caseWithCOBAndPid2.AccountId,
      'AccountId for Case with COB and PID 2 should match Account 2'
    );
  }

  @IsTest
  static void testExecuteNoPid() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobByIds',
      new List<CustomerOnboardingApplication__c>{
        caseWithCOBNoPid.CustomerOnboardingApplication__r
      }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByMobileNumberAndDOB',
      new List<Account>{}
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByOCVIdAndDOB',
      new List<Account>{}
    );

    Test.startTest();
    (new COBOrphanedKYCQABatch())
      .execute(null, new List<Case>{ caseWithCOBNoPid });
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> casesToUpdate = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      0,
      casesToUpdate.size(),
      '0 records should have been passed on to the doUpdate method'
    );
  }

  @isTest
  static void testExecuteMatchMobileFirst() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobByIds',
      new List<CustomerOnboardingApplication__c>{
        caseWithCOBAndPid1.CustomerOnboardingApplication__r,
        caseWithCOBAndPid2.CustomerOnboardingApplication__r,
        caseWithCOBAndPid3.CustomerOnboardingApplication__r
      }
    );

    // Different OCV ID to ensure no match
    acc1.OCV_ID__c = KYCQACustomerLinkingUtilTestHelper.OCV_ID_1 + 'Dummy';
    // Different mobile to ensure no match
    acc2.PersonMobilePhone = KYCQACustomerLinkingUtilTestHelper.ACCOUNT_DUMMY_MOBILE;
    // Different DOB to ensure no match
    acc3.PersonBirthdate = dob3.addDays(2);
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByMobileNumberAndDOB',
      new List<Account>{ acc1, acc2, acc3 }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByOCVIdAndDOB',
      new List<Account>{ acc1, acc2, acc3 }
    );

    Test.startTest();
    (new COBOrphanedKYCQABatch())
      .execute(
        null,
        new List<Case>{
          caseWithCOBAndPid1,
          caseWithCOBAndPid2,
          caseWithCOBAndPid3
        }
      );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> casesToUpdate = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      2,
      casesToUpdate.size(),
      '2 records should have been passed on to the doUpdate method'
    );
    Assert.areEqual(
      acc1.Id,
      casesToUpdate[0].AccountId,
      'KYC QA Case should be linked to acc1'
    );
    Assert.areEqual(
      acc2.Id,
      casesToUpdate[1].AccountId,
      'KYC QA Case should be linked to acc2'
    );
  }

  @isTest
  static void testExecuteMatchOCVFirst() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobByIds',
      new List<CustomerOnboardingApplication__c>{
        caseWithCOBAndPid1.CustomerOnboardingApplication__r,
        caseWithCOBAndPid2.CustomerOnboardingApplication__r,
        caseWithCOBAndPid3.CustomerOnboardingApplication__r
      }
    );

    // Different mobile to ensure no match
    acc1.PersonMobilePhone = KYCQACustomerLinkingUtilTestHelper.ACCOUNT_DUMMY_MOBILE;
    // Different OCV ID to ensure no match
    acc2.OCV_ID__c = KYCQACustomerLinkingUtilTestHelper.OCV_ID_2 + 'Dummy';
    // Different DOB to ensure no match
    acc3.PersonBirthdate = dob3.addDays(2);

    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByMobileNumberAndDOB',
      new List<Account>{ acc1, acc2, acc3 }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByOCVIdAndDOB',
      new List<Account>{ acc1, acc2, acc3 }
    );

    Test.startTest();
    (new COBOrphanedKYCQABatch())
      .execute(
        null,
        new List<Case>{
          caseWithCOBAndPid1,
          caseWithCOBAndPid2,
          caseWithCOBAndPid3
        }
      );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> casesToUpdate = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      2,
      casesToUpdate.size(),
      '2 records should have been passed on to the doUpdate method'
    );
    Assert.areEqual(
      acc1.Id,
      casesToUpdate[0].AccountId,
      'KYC QA Case should be linked to acc1'
    );
    Assert.areEqual(
      acc2.Id,
      casesToUpdate[1].AccountId,
      'KYC QA Case should be linked to acc2'
    );
  }

  @isTest
  static void testExecuteMatchAll() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobByIds',
      new List<CustomerOnboardingApplication__c>{
        caseWithCOBAndPid1.CustomerOnboardingApplication__r,
        caseWithCOBAndPid2.CustomerOnboardingApplication__r,
        caseWithCOBAndPid3.CustomerOnboardingApplication__r
      }
    );

    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByMobileNumberAndDOB',
      new List<Account>{ acc1, acc2, acc3 }
    );
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByOCVIdAndDOB',
      new List<Account>{ acc1, acc2, acc3 }
    );

    Test.startTest();
    (new COBOrphanedKYCQABatch())
      .execute(
        null,
        new List<Case>{
          caseWithCOBAndPid1,
          caseWithCOBAndPid2,
          caseWithCOBAndPid3
        }
      );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called.'
    );
    List<Case> casesToUpdate = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      3,
      casesToUpdate.size(),
      '3 records should have been passed on to the doUpdate method'
    );
    Assert.areEqual(
      acc1.Id,
      casesToUpdate[0].AccountId,
      'KYC QA Case should be linked to acc1'
    );
    Assert.areEqual(
      acc2.Id,
      casesToUpdate[1].AccountId,
      'KYC QA Case should be linked to acc2'
    );
    Assert.areEqual(
      acc3.Id,
      casesToUpdate[2].AccountId,
      'KYC QA Case should be linked to acc3'
    );
  }
}
