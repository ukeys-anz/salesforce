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
          Status = IDRConstants.OPEN_STATUS,
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
          Status = IDRConstants.UNDER_INVESTIGATION_STATUS,
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

  @isTest
  static void testPreventCloseStatusOnCaseWithPendingTaskCase() {
    //data setup
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open',
          isEscalated = false
        )
      );
    }
    insert newCases;
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Status = 'Open',
          Subject = 'Call',
          Type = 'Pend Case',
          //Below are fields inserted due to validation rules based on the 'Pend Case' status
          IDR_Key_Contact_Name__c = 'Test',
          IDR_Pended_To__c = 'Customer',
          IDR_Internal_or_External_Party__c = 'External',
          IDR_Pend_Reason__c = 'Awaiting information to be provided',
          ActivityDate = Date.today() + 1,
          WhatId = newCases[i].Id
        )
      );
    }
    insert newTasks;
    Boolean preventCaseCloseErrorThrown = false;

    //Scenario where it Case Closed Status should be prevented
    for (Case c : newCases) {
      c.Status = 'Closed';
      c.IDR_Complaint_Outcome__c = '3';
      c.IDR_Description_of_Outcome__c = 'Test';
    }

    try {
      update newCases;
    } catch (Exception e) {
      if (
        e.getMessage()
          .contains(
            'You cannot close the case as there is currently an open \'Pend Case\' task. Please review and action the open \'Pend Case\' task before closing the case.'
          )
      ) {
        preventCaseCloseErrorThrown = true;
      }
    }
    System.assertEquals(
      true,
      preventCaseCloseErrorThrown,
      'Expected update to \'Closed\' status to be prevented, however no error was thrown/wrong error thrown'
    );
  }

  @isTest
  static void testPreventClosedStatusOnCaseWithPendingTaskCase() {
    //data setup
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open',
          isEscalated = false
        )
      );
    }
    insert newCases;
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Status = 'Open',
          Subject = 'Call',
          Type = 'Pend Case',
          //Below are fields inserted due to validation rules based on the 'Pend Case' status
          IDR_Key_Contact_Name__c = 'Test',
          IDR_Pended_To__c = 'Customer',
          IDR_Internal_or_External_Party__c = 'External',
          IDR_Pend_Reason__c = 'Awaiting information to be provided',
          ActivityDate = Date.today() + 1,
          WhatId = newCases[i].Id
        )
      );
    }
    insert newTasks;
    Boolean preventCaseCloseErrorThrown = false;

    //Scenario where it Case Closed Status should be prevented
    for (Case c : newCases) {
      c.Status = 'Closed';
      c.IDR_Complaint_Outcome__c = '3';
      c.IDR_Description_of_Outcome__c = 'Test';
    }

    try {
      update newCases;
    } catch (Exception e) {
      if (
        e.getMessage()
          .contains(
            'You cannot close the case as there is currently an open \'Pend Case\' task. Please review and action the open \'Pend Case\' task before closing the case.'
          )
      ) {
        preventCaseCloseErrorThrown = true;
      }
    }

    System.assertEquals(
      true,
      preventCaseCloseErrorThrown,
      'Expected update to \'Closed\' status to be prevented, however no error was thrown/wrong error thrown'
    );
  }

  @isTest
  static void testPreventClosedStatusOnCaseWithCompletedPendingTaskCase() {
    //data setup
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open',
          isEscalated = false
        )
      );
    }
    insert newCases;
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Status = 'Completed',
          Subject = 'Call',
          Type = 'Pend Case',
          //Below are fields inserted due to validation rules based on the 'Pend Case' status
          IDR_Key_Contact_Name__c = 'Test',
          IDR_Pended_To__c = 'Customer',
          IDR_Internal_or_External_Party__c = 'External',
          IDR_Pend_Reason__c = 'Awaiting information to be provided',
          ActivityDate = Date.today() + 1,
          WhatId = newCases[i].Id
        )
      );
    }
    insert newTasks;
    Boolean preventCaseCloseErrorThrown = false;

    //Scenario where it Case Closure should be allowed
    for (Case c : newCases) {
      c.Status = 'Closed';
      c.IDR_Complaint_Outcome__c = '3';
      c.IDR_Description_of_Outcome__c = 'Test';
    }

    try {
      update newCases;
    } catch (Exception e) {
      preventCaseCloseErrorThrown = true;
    }
    System.assertEquals(
      false,
      preventCaseCloseErrorThrown,
      'Expected update to Closed status to be allowed, however Status update was prevented, throwing an error'
    );
  }

  @isTest
  static void testUpdateKnowledgeKeyWordCaseFields() {
    //data setup
    Product2 p = new Product2(
      Name = 'Test',
      IsActive = true,
      IDR_Product_or_Service_Line__c = '1',
      IDR_Product_or_Service_Category__c = '1',
      IDR_Product_or_Service_Type__c = '1'
    );
    insert p;
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open',
          isEscalated = false,
          IDR_Second_Issue__c = true,
          IDR_Third_Issue__c = true,
          IDR_Issue_Type_2__c = '9',
          IDR_Issue_Type_3__c = '2',
          IDR_Subsequent_Issue_2__c = '57',
          IDR_Subsequent_Issue_3__c = '14',
          IDR_Product_2__c = p.Id,
          IDR_Product_3__c = p.Id
        )
      );
    }
    insert newCases;
    Case c = [
      SELECT
        Id,
        toLabel(IDR_Issue_Type_2__c),
        toLabel(IDR_Subsequent_Issue_2__c),
        toLabel(IDR_Issue_Type_3__c),
        toLabel(IDR_Subsequent_Issue_3__c),
        IDR_Knowledge_Keyword_1__c,
        IDR_Knowledge_Keyword_2__c
      FROM Case
      LIMIT 1
    ];
    System.assertEquals(
      c.IDR_Issue_Type_2__c +
      ' ' +
      c.IDR_Subsequent_Issue_2__c,
      c.IDR_Knowledge_Keyword_1__c,
      'Expected Knowledge Keyword 1 to complete on case create, however it did not'
    );
    System.assertEquals(
      c.IDR_Issue_Type_3__c +
      ' ' +
      c.IDR_Subsequent_Issue_3__c,
      c.IDR_Knowledge_Keyword_2__c,
      'Expected Knowledge Keyword 2 to complete on case create, however it did not'
    );

    for (Case cs : newCases) {
      cs.IDR_Issue_Type_2__c = '18';
      cs.IDR_Issue_Type_3__c = '16';
      cs.IDR_Subsequent_Issue_2__c = '63';
      cs.IDR_Subsequent_Issue_3__c = '78';
    }
    update newCases;
    c = [
      SELECT
        Id,
        toLabel(IDR_Issue_Type_2__c),
        toLabel(IDR_Subsequent_Issue_2__c),
        toLabel(IDR_Issue_Type_3__c),
        toLabel(IDR_Subsequent_Issue_3__c),
        IDR_Knowledge_Keyword_1__c,
        IDR_Knowledge_Keyword_2__c
      FROM Case
      LIMIT 1
    ];

    System.assertEquals(
      c.IDR_Issue_Type_2__c +
      ' ' +
      c.IDR_Subsequent_Issue_2__c,
      c.IDR_Knowledge_Keyword_1__c,
      'Expected Knowledge Keyword 1 on update, however it did not'
    );
    System.assertEquals(
      c.IDR_Issue_Type_3__c +
      ' ' +
      c.IDR_Subsequent_Issue_3__c,
      c.IDR_Knowledge_Keyword_2__c,
      'Expected Knowledge Keyword 2 on update, however it did not'
    );
  }
}
