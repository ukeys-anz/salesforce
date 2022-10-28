@isTest
private class QualityAssessmentActionsTest {
  //method to test negative case (return false) when calling isDisputeCaseType mehtod
  @isTest
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
  @isTest
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
  @isTest
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
  @isTest
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
  @isTest
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
      Evaluation_type__c = 'Email',
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
  @isTest
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
  @isTest
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
}
