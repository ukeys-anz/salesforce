/**
 * @author Karen Valeriano
 * @since 10/2024
 * @description Tests for AutoKYCQACaseController of kycqaCompleteChecksAsYes LWC
 */
@isTest
private class AutoKYCQACaseControllerTest {
  static Lib_MockProvider autoKYCQACaseRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    autoKYCQACaseRepoMock = Lib_MockProvider.forType(
      AutoKYCQACaseRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
  static final String YES = 'Yes';
  static final String NO = 'No';

  static Case kycQAForCompletion = new Case(
    Id = caseId,
    Fraud_MiddleNameCheck__c = NO
  );

  static Case kycQACompleted = new Case(
    Id = caseId,
    Fraud_Customer_Details__c = NO,
    Fraud_MiddleNameCheck__c = YES,
    Fraud_Selfie_Comparison_Match__c = YES,
    Fraud_PO_Box__c = YES,
    Fraud_Address_Valid__c = YES,
    Fraud_ID_Legible__c = YES,
    Fraud_Customer_Photo_Modified__c = YES,
    Fraud_ID_Not_Picture__c = YES,
    Fraud_Security_Features__c = YES
  );

  @isTest
  static void testCompleteChecksAsYesSuccess() {
    registerMocks();

    autoKYCQACaseRepoMock.mock(
      'queryKYCQAChecksByIds',
      new List<Case>{ kycQAForCompletion }
    );

    Test.startTest();
    AutoKYCQACaseController.completeChecksAsYes(kycQAForCompletion.Id);
    Test.stopTest();

    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories('queryKYCQAChecksByIds').isEmpty(),
      'queryKYCQAChecksByIds should have been called'
    );

    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Case> updateRecordList = (List<Case>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    //The check field initially set to NO should not be updated
    Assert.areEqual(
      NO,
      updateRecordList[0].Fraud_MiddleNameCheck__c,
      'The Fraud_MiddleNameCheck__c should be set to ' + NO
    );

    //All other empty check fields should be updated with YES
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_Customer_Details__c,
      'The Fraud_Customer_Details__c should be set to ' + YES
    );
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_Selfie_Comparison_Match__c,
      'The Fraud_Selfie_Comparison_Match__c should be set to ' + YES
    );
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_PO_Box__c,
      'The Fraud_PO_Box__c should be set to ' + YES
    );
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_Address_Valid__c,
      'The Fraud_Address_Valid__c should be set to ' + YES
    );
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_ID_Legible__c,
      'The Fraud_ID_Legible__c should be set to ' + YES
    );
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_Customer_Photo_Modified__c,
      'The Fraud_Customer_Photo_Modified__c should be set to ' + YES
    );
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_ID_Not_Picture__c,
      'The Fraud_ID_Not_Picture__c should be set to ' + YES
    );
    Assert.areEqual(
      YES,
      updateRecordList[0].Fraud_Security_Features__c,
      'The Fraud_Security_Features__c should be set to ' + YES
    );
  }

  @isTest
  static void testCompleteCheckAsYesFailed() {
    registerMocks();

    autoKYCQACaseRepoMock.mock(
      'queryKYCQAChecksByIds',
      new List<Case>{ kycQACompleted }
    );

    try {
      Test.startTest();
      AutoKYCQACaseController.completeChecksAsYes(kycQACompleted.Id);
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'AuraHandledException should have been thrown'
      );
    }
  }
}
