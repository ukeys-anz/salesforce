/**
 * @author Batya Aisman Sufrin
 * @date June 2023
 * @description Test class for {@link AccountCommonActionsHelper}
 * @group ANZx
 */
@isTest
public with sharing class AccountCommonActionsHelperTest {
  private static final String OCV_ID1 = '0123456789';
  private static final String OCV_ID2 = '9876543210';
  private static final String OCV_ID3 = '0126789345';
  private static final String OCV_ID4 = '9876210543';
  private static final String MOBILE_PHONE1 = '0411111111';
  private static final String MOBILE_PHONE2 = '0422222222';
  private static final String MOBILE_PHONE3 = '0433333333';
  private static final String MOBILE_PHONE4 = '0455555555';

  private static final List<String> OCV_IDS = new List<String>{
    OCV_ID1,
    OCV_ID2,
    OCV_ID3,
    OCV_ID4
  };

  private static final List<String> MOBILE_PHONES = new List<String>{
    MOBILE_PHONE1,
    MOBILE_PHONE2,
    MOBILE_PHONE3,
    MOBILE_PHONE4
  };

  private static final Map<String, List<String>> OCV_IDS_MOBILE_PHONES = new Map<String, List<String>>{
    '1' => new List<String>{ OCV_IDS[0], MOBILE_PHONES[0] },
    '2' => new List<String>{ OCV_IDS[1], MOBILE_PHONES[1] },
    '3' => new List<String>{ OCV_IDS[2], null },
    '4' => new List<String>{ OCV_IDS[3], null },
    '5' => new List<String>{ null, MOBILE_PHONES[2] },
    '6' => new List<String>{ null, MOBILE_PHONES[3] }
  };

  @TestSetup
  private static void makeData() {
    buildCOBData();
  }

  private static void buildCOBData() {
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    List<Case> cases = new List<Case>();

    for (String scenario : OCV_IDS_MOBILE_PHONES.keySet()) {
      cobApps.add(createCOBApp(OCV_IDS_MOBILE_PHONES.get(scenario)));
    }
    insert cobApps;

    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      cases.add(createKYCQACase(cobApp));
    }
    insert cases;
  }

  private static CustomerOnboardingApplication__c createCOBApp(
    List<String> ocvIdsMobiles
  ) {
    return new CustomerOnboardingApplication__c(
      OCVId__c = ocvIdsMobiles[0],
      SecurityMobile__c = ocvIdsMobiles[1]
    );
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [
      SELECT Id, OCVId__c, SecurityMobile__c
      FROM CustomerOnboardingApplication__c
    ];
  }

  private static Case createKYCQACase(CustomerOnboardingApplication__c cobApp) {
    return new Case(
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      CustomerOnboardingApplication__c = cobApp.Id,
      OCV_Id__c = cobApp.OCVId__c
    );
  }

  private static List<Case> getKYCQACase() {
    return [
      SELECT Id, OCV_Id__c, CustomerOnboardingApplication__c
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
    ];
  }

  @isTest
  private static void testGetCasesByOCVIdsOrMobiles() {
    Test.startTest();
    List<Case> accountsByOCVIds = AccountCommonActionsHelper.getCasesByOCVIdsOrMobiles(
      new Set<String>(OCV_IDS),
      new Set<String>(MOBILE_PHONES),
      GetHelpConstants.KYCQA_RT_ID
    );
    Test.stopTest();

    Assert.areEqual(
      OCV_IDS_MOBILE_PHONES.size(),
      accountsByOCVIds.size(),
      'There should be ' +
      OCV_IDS_MOBILE_PHONES.size() +
      ' accounts.'
    );
  }

  @isTest
  private static void testGetCasesByOCVIdsOrMobilesWithMobilesEmptySet() {
    Set<String> ocvIds = new Set<String>{ OCV_ID1 };
    List<Case> cases = AccountCommonActionsHelper.getCasesByOCVIdsOrMobiles(
      new Set<String>(OCV_IDS),
      new Set<String>(),
      GetHelpConstants.KYCQA_RT_ID
    );

    Assert.areEqual(
      OCV_IDS.size(),
      cases.size(),
      'There should be ' +
      OCV_IDS.size() +
      ' Cases.'
    );
  }

  @isTest
  private static void testGetCasesByOCVIdsOrMobilesWithOCVIDsEmptySet() {
    List<Case> cases = AccountCommonActionsHelper.getCasesByOCVIdsOrMobiles(
      new Set<String>(),
      new Set<String>(MOBILE_PHONES),
      GetHelpConstants.KYCQA_RT_ID
    );

    Assert.areEqual(
      MOBILE_PHONES.size(),
      cases.size(),
      'There should be ' +
      MOBILE_PHONES.size() +
      ' Cases.'
    );
  }

  @isTest
  private static void testGetCasesByOCVIdsOrMobilesWithEmptySets() {
    List<Case> cases = AccountCommonActionsHelper.getCasesByOCVIdsOrMobiles(
      new Set<String>(),
      new Set<String>(),
      GetHelpConstants.KYCQA_RT_ID
    );

    Assert.isTrue(cases.isEmpty(), 'There should be an empty list of Cases.');
  }
}
