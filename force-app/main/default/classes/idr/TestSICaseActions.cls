@isTest
private with sharing class TestSICaseActions {
  @TestSetup
  static void testSetup() {
    // Open/Assessing SIs
    Case[] newSIs = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newSIs.add(
        new Case(
          RecordTypeId = SICaseActions.SI_RT_ID,
          Status = 'Open',
          SI_Workflow_step__c = '1'
        )
      );
    }
    // Closed/Monitoring SIs
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newSIs.add(
        new Case(
          RecordTypeId = SICaseActions.SI_RT_ID,
          Status = 'Closed',
          SI_Workflow_step__c = '4'
        )
      );
    }
    insert newSIs;
    // Related complaints
    Case[] newComplaints = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newComplaints.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open',
          IDR_Parent_Systemic_Issue__c = newSIs[i].Id
        )
      );
    }
    insert newComplaints;
  }

  @isTest
  static void testWorkflowStepWhenClosing() {
    //GIVEN open/assessing SIs
    Case[] newCases = [
      SELECT Status
      FROM Case
      WHERE
        RecordTypeId = :SICaseActions.SI_RT_ID
        AND Status = 'Open'
        AND SI_Workflow_step__c = '1'
    ];

    //WHEN they're closed
    for (Case c : newCases) {
      c.Status = 'Closed';
    }
    update newCases;

    //THEN workflow step has not changed
    Case[] c = [
      SELECT SI_Workflow_Step__c
      FROM Case
      WHERE Status = 'Closed' AND SI_Workflow_step__c = '1'
    ];
    System.assertEquals(
      newCases.size(),
      c.size(),
      'Able to close SI at any step of the workflow'
    );
  }

  @isTest
  static void testStatusWhenWorkflowChanges() {
    //GIVEN closed/monitoring SI
    Case[] newCases = [
      SELECT SI_Workflow_step__c
      FROM Case
      WHERE
        RecordTypeId = :SICaseActions.SI_RT_ID
        AND Status = 'Closed'
        AND SI_Workflow_step__c = '4'
    ];

    //WHEN workflopw step goes back to investigating
    for (Case c : newCases) {
      c.SI_Workflow_step__c = '2';
    }
    update newCases;

    //THEN Status is Open
    Case[] c = [
      SELECT Status
      FROM Case
      WHERE Status = 'Open' AND SI_Workflow_step__c = '2'
    ];
    System.assertEquals(
      newCases.size(),
      c.size(),
      'SI not in Monitoring should not be closed'
    );
  }

  @isTest
  static void testTasksOnCaseUpdate() {
    //GIVEN open/assessing SIs
    Case[] newCases = [
      SELECT SI_Workflow_step__c
      FROM Case
      WHERE
        RecordTypeId = :SICaseActions.SI_RT_ID
        AND Status = 'Open'
        AND SI_Workflow_step__c = '1'
    ];

    //WHEN they go into monitoring
    for (Case c : newCases) {
      c.SI_Workflow_step__c = '4';
    }

    update newCases;

    //THEN 2 monitoring tasks are created per case
    Task[] tasks = [SELECT id FROM Task WHERE WhatId IN :newCases];
    System.assertEquals(
      2 * newCases.size(),
      tasks.size(),
      '2 monitoring tasks should be created per case'
    );

    //AND WHEN they go back to Investigating
    for (Case c2 : newCases) {
      c2.SI_Workflow_step__c = '2';
    }
    checkRecursive.firstCall = false;
    update newCases;

    //THEN they are removed
    tasks = [
      SELECT id
      FROM Task
      WHERE WhatId IN :newCases AND Type = 'Monitoring'
    ];
    System.assertEquals(
      0,
      tasks.size(),
      'Monitoring tasks should be removed because cases are no longer in Monitoring'
    );
  }

  @isTest
  static void testRollupToParentSI() {
    //Assert that testsetup complaint count has rollup to the parent SI records
    Case[] newSIs = [
      SELECT SI_Complaint_Count__c
      FROM Case
      WHERE SI_Complaint_Count__c > 0
    ];
    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      newSIs.size(),
      'All SI records should have a child'
    );

    //AND WHEN I unlink the complaints from their parent SI
    Case[] newComplaints = [
      SELECT IDR_Parent_Systemic_Issue__c
      FROM Case
      WHERE IDR_Parent_Systemic_Issue__c != NULL
    ];
    for (Integer i = 0; i < newComplaints.size(); i++) {
      newComplaints[i].IDR_Parent_Systemic_Issue__c = null;
    }
    update newComplaints;

    //THEN rollup count has updated
    newSIs = [
      SELECT SI_Complaint_Count__c
      FROM Case
      WHERE SI_Complaint_Count__c > 0
    ];
    System.assertEquals(
      0,
      newSIs.size(),
      'All child records should have been unlinked'
    );

    //AND WHEN I link all complaints to one SI
    newComplaints = [
      SELECT IDR_Parent_Systemic_Issue__c
      FROM Case
      WHERE RecordTypeId = :IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
    ];
    newSIs = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :SICaseActions.SI_RT_ID
      LIMIT 1
    ];
    checkRecursive.firstCall = false;
    for (Integer i = 0; i < newComplaints.size(); i++) {
      newComplaints[i].IDR_Parent_Systemic_Issue__c = newSIs[0].Id;
    }
    update newComplaints;

    //THEN rollup count has updated
    newSIs = [
      SELECT SI_Complaint_Count__c
      FROM Case
      WHERE SI_Complaint_Count__c > 0
    ];
    System.assertEquals(
      1,
      newSIs.size(),
      'All complaints should have been linked to the same SI'
    );
    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      newSIs[0].SI_Complaint_Count__c,
      'Counter should have been updated'
    );
  }
}
