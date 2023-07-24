/**
 * @description       : Test class for Quality Assessment Trigger Handler
 * @author            : Prakash
 * @group             :
 * @last modified on  : 10-04-2022
 **/
@isTest
private class QualityAssessmentTriggerHandlerTest {
  private static final String CUSTOMER_PURPOSE = 'Customer';
  private static final String STORE_LOCATION = 'Store';
  public static final String REFERENCE_VALUE = 'TestRef';

  //method to test the Assign to Coach Lead Escalation Queu e when QA updates to Breached
  @isTest
  static void testAssignTocoachLeadQueueWhenQAUpdatedToBreached() {
    Quality_Assessment__c[] newQARecords = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQARecords.add(
        new Quality_Assessment__c(
          Status__c = 'In Progress',
          Reference__c = REFERENCE_VALUE
        )
      );
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

  //method to test the Assign to Coach Lead Escalation Queue when QA created with Compliance Review sub status
  @isTest
  static void testAssignTocoachLeadQueueWhenQACreatedWithBreached() {
    Quality_Assessment__c[] newQARecordsList = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQARecordsList.add(
        new Quality_Assessment__c(
          RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
          Status__c = QualityAssessmentActions.STATUS_REFERRED,
          Sub_Status__c = QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW,
          Reference__c = REFERENCE_VALUE
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
          Sub_Status__c = QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW,
          Reference__c = REFERENCE_VALUE
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
          Status__c = QualityAssessmentActions.STATUS_UNASSIGNED,
          Reference__c = REFERENCE_VALUE
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
      complaintCases[i].Has_complaint_met_RG_271_delay_criteria__c = 'No';
      complaintCases[i].How_has_delay_criteria_been_met_not_met__c = 'test';
      complaintCases[i].IDR_Is_Common__c = 'No';
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
  static void testQAValidation() {
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
          Evaluation_Type__c = 'Chat',
          Interaction_Type__c = 'Email',
          Customer__c = unlinkedTestAccount.Id
        )
      );
    }

    Boolean exceptionWasThrown = false;

    Test.startTest();
    try {
      insert newQArecords;
      System.assert(
        false,
        'Failed to prevent against user creating quality assessment.'
      );
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

    System.assert(exceptionWasThrown, 'The exception error should be thrown.');
  }

  @isTest
  static void testCreateQAShareRecord() {
    Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole role = CommonUtil.getUserRoleByDevName('FraudX_Agent');
    User fraudXAgent = new User();
    System.runAs(new User(Id = UserInfo.getUserId())) {
      fraudXAgent = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'FraudXTest',
          'ProfileId' => profile.Id,
          'UserRoleId' => role.Id
        }
      );
      insert fraudXAgent;
    }
    Quality_Assessment__c[] newQARecords = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQARecords.add(
        new Quality_Assessment__c(
          Status__c = QualityAssessmentActions.STATUS_IN_PROGRESS,
          Interaction_Owner__c = fraudXAgent.Id,
          Reference__c = REFERENCE_VALUE
        )
      );
    }
    insert newQARecords;
    Set<Id> qaIds = new Set<Id>();
    for (Integer i = 0; i < newQARecords.size(); i++) {
      newQARecords[i].Status__c = QualityAssessmentActions.STATUS_COMPLETE;
      newQARecords[i]
        .Sub_Status__c = QualityAssessmentActions.SUB_STATUS_EVALUATION_COMPLETED;
      newQARecords[i].Context_and_General_Comments__c = 'test comment';
      qaIds.add(newQARecords[i].Id);
    }

