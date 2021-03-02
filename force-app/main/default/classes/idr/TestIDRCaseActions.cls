@isTest
private with sharing class TestIDRCaseActions {
  @isTest
  static void testFormatedCaseNumber() {
    Case c = new Case(
      RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID
    );
    insert c;
    c.CaseNumber__c = '00009999';
    update c;
    String caseNumberNotif = IDRCaseActions.getFormattedCaseNumberToNotify(c);
    System.assertEquals(
      '9999',
      caseNumberNotif,
      'Use CaseNumber__c instead of CaseNumber, and remove trailing zeros'
    );
  }

  @isTest
  static void testPicklistLabelFromValue() {
    System.assertEquals(
      'VIC',
      CommonUtils.getSinglePicklistLabel(Case.IDR_NC_State__c, '2'),
      'Key=2, Value=VIC'
    );
  }

  @isTest
  static void testNotificationsWithContactDetails() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1'
        )
      );
    }
    insert newCases;
    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      IDRCaseActions.idrNotifications.size(),
      'Matching no of events'
    );
  }

  @isTest
  static void testNotificationsWithoutContactDetails() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open'
        )
      );
    }
    insert newCases;
    System.assertEquals(
      0,
      IDRCaseActions.idrNotifications.size(),
      'Matching no of events'
    );
  }

  @isTest
  static void testPseudoAutoEscalation3Days() {
    //GIVEN new complaints created as OPEN
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = IDRCaseActions.OPEN_STATUS,
          isEscalated = false
        )
      );
    }
    insert newCases;

    //WHEN they are updated as auto-escalation would do (owner and escalated flag)
    Set<Id> caseIds = (new Map<Id, Case>(newCases)).keySet();
    newCases = [SELECT OwnerId, isEscalated FROM Case WHERE id IN :caseIds];
    for (Case c : newCases) {
      c.OwnerId = IDRCaseActions.queue.id;
      c.IsEscalated = true;
    }
    update newCases;

    //THEN escalation reason is updated accordingly
    Case c = [
      SELECT IDR_Escalation_Reason__c
      FROM Case
      WHERE id = :newCases[0].Id
    ];
    System.assertEquals(
      IDRCaseActions.DAY_3_ESCALATION_REASON,
      c.IDR_Escalation_Reason__c,
      'Escalation reason should be auto-escalated'
    );
  }

  @isTest
  static void testPseudoAutoEscalation5Days() {
    //GIVEN new complaints created as UNDER INVESTIGATION
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = IDRCaseActions.UNDER_INVESTIGATION_STATUS,
          isEscalated = false
        )
      );
    }
    insert newCases;

    //WHEN they are updated as auto-escalation would do (owner and escalated flag)
    Set<Id> caseIds = (new Map<Id, Case>(newCases)).keySet();
    newCases = [SELECT OwnerId, isEscalated FROM Case WHERE id IN :caseIds];
    for (Case c : newCases) {
      c.OwnerId = IDRCaseActions.queue.id;
      c.IsEscalated = true;
    }
    update newCases;

    //THEN escalation reason is updated accordingly
    Case c = [
      SELECT IDR_Escalation_Reason__c
      FROM Case
      WHERE id = :newCases[0].Id
    ];
    System.assertEquals(
      IDRCaseActions.DAY_5_ESCALATION_REASON,
      c.IDR_Escalation_Reason__c,
      'Escalation reason should be auto-escalated'
    );
  }
}
