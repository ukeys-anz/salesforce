@IsTest
private class QualityAssessmentActionsTest {
  private static final Faker FAKER = new Faker('AU');
  static Lib_MockProvider qualityAssessmentRepositoryMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    qualityAssessmentRepositoryMock = Lib_MockProvider.forType(
      IDRQualityAssessmentRepository.class
    );
  }

  static Case idrCase = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      IDR_Completed_Evaluations__c = 'Call Review Assessment: 0 | Letter Review Assessment: 0 | C&Q Assessment: 0'
    ),
    new Map<String, List<SObject>>{
      'Quality_Assessments__r' => new List<Quality_Assessment__c>{
        new Quality_Assessment__c(
          Id = Lib_FakeIdGenerator.getMockId(Quality_Assessment__c.SObjectType),
          Evaluation_Type__c = IDRConstants.CQ_EVAL,
          RecordTypeId = IDRConstants.idrtCQQualityAssessment,
          Status__c = IDRConstants.STATUS_COMPLETE,
          Related_Case__r = new Case(
            IDR_Completed_Evaluations__c = 'Call Review Assessment: 0 | Letter Review Assessment: 0 | C&Q Assessment: 0'
          )
        ),
        new Quality_Assessment__c(
          Id = Lib_FakeIdGenerator.getMockId(Quality_Assessment__c.SObjectType),
          Evaluation_Type__c = IDRConstants.LETTER_EVAL,
          RecordTypeId = IDRConstants.idrtCallLetterReviewQualityAssessment,
          Status__c = IDRConstants.STATUS_COMPLETE
        ),
        new Quality_Assessment__c(
          Id = Lib_FakeIdGenerator.getMockId(Quality_Assessment__c.SObjectType),
          Evaluation_Type__c = IDRConstants.CALL_REVIEW_EVAL,
          RecordTypeId = IDRConstants.idrtCallLetterReviewQualityAssessment,
          Status__c = IDRConstants.STATUS_COMPLETE
        )
      }
    }
  );

  //method to test negative case (return false) when calling isDisputeCaseType mehtod
  @IsTest
  private static void testIsDisputeCaseTypeNegative() {
    Test.startTest();

    Case caseRecord = new Case(Subject = 'Non Dispute Case');

    Boolean isDisputeCaseType = QualityAssessmentActions.isDisputeCaseType(
      caseRecord
    );

    Test.stopTest();

    System.assert(
      !isDisputeCaseType,
      'Passing non Dispute Case record into isDisputeCaseType method should return false.'
    );
  }

  //method to test positive case (return true) when calling isDisputeCaseType mehtod
  @IsTest
  private static void testIsDisputeCaseTypePositive() {
    Test.startTest();

    Case caseRecord = new Case(
      Subject = 'Dispute Case',
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );

    Boolean isDisputeCaseType = QualityAssessmentActions.isDisputeCaseType(
      caseRecord
    );

    Test.stopTest();

    System.assert(
      isDisputeCaseType,
      'Passing Dispute Case record into isDisputeCaseType method should return true.'
    );
  }

  //method to test pass null param when calling assignRelatedCaseFieldsToQA mehtod
  @IsTest
  private static void testAssignRelatedCaseFieldsToQAWithNullParam() {
    Test.startTest();

    List<Quality_Assessment__c> qaRecords = QualityAssessmentActions.assignRelatedCaseFieldsToQA(
      null
    );

    Test.stopTest();

    System.assertEquals(
      null,
      qaRecords,
      'Passing null into assignRelatedCaseFieldsToQA method should return null.'
    );
  }

  //method to test assignRelatedCaseFieldsToQA mehtod
  @IsTest
  private static void testAssignRelatedCaseFieldsToQA() {
    Test.startTest();

    Case caseRecord = new Case(
      Subject = 'Dispute Case',
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      Origin = 'Chat'
    );

    insert caseRecord;

    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
      Related_Case__c = caseRecord.Id
    );

    insert qaRecord;

    List<Quality_Assessment__c> updatedQARecords = QualityAssessmentActions.assignRelatedCaseFieldsToQA(
      new List<Quality_Assessment__c>{ qaRecord }
    );

    Test.stopTest();

    System.assertEquals(
      'Chat',
      updatedQARecords[0].Interaction_Type__c,
      'Passing Quality Assessment list into assignRelatedCaseFieldsToQA mehtod should assign correct value to Quality Assessment records in the list.'
    );
  }

  //method to test assignRelatedCaseFieldsToQA method if QA record has a pre-select value, then this value should not be overwritten
  @IsTest
  private static void testAssignRelatedCaseFieldsToQAWhenOriginPreSelected() {
    Test.startTest();

    Case caseRecord = new Case(
      Subject = 'Dispute Case',
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      Origin = 'Chat'
    );

    insert caseRecord;

    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
      Related_Case__c = caseRecord.Id,
      Evaluation_Type__c = 'Email',
      Interaction_Type__c = 'Email'
    );

    insert qaRecord;

    List<Quality_Assessment__c> updatedQARecords = QualityAssessmentActions.assignRelatedCaseFieldsToQA(
      new List<Quality_Assessment__c>{ qaRecord }
    );

    Test.stopTest();

    System.assertEquals(
      'Email',
      updatedQARecords[0].Interaction_Type__c,
      'Method assignRelatedCaseFieldsToQA should not overwrite pre-selected value of Quality Assessment record.'
    );
  }

  //method to test pass null param when calling calculateInteractionType mehtod
  @IsTest
  private static void testCalculateInteractionTypeWithNullParam() {
    Test.startTest();

    String interactionType = QualityAssessmentActions.calculateInteractionType(
      null
    );

    Test.stopTest();

    System.assertEquals(
      null,
      interactionType,
      'Passing null into calculateInteractionType method should return null.'
    );
  }

  //method to test calculateInteractionType mehtod - Store as Origin
  @IsTest
  private static void testCalculateInteractionTypeWithStoreOrigin() {
    Test.startTest();

    String interactionType = QualityAssessmentActions.calculateInteractionType(
      'Store'
    );

    Test.stopTest();

    System.assertEquals(
      'Store',
      interactionType,
      'Passing Store into calculateInteractionType method should return Store.'
    );
  }
  //method to test assignUsersDetailsToQaFields
  @IsTest
  private static void testAssignUsersDetailsToQaFields() {
    Case testCase = new Case();
    testCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    testCase.OwnerId = UserInfo.getUserId();
    Map<Id, Case> caseMap = new Map<Id, Case>();
    caseMap.put(testCase.Id, testCase);
    Quality_Assessment__c qa = new Quality_Assessment__c();
    qa.RecordTypeId = IDRConstants.idrtCQQualityAssessment;
    qa.Related_Case__c = testCase.Id;
    qa.OwnerId = UserInfo.getUserId();
    List<Quality_Assessment__c> qaList = new List<Quality_Assessment__c>{ qa };
    QualityAssessmentActions.assignUsersDetailsToQaFields(caseMap, qaList);
    System.assertEquals(
      qa.C_Q_Specialist__c,
      UserInfo.getUserId(),
      'CQ Specialist is the owner of the record'
    );
  }
  //method to test autoCalculateScore
  @IsTest
  private static void testCaseManagerScoreAndBusinessScore() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole cqRole = CommonUtil.getUserRoleByDevName(
      'Capability_Quality_C_Q_Team'
    );

    // Create QA user
    User oQAUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'QA_User',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => cqRole.Id
      }
    );
    insert oQAUser;
    // Add IDR User permissions on test users
    PermissionSet ps = CommonUtil.getPermissionSetByName('IDR_User');
    insert TestUtil.createPSAssignment(oQAUser.Id, ps.Id);

    System.runAs(oQAUser) {
      Test.startTest();

      Case caseRecord = new Case(
        RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
        IDR_Customer_Number__c = '1234567890',
        Status = 'Closed'
      );

      insert caseRecord;

      Quality_Assessment__c qaRecord = new Quality_Assessment__c(
        RecordTypeId = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
          .get('Call_Letter_Review_Assessment')
          .getRecordTypeId(),
        Related_Case__c = caseRecord.Id,
        Evaluation_Type__c = 'Letter Review Assessment',
        Status__c = 'Complete'
      );
      Map<String, FieldSet> mpAssessmentFieldSets = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap();
      IDRQualityAssessmentTaskActionsTest.fillMandatoryFields(
        qaRecord,
        mpAssessmentFieldSets
      );

      insert qaRecord;

      qaRecord = new Quality_Assessment__c(
        RecordTypeId = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
          .get('Call_Letter_Review_Assessment')
          .getRecordTypeId(),
        Related_Case__c = caseRecord.Id,
        Evaluation_Type__c = 'Call Review Assessment',
        Status__c = 'Complete'
      );
      IDRQualityAssessmentTaskActionsTest.fillMandatoryFields(
        qaRecord,
        mpAssessmentFieldSets
      );
      insert qaRecord;

      Test.stopTest();

      qaRecord = [
        SELECT Id, Case_Manager_Score__c, Business_score__c
        FROM Quality_Assessment__c
        WHERE Id = :qaRecord.Id
      ];
      System.Debug('Result++ ' + qaRecord);
      System.assertEquals(
        100,
        qaRecord.Case_Manager_Score__c,
        'Case Manager Score Mismatch'
      );
      System.assertEquals(
        0,
        qaRecord.Business_score__c,
        'Business Score Mismatch'
      );

      Quality_Assessment__c qaRecordCQ = new Quality_Assessment__c(
        RecordTypeId = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
          .get('C_Q_Assessment')
          .getRecordTypeId(),
        Related_Case__c = caseRecord.Id,
        Team_Manager_Response__c = 'Accepted by TM',
        Evaluation_Type__c = 'C & Q Assessment',
        Status__c = 'Complete'
      );
      Map<String, FieldSet> mpAssessmentFieldSetsCQ = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap();
      IDRQualityAssessmentTaskActionsTest.fillMandatoryFields(
        qaRecordCQ,
        mpAssessmentFieldSetsCQ
      );
      try {
        insert qaRecordCQ;
      } catch (Exception e) {
        System.assert(
          true,
          e.getMessage()
            .contains('A Quality Assessment has already been completed')
        );
      }
    }
  }
  @IsTest
  static void testSetAssessmentOutcomeStatusValid() {
    String qaRecordId = Lib_FakeIdGenerator.getMockId(
      Quality_Assessment__c.SObjectType
    );
    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      Id = qaRecordId,
      Status__c = IDRConstants.STATUS_COMPLETE,
      Team_Manager_Response__c = '',
      RecordTypeId = IDRConstants.idrtCQQualityAssessment
    );
    Quality_Assessment__c qaRecordV1 = new Quality_Assessment__c(
      Id = qaRecordId,
      Status__c = IDRConstants.STATUS_COMPLETE,
      Team_Manager_Response__c = 'Rejected by TM',
      RecordTypeId = IDRConstants.idrtCQQualityAssessment
    );
    IDRQualityAssessmentActions.setAssessmentOutcomeStatus(
      new List<Quality_Assessment__c>{ qaRecordV1 },
      new Map<Id, Quality_Assessment__c>{ qaRecord.Id => qaRecord }
    );
    System.AssertEquals(
      'Disputed',
      qaRecordV1.Assessment_Outcome_Status__c,
      'Assessment Outcome Status updated correctly'
    );
  }

  @IsTest
  static void testSetAssessmentOutcomeStatusInvalid() {
    String qaRecordId = Lib_FakeIdGenerator.getMockId(
      Quality_Assessment__c.SObjectType
    );
    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      Id = qaRecordId,
      Status__c = 'Pending',
      RecordTypeId = IDRConstants.idrtCQQualityAssessment
    );
    Quality_Assessment__c qaRecordV1 = new Quality_Assessment__c(
      Id = qaRecordId,
      Status__c = 'Complete',
      RecordTypeId = IDRConstants.idrtCQQualityAssessment
    );
    IDRQualityAssessmentActions.setAssessmentOutcomeStatus(
      new List<Quality_Assessment__c>{ qaRecordV1 },
      new Map<Id, Quality_Assessment__c>{ qaRecord.Id => qaRecord }
    );
    System.AssertNotEquals(
      'Accepted',
      qaRecordV1.Assessment_Outcome_Status__c,
      'Assessment Outcome Status should not be updated when Outcome fields are not changed'
    );
  }
  @isTest
  private static void testupdateCompletedEvaluations() {
    Case testCase = idrCase;
    List<Quality_Assessment__c> qaList = testCase.Quality_Assessments__r;

    Test.startTest();
    String newEvaluationString = IDRQualityAssessmentActions.updateCompletedEvaluations(
      testCase,
      qaList
    );
    Test.stopTest();

    System.assertNotEquals(
      idrCase.IDR_Completed_Evaluations__c,
      newEvaluationString,
      'Evaluation String should have been updated'
    );
  }

  @isTest
  public static void testUpdateCaseToQualityAssessmentMap() {
    Case testCase = idrCase;
    List<Quality_Assessment__c> qaList = testCase.Quality_Assessments__r;
    Map<Id, List<Quality_Assessment__c>> mapQualityAssessments = new Map<Id, List<Quality_Assessment__c>>();
    mapQualityAssessments.put(testCase.Id, qaList);
    mapQualityAssessments = IDRQualityAssessmentActions.updateCaseToQualityAssessmentMap(
      qaList,
      mapQualityAssessments
    );
    System.assertEquals(
      3,
      mapQualityAssessments.get(testCase.Id).size(),
      'Case must contain 3 Quality Assessment Record'
    );
  }

  @isTest
  public static void testGetEvaluationsCountMap() {
    Map<String, Integer> evaluationsCountMap = IDRQualityAssessmentActions.getEvaluationsCountMap(
      'Call Review Assessment: 2 | Letter Review Assessment: 1 | C&Q Assessment: 3'
    );
    System.assertEquals(
      3,
      evaluationsCountMap.get('C&Q Assessment'),
      'Three C&Q Assessment should be completed'
    );
    System.assertEquals(
      2,
      evaluationsCountMap.get('Call Review Assessment'),
      'Two Call Review Assessment should be completed'
    );
    System.assertEquals(
      1,
      evaluationsCountMap.get('Letter Review Assessment'),
      'One Letter Review Assessment should be complete'
    );
  }
  @isTest
  public static void testGetUpdatedEvaluationsString() {
    Map<String, Integer> evaluationsCountMap = new Map<String, Integer>();
    evaluationsCountMap.put('Call Review Assessment', 1);
    evaluationsCountMap.put('Letter Review Assessment', 2);
    System.assertEquals(
      'Call Review Assessment: 1 | Letter Review Assessment: 2 | C&Q Assessment: 0',
      IDRQualityAssessmentActions.getUpdatedEvaluationsString(
        evaluationsCountMap
      ),
      'Evaluation String should update'
    );
  }

  @isTest
  public static void testcountRecords() {
    registerMocks();
    Case testCase = idrCase;
    List<Quality_Assessment__c> qaList = testCase.Quality_Assessments__r;
    qaList[0].Related_Case__c = testCase.Id;
    qaList[1].Related_Case__c = testCase.Id;
    Map<Id, Quality_Assessment__c> oldMap = new Map<Id, Quality_Assessment__c>();
    Quality_Assessment__c oldqa1 = new Quality_Assessment__c(
      Id = qaList[0].Id,
      Status__c = IDRConstants.STATUS_PENDING
    );
    Quality_Assessment__c oldqa2 = new Quality_Assessment__c(
      Id = qaList[1].Id,
      Status__c = IDRConstants.STATUS_PENDING
    );
    oldMap.put(qaList[0].Id, oldqa1);
    oldMap.put(qaList[1].Id, oldqa2);

    qualityAssessmentRepositoryMock.mock(
      'getCases',
      new List<Case>{ testCase }
    );
    qualityAssessmentRepositoryMock.mock(
      'getQualityAssessments',
      new List<Quality_Assessment__c>{ qaList[0] }
    );
    Test.startTest();
    IDRQualityAssessmentActions.countRecords(
      new List<Quality_Assessment__c>{ qaList[1] },
      oldMap
    );
    Test.stopTest();
    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');
    System.assertEquals(
      'Call Review Assessment: 0 | Letter Review Assessment: 1 | C&Q Assessment: 0',
      cases[0].IDR_Completed_Evaluations__c,
      'Case Should have Completed Evaluations'
    );
  }
}