    Test.startTest();
    update newQARecords;
    Test.stopTest();
    Quality_Assessment__Share[] shareRecords = [
      SELECT Id, AccessLevel, ParentId, UserOrGroupId
      FROM Quality_Assessment__Share
      WHERE ParentId IN :qaIds AND AccessLevel != 'All'
    ];
    System.assertEquals(
      newQARecords.size(),
      shareRecords.size(),
      'sharing record number does not match'
    );
    System.assertEquals(
      'Read',
      shareRecords[0].AccessLevel,
      'wrong access level'
    );
    System.assertEquals(
      fraudXAgent.Id,
      shareRecords[0].UserOrGroupId,
      'assign to the wrong user'
    );
  }

  @isTest
  static void testValidateEvaluationType() {
    Case scamCase = new Case(RecordTypeId = GetHelpConstants.SCAM_RT_ID);
    insert scamCase;
    System.assertNotEquals(
      null,
      scamCase.Id,
      'scam case should be created with an Id'
    );
    Quality_Assessment__c[] newQARecords = new List<Quality_Assessment__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newQARecords.add(
        new Quality_Assessment__c(
          RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID,
          Related_Case__c = scamCase.Id,
          Evaluation_Type__c = 'Identity & KYC'
        )
      );
    }
    Boolean exceptionThrown = false;
    try {
      Test.startTest();
      insert newQARecords;
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
      System.AssertEquals(
        true,
        e.getMessage()
          .contains(QualityAssessmentActions.EVALUATION_TYPE_MAPPING_ERROR),
        'not expected error'
      );
    }
    System.assertEquals(true, exceptionThrown, 'No exception was thrown');
  }

  // method to test updating related cases in afterInsert and afterUpdate trigger
  @isTest
  private static void testUpdateRelatedCases() {
    List<Quality_Assessment__c> qaRecords = new List<Quality_Assessment__c>();
    List<Case> testCases = new List<Case>();
    testCases.add(new Case(RecordTypeId = GetHelpConstants.FRAUD_RT_ID));
    testCases.add(
      new Case(
        Subject = 'Dispute Case',
        RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
        Origin = 'Chat'
      )
    );
    insert testCases;

    Test.startTest();
    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID,
      Related_Case__c = testCases[0].Id,
      Evaluation_type__c = 'Fraud & Dispute'
    );
    qaRecords.add(qaRecord);
    Quality_Assessment__c qaRecord1 = new Quality_Assessment__c(
      RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GETHELP_RT_ID,
      //Related_Case__c = testCases[1].Id,
      Evaluation_type__c = 'Email',
      Interaction_Type__c = 'Email',
      Reference__c = REFERENCE_VALUE
    );
    qaRecords.add(qaRecord1);
    insert qaRecords;
    qaRecord1.Related_Case__c = testCases[1].Id;
    qaRecord1.Reference__c = '';
    update qaRecord1;
    Test.stopTest();

    System.assertEquals(
      true,
      [SELECT Has_Assessment__c FROM Case WHERE Id = :testCases[0].Id]
      .Has_Assessment__c,
      'case has assessment should be true'
    );
    System.assertEquals(
      true,
      [SELECT Has_Assessment__c FROM Case WHERE Id = :testCases[1].Id]
      .Has_Assessment__c,
      'case has assessment should be true'
    );
  }

  //method to test createChatterPost method, need SeeAllData=true to test ConnectApi
  @isTest(SeeAllData=true)
  private static void testCreateChatterPost() {
    User groupUser = TestUtil.createTestUserWithProfile('System Administrator');
    insert groupUser;
    List<String> groupPSs = new List<String>{
      'Quality_Assessment_Read_Write',
      'Case Read/Write - Quality Analyst'
    };
    List<PermissionSet> groupPsList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :groupPSs
    ];
    List<PermissionSetAssignment> groupPsaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : groupPsList) {
      groupPsaList.add(TestUtil.createPSAssignment(groupUser.id, ps.Id));
    }
    insert groupPsaList;
    //create chatter groups if missing
    List<CollaborationGroup> groups = [
      SELECT Id
      FROM CollaborationGroup
      WHERE
        Name IN (
          :QualityAssessmentActions.GROUP_ASSURANCE_TEAM,
          :QualityAssessmentActions.GROUP_COACH_LEAD,
          :QualityAssessmentActions.GROUP_JOIN_LEAD
        )
    ];
    if (groups.size() == 0) {
      groups.add(
        new CollaborationGroup(
          Name = QualityAssessmentActions.GROUP_ASSURANCE_TEAM,
          CollaborationType = 'Private'
        )
      );
      groups.add(
        new CollaborationGroup(
          Name = QualityAssessmentActions.GROUP_COACH_LEAD,
          CollaborationType = 'Private'
        )
      );
      groups.add(
        new CollaborationGroup(
          Name = QualityAssessmentActions.GROUP_JOIN_LEAD,
          CollaborationType = 'Private'
        )
      );
      insert groups;
    }

    System.runAs(groupUser) {
      List<CollaborationGroupMember> collGroupMembers = new List<CollaborationGroupMember>();
      for (CollaborationGroup cg : groups) {
        CollaborationGroupMember member = new CollaborationGroupMember();
        member.MemberId = groupUser.Id;
        member.CollaborationGroupId = cg.Id;
        collGroupMembers.add(member);
      }
      upsert collGroupMembers;

      List<Quality_Assessment__c> qaRecords = new List<Quality_Assessment__c>();
      List<Case> testCases = new List<Case>();
      testCases.add(new Case(RecordTypeId = GetHelpConstants.FRAUD_RT_ID));
      testCases.add(
        new Case(
          Subject = 'Dispute Case',
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          Origin = 'Chat'
        )
      );
      insert testCases;

      Test.startTest();
      Quality_Assessment__c qaRecord = new Quality_Assessment__c(
        RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID,
        Related_Case__c = testCases[0].Id,
        Evaluation_type__c = 'Fraud & Dispute',
        Status__c = 'Referred',
        Sub_Status__c = 'Other'
      );
      qaRecords.add(qaRecord);
      Quality_Assessment__c qaRecord1 = new Quality_Assessment__c(
        RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GETHELP_RT_ID,
        //Related_Case__c = testCases[1].Id,
        Evaluation_type__c = 'Email',
        Interaction_Type__c = 'Email',
        Reference__c = REFERENCE_VALUE
      );
      qaRecords.add(qaRecord1);
      insert qaRecords;
      qaRecord1.Status__c = 'Referred';
      qaRecord1.Sub_Status__c = 'Compliance Review';
      qaRecord1.Reference__c = REFERENCE_VALUE;
      update qaRecord1;
      Test.stopTest();

      System.assertEquals(
        true,
        [
            SELECT Body, HasLink, ParentId, Status, RelatedRecordId, Title
            FROM FeedItem
            WHERE ParentId = :qaRecord.Id
          ]
          ?.Body.contains('There is a new item for review.'),
        'failed to create the chatter feed'
      );
      System.assertEquals(
        true,
        [
            SELECT Body, HasLink, ParentId, Status, RelatedRecordId, Title
            FROM FeedItem
            WHERE ParentId = :qaRecord1.Id
          ]
          ?.Body.contains('There is a new item for review.'),
        'failed to create the chatter feed'
      );
    }
  }

  //method to test populateFieldsBeforeTrigger mehtod
  @isTest
  private static void testPopulateFieldsBeforeTrigger() {
    Faker faker = new Faker('AU');

    Lead testLead = new Lead(
      RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID,
      FirstName = faker.randomString(6),
      LastName = faker.randomString(6),
      Company = faker.randomString(6),
      Email = faker.randomString(6) + '@testtest.com',
      MobilePhone = faker.person.phone()
    );
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      insert testLead;
    }

    Interaction interaction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      Lead__c = testLead.Id,
      Name = faker.randomString(10),
      StartTime = Datetime.now(),
      Interaction_Purpose__c = CUSTOMER_PURPOSE,
      InteractionType = 'Call'
    );
    insert interaction;

    Test.startTest();
    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID,
      Interaction__c = interaction.Id,
      Evaluation_type__c = 'Fraud & Dispute'
    );
    insert qaRecord;
    Quality_Assessment__c qa = [
      SELECT Id, Lead__c, Interaction_Date_Time__c
      FROM Quality_Assessment__c
      WHERE Id = :qaRecord.Id
    ];
    System.assertEquals(testLead.Id, qa.Lead__c, 'lead field populated');
    System.assertEquals(
      Date.today(),
      qa.Interaction_Date_Time__c.date(),
      'interaction date not populated'
    );

    Test.stopTest();
  }
}
