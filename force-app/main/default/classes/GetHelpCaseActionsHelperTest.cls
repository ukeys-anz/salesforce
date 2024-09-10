/**
 * @author Batya Aisman Sufrin
 * @date February 2023
 * @description Test class for {@link GetHelpCaseAcctionsHelper}
 * @group ANZx
 */
@isTest
public with sharing class GetHelpCaseActionsHelperTest {
  private static final List<String> COB_CLOSED_STATUSES = new List<String>{
    COBCaseConstants.COB_ID_CHECK_OK_STATUS,
    COBCaseConstants.COB_FAILED_OK_STATUS,
    COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  private static final Integer COB_CASES_COUNT = COB_CLOSED_STATUSES.size();
  private static final String MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE = 'Date_Time_Provisionally_Closed__c should be the current date and time';
  private static final String MSG_DATE_TIME_PROVISIONALLY_CLOSED_NULL = 'Date_Time_Provisionally_Closed__c should be null';

  @TestSetup
  private static void makeData() {
    makeCOBData();
  }

  private static void makeCOBData() {
    List<Case> cases = new List<Case>();

    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      cases.add(
        createCase(
          COBCaseConstants.COB_POTENTIAL_FRAUD_STATUS,
          RTCase.idOpsAssistance
        )
      );

      cases.add(createCase(COB_CLOSED_STATUSES[i], RTCase.fraudCheck));
    }
    insert cases;
  }

  private static Case createCase(String status, String recordTypeId) {
    Case c = new Case();
    c.Status = status;
    c.RecordTypeId = recordTypeId;
    return c;
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

    Assert.areEqual(
      c1.Date_Time_Provisionally_Closed__c,
      DateTime.now(),
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE
    );
    Assert.areEqual(
      c2.Date_Time_Provisionally_Closed__c,
      DateTime.now(),
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE
    );
    Assert.areEqual(
      c3.Date_Time_Provisionally_Closed__c,
      null,
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_NULL
    );
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

    Assert.areEqual(
      c.Date_Time_Provisionally_Closed__c,
      null,
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_NULL
    );
    Assert.areEqual(
      c2.Date_Time_Provisionally_Closed__c,
      DateTime.now(),
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE
    );
  }
}
