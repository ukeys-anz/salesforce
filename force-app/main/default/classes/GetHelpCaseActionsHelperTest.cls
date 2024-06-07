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
    GetHelpConstants.COB_FAILED_OK_STATUS,
    GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  private static final Integer COB_CASES_COUNT = COB_CLOSED_STATUSES.size();

  private static final String FAILED_REASON = 'Selfie fail - selfie image is not clear enough to match';
  private static final String CONFIRMED_FRAUD_REASON = 'Confirmed Fraud';

  private static final String EMPTY_FAILED_REASON = '';

  @TestSetup
  private static void makeData() {
    makeCOBData();
  }

  private static void makeCOBData() {
    List<Case> cases = new List<Case>();

    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      cases.add(
        createCase(
          GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
          GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
        )
      );

      cases.add(
        createCase(COB_CLOSED_STATUSES[i], GetHelpConstants.FRAUD_CHECK_RT_ID)
      );
    }
    insert cases;
  }

  private static Case createCase(String status, String recordTypeId) {
    Case c = new Case();
    c.Status = status;
    c.RecordTypeId = recordTypeId;
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
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Case newRecord = createCase(
      GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Test.startTest();
    Boolean isStatusChanged = GetHelpCaseActionsHelper.isStatusChanged(
      newRecord,
      oldRecord
    );
    Test.stopTest();

    Assert.isTrue(isStatusChanged, 'Status should have changed.');
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
      'There should be ' + COB_CASES_COUNT + ' cases.'
    );
  }

  @isTest
  private static void testGetCasesByIdsEmptySet() {
    Test.startTest();
    List<Case> casesByIds = GetHelpCaseActionsHelper.getCasesByIds(
      new Set<Id>()
    );
    Test.stopTest();

    Assert.isTrue(
      casesByIds.isEmpty(),
      'There should be an empty list of cases.'
    );
  }

  @isTest
  private static void testSetIDOpsCaseStatus() {
    Map<Id, Case> parentIdAndChildCasesMap = setFraudCheckStatuses();

    Test.startTest();
    List<Case> updatedIdOpsCases = GetHelpCaseActionsHelper.setIDOpsCaseStatus(
      parentIdAndChildCasesMap
    );
    Test.stopTest();

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
        : fraudCheckCase.Status == GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
            ? CONFIRMED_FRAUD_REASON
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
          'Failed reason should be ' + FAILED_REASON
        );
      }

      if (
        COB_CLOSED_STATUSES[i] == GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
      ) {
        Assert.areEqual(
          CONFIRMED_FRAUD_REASON,
          updatedIdOpsCases[i].OnboardingVerificationFailedReason__c,
          'Failed reason should be ' + CONFIRMED_FRAUD_REASON
        );
      }
    }
  }

  @isTest
  private static void testSetIDOpsCaseStatusEmptyMap() {
    Test.startTest();
    List<Case> updatedIdOpsCases = GetHelpCaseActionsHelper.setIDOpsCaseStatus(
      new Map<Id, Case>()
    );
    Test.stopTest();

    Assert.isTrue(
      updatedIdOpsCases.isEmpty(),
      'There should be an empty list of cases.'
    );
  }

  @isTest
  public static void testCaseProvisionallyClosedDateTimeUpdateScenario() {
    String caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case c = TestDataFactory.createCase('Card_Dispute');
    c.Status = 'Open';
    c.External_System__c = 'Pega_Smarts';
    c.External_Case_ID__c = 'C-1234';
    c.Id = caseId;

    Case c1 = TestDataFactory.createCase('Card_Dispute');
    c1.Status = GetHelpConstants.PROVISIONALLY_CLOSED_STATUS;
    c1.External_System__c = 'Pega_Smarts';
    c1.External_Case_ID__c = 'C-1234';
    c1.Id = caseId;

    Case c2 = TestDataFactory.createCase('Card_Dispute');
    c2.Status = GetHelpConstants.PROVISIONALLY_CLOSED_STATUS;
    c2.External_System__c = '2342';
    c2.External_Case_ID__c = 'C-1234';
    c2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case c3 = TestDataFactory.createCase('Card_Dispute');
    c3.Status = 'Open';
    c3.External_System__c = '2342';
    c3.External_Case_ID__c = 'C-3242';
    c3.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    List<Case> cases = new List<Case>{ c1, c2, c3 };

    Map<Id, Case> oldMap = new Map<Id, Case>{ c.Id => c };

    Test.startTest();
    GetHelpCaseActions.handleProvisionallyClosedDateTimeField(oldMap, cases);
    Test.stopTest();

    System.assertEquals(c1.Date_Time_Provisionally_Closed__c, DateTime.now());
    System.assertEquals(c2.Date_Time_Provisionally_Closed__c, DateTime.now());
    System.assertEquals(c3.Date_Time_Provisionally_Closed__c, null);
  }

  @isTest
  public static void testCaseProvisionallyClosedDateTimeInsertScenario() {
    String caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case c = TestDataFactory.createCase('Card_Dispute');
    c.Status = 'Open';
    c.External_System__c = 'Pega_Smarts';
    c.External_Case_ID__c = 'C-1234';
    c.Id = caseId;

    Case c2 = TestDataFactory.createCase('Card_Dispute');
    c2.Status = GetHelpConstants.PROVISIONALLY_CLOSED_STATUS;
    c2.External_System__c = '2342';
    c2.External_Case_ID__c = 'C-4235';
    c2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    List<Case> cases = new List<Case>{ c, c2 };
    Test.startTest();
    GetHelpCaseActions.handleProvisionallyClosedDateTimeField(null, cases);
    Test.stopTest();

    System.assertEquals(c.Date_Time_Provisionally_Closed__c, null);
    System.assertEquals(c2.Date_Time_Provisionally_Closed__c, DateTime.now());
  }

  @isTest
  private static void testGetIDOpsWatchlistRecords() {
    Map<Id, Case> oldMap = new Map<Id, Case>();
    List<Case> records = new List<Case>();

    //ID Ops Case Watchlist
    Case idOpsCaseWatchlist = createCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    idOpsCaseWatchlist.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    idOpsCaseWatchlist.Subject =
      'ID Ops Assistance - ' +
      GetHelpConstants.COB_DAON_FAILED_SUBJECT_WATCHLIST_HIT;
    records.add(idOpsCaseWatchlist);

    //Non-ID Ops Case
    Case fraudCheckCase = createCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    fraudCheckCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    records.add(fraudCheckCase);

    //ID Ops Case with non-Watchlist subject
    Case idOpsCaseNonWatchlist = createCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    idOpsCaseNonWatchlist.Subject = 'ID Ops Assistance - Daon Fallout: NO_MATCH';
    idOpsCaseNonWatchlist.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    records.add(idOpsCaseNonWatchlist);

    oldMap = new Map<Id, Case>(records.deepClone(true, true, true));

    //update the status
    idOpsCaseWatchlist.Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS;
    idOpsCaseNonWatchlist.Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS;

    Test.startTest();
    List<Case> idOpsCases = GetHelpCaseActionsHelper.getIDOpsWatchlistRecords(
      records,
      oldMap
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      idOpsCases.size(),
      'There should be 1 ID Ops case that is in Watchlist retrieved.'
    );
  }
}
