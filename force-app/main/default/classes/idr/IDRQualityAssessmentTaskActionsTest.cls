/**
 * @author CMOS
 * @since 09-2025
 * @description Test class for IDRQualityAssessmentTaskActions
 */
@isTest
public with sharing class IDRQualityAssessmentTaskActionsTest {
  static Lib_MockProvider qaRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Id ownerUserId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
  static void registerMocks() {
    qaRepoMock = Lib_MockProvider.forType(IDRQualityAssessmentRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testCheckOnReversionFromComplete() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    oldQa.OwnerId = ownerUserId;
    Quality_Assessment__c newQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    newQa.OwnerId = ownerUserId;
    newQa.Id = oldQa.Id;
    Task task1 = IDRTestDataFactory.getTask(
      oldQa.Id,
      IDRConstants.TASK_QA_COMPLIANCE_SUBJECT
    );
    Task task2 = IDRTestDataFactory.getTask(
      oldQa.Id,
      IDRConstants.TASK_QA_FEEDBACK_SUBJECT
    );
    Quality_Assessment__Share qaShare = IDRTestDataFactory.getQAShare(
      newQa.Id,
      manager.Id
    );
    qaRepoMock.mock('getOpenTask', new List<Task>{ task1, task2 });
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + task1.Id + '","errors":[]}'
        ),
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + task2.Id + '","errors":[]}'
        )
      }
    );
    qaRepoMock.mock(
      'getQAShareRecords',
      new List<Quality_Assessment__Share>{ qaShare }
    );
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(
          '{"success":true,"id":"' + qaShare.Id + '","errors":[]}'
        )
      }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.checkOnReversionFromComplete(
      new List<Quality_Assessment__c>{ newQa },
      new Map<Id, Quality_Assessment__c>{ oldQa.Id => oldQa }
    );
    Test.stopTest();
    List<Task> updatedTasks = (List<Task>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      IDRConstants.TASK_STATUS_EXPIRED,
      updatedTasks[0].Status,
      'Task record status field is not updated to ' +
      IDRConstants.TASK_STATUS_EXPIRED
    );
    Assert.areEqual(
      IDRConstants.TASK_STATUS_EXPIRED,
      updatedTasks[1].Status,
      'Task record status field is not updated to ' +
      IDRConstants.TASK_STATUS_EXPIRED
    );
    List<Quality_Assessment__Share> deletedShares = (List<Quality_Assessment__Share>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      deletedShares.size(),
      'There should be one share record deleted'
    );
  }

  /**
   * @description Test negative scenario when QA record is updated to Pending status but records are filtered out so Tasks are not updated.
   */
  @isTest
  static void testCheckOnReversionFromCompleteNoTasks() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    oldQa.OwnerId = ownerUserId;
    Quality_Assessment__c newQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    newQa.OwnerId = ownerUserId;
    newQa.Id = oldQa.Id;
    Task task1 = IDRTestDataFactory.getTask(
      oldQa.Id,
      IDRConstants.TASK_CORRESPONDENCE_SUBJECT
    );
    Quality_Assessment__Share qaShare = IDRTestDataFactory.getQAShare(
      newQa.Id,
      manager.Id
    );
    qaRepoMock.mock('getOpenTask', new List<Task>{ task1 });
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{ TestUtil.getMockSaveResult('{}') }
    );
    qaRepoMock.mock(
      'getQAShareRecords',
      new List<Quality_Assessment__Share>{ qaShare }
    );
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(
          '{"success":true,"id":"' + qaShare.Id + '","errors":[]}'
        )
      }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.checkOnReversionFromComplete(
      new List<Quality_Assessment__c>{ newQa },
      new Map<Id, Quality_Assessment__c>{ oldQa.Id => oldQa }
    );
    Test.stopTest();
    List<Task> updatedTasks = (List<Task>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(0, updatedTasks.size(), 'No records should be updated');
  }
  /**
   * @description Test positive scenario when QA record is updated to Complete status so QA record is shared with Case manager.
   */
  @isTest
  static void testCreateQAShareRecord() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    oldQa.OwnerId = ownerUserId;
    Quality_Assessment__c newQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    newQa.OwnerId = ownerUserId;
    newQa.Id = oldQa.Id;
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":1323235,"errors":[]}')
      }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.createQAShareRecord(
      new List<Quality_Assessment__c>{ newQa },
      new Map<Id, Quality_Assessment__c>{ oldQa.Id => oldQa }
    );
    Test.stopTest();
    List<Quality_Assessment__Share> insertedQAShare = (List<Quality_Assessment__Share>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      insertedQAShare[0].AccessLevel,
      'Edit',
      'Quality assessment share record should have been inserted with Edit access'
    );
  }
  /**
   * @description Test negative scenario when QA record is updated to Complete status but records are filtered out so record is not shared with manager.
   */
  @isTest
  static void testCreateQAShareRecordNegative() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    oldQa.OwnerId = ownerUserId;
    Quality_Assessment__c newQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_WITHDRAWN
    );
    newQa.OwnerId = ownerUserId;
    newQa.Id = oldQa.Id;
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{ TestUtil.getMockSaveResult('{}') }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.createQAShareRecord(
      new List<Quality_Assessment__c>{ newQa },
      new Map<Id, Quality_Assessment__c>{ oldQa.Id => oldQa }
    );
    Test.stopTest();
    List<Quality_Assessment__Share> insertedQAShare = (List<Quality_Assessment__Share>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      0,
      insertedQAShare.size(),
      'No Quality assessment share record should have been inserted'
    );
  }
  /**
   * @description Test positive scenario when QA record is updated to Complete status and compliance tasks are created.
   */
  @isTest
  static void testCreateComplianceTasks() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    Quality_Assessment__c oldQafl = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    oldQa.OwnerId = ownerUserId;
    oldQa.Evaluation_Type__c = IDRConstants.QA_CR_ASSESSMENT;
    oldQa.Corrective_actions_for_TM_CM__c = '';
    oldQafl.OwnerId = ownerUserId;
    oldQafl.Evaluation_Type__c = IDRConstants.QA_FRONTLINE_ASSESSMENT;
    oldQafl.Corrective_actions_requiring_FL_action__c = '';
    Quality_Assessment__c newQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    newQa.OwnerId = ownerUserId;
    newQa.Id = oldQa.Id;
    newQa.Evaluation_Type__c = IDRConstants.QA_CR_ASSESSMENT;
    newQa.Corrective_actions_for_TM_CM__c = 'Coaching recommended';
    Quality_Assessment__c newQafl = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    newQafl.OwnerId = ownerUserId;
    newQafl.Id = oldQa.Id;
    newQafl.Evaluation_Type__c = IDRConstants.QA_FRONTLINE_ASSESSMENT;
    newQafl.Corrective_actions_requiring_FL_action__c = 'Other';

    qaRepoMock.mock(
      'getQualityAssessments',
      new List<Quality_Assessment__c>{ newQa, newQafl }
    );

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":1323235,"errors":[]}')
      }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.createComplianceTasks(
      new List<Quality_Assessment__c>{ newQa, newQafl },
      new Map<Id, Quality_Assessment__c>{
        oldQa.Id => oldQa,
        oldQafl.Id => oldQafl
      }
    );
    Test.stopTest();
    List<Task> insertedTasks = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');
    Assert.areEqual(
      4,
      insertedTasks.size(),
      '4 Tasks should have been inserted'
    );
    Assert.areEqual(
      true,
      insertedTasks[0]
        .Subject.startsWith(IDRConstants.TASK_QA_COMPLIANCE_SUBJECT),
      '1st CR Task should start with ' + IDRConstants.TASK_QA_COMPLIANCE_SUBJECT
    );
    Assert.areEqual(
      true,
      insertedTasks[1]
        .Subject.startsWith(IDRConstants.TASK_QA_COMPLIANCE_SUBJECT),
      '1st FL Task should start with ' + IDRConstants.TASK_QA_COMPLIANCE_SUBJECT
    );
    Assert.areEqual(
      true,
      insertedTasks[2]
        .Subject.startsWith(IDRConstants.TASK_QA_FEEDBACK_SUBJECT),
      '2nd CR Task should start with ' + IDRConstants.TASK_QA_FEEDBACK_SUBJECT
    );
    Assert.areEqual(
      true,
      insertedTasks[3]
        .Subject.startsWith(IDRConstants.TASK_QA_FEEDBACK_SUBJECT),
      '2nd FL Task should start with ' + IDRConstants.TASK_QA_FEEDBACK_SUBJECT
    );
  }
  /**
   * @description Test negative scenario when QA record is updated to Complete status but no compliance tasks are created.
   */

  @isTest
  static void testCreateComplianceTasksNegative() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    oldQa.OwnerId = ownerUserId;
    oldQa.Corrective_actions_for_TM_CM__c = '';
    Quality_Assessment__c newQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    newQa.OwnerId = ownerUserId;
    newQa.Id = oldQa.Id;
    newQa.Corrective_actions_for_TM_CM__c = null;
    newQa.Evaluation_Type__c = IDRConstants.QA_FRONTLINE_ASSESSMENT;
    qaRepoMock.mock(
      'getQualityAssessments',
      new List<Quality_Assessment__c>{ newQa }
    );

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{ TestUtil.getMockSaveResult('{}') }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.createComplianceTasks(
      new List<Quality_Assessment__c>{ newQa },
      new Map<Id, Quality_Assessment__c>{ oldQa.Id => oldQa }
    );
    Test.stopTest();
    List<Task> insertedTasks = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');
    Assert.areEqual(
      1,
      insertedTasks.size(),
      '1 Task should have been inserted'
    );
  }
  /**
   * @description Test positive scenario when QA record is updated to Complete status and final letter review task is created.
   */
  @isTest
  static void testcreateFinalLetterReviewTask() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQaCM = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    oldQaCM.OwnerId = ownerUserId;
    oldQaCM.Corrective_actions_required_CM__c = '';
    Quality_Assessment__c oldQaTL = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    oldQaTL.OwnerId = ownerUserId;
    oldQaTL.Corrective_actions_required_TL__c = '';
    Quality_Assessment__c newQaCM = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    newQaCM.RecordTypeId = RTQualityAssessment.idrReviewAssessmentId;
    newQaCM.OwnerId = ownerUserId;
    newQaCM.Id = oldQaCM.Id;
    newQaCM.Corrective_actions_required_CM__c = 'Final letter not compliant';
    newQaCM.Evaluation_Type__c = IDRConstants.QA_FINAL_LETTER_REVIEW_ASSESSMENT;
    Quality_Assessment__c newQaTL = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    newQaTL.RecordTypeId = RTQualityAssessment.idrReviewAssessmentId;
    newQaTL.OwnerId = ownerUserId;
    newQaTL.Id = oldQaTL.Id;
    newQaTL.Corrective_actions_required_TL__c = 'Further review due to potential customer detriment';
    newQaTL.Evaluation_Type__c = IDRConstants.QA_FINAL_LETTER_REVIEW_ASSESSMENT;
    qaRepoMock.mock(
      'getQualityAssessments',
      new List<Quality_Assessment__c>{ newQaCM }
    );

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":1323235,"errors":[]}')
      }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.createFinalLetterReviewTask(
      new List<Quality_Assessment__c>{ newQaCM, newQaTL },
      new Map<Id, Quality_Assessment__c>{
        oldQaCM.Id => oldQaCM,
        oldQaTL.Id => oldQaTL
      }
    );
    Test.stopTest();
    List<Task> insertedTasks = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');
    Assert.areEqual(2, insertedTasks.size(), '2 Task is created');
  }
  /**
   * @description Test negative scenario when QA record is updated to Complete status but final letter review task is not created.
   */
  @isTest
  static void createFinalLetterReviewTaskFalse() {
    registerMocks();
    Case relatedCase = IDRTestDataFactory.getCase();
    User manager = IDRTestDataFactory.getUser('Test user1');
    Quality_Assessment__c oldQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_PENDING
    );
    oldQa.OwnerId = ownerUserId;
    Quality_Assessment__c newQa = IDRTestDataFactory.getQA(
      manager,
      relatedCase,
      QualityAssessmentActions.STATUS_COMPLETE
    );
    newQa.OwnerId = ownerUserId;
    newQa.Id = oldQa.Id;
    newQa.Evaluation_Type__c = IDRConstants.QA_FRONTLINE_ASSESSMENT;
    qaRepoMock.mock('getQualityAssessments', new List<Quality_Assessment__c>{});

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{ TestUtil.getMockSaveResult('{}') }
    );
    Test.startTest();
    IDRQualityAssessmentTaskActions.createFinalLetterReviewTask(
      new List<Quality_Assessment__c>{ newQa },
      new Map<Id, Quality_Assessment__c>{ oldQa.Id => oldQa }
    );
    Test.stopTest();
    List<Task> insertedTasks = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');
    Assert.areEqual(
      0,
      insertedTasks.size(),
      'No Task is created as recordtype && evaluation type does not match'
    );
  }

  /**
   * @description fill Quality_Assessment__c record with mandatory fields noted in fieldset
   * @param oAssessment  record to apply mandatory values to
   * @param mpAssessmentFieldSets map of fieldsets
   */
  public static void fillMandatoryFields(
    Quality_Assessment__c oAssessment,
    Map<String, FieldSet> mpAssessmentFieldSets
  ) {
    String strFieldsetId = IDRQualityAssessmentActions.getFieldsetId(
      oAssessment
    );
    Schema.FieldSet oFieldSet;
    if (
      strFieldsetId != '' &&
      (oFieldSet = mpAssessmentFieldSets.get(strFieldsetId + '_mandatory')) !=
      null
    ) {
      for (Schema.FieldSetMember field : oFieldSet.getFields()) {
        if (oAssessment.get(field.SObjectField) == null) {
          if (field.getType() == DisplayType.REFERENCE) {
            switch on field.fieldPath {
              when 'C_Q_Specialist__c' {
                oAssessment.put(field.SObjectField, UserInfo.getUserId());
              }
              when 'Case_Manager__c' {
                oAssessment.put(field.SObjectField, UserInfo.getUserId());
              }
              when 'TeamManager__c' {
                oAssessment.put(field.SObjectField, UserInfo.getUserId());
              }
            }
          } else if (field.getType() == DisplayType.PICKLIST) {
            for (
              PicklistEntry peEntry : field.getSObjectField()
                .getDescribe()
                .getPicklistValues()
            ) {
              // just use first one.
              oAssessment.put(field.SObjectField, peEntry.value);
              break;
            }
          } else {
            oAssessment.put(field.SObjectField, 'Met');
          }
        }
      }
    }
  }
}
