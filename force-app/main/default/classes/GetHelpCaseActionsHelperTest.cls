/**
 * @author Batya Aisman Sufrin
 * @date February 2023
 * @description Test class for {@link GetHelpCaseAcctionsHelper}
 * @group ANZx
 */
@isTest
public with sharing class GetHelpCaseActionsHelperTest {
  private static final List<String> COB_CLOSED_STATUSES = new List<String>{
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
    GetHelpConstants.COB_FAILED_OK_STATUS
  };

  private static final Integer COB_CASES_COUNT = COB_CLOSED_STATUSES.size();

  private static final String FAILED_REASON = 'Selfie fail - selfie image is not clear enough to match';

  private static final String EMPTY_FAILED_REASON = '';

  @TestSetup
  private static void makeData() {
    List<Case> idOpsCases = new List<Case>();
    List<Case> fraudCheckCases = new List<Case>();

    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      idOpsCases.add(
        createCobCase(
          GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
          GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
        )
      );

      fraudCheckCases.add(
        createCobCase(
          COB_CLOSED_STATUSES[i],
          GetHelpConstants.FRAUD_CHECK_RT_ID
        )
      );
    }

    insert idOpsCases;
    insert fraudCheckCases;
  }

  private static Case createCobCase(String status, String recordTypeId) {
    return new Case(Status = status, RecordTypeId = recordTypeId);
  }

  private static List<Case> getCOBCase(String recordtype) {
    return [SELECT Id, Status FROM Case WHERE RecordTypeId = :recordtype];
  }

  @isTest
  private static void testIsStatusChanged() {
    Case oldRecord = createCobCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Case newRecord = createCobCase(
      GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Boolean isStatusChanged = GetHelpCaseActionsHelper.isStatusChanged(
      newRecord,
      oldRecord
    );

    Assert.isTrue(isStatusChanged);
  }

  @isTest
  private static void testGetCasesByIds() {
    List<Case> caseRecords = getCOBCase(
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

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
    List<Case> idOpsCases = getCOBCase(
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    List<Case> fraudCheckCases = getCOBCase(GetHelpConstants.FRAUD_CHECK_RT_ID);

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
}
