@isTest
private with sharing class SICaseActionsTest {
  @TestSetup
  static void testSetup() {
    // Open/Assessing SIs, with fields to test masking
    Case[] newSIs = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newSIs.add(
        new Case(
          RecordTypeId = IDRConstants.SI_RT_ID,
          Status = 'Open',
          SI_Workflow_step__c = 'Assessing',
          Subject = '000001234',
          Description = 'Test description 1234-5678-9101 check mask',
          IDR_Description_of_Outcome__c = 'Test description 1234 5678 9101 check mask',
          RAG_Comments__c = 'Test description 123456789101 check mask',
          SI_Definite_Action_Completed__c = 'Test description 1234-5678-9101 check mask',
          SI_Rec_Rem_Actions__c = 'Test description 1234-5678-9101 check mask',
          SI_Subject_of_Breach_Report_Comments__c = 'Test description 1234-5678-9101 check mask'
        )
      );
    }
    // Closed/Monitoring SIs
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newSIs.add(
        new Case(
          RecordTypeId = IDRConstants.SI_RT_ID,
          Status = 'Closed',
          SI_Workflow_step__c = 'Monitoring'
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
        RecordTypeId = :IDRConstants.SI_RT_ID
        AND Status = 'Open'
        AND SI_Workflow_step__c = 'Assessing'
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
      WHERE Status = 'Closed' AND SI_Workflow_step__c = 'Assessing'
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
        RecordTypeId = :IDRConstants.SI_RT_ID
        AND Status = 'Closed'
        AND SI_Workflow_step__c = 'Monitoring'
    ];

    //WHEN workflopw step goes back to investigating
    for (Case c : newCases) {
      c.SI_Workflow_step__c = 'Investigating';
    }
    update newCases;

    //THEN Status is Open
    Case[] c = [
      SELECT Status
      FROM Case
      WHERE Status = 'Open' AND SI_Workflow_step__c = 'Investigating'
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
        RecordTypeId = :IDRConstants.SI_RT_ID
        AND Status = 'Open'
        AND SI_Workflow_step__c = 'Assessing'
    ];

    //WHEN they go into monitoring
    for (Case c : newCases) {
      c.SI_Workflow_step__c = 'Monitoring';
    }

    Test.startTest();
    
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
      c2.SI_Workflow_step__c = 'Investigating';
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
    Test.stopTest();
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

    Test.startTest();
    
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
      WHERE RecordTypeId = :IDRConstants.SI_RT_ID
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
    Test.stopTest();
  }
  
  @isTest
  static void testSystemicIssueFieldMasking() {
    //GIVEN SIs
    //WHEN they're inserted
    // THEN long numbers in free text fields are masked, showing only the last four digits
    Case c = [
      SELECT
        Subject,
        Description,
        IDR_Description_of_Outcome__c,
        RAG_Comments__c,
        SI_Definite_Action_Completed__c,
        SI_Rec_Rem_Actions__c,
        SI_Subject_of_Breach_Report_Comments__c
      FROM Case
      WHERE SI_Workflow_step__c = 'Assessing'
      LIMIT 1
    ];
    System.assertEquals('*****1234', c.Subject, 'Subject should be masked.');
    System.assertEquals(
      'Test description ********9101 check mask',
      c.Description,
      'Description should be masked.'
    );
    System.assertEquals(
      'Test description ********9101 check mask',
      c.IDR_Description_of_Outcome__c,
      'IDR_Description_of_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test description ********9101 check mask',
      c.RAG_Comments__c,
      'RAG_Comments__c should be masked.'
    );
    System.assertEquals(
      'Test description ********9101 check mask',
      c.SI_Definite_Action_Completed__c,
      'SI_Definite_Action_Completed__c should be masked.'
    );
    System.assertEquals(
      'Test description ********9101 check mask',
      c.SI_Rec_Rem_Actions__c,
      'SI_Rec_Rem_Actions__c should be masked.'
    );
    System.assertEquals(
      'Test description ********9101 check mask',
      c.SI_Subject_of_Breach_Report_Comments__c,
      'SI_Subject_of_Breach_Report_Comments__c should be masked.'
    );
    //AND WHEN updated
    c.Subject = '987654321';
    update c;
    //THEN long numbers in free text fields are masked, showing only the last four digits
    c = [SELECT Subject FROM Case LIMIT 1];
    System.assertEquals('*****4321', c.Subject, 'Subject should be masked.');
  }
}
