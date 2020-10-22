@isTest
private with sharing class TestIDRCaseActions {
  @isTest
  static void testFormatedCaseNumber() {
    Case c = new Case();
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
      IDRCaseActions.getPicklistLabel(Case.IDR_NC_State__c, '2'),
      'Key=2, Value=VIC'
    );
  }

  @istest
  static void testNotificationsWithContactDetails() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
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

  @istest
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
}
