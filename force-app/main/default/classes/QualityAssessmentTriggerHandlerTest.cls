@isTest
private class QualityAssessmentTriggerHandlerTest {
  //method to test pre-populated fields when create Quality Assessment record, value are from Related Case lookup
  @isTest
  static void testPopulateFieldsFromCaseWhenCreateQA() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID,
          Status = GetHelpConstants.CLOSED_STATUS,
          Origin = 'Phone'
        )
      );
    }

    Test.startTest();

    insert newCases;

    Test.stopTest();

    List<Quality_Assessment__c> newQARecords = [
      SELECT
        Id,
        Related_Case__c,
        Related_Case__r.Owner.Type,
        Related_Case__r.OwnerId,
        Interaction_Owner__c,
        Interaction_Type__c
      FROM Quality_Assessment__c
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      newQARecords.size(),
      'Should have ' +
      Label.Test_Bulk_Size +
      ' Quality Assessment records.'
    );

    for (Quality_Assessment__c record : newQARecords) {
      System.assertNotEquals(
        null,
        record.Related_Case__c,
        'Related Case field should not be null if Quality Assessment record is created from Case closure.'
      );

      //Case.Origin = Phone is mapped to Quality_Assessment__c.Interaction_Type__c = Voice Call
      System.assertEquals(
        'Voice Call',
        record.Interaction_Type__c,
        'Interaction Type of Quality Assessment should be Voice Call if realated case origin is Phone.'
      );

      if (record.Related_Case__r?.Owner.Type == 'Queue') {
        System.assertEquals(
          null,
          record.Interaction_Owner__c,
          'Interaction Owner field should be null if Related Case owner is a queue.'
        );
      } else if (record.Related_Case__r?.Owner.Type == 'User') {
        System.assertNotEquals(
          null,
          record.Interaction_Owner__c,
          'Interaction Owner field should not be null if Related Case owner is a user.'
        );
      }
    }
  }

  //method to test format Name field when create Quality Assessment record
  @isTest
  static void testFormatQARecordName() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID,
          Status = GetHelpConstants.CLOSED_STATUS
        )
      );
    }

    Test.startTest();

    insert newCases;

    Test.stopTest();

    List<Quality_Assessment__c> newQARecords = [
      SELECT Id, Name
      FROM Quality_Assessment__c
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      newQARecords.size(),
      'Should have ' +
      Label.Test_Bulk_Size +
      ' Quality Assessment records.'
    );

    for (Quality_Assessment__c record : newQARecords) {
      System.assert(
        record.Name.contains('Q-'),
        'Name field should have format Q-00000000. Actual is ' + record.Name
      );
    }
  }

  //method to test the Assign to Coach Lead Escalation Queue when QA updates to Breached
  @isTest
  static void testAssignTocoachLeadQueueWhenQAUpdatedToBreached() {
    Quality_Assessment__c[] newQARecords = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQARecords.add(new Quality_Assessment__c(Status__c = 'In Progress'));
    }
    insert newQARecords;

    for (Integer i = 0; i < newQARecords.size(); i++) {
      newQARecords[i].Status__c = QualityAssessmentActions.STATUS_REFERRED;
      newQARecords[i]
        .Sub_Status__c = QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW;
    }

    Test.startTest();

    update newQARecords;
    Test.stopTest();

    Group coachLeadQueue = [
      SELECT Id
      FROM Group
      WHERE type = 'Queue' AND DeveloperName = 'Coach_Lead_Escalation'
      LIMIT 1
    ];

    List<Quality_Assessment__c> records = [
      SELECT Id, OwnerId
      FROM Quality_Assessment__c
    ];

    for (Integer i = 0; i < records.size(); i++) {
      System.assertEquals(
        coachLeadQueue.Id,
        records[i].OwnerId,
        'Breached QA should be assigned to Coach Lead Escalation queue'
      );
    }
  }

  //method to test the Assign to Quality Assessor Queue when QA is created
  @isTest
  static void testAssignToqualityAssessorQueueWhenQACreated() {
    Quality_Assessment__c[] newQARecords = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQARecords.add(
        new Quality_Assessment__c(
          RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
          Status__c = QualityAssessmentActions.STATUS_UNASSIGNED
        )
      );
    }

    Test.startTest();
    insert newQARecords;

    Test.stopTest();

    Group qualityAssessorQueue = [
      SELECT Id
      FROM Group
      WHERE type = 'Queue' AND DeveloperName = 'Quality_Assessor'
      LIMIT 1
    ];

    List<Quality_Assessment__c> records = [
      SELECT Id, OwnerId
      FROM Quality_Assessment__c
    ];

    for (Integer i = 0; i < records.size(); i++) {
      System.assertEquals(
        qualityAssessorQueue.Id,
        records[i].OwnerId,
        'Unassigned QA should be assigned to Quality Assessor queue'
      );
    }
  }

  //method to test the Assign to Coach Lead Escalation Queue when QA created with Compliance Review sub status
  @isTest
  static void testAssignTocoachLeadQueueWhenQACreatedWithBreached() {
    Quality_Assessment__c[] newQARecordsList = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQARecordsList.add(
        new Quality_Assessment__c(
          RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
          Status__c = QualityAssessmentActions.STATUS_REFERRED,
          Sub_Status__c = QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW
        )
      );
    }

    Test.startTest();
    insert newQARecordsList;
    Test.stopTest();

    Group coachLeadQueue = [
      SELECT Id
      FROM Group
      WHERE type = 'Queue' AND DeveloperName = 'Coach_Lead_Escalation'
      LIMIT 1
    ];

    List<Quality_Assessment__c> records = [
      SELECT Id, OwnerId
      FROM Quality_Assessment__c
    ];

    for (Integer i = 0; i < records.size(); i++) {
      System.assertEquals(
        coachLeadQueue.Id,
        records[i].OwnerId,
        'Breached QA should be assigned to Coach Lead Escalation queue'
      );
    }
  }

  //method to test create compliance tasks when new Quality Assessment get created with Compliance Review sub status
  @isTest
  static void testCreateComplianceTaskWhenQACreatedWithBreached() {
    List<Quality_Assessment__c> newQAs = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQAs.add(
        new Quality_Assessment__c(
          RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
          Status__c = QualityAssessmentActions.STATUS_REFERRED,
          Sub_Status__c = QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW
        )
      );
    }

    Test.startTest();

    List<Task> tasks = [SELECT Id FROM Task];

    System.assertEquals(
      0,
      tasks.size(),
      'Should have 0 task before creating Quality Assessment records.'
    );

    insert newQAs;

    Test.stopTest();

    try {
      List<Task> newTasks = [
        SELECT Id, Subject, Status, Priority, RecordTypeId, OwnerId
        FROM Task
      ];

      Group complianceTaskQueue = [
        SELECT Id
        FROM Group
        WHERE DeveloperName = 'Compliance_Tasks' AND Type = 'Queue'
        LIMIT 1
      ];

      System.assertEquals(
        Integer.valueOf(Label.Test_Bulk_Size),
        newTasks.size(),
        'Should have ' +
        Label.Test_Bulk_Size +
        ' new Tasks.'
      );

      for (Task record : newTasks) {
        System.assert(
          record.Subject.contains(
            QualityAssessmentTaskActions.TASK_SUBJECT_COMPLIANCE_REVIEW
          ),
          'Task Subject should be ' +
          QualityAssessmentTaskActions.TASK_SUBJECT_COMPLIANCE_REVIEW
        );
        System.assertEquals(
          QualityAssessmentTaskActions.TASK_STATUS_NOT_STARTED,
          record.Status,
          'Task Status should be ' +
          QualityAssessmentTaskActions.TASK_STATUS_NOT_STARTED
        );
        System.assertEquals(
          QualityAssessmentTaskActions.TASK_PRIORITY_HIGH,
          record.Priority,
          'Task Priority should be ' +
          QualityAssessmentTaskActions.TASK_PRIORITY_HIGH
        );
        System.assertEquals(
          GetHelpConstants.TASK_COMPLIANCE_RT_ID,
          record.RecordTypeId,
          'Task RecordTypeId should be ' +
          GetHelpConstants.TASK_COMPLIANCE_RT_ID
        );
        System.assertEquals(
          complianceTaskQueue.Id,
          record.OwnerId,
          'Task Owner should be Compliance Task queue.'
        );
      }
    } catch (System.QueryException e) {
      system.assert(
        e.getMessage().contains('List has no rows for assignment to sobject'),
        'Should have no such a queue called Compliance Task.'
      );
    }
  }

  //method to test create compliance tasks when Quality Assessment get updated to Compliance Review sub status
  @isTest
  static void testCreateComplianceTaskWhenQAUpdatedWithBreached() {
    List<Quality_Assessment__c> newQAs = new List<Quality_Assessment__c>();

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQAs.add(
        new Quality_Assessment__c(
          RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
          Status__c = QualityAssessmentActions.STATUS_UNASSIGNED
        )
      );
    }

    Test.startTest();

    insert newQAs;

    List<Task> tasks = [SELECT Id FROM Task];

    System.assertEquals(
      0,
      tasks.size(),
      'Should have 0 task before updating Quality Assessment records.'
    );

    for (Quality_Assessment__c record : newQAs) {
      record.Status__c = QualityAssessmentActions.STATUS_REFERRED;
      record.Sub_Status__c = QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW;
    }

    update newQAs;

    Test.stopTest();

    try {
      List<Task> newTasks = [
        SELECT Id, Subject, Status, Priority, RecordTypeId, OwnerId
        FROM Task
      ];

      Group complianceTaskQueue = [
        SELECT Id
        FROM Group
        WHERE DeveloperName = 'Compliance_Tasks' AND Type = 'Queue'
        LIMIT 1
      ];

      System.assertEquals(
        Integer.valueOf(Label.Test_Bulk_Size),
        newTasks.size(),
        'Should have ' +
        Label.Test_Bulk_Size +
        ' new Tasks.'
      );

      for (Task record : newTasks) {
        System.assert(
          record.Subject.contains(
            QualityAssessmentTaskActions.TASK_SUBJECT_COMPLIANCE_REVIEW
          ),
          'Task Subject should be ' +
          QualityAssessmentTaskActions.TASK_SUBJECT_COMPLIANCE_REVIEW
        );
        System.assertEquals(
          QualityAssessmentTaskActions.TASK_STATUS_NOT_STARTED,
          record.Status,
          'Task Status should be ' +
          QualityAssessmentTaskActions.TASK_STATUS_NOT_STARTED
        );
        System.assertEquals(
          QualityAssessmentTaskActions.TASK_PRIORITY_HIGH,
          record.Priority,
          'Task Priority should be ' +
          QualityAssessmentTaskActions.TASK_PRIORITY_HIGH
        );
        System.assertEquals(
          GetHelpConstants.TASK_COMPLIANCE_RT_ID,
          record.RecordTypeId,
          'Task RecordTypeId should be ' +
          GetHelpConstants.TASK_COMPLIANCE_RT_ID
        );
        System.assertEquals(
          complianceTaskQueue.Id,
          record.OwnerId,
          'Task Owner should be Compliance Task queue.'
        );
      }
    } catch (System.QueryException e) {
      system.assert(
        e.getMessage().contains('List has no rows for assignment to sobject'),
        'Should have no such a queue called Compliance Task.'
      );
    }
  }

  //test to ensure that when an ANZx complaint is escalated to a CMOS complaint it is not displayed in QA
  @istest
  static void testQACreatedForComplaintsEscalatedToCRC() {
    Case[] complaintCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      complaintCases.add(
        new Case(RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID)
      );
    }

    insert complaintCases;

    for (Integer i = 0; i < complaintCases.size(); i++) {
      complaintCases[i].Status = 'Escalated';
      complaintCases[i].IDR_Escalation_Reason__c = 'Indexing';
      complaintCases[i].RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    }

    update complaintCases;

    for (Integer i = 0; i < complaintCases.size(); i++) {
      complaintCases[i].Status = 'Closed';
      complaintCases[i].IDR_Complaint_Outcome__c = '1';
      complaintCases[i].IDR_Description_of_Outcome__c = 'test';
    }

    Test.startTest();

    update complaintCases;

    Test.stopTest();

    Integer qaCount = [SELECT COUNT() FROM Quality_Assessment__c];

    System.assertEquals(
      0,
      qaCount,
      'Should have no QA record been created if cases are originates as ANZx Complaints but were escalated to CRC.'
    );
  }

  @istest
  static void testQAvalidation() {
    Faker faker = new Faker('AU');
    // insert an account
    Account caseTestAccount = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert caseTestAccount;

    Account unlinkedTestAccount = new Account(
      Name = 'TestAccount2',
      Display_Name__c = 'TestAccount2',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert unlinkedTestAccount;

    // insert one case record, with caseTestAccount as the customer
    Case caseRecord = new Case(
      Subject = 'Dispute Case',
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      Origin = 'Chat',
      AccountId = caseTestAccount.Id
    );
    insert caseRecord;

    // create QA records with the unlinkedTestAccount as a customer, and the case with a different account
    List<Quality_Assessment__c> newQArecords = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQArecords.add(
        new Quality_Assessment__c(
          RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
          Related_Case__c = caseRecord.Id,
          Interaction_Type__c = 'Email',
          Customer__c = unlinkedTestAccount.Id
        )
      );
    }

    Boolean exceptionWasThrown = false;

    Test.startTest();
    try {
      insert newQArecords;
    } catch (Exception e) {
      System.assert(
        e.getMessage()
          .contains(
            'Related case must be under the same customer as the QA record'
          ),
        'Incorrect error message.'
      );
      exceptionWasThrown = true;
    }
    Test.stopTest();

    System.assert(exceptionWasThrown);
  }
}
