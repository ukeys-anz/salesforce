/* @description TestTaskTriggerHandler test class for TaskTriggerHandler
 * @author Boobalakrishnan Duraisamy
 * @since 02/2021
 */
@isTest
private class TestTaskTriggerHandler {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    account a = new account(
      Name = 'Complaint Entitlement Account',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = false
    );
    insert a;
    Slaprocess sla = [
      SELECT Id, NAME
      FROM Slaprocess
      WHERE Name = 'complaints'
      LIMIT 1
    ];
    //insert sla;
    Entitlement et = new Entitlement(
      Name = 'Complaints Entitlement',
      AccountId = a.Id,
      StartDate = Date.valueof(System.now().addDays(-2)),
      SlaProcessId = sla.Id
    );
    insert et;
    Case[] complaintCaselist = new List<Case>();

    complaintCaselist.add(
      new Case(
        IDR_Account_Card_Policy_Number__c = '000001234',
        Description = 'Test IDR Maximum Time Standard',
        IDR_Complainant_Desired_Outcome__c = 'Test IDR Maximum Time Standard',
        IDR_Description_of_Outcome__c = 'Test IDR Maximum Time Standard',
        IDR_Systemic_Issue_Description__c = 'None',
        IDR_Date_Received__c = system.now(),
        RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
        IDR_Customer_Number__c = '1234567890',
        Priority = 'Standard'
      )
    );

    complaintCaselist.add(
      new Case(
        IDR_Account_Card_Policy_Number__c = '000001234',
        Description = 'Test IDR Maximum Time Priority',
        IDR_Complainant_Desired_Outcome__c = 'Test IDR Maximum Time Priority',
        IDR_Description_of_Outcome__c = 'Test IDR Maximum Time Priority',
        IDR_Systemic_Issue_Description__c = 'None',
        IDR_Date_Received__c = system.now(),
        RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
        IDR_Customer_Number__c = '1234567890',
        Priority = 'Vulnerable Customer'
      )
    );
    insert complaintCaselist;
  }

  @isTest
  static void testcheckIDRMaximumTimeTasks() {
    case standardComplaint = [
      SELECT Id
      FROM Case
      WHERE
        RecordTypeId = :IDRConstants.CUSTOMER_COMPLAINT_RT_ID
        AND Priority = 'Standard'
      LIMIT 1
    ];
    case priorityComplaint = [
      SELECT Id
      FROM Case
      WHERE
        RecordTypeId = :IDRConstants.CUSTOMER_COMPLAINT_RT_ID
        AND Priority = 'Vulnerable Customer'
      LIMIT 1
    ];
    List<Task> listofTasks = new List<Task>();

    Task standard5day = new Task(
      Subject = IDRConstants.TASK_SUBJECT_DAY5,
      Priority = 'Normal',
      ActivityDate = system.today().addDays(60),
      WhatId = standardComplaint.Id
    );
    insert standard5day;
    Task standard1day = new Task(
      Subject = IDRConstants.TASK_SUBJECT_DAY1,
      Priority = 'High',
      ActivityDate = system.today().addDays(60),
      WhatId = standardComplaint.Id
    );
    listofTasks.add(standard1day);

    Task priority5day = new Task(
      Subject = IDRConstants.TASK_SUBJECT_DAY5,
      Priority = 'Normal',
      ActivityDate = system.today().addDays(60),
      WhatId = priorityComplaint.Id
    );
    listofTasks.add(priority5day);
    Task priority1day = new Task(
      Subject = IDRConstants.TASK_SUBJECT_DAY1,
      Priority = 'High',
      ActivityDate = system.today().addDays(60),
      WhatId = priorityComplaint.Id
    );
    listofTasks.add(priority1day);

    insert ListofTasks;

    //check standard5Day Task is closed
    task checkTask = [
      SELECT Id, Status
      FROM Task
      WHERE
        Subject = :IDRConstants.TASK_SUBJECT_DAY5
        AND WhatId = :standardComplaint.Id
    ];

    system.assertEquals('Expired', checkTask.Status);
  }

  @isTest
  static void testCollectionTaskCreation() {
    List<Case> newCases = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :IDRConstants.CUSTOMER_COMPLAINT_RT_ID
    ];
    List<Task> newTasks = new List<Task>();

    Test.startTest();
    //GIVEN list of collection tasks created by Mulesoft
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          whatId = newCases[0].Id,
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Status = 'Open',
          Priority = 'High',
          ActivityDate = system.today()
        )
      );
    }
    newTasks[0].Subject = 'STOP Collection FOR ****1111';
    newTasks[1].Subject = 'START Collection FOR ****1111';
    //WHEN they are inserted into Salesforce
    insert newTasks;

    Test.stopTest();

    List<Task> taskList = [
      SELECT OwnerId
      FROM Task
      WHERE
        RecordTypeId = :IDRConstants.IDR_SYSTEM_TASK_RT_ID
        AND Status = 'Open'
    ];
    //THEN they are automatically assigned to STOP or START collections queue
    system.assertEquals(IDRTaskActions.stopQueue.Id, taskList[0].OwnerId);
    system.assertEquals(IDRTaskActions.startQueue.Id, taskList[1].OwnerId);
  }
}
