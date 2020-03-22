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
  static void testTemplateIDBasedOnStatus() {
    System.assertEquals(
      'AgCaseReopen',
      IDRCaseActions.getTemplateIdBasedOnStatus('Re-opened')
    );
    System.assertEquals(
      'AgCaseUdInvest',
      IDRCaseActions.getTemplateIdBasedOnStatus('Under Investigation')
    );
    System.assertEquals(
      'AgCaseEsclt',
      IDRCaseActions.getTemplateIdBasedOnStatus('Escalated')
    );
  }
}
