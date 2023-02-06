/*
 * @author Shermal Warnakula
 * @since  03/2021
 * @description TaskTriggerHandlerTest is the test class to cover tests for {@link TaskTriggerHandler}
 */
@isTest
private class TaskTriggerHandlerTest {
  public static final String TEST_CALL_SID = 'CA52ac7c0cf5891c04e1873e1f147f9ed6';
  public static final String ORIGINAL_LOG_SUBJECT_IDENTIFIER = 'THIS WAS IN SUBJECT';
  public static Task outboundCallLogTemplate = new Task(
    ActivityDate = Date.Today(),
    CallType = 'Outbound',
    Description = '[Completed] outbound voice. Details: Conference:' +
      '\n' +
      'Sid: CF7bce65a854ead770c7ecec580fd8a36a' +
      '\n' +
      'Participants:' +
      '\n' +
      'Worker: CA83a0103cf721955a36eca75c9a55da9d' +
      '\n' +
      'Customer: CA52ac7c0cf5891c04e1873e1f147f9ed6' +
      '\n' +
      'Call Sid: ' +
      TEST_CALL_SID +
      '\n' +
      'From: +61480022699' +
      '\n' +
      'Outbound To: +61414228054' +
      '\n' +
      'Direction: outbound',
    Priority = 'Normal',
    Status = 'Completed',
    Subject = ORIGINAL_LOG_SUBJECT_IDENTIFIER +
      '[Completed] outbound voice at Wed Mar 24 2021 13:33:22 GMT+1100 (Australian Eastern Daylight Time)',
    TaskSubtype = 'Task',
    Type = 'outbound'
  );

  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    // create an ANZx Customer
    Account acc = new Account(
      Name = 'Test ANZx Account',
      OCV_ID__c = 'TESTOCVID4321',
      ANZx_Customer__c = true
    );
    insert acc;

    // create a Case
    Case generalEnquiryCase = new Case(
      RecordTypeId = CaseCommonActions.GENERAL_INQUIRY_RT_ID,
      AccountId = acc.Id,
      Type = 'Cards'
    );
    insert generalEnquiryCase;

    // create complaint entitlement account
    Account a = new Account(
      Name = 'Complaint Entitlement Account',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = false
    );
    insert a;
    Slaprocess sla = [
      SELECT Id, NAME
      FROM Slaprocess
      WHERE Name = 'complaints' AND IsActive = TRUE AND IsVersionDefault = TRUE
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

    complaintCaselist.addAll(
      new List<Case>{
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
        ),
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
      }
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
    listofTasks.addAll(
      new List<Task>{
        new Task(
          Subject = IDRConstants.TASK_SUBJECT_DAY5,
          Priority = 'Normal',
          ActivityDate = system.today().addDays(60),
          WhatId = standardComplaint.Id
        ),
        new Task(
          Subject = IDRConstants.TASK_SUBJECT_DAY1,
          Priority = 'High',
          ActivityDate = system.today().addDays(60),
          WhatId = standardComplaint.Id
        ),
        new Task(
          Subject = IDRConstants.TASK_SUBJECT_DAY5,
          Priority = 'Normal',
          ActivityDate = system.today().addDays(60),
          WhatId = priorityComplaint.Id
        ),
        new Task(
          Subject = IDRConstants.TASK_SUBJECT_DAY1,
          Priority = 'High',
          ActivityDate = system.today().addDays(60),
          WhatId = priorityComplaint.Id
        )
      }
    );
    try {
      insert listofTasks;
    } catch (DMLexception e) {
      e.getMessage();
    }

    //check standard5Day Task is closed
    List<Task> checkTask = new List<Task>();
    checkTask = [
      SELECT Id, Status
      FROM Task
      WHERE
        Subject = :IDRConstants.TASK_SUBJECT_DAY5
        AND WhatId = :standardComplaint.Id
    ];
    if (checkTask.size() > 0) {
      system.assertEquals(
        'Expired',
        checkTask[0].Status,
        'Status should be as expected.'
      );
    }
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
    newTasks[0].Subject =
      IDRTaskActions.STOP_COLLECTIONS_SUBJECT +
      '- Account with 3rd Party/Asset Finance';
    newTasks[1].Subject =
      IDRTaskActions.START_COLLECTIONS_SUBJECT +
      '- Account with 3rd Party/Asset Finance';
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
    system.assertEquals(
      IDRTaskActions.stopQueue.Id,
      taskList[0].OwnerId,
      'Task owner should be as expected.'
    );
    system.assertEquals(
      IDRTaskActions.startQueue.Id,
      taskList[1].OwnerId,
      'Task owner should be as expected.'
    );
  }

