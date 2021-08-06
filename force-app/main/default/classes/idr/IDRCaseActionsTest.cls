/**
 * @author David Dawson
 * @date April 2020
 * @description Test class for {@link IDRCaseActions}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class IDRCaseActionsTest {
  @isTest
  static void testFormatedCaseNumber() {
    Case c = new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID);
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
      CommonUtil.getSinglePicklistLabel(Case.IDR_NC_State__c, '2'),
      'Key=2, Value=VIC'
    );
  }

  @isTest
  static void testNotificationsWithContactDetails() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1',
          IDR_SwicthOff_3rd_Party_Notification__c = false,
          IDR_SwitchOff_Customer_Notification__c = false
        )
      );
    }
    insert newCases;
    List<Notification_Handler__c> nhList = [
      SELECT Id
      FROM Notification_Handler__c
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      nhList.size(),
      'Matching no of events'
    );
  }

  @isTest
  static void testNotificationsWithoutContactDetails() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open'
        )
      );
    }
    insert newCases;
    List<Notification_Handler__c> nhList = [
      SELECT Id
      FROM Notification_Handler__c
    ];

    System.assertEquals(0, nhList.size(), 'Matching no of events');
  }

  @isTest
  static void testPseudoAutoEscalation3Days() {
    //GIVEN new complaints created as OPEN
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
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
      c.IDR_Escalated_to__c = '1';
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

  @isTest
  static void testPseudoAutoEscalation5Days() {
    //GIVEN new complaints created as UNDER INVESTIGATION
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
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
      c.IDR_Escalated_to__c = '1';
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

  @istest
  static void testCustomerNumberValidation() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890'
        )
      );
    }
    insert newCases;

    for (Case c : newCases) {
      c.IDR_Customer_Number__c = '0987654321';
    }
    try {
      update newCases;
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('This field can no longer be edited.')
      );
    }
  }

  @isTest
  static void testUpdateDateTimePsiTicked() {
    //GIVEN new PSIs
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          IDR_Is_Common__c = 'yes',
          IDR_Systemic_Issue_Category__c = '1',
          IDR_Systemic_Issue_Description__c = 'Test'
        )
      );
    }
    //WHEN they're inserted
    insert newCases;
    //THEN Date/Time flag is populated
    Case c = [SELECT IDR_Datetime_PSI_Ticked__c FROM Case LIMIT 1];
    System.assert(
      c.IDR_Datetime_PSI_Ticked__c != null,
      'Date/Time flag should have been populated'
    );
    //AND WHEN they're unflagged
    for (Case newCase : newCases) {
      newCase.IDR_Is_Common__c = 'No';
    }
    update newCases;
    //THEN Date/Time flag is cleared
    c = [SELECT IDR_Datetime_PSI_Ticked__c FROM Case LIMIT 1];
    System.assert(
      c.IDR_Datetime_PSI_Ticked__c == null,
      'Date/Time flag should have been cleared'
    );
  }
}
