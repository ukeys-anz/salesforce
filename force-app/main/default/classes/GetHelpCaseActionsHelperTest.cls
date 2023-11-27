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

  @TestSetup
  private static void makeData() {
    User usr = TestDataFactory.getANZxUser('FraudX_Agent');
    System.runAs(usr) {
      makeCOBData();
    }
  }

  private static void makeCOBData() {
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    CustomerOnboardingApplication__c cobAppSTP = createCOBApp(
      COBApplicationActionsHelper.VERIFICATION_TYPE_STP
    );
    cobApps.add(cobAppSTP);
    CustomerOnboardingApplication__c cobAppAssisted = createCOBApp(
      COBApplicationActionsHelper.VERIFICATION_TYPE_ASSISTED
    );
    cobApps.add(cobAppAssisted);
    insert cobApps;

    List<Case> cases = new List<Case>();

    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      cases.add(
        createCase(
          GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
          GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
          cobAppSTP.Id
        )
      );

      cases.add(
        createCase(
          COB_CLOSED_STATUSES[i],
          GetHelpConstants.FRAUD_CHECK_RT_ID,
          cobAppSTP.Id
        )
      );
    }

    Case newCase = createCase(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      cobAppAssisted.Id
    );
    cases.add(newCase);
    insert cases;
  }

  private static CustomerOnboardingApplication__c createCOBApp(
    String verificationType
  ) {
    CustomerOnboardingApplication__c cob = new CustomerOnboardingApplication__c(
      PersonaId__c = FAKER.randomString(15),
      OCVId__c = FAKER.randomString(10),
      SecurityMobile__c = FAKER.randomString(10),
      VerificationType__c = verificationType,
      EquifaxAttemptCount__c = 1
    );
    return cob;
  }

  private static Case createCase(
    String status,
    String recordTypeId,
    String cobId
  ) {
    Case c = new Case();
    c.Status = status;
    c.RecordTypeId = recordTypeId;
    c.CustomerOnboardingApplication__c = cobId;
    return c;
  }

  private static List<Case> getCases(String recordtype) {
    return [
      SELECT Id, Status, RecordTypeId
      FROM Case
      WHERE RecordTypeId = :recordtype
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
  private static void testGetCOBAppsHasIDOpsAssistanceCases() {
    List<CustomerOnboardingApplication__c> cobApps = [
      SELECT Id
      FROM CustomerOnboardingApplication__c
      WHERE Has_ID_Ops_Assistance_Cases__c = TRUE
    ];
    Assert.areEqual(
      1,
      cobApps.size(),
      'Should has 1 COB Application records Has ID Ops Assistance Cases'
    );
  }
}
