@IsTest
private class QualityAssessmentActionsTest {
  static Quality_Assessment__c oldqaRecord = new Quality_Assessment__c(
    Id = Lib_FakeIdGenerator.getMockId(Quality_Assessment__c.SObjectType),
    RecordTypeId = RTQualityAssessment.idrCQQualityId
  );
  static Quality_Assessment__c newqaRecord = new Quality_Assessment__c(
    Id = oldqaRecord.Id,
    RecordTypeId = RTQualityAssessment.idrCQQualityId,
    Status__c = QualityAssessmentActions.STATUS_COMPLETE
  );

  /**
   * @description Test method to test data masking for QA fields for CMOS
   */
  @isTest
  static void testHandleMaskingPositive() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    oldRecord.Evaluation_Type__c = IDRConstants.QA_CR_ASSESSMENT;
    oldRecord.Q1_Comments__c = '';
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    newRecord.Evaluation_Type__c = IDRConstants.QA_CR_ASSESSMENT;
    newRecord.Q1_Comments__c = 'card 4123-1233-1111-2222';
    Test.startTest();
    IDRQualityAssessmentActions.applyDefaults(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      'card ************2222',
      newRecord.Q1_Comments__c,
      'Q1 Comments field value should be masked for CMOS if text has card string'
    );
  }
  /**
   * @description Test method to test data masking should be skipped for a particular pattern for CMOS
   */
  @isTest
  static void testHandleMaskingNegative() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    oldRecord.Evaluation_Type__c = IDRConstants.QA_CR_ASSESSMENT;
    oldRecord.Q1_Comments__c = '';
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    newRecord.Evaluation_Type__c = IDRConstants.QA_CR_ASSESSMENT;
    newRecord.Q1_Comments__c = '$12345678';
    Test.startTest();
    IDRQualityAssessmentActions.applyDefaults(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      '$12345678',
      newRecord.Q1_Comments__c,
      'Q1 Comments field value should not be masked for CMOS if text has $ prefix'
    );
  }

  /**
   * @description Test method to test data masking for Final letter review - QA fields for CMOS
   */
  @isTest
  static void testHandleMaskingFinalLetterPositive() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    oldRecord.Evaluation_Type__c = IDRConstants.QA_FINAL_LETTER_REVIEW_ASSESSMENT;
    oldRecord.RecordTypeId = RTQualityAssessment.idrReviewAssessmentId;
    oldRecord.Feedback_summary_for_the_Case_Manager__c = '';
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    newRecord.Evaluation_Type__c = IDRConstants.QA_FINAL_LETTER_REVIEW_ASSESSMENT;
    newRecord.Feedback_summary_for_the_Case_Manager__c = 'card 4123-1233-1111-2222';
    Test.startTest();
    IDRQualityAssessmentActions.applyDefaults(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      'card ************2222',
      newRecord.Feedback_summary_for_the_Case_Manager__c,
      'Feedback summary for the Case Manager field value should be masked for CMOS if text has card string'
    );
  }
  /**
   * @description Test method to test data masking should be skipped for a particular pattern for CMOS
   */
  @isTest
  static void testHandleMaskingFinalLetterNegative() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    oldRecord.Evaluation_Type__c = IDRConstants.QA_FINAL_LETTER_REVIEW_ASSESSMENT;
    oldRecord.RecordTypeId = RTQualityAssessment.idrReviewAssessmentId;
    oldRecord.Feedback_summary_for_the_Case_Manager__c = '';
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    newRecord.Evaluation_Type__c = IDRConstants.QA_FINAL_LETTER_REVIEW_ASSESSMENT;
    newRecord.Feedback_summary_for_the_Case_Manager__c = '$12345678';
    Test.startTest();
    IDRQualityAssessmentActions.applyDefaults(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      '$12345678',
      newRecord.Feedback_summary_for_the_Case_Manager__c,
      'Feedback summary for the Case Manager field value should not be masked for CMOS if text has $ prefix'
    );
  }

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
    Profile stdUserProfile = QueryProfile.anzUser;
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
        RecordTypeId = RTQualityAssessment.idrReviewAssessmentId,
        Related_Case__c = caseRecord.Id,
        Evaluation_Type__c = 'Call Review Assessment',
        Status__c = 'Complete'
      );
      Map<String, FieldSet> mpAssessmentFieldSets = Schema.SObjectType.Quality_Assessment__c.fieldSets.getMap();
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
      Status__c = IDRConstants.STATUS_PENDING,
      RecordTypeId = IDRConstants.idrtCQQualityAssessment
    );
    Quality_Assessment__c qaRecordV1 = new Quality_Assessment__c(
      Id = qaRecordId,
      Status__c = IDRConstants.STATUS_COMPLETE,
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
  /**
   * @description Test to get respective fieldset for evaluation type.
   */
  @IsTest
  static void testGetFieldSet() {
    Quality_Assessment__c newQa = newqaRecord;
    newQa.Evaluation_Type__c = IDRConstants.QA_CQ_ASSESSMENT;
    Test.startTest();
    String evaluationType = IDRQualityAssessmentActions.getFieldsetId(newQa);
    Test.stopTest();
    Assert.areEqual(
      evaluationType,
      'C_Q_Assessment',
      'Field set id should be CQ'
    );
  }
  /**
   * @description Test to validate QA status on update of QA records.
   */
  @IsTest
  static void testValidateStatusCompleteforUpdate() {
    Quality_Assessment__c newQa = newqaRecord;
    newQa.Evaluation_Type__c = IDRConstants.QA_CQ_ASSESSMENT;
    Quality_Assessment__c oldQa = oldqaRecord;

    Test.startTest();
    IDRQualityAssessmentActions.validateStatusComplete(
      new List<Quality_Assessment__c>{ newQa },
      new Map<Id, Quality_Assessment__c>{ oldQa.Id => oldQa }
    );
    Test.stopTest();
    Assert.areEqual(newQa.Status__c, 'Complete', 'Status should be complete');
  }
  /**
   * @description Test to validate QA status on insert of QA records.
   */
  @IsTest
  static void testValidateStatusCompleteforInsert() {
    Quality_Assessment__c newQa = newqaRecord;
    Test.startTest();
    IDRQualityAssessmentActions.validateStatusComplete(
      new List<Quality_Assessment__c>{ newQa },
      null
    );
    Test.stopTest();
    Assert.areEqual(newQa.Status__c, 'Complete', 'Status should be complete');
  }
  /**
   * @description Test when CQ fieldset field is updated with null value.
   */
  @IsTest
  static void testAutoCalculateScore() {
    Quality_Assessment__c newQa = newqaRecord;
    newQa.Evaluation_Type__c = IDRConstants.QA_CQ_ASSESSMENT;
    newQa.Was_quick_resolution_offer_appropriate__c = '';
    Test.startTest();
    IDRQualityAssessmentActions.autoCalculateScore(
      new List<Quality_Assessment__c>{ newQa }
    );
    Test.stopTest();
    Assert.areEqual(0, newQa.Case_Manager_Score__c, 'Case Manager score is 0');
  }
  /**
   * @description Test when only status is getting changed.
   */
  @isTest
  static void testGetNotChangedQARecords() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Status__c = QualityAssessmentActions.STATUS_COMPLETE;
    Test.startTest();
    IDRQualityAssessmentActions.getNotChangedQARecords(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      IDRConstants.qaAssessmentStatusMapping.get(
        IDRConstants.QA_TM_RESPONSE_AWAITING
      ),
      newRecord.Assessment_Outcome_Status__c,
      'Assessment outcome status should Submitted'
    );
  }
  /**
   * @description Test when Team Manager response is updated along with status.
   */
  @isTest
  static void testGetNotChangedQARecordsInvalid() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    oldRecord.Assessment_Outcome_Status__c = null;
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Team_Manager_Response__c = IDRConstants.TEAM_MANAGER_REJECTION_RESPONSE;
    newRecord.Status__c = QualityAssessmentActions.STATUS_COMPLETE;
    Test.startTest();
    IDRQualityAssessmentActions.getNotChangedQARecords(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.isNull(
      oldRecord.Assessment_Outcome_Status__c,
      'Assessment  outcome status should be null i.e., no change in value'
    );
  }
  /**
   * @description Test when Team Manager response is updated along with status.
   */
  @isTest
  static void testGetChangedQARecords() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    oldRecord.Assessment_Outcome_Status__c = null;
    oldRecord.Team_Manager_Response__c = null;
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Team_Manager_Response__c = IDRConstants.TEAM_MANAGER_REJECTION_RESPONSE;
    newRecord.Status__c = QualityAssessmentActions.STATUS_COMPLETE;
    Test.startTest();
    IDRQualityAssessmentActions.getChangedQARecords(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.areEqual(
      IDRConstants.qaAssessmentStatusMapping.get(
        IDRConstants.TEAM_MANAGER_REJECTION_RESPONSE
      ),
      newRecord.Assessment_Outcome_Status__c,
      'Assessment outcome status should be Disputed'
    );
  }
  /**
   * @description Test when only status is getting changed.
   */
  @isTest
  static void testGetChangedQARecordsInvalid() {
    Quality_Assessment__c oldRecord = oldqaRecord;
    oldRecord.Status__c = QualityAssessmentActions.STATUS_PENDING;
    oldRecord.Assessment_Outcome_Status__c = null;
    Quality_Assessment__c newRecord = newqaRecord;
    newRecord.Status__c = QualityAssessmentActions.STATUS_COMPLETE;
    Test.startTest();
    IDRQualityAssessmentActions.getChangedQARecords(
      new List<Quality_Assessment__c>{ newRecord },
      new Map<Id, Quality_Assessment__c>{ oldRecord.Id => oldRecord }
    );
    Test.stopTest();
    Assert.isNull(
      oldRecord.Assessment_Outcome_Status__c,
      'Assessment  outcome status should be null i.e., no change in value'
    );
  }
}
