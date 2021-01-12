@isTest
private with sharing class TestSICaseActions {
  @isTest
  static void testWorkflowStepWhenClosing() {
    //GIVEN new SIs are inserted
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = SICaseActions.SI_RT_ID,
          Status = 'Open',
          SI_Workflow_step__c = '1'
        )
      );
    }
    insert newCases;

    //WHEN they're closed
    for (Case c : newCases) {
      c.Status = 'Closed';
    }
    update newCases;

    //THEN workflow step has not changed
    Case c = [SELECT SI_Workflow_Step__c FROM Case LIMIT 1];
    System.assertEquals(
      '1',
      c.SI_Workflow_Step__c,
      'Able to close SI at any step of the workflow'
    );
  }

  @isTest
  static void testStatusWhenWorkflowChanges() {
    //GIVEN closed SI
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = SICaseActions.SI_RT_ID,
          Status = 'Closed',
          SI_Workflow_step__c = '4'
        )
      );
    }
    insert newCases;

    //WHEN workflopw step goes back to investigating
    for (Case c : newCases) {
      c.SI_Workflow_step__c = '2';
    }
    update newCases;

    //THEN Status is Open
    Case c = [SELECT Status FROM Case LIMIT 1];
    System.assertEquals(
      'Open',
      c.Status,
      'SI not in Monitoring should not be closed'
    );
  }

  @isTest
  static void testTasksOnCaseUpdate() {
    //GIVEN new SIs are inserted
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = SICaseActions.SI_RT_ID,
          Status = 'Open',
          SI_Workflow_step__c = '1'
        )
      );
    }
    insert newCases;

    //WHEN they go into monitoring
    for (Case c : newCases) {
      c.SI_Workflow_step__c = '4';
    }
    update newCases;

    //THEN 2 monitoring tasks are created per case
    Case c = [SELECT Status FROM Case LIMIT 1];
    Task[] tasks = [SELECT id FROM Task WHERE WhatId = :c.Id];
    System.assertEquals(
      2,
      tasks.size(),
      '2 monitoring tasks should be created per case'
    );

    //AND WHEN they go back to Investigating
    for (Case c2 : newCases) {
      c2.SI_Workflow_step__c = '2';
    }
    update newCases;

    //THEN they are removed
    tasks = [SELECT id FROM Task WHERE WhatId = :c.Id];
    System.assertEquals(
      0,
      tasks.size(),
      '2 monitoring tasks should be removed because case is no longer in Monitoring'
    );
  }
}