  @isTest
  static void testHappyPathWhenLinkedToCase() {
    // GIVEN a Case record is available with a customer Phone number in it
    // query for Case
    Case caseRec = [
      SELECT Id, ContactId, Type
      FROM Case
      WHERE RecordTypeId = :CaseCommonActions.GENERAL_INQUIRY_RT_ID
      LIMIT 1
    ];
    // link Outbound Task to a Case
    Task outboundTask = outboundCallLogTemplate;
    outboundTask.WhatId = caseRec.Id;

    // WHEN a Coach initiates an Outbound call from Case detail page and completes it
    Test.startTest();

    insert outboundTask;

    Test.stopTest();

    // THEN a Call Log should be automatically created with relevant information auto-populated in it
    // verify updated outbound Call Log fields
    Task insertedTask = [
      SELECT
        Id,
        RecordTypeId,
        TaskSubtype,
        Voice_Call_SID__c,
        Description,
        Subject,
        WhoId
      FROM Task
      WHERE Id = :outboundTask.Id
    ];

    System.assertEquals(
      GetHelpTaskActions.CALL_LOG_RT_ID,
      insertedTask.RecordTypeId,
      'Failed to assign `Call Log` record type while creating outbound call logs'
    );
    System.assertEquals(
      GetHelpTaskActions.TASK_SUBTYPE_CALL,
      insertedTask.TaskSubtype,
      'Failed to assign Task Subtype as `Call` while creating outbound call logs'
    );
    System.assertEquals(
      TEST_CALL_SID,
      insertedTask.Voice_Call_SID__c,
      'Failed to extract Call SID from Description (comments) while creating outbound call logs'
    );
    System.assert(
      insertedTask.Description.contains(ORIGINAL_LOG_SUBJECT_IDENTIFIER),
      'Failed to append original Subject text on Description field value while creating outbound call logs'
    );
    System.assertEquals(
      CommonUtil.getSinglePicklistLabel(Case.Type, caseRec.Type),
      insertedTask.Subject,
      'Failed to assign Type from linked Case as the Task Subject while creating outbound call logs'
    );
    System.assertEquals(
      caseRec.ContactId,
      insertedTask.WhoId,
      'Failed to assign linked customer Contact as WhoId (Name on Task) while creating outbound call logs'
    );
  }

  @isTest
  static void testWhenLinkedToAccount() {
    // GIVEN a Phone number is available on an Account detail page related to a Customer
    // query for Account
    Account accountRec = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = 'TESTOCVID4321'
      LIMIT 1
    ];
    // link Outbound Task directly to Account
    Task outboundTask = outboundCallLogTemplate;
    outboundTask.WhatId = accountRec.Id;

    // WHEN a Coach initiates an Outbound call directly from an Account detail page and completes it
    Test.startTest();

    GetHelpTaskActions.enrichOutboundCallLogs(new List<Task>{ outboundTask });

    Test.stopTest();

    // THEN a Call Log should be automatically created without relying on any information from a Case
    // verify updated outbound Call Log fields
    System.assertEquals(
      outboundCallLogTemplate.Subject,
      outboundTask.Subject,
      'Call Log subject should not have changed if the call was made directly from the Account'
    );
    System.assert(
      outboundTask.WhoId == null,
      'WhoId should not have been populated if the call was made directly from the Account'
    );
  }

  @isTest
  static void testWhenInbound() {
    // GIVEN a Case record is available
    // query for Case
    Case caseRec = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :CaseCommonActions.GENERAL_INQUIRY_RT_ID
      LIMIT 1
    ];
    // link Inbound Task to a Case
    Task inboundTask = outboundCallLogTemplate;
    inboundTask.WhatId = caseRec.Id;
    inboundTask.CallType = 'Inbound';
    inboundTask.Type = '';

    // WHEN a Coach manually creates a Call Log on the Case for an Inbound call interaction
    Test.startTest();

    GetHelpTaskActions.enrichOutboundCallLogs(new List<Task>{ inboundTask });

    Test.stopTest();

    // THEN the custom `outbound Call Log data population logic` should not be applied
    // verify inbound Call Log fields
    System.assertNotEquals(
      TEST_CALL_SID,
      inboundTask.Voice_Call_SID__c,
      'Call Log data population logic should not apply on manually created Inbound Call Logs'
    );
  }

  @isTest
  static void testCallSIDWasMissing() {
    // GIVEN a Coach has completed an Outbound call from Case detail page
    // query for Case
    Case caseRec = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :CaseCommonActions.GENERAL_INQUIRY_RT_ID
      LIMIT 1
    ];
    // link Outbound Task to a Case
    Task outboundTask = outboundCallLogTemplate;
    outboundTask.WhatId = caseRec.Id;
    outboundTask.Description = '[Completed] outbound voice.';

    // WHEN the auto-created Call Log Description does not have a Call Sid in it
    Test.startTest();

    GetHelpTaskActions.enrichOutboundCallLogs(new List<Task>{ outboundTask });

    Test.stopTest();

    // THEN the Voice_Call_SID__c on Task record should not have any values populated
    // verify updated outbound Call Log fields
    System.assertEquals(
      null,
      outboundTask.Voice_Call_SID__c,
      'Voice_Call_SID__c should not have any value populated if Call Sid was not part of the Description (comments) while creating outbound call logs'
    );
  }

  @isTest
  static void testWhenCaseTypeNotSet() {
    // GIVEN a Case record is available without a Type being selected (with a customer Phone number in it)
    // query for Case and deselect Type
    Case caseRec = [
      SELECT Id, Subject
      FROM Case
      WHERE RecordTypeId = :CaseCommonActions.GENERAL_INQUIRY_RT_ID
      LIMIT 1
    ];
    caseRec.Type = null;
    Test.startTest();

    update caseRec;
    // link Outbound Task to a Case
    Task outboundTask = outboundCallLogTemplate;
    outboundTask.WhatId = caseRec.Id;

    // WHEN a Coach initiates an Outbound call from Case detail page and completes it

    GetHelpTaskActions.enrichOutboundCallLogs(new List<Task>{ outboundTask });

    Test.stopTest();

    // THEN the auto-created Call Log `Subject` should have the Case `Subject` instead of Case 'Type'
    // verify updated outbound Call Log fields
    System.assertEquals(
      caseRec.Subject,
      outboundTask.Subject,
      'Call Log Subject should have the Case Subject, if Case Type was not available while creating an outbound call log'
    );
  }
}
