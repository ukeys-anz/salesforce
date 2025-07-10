/**
 * @author Batya Aisman Sufrin
 * @since 05/2025
 * @description tests for {@link KYCQACustomerLinkingUtil}
 */
@isTest
private class KYCQACustomerLinkingUtilTest {
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
  static Case caseWithCOBAndNoPid = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBNoPid(
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

  static void registerMocks() {
    kycQACustomerLinkingUtilRepoMock = Lib_MockProvider.forType(
      KYCQACustomerLinkingUtilRepository.class
    );
  }

  @IsTest
  static void testGetAccountsByOCVIdAndDOB() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobByIds',
      new List<CustomerOnboardingApplication__c>{
        caseWithCOBAndPid1.CustomerOnboardingApplication__r,
        caseWithCOBAndPid2.CustomerOnboardingApplication__r,
        caseWithCOBAndNoPid.CustomerOnboardingApplication__r
      }
    );

    // Different DOB to ensure no match
    acc2.PersonBirthdate = dob2.addDays(2);
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByOCVIdAndDOB',
      new List<Account>{ acc1, acc2 }
    );

    Test.startTest();
    Map<Id, Account> cobIdToAccountMap = KYCQACustomerLinkingUtil.getAccountsByOCVIdAndDOB(
      new List<Case>{
        caseWithCOBAndPid1,
        caseWithCOBAndPid2,
        caseWithCOBAndNoPid
      }
    );
    Test.stopTest();

    Assert.isFalse(
      kycQACustomerLinkingUtilRepoMock.getHistories('queryCobByIds').isEmpty(),
      'queryCobByIds should have been called.'
    );
    Set<Id> cobIds = (Set<Id>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryCobByIds'
      )
      .getParam('cobIds');
    Assert.areEqual(
      3,
      cobIds.size(),
      '3 cobIds should have been passed on to the queryCobByIds method'
    );

    Assert.isFalse(
      kycQACustomerLinkingUtilRepoMock.getHistories(
          'queryAccountsByOCVIdAndDOB'
        )
        .isEmpty(),
      'queryAccountsByOCVIdAndDOB should have been called.'
    );
    Set<String> ocvIds = (Set<String>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryAccountsByOCVIdAndDOB'
      )
      .getParam('ocvIds');
    Assert.areEqual(
      3,
      ocvIds.size(),
      '3 ocvIds should have been passed on to the queryAccountsByOCVIdAndDOB method'
    );
    List<Date> dobList = (List<Date>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryAccountsByOCVIdAndDOB'
      )
      .getParam('dobList');
    Assert.areEqual(
      2,
      dobList.size(),
      '2 dobList should have been passed on to the queryAccountsByOCVIdAndDOB method'
    );

    Assert.areEqual(
      1,
      cobIdToAccountMap.size(),
      'Should only map accounts for COBs with PIDs and matching OCV Id and DOB'
    );
    Assert.areEqual(
      acc1,
      cobIdToAccountMap.get(
        caseWithCOBAndPid1.CustomerOnboardingApplication__c
      ),
      'Should map the Account acc1 to the COB with matching OCV Id and DOB'
    );
  }

  @IsTest
  static void testGetAccountsByMobileAndDOB() {
    registerMocks();
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobByIds',
      new List<CustomerOnboardingApplication__c>{
        caseWithCOBAndPid1.CustomerOnboardingApplication__r,
        caseWithCOBAndPid2.CustomerOnboardingApplication__r,
        caseWithCOBAndNoPid.CustomerOnboardingApplication__r
      }
    );

    // Different DOB to ensure no match
    acc2.PersonBirthdate = dob2.addDays(2);
    kycQACustomerLinkingUtilRepoMock.mock(
      'queryAccountsByMobileNumberAndDOB',
      new List<Account>{ acc1, acc2 }
    );

    Test.startTest();
    Map<Id, Account> cobIdToAccountMap = KYCQACustomerLinkingUtil.getAccountsByMobileAndDOB(
      new List<Case>{
        caseWithCOBAndPid1,
        caseWithCOBAndPid2,
        caseWithCOBAndNoPid
      }
    );
    Test.stopTest();

    Assert.isFalse(
      kycQACustomerLinkingUtilRepoMock.getHistories('queryCobByIds').isEmpty(),
      'queryCobByIds should have been called.'
    );
    Set<Id> cobIds = (Set<Id>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryCobByIds'
      )
      .getParam('cobIds');
    Assert.areEqual(
      3,
      cobIds.size(),
      '3 cobIds should have been passed on to the queryCobByIds method'
    );

    Assert.isFalse(
      kycQACustomerLinkingUtilRepoMock.getHistories(
          'queryAccountsByMobileNumberAndDOB'
        )
        .isEmpty(),
      'queryAccountsByMobileNumberAndDOB should have been called.'
    );
    Set<String> mobileNumbers = (Set<String>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryAccountsByMobileNumberAndDOB'
      )
      .getParam('mobileNumbers');
    Assert.areEqual(
      3,
      mobileNumbers.size(),
      '3 mobileNumbers should have been passed on to the queryAccountsByMobileNumberAndDOB method'
    );
    List<Date> dobList = (List<Date>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryAccountsByMobileNumberAndDOB'
      )
      .getParam('dobList');
    Assert.areEqual(
      2,
      dobList.size(),
      '2 dobList should have been passed on to the queryAccountsByMobileNumberAndDOB method'
    );

    Assert.areEqual(
      1,
      cobIdToAccountMap.size(),
      'Should only map accounts for cases with PIDs and matching Mobiles and DOB'
    );
    Assert.areEqual(
      acc1,
      cobIdToAccountMap.get(
        caseWithCOBAndPid1.CustomerOnboardingApplication__c
      ),
      'Should map the Account to the COB with matching Mobile and DOB'
    );
  }

  @IsTest
  static void testGetCobByAccountOCVIdAndDOB() {
    registerMocks();
    // Different DOB to ensure no match
    acc3.PersonBirthdate = dob3.addDays(2);

    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByOCVIdAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2
      }
    );

    Test.startTest();
    Map<Id, CustomerOnboardingApplication__c> accountIdToCOBMap = KYCQACustomerLinkingUtil.getCobByAccountOCVIdAndDOB(
      new List<Account>{ acc1, acc2, acc3 }
    );
    Test.stopTest();

    Assert.isFalse(
      kycQACustomerLinkingUtilRepoMock.getHistories('queryCobsByOCVIdAndDOB')
        .isEmpty(),
      'queryCobsByOCVIdAndDOB should have been called.'
    );
    Set<String> ocvIds = (Set<String>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryCobsByOCVIdAndDOB'
      )
      .getParam('ocvIds');
    Assert.areEqual(
      3,
      ocvIds.size(),
      '3 ocvIds should have been passed on to the queryCobsByOCVIdAndDOB method'
    );
    Set<Date> dobs = (Set<Date>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryCobsByOCVIdAndDOB'
      )
      .getParam('dobs');
    Assert.areEqual(
      3,
      dobs.size(),
      '3 dobs should have been passed on to the queryCobsByOCVIdAndDOB method'
    );

    Assert.areEqual(
      2,
      accountIdToCOBMap.size(),
      'Should only map COBs with matching OCV Id and DOB'
    );
    Assert.areEqual(
      cobWithPidAndCase1,
      accountIdToCOBMap.get(acc1.Id),
      'Should map the COB to the Account with matching OCV Id and DOB'
    );
    Assert.areEqual(
      cobWithPidAndCase2,
      accountIdToCOBMap.get(acc2.Id),
      'Should map the COB to the Account with matching OCV Id and DOB'
    );
    Assert.isFalse(
      accountIdToCOBMap.containsKey(acc3.Id),
      'Should not contain acc3 as there is no matching COB'
    );
  }

  @IsTest
  static void testGetCobByAccountMobileAndDOB() {
    registerMocks();
    // Different DOB to ensure no match
    acc3.PersonBirthdate = dob3.addDays(2);

    kycQACustomerLinkingUtilRepoMock.mock(
      'queryCobsByMobileNumberAndDOB',
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2
      }
    );

    Test.startTest();
    Map<Id, CustomerOnboardingApplication__c> accountIdToCOBMap = KYCQACustomerLinkingUtil.getCobByAccountMobileAndDOB(
      new List<Account>{ acc1, acc2, acc3 }
    );
    Test.stopTest();

    Assert.isFalse(
      kycQACustomerLinkingUtilRepoMock.getHistories(
          'queryCobsByMobileNumberAndDOB'
        )
        .isEmpty(),
      'queryCobsByMobileNumberAndDOB should have been called.'
    );

    Set<String> mobileNumbers = (Set<String>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryCobsByMobileNumberAndDOB'
      )
      .getParam('mobileNumbers');
    Assert.areEqual(
      3,
      mobileNumbers.size(),
      '3 mobileNumbers should have been passed on to the queryCobsByMobileNumberAndDOB method'
    );
    Set<Date> dobs = (Set<Date>) kycQACustomerLinkingUtilRepoMock.getHistory(
        'queryCobsByMobileNumberAndDOB'
      )
      .getParam('dobs');
    Assert.areEqual(
      3,
      dobs.size(),
      '3 dobs should have been passed on to the queryCobsByMobileNumberAndDOB method'
    );

    Assert.areEqual(
      2,
      accountIdToCOBMap.size(),
      'Should only map COBs with matching Mobile and DOB'
    );
    Assert.areEqual(
      cobWithPidAndCase1,
      accountIdToCOBMap.get(acc1.Id),
      'Should map the COB to the Account with matching Mobile and DOB'
    );
    Assert.areEqual(
      cobWithPidAndCase2,
      accountIdToCOBMap.get(acc2.Id),
      'Should map the COB to the Account with matching Mobile and DOB'
    );
    Assert.isFalse(
      accountIdToCOBMap.containsKey(acc3.Id),
      'Should not contain acc3 as there is no matching COB'
    );
  }

  @isTest
  static void testGetCobIdWithAccountOCVId() {
    List<CustomerOnboardingApplication__c> cobs = new List<CustomerOnboardingApplication__c>{
      cobWithPidAndCase1,
      cobWithPidAndCase2,
      cobWithCaseNoPid
    };
    Map<Id, Date> cobDOBs = new Map<Id, Date>{
      cobWithPidAndCase1.Id => dob1,
      cobWithPidAndCase2.Id => dob2
    };

    // Different DOB to ensure no match
    acc2.PersonBirthdate = dob2.addDays(2);
    List<Account> accs = new List<Account>{ acc1, acc2 };

    Test.startTest();
    Map<Id, Account> cobIdsWithAccount = KYCQACustomerLinkingUtil.getCobIdWithAccount(
      cobs,
      cobDOBs,
      accs,
      Account.KYCQACustomerLinkingUtilTestHelper.OCV_ID__c
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      cobIdsWithAccount.size(),
      'Should only map accounts for COBs with PIDs and matching OCV Id and DOB'
    );
    Assert.areEqual(
      acc1,
      cobIdsWithAccount.get(cobWithPidAndCase1.Id),
      'Should map the Account acc1 to the COB with matching OCV Id and DOB'
    );
  }

  @isTest
  static void testGetCobIdWithAccountMobile() {
    List<CustomerOnboardingApplication__c> cobs = new List<CustomerOnboardingApplication__c>{
      cobWithPidAndCase1,
      cobWithPidAndCase2,
      cobWithCaseNoPid
    };
    Map<Id, Date> cobDOBs = new Map<Id, Date>{
      cobWithPidAndCase1.Id => dob1,
      cobWithPidAndCase2.Id => dob2
    };

    // Different DOB to ensure no match
    acc2.PersonBirthdate = dob2.addDays(2);
    List<Account> accs = new List<Account>{ acc1, acc2 };

    Test.startTest();
    Map<Id, Account> cobIdsWithAccount = KYCQACustomerLinkingUtil.getCobIdWithAccount(
      cobs,
      cobDOBs,
      accs,
      Account.PersonMobilePhone
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      cobIdsWithAccount.size(),
      'Should only map accounts for COBs with PIDs and matching Mobile and DOB'
    );
    Assert.areEqual(
      acc1,
      cobIdsWithAccount.get(cobWithPidAndCase1.Id),
      'Should map the Account acc1 to the COB with matching Mobile and DOB'
    );
  }

  @IsTest
  static void testGetAccountIdsWithCOBsOCVId() {
    // Different DOB to ensure no match
    acc3.PersonBirthdate = dob3.addDays(2);
    List<Account> accs = new List<Account>{ acc1, acc2, acc3 };

    List<CustomerOnboardingApplication__c> cobs = new List<CustomerOnboardingApplication__c>{
      cobWithPidAndCase1,
      cobWithPidAndCase2
    };

    Test.startTest();
    Map<Id, CustomerOnboardingApplication__c> accountIdsWithCOB = KYCQACustomerLinkingUtil.getAccountIdsWithCOBs(
      accs,
      cobs,
      CustomerOnboardingApplication__c.OCVId__c
    );
    Test.stopTest();

    Assert.areEqual(
      2,
      accountIdsWithCOB.size(),
      'Should only map COBs with matching OCV Id and DOB'
    );
    Assert.areEqual(
      cobWithPidAndCase1,
      accountIdsWithCOB.get(acc1.Id),
      'Should map the COB to the Account with matching OCV Id and DOB'
    );
    Assert.isFalse(
      accountIdsWithCOB.containsKey(acc3.Id),
      'Should not contain acc3 as there is no matching COB'
    );
  }

  @IsTest
  static void testGetAccountIdsWithCOBsMobile() {
    // Different DOB to ensure no match
    acc3.PersonBirthdate = dob3.addDays(2);
    List<Account> accs = new List<Account>{ acc1, acc2, acc3 };

    List<CustomerOnboardingApplication__c> cobs = new List<CustomerOnboardingApplication__c>{
      cobWithPidAndCase1,
      cobWithPidAndCase2
    };

    Test.startTest();
    Map<Id, CustomerOnboardingApplication__c> accountIdsWithCOB = KYCQACustomerLinkingUtil.getAccountIdsWithCOBs(
      accs,
      cobs,
      CustomerOnboardingApplication__c.SecurityMobile__c
    );
    Test.stopTest();

    Assert.areEqual(
      2,
      accountIdsWithCOB.size(),
      'Should only map COBs with matching Mobile and DOB'
    );
    Assert.areEqual(
      cobWithPidAndCase1,
      accountIdsWithCOB.get(acc1.Id),
      'Should map the COB to the Account with matching Mobile and DOB'
    );
    Assert.isFalse(
      accountIdsWithCOB.containsKey(acc3.Id),
      'Should not contain acc3 as there is no matching COB'
    );
  }

  @IsTest
  static void testConstructKey() {
    // Test with both prefix and date
    String prefix = KYCQACustomerLinkingUtilTestHelper.OCV_ID_1;
    Date dob = Date.today();

    String key1 = KYCQACustomerLinkingUtil.constructKey(prefix, dob);
    String expectedResult1 = prefix + '_' + dob.format();
    Assert.areEqual(expectedResult1, key1, 'Should be ' + expectedResult1);

    // Test with prefix and null date
    String key2 = KYCQACustomerLinkingUtil.constructKey(prefix, null);
    String expectedResult2 = prefix;
    Assert.areEqual(
      expectedResult2,
      key2,
      'Should return only prefix if date is null'
    );

    // Test with empty prefix and date
    String key3 = KYCQACustomerLinkingUtil.constructKey('', dob);
    String expectedResult3 = '_' + dob.format();
    Assert.areEqual(expectedResult3, key3, 'Should handle empty prefix');

    // Test with null prefix and date
    String key4 = KYCQACustomerLinkingUtil.constructKey(null, dob);
    String expectedResult4 = null + '_' + dob.format();
    Assert.areEqual(expectedResult4, key4, 'Should handle null prefix');
  }

  @IsTest
  static void testConstructCOBsMapWithCombinedKeyOCVId() {
    Test.startTest();
    Map<String, CustomerOnboardingApplication__c> cobsMap = KYCQACustomerLinkingUtil.constructCOBsMapWithCombinedKey(
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithCaseNoPid,
        cobWithPidNoCase
      },
      CustomerOnboardingApplication__c.OCVId__c
    );
    Test.stopTest();

    Assert.areEqual(
      2,
      cobsMap.size(),
      'Should only include COBs with at least one PID'
    );

    String key1 =
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_1 +
      '_' +
      dob1.format();
    Assert.isTrue(cobsMap.containsKey(key1), 'Key should be ' + key1);
    Assert.areEqual(
      cobWithPidAndCase1,
      cobsMap.get(key1),
      'Should be the same object'
    );

    String key2 =
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_2 +
      '_' +
      dob2.format();
    Assert.isTrue(cobsMap.containsKey(key2), 'Key should be ' + key2);
    Assert.areEqual(
      cobWithPidAndCase2,
      cobsMap.get(key2),
      'Should be the same object'
    );

    String key3 =
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_NO_PID +
      '_' +
      dob3.format();
    Assert.isFalse(
      cobsMap.containsKey(key3),
      'Should not include COB without PID'
    );
  }

  @IsTest
  static void testConstructCOBsMapWithCombinedKeyMobile() {
    Test.startTest();
    Map<String, CustomerOnboardingApplication__c> cobsMap = KYCQACustomerLinkingUtil.constructCOBsMapWithCombinedKey(
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithCaseNoPid,
        cobWithPidNoCase
      },
      CustomerOnboardingApplication__c.SecurityMobile__c
    );
    Test.stopTest();

    Assert.areEqual(
      2,
      cobsMap.size(),
      'Should only include COBs with at least one PID'
    );

    String key1 =
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_1 +
      '_' +
      dob1.format();
    Assert.isTrue(cobsMap.containsKey(key1), 'Key should be ' + key1);
    Assert.areEqual(
      cobWithPidAndCase1,
      cobsMap.get(key1),
      'Should be the same object'
    );

    String key2 =
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_2 +
      '_' +
      dob2.format();
    Assert.isTrue(cobsMap.containsKey(key2), 'Key should be ' + key2);
    Assert.areEqual(
      cobWithPidAndCase2,
      cobsMap.get(key2),
      'Should be the same object'
    );

    String key3 =
      '+' +
      KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_NO_PID +
      '_' +
      dob3.format();
    Assert.isFalse(
      cobsMap.containsKey(key3),
      'Should not include COB without PID'
    );
  }

  @IsTest
  static void testConstructAccountsMapWithCombinedKeyOCVId() {
    Test.startTest();
    Map<String, Account> accsMap = KYCQACustomerLinkingUtil.constructAccountsMapWithCombinedKey(
      new List<Account>{ acc1, acc2 },
      Account.KYCQACustomerLinkingUtilTestHelper.OCV_ID__c
    );
    Test.stopTest();

    Assert.areEqual(2, accsMap.size(), 'Should map both accounts');

    String key1 =
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_1 +
      '_' +
      dob1.format();
    Assert.isTrue(accsMap.containsKey(key1), 'Key should be ' + key1);
    Assert.areEqual(acc1, accsMap.get(key1), 'Should be the same object');

    String key2 =
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_2 +
      '_' +
      dob2.format();
    Assert.isTrue(accsMap.containsKey(key2), 'Key should be ' + key2);
    Assert.areEqual(acc2, accsMap.get(key2), 'Should be the same object');
  }

  @IsTest
  static void testConstructAccountsMapWithCombinedKeyMobile() {
    Test.startTest();
    Map<String, Account> accsMap = KYCQACustomerLinkingUtil.constructAccountsMapWithCombinedKey(
      new List<Account>{ acc1, acc2 },
      Account.PersonMobilePhone
    );
    Test.stopTest();

    Assert.areEqual(2, accsMap.size(), 'Should map both accounts');
    String key1 =
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_1 +
      '_' +
      dob1.format();
    Assert.isTrue(accsMap.containsKey(key1), 'Key should be ' + key1);
    Assert.areEqual(acc1, accsMap.get(key1), 'Should be the same object');

    String key2 =
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_2 +
      '_' +
      dob2.format();
    Assert.isTrue(accsMap.containsKey(key2), 'Key should be ' + key2);
    Assert.areEqual(acc2, accsMap.get(key2), 'Should be the same object');
  }

  @IsTest
  private static void testRetrieveDOBs() {
    Test.startTest();
    Map<Id, Date> dobs = KYCQACustomerLinkingUtil.retrieveDOBs(
      new List<CustomerOnboardingApplication__c>{
        cobWithPidAndCase1,
        cobWithPidAndCase2,
        cobWithCaseNoPid
      }
    );
    Test.stopTest();

    Assert.areEqual(
      2,
      dobs.size(),
      'Should only include COBs with at least one PID'
    );
    Assert.areEqual(
      dob1,
      dobs.get(cobWithPidAndCase1.Id),
      'Should map correct DOB for cobWithPidAndCase1'
    );
    Assert.areEqual(
      dob2,
      dobs.get(cobWithPidAndCase2.Id),
      'Should map correct DOB for cobWithPidAndCase2'
    );
    Assert.isFalse(
      dobs.containsKey(cobWithCaseNoPid.Id),
      'Should not include COBs with no PID'
    );
  }

  @IsTest
  private static void testRetrieveMobileNumbers() {
    Case case1 = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBNoPid(
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_1,
      KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_1
    );
    Case case2 = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBNoPid(
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_2,
      KYCQACustomerLinkingUtilTestHelper.COB_SECURITY_MOBILE_2
    );
    Case case3 = KYCQACustomerLinkingUtilTestHelper.constructCaseWithCOBNoPid(
      KYCQACustomerLinkingUtilTestHelper.OCV_ID_1,
      null
    );

    List<Case> cases = new List<Case>{ case1, case2, case3 };

    Set<String> mobiles = KYCQACustomerLinkingUtil.retrieveMobileNumbers(cases);

    Assert.areEqual(
      3,
      mobiles.size(),
      'Should include all cases, even if SecurityMobile__c is null'
    );
    Assert.isTrue(
      mobiles.contains(
        KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_1
      ),
      'Should contain ' +
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_1
    );
    Assert.isTrue(
      mobiles.contains(
        KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_2
      ),
      'Should contain ' +
      KYCQACustomerLinkingUtilTestHelper.ACCOUNT_PERSON_MOBILE_2
    );
    Assert.isTrue(
      mobiles.contains('+null'),
      'Should handle null SecurityMobile__c'
    );
  }

  @IsTest
  static void testGetFormatedMobilePhones() {
    // Test various mobile phone formats that should be cleaned up
    List<Account> accounts = new List<Account>{ acc1, acc2, acc3 };

    Test.startTest();
    Set<String> formattedMobiles = KYCQACustomerLinkingUtil.retrieveAccFormattedMobiles(
      accounts
    );
    Test.stopTest();

    // Verify expected cleaned mobile numbers are returned
    Assert.areEqual(
      3,
      formattedMobiles.size(),
      'Should return 3 formatted mobile numbers'
    );

    Assert.isTrue(
      formattedMobiles.contains(KYCQACustomerLinkingUtilTestHelper.MOBILE_1),
      'Should contain cleaned mobile ' +
      KYCQACustomerLinkingUtilTestHelper.MOBILE_1
    );
    Assert.isTrue(
      formattedMobiles.contains(KYCQACustomerLinkingUtilTestHelper.MOBILE_2),
      'Should contain cleaned mobile ' +
      KYCQACustomerLinkingUtilTestHelper.MOBILE_2
    );
    Assert.isTrue(
      formattedMobiles.contains(KYCQACustomerLinkingUtilTestHelper.MOBILE_3),
      'Should contain cleaned mobile ' +
      KYCQACustomerLinkingUtilTestHelper.MOBILE_3
    );
  }

  @IsTest
  static void testGetFormatedMobilePhonesEmptyList() {
    Test.startTest();
    Set<String> formattedMobiles = KYCQACustomerLinkingUtil.retrieveAccFormattedMobiles(
      new List<Account>()
    );
    Test.stopTest();

    Assert.areEqual(
      0,
      formattedMobiles.size(),
      'Should return empty set for empty account list'
    );
  }
}
