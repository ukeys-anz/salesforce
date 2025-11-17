/**
 * @author Shivraj
 * @since Feb 2025
 * @description Test class for TrustMeCaseActions
 */
@IsTest
private class TrustMeCaseActionsTest {
  static Lib_MockProvider queryMockCls;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    queryMockCls = Lib_MockProvider.forType(IDOpsQueryRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static Faker faker = new Faker('AU');
  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Case> caseTrustMeQARecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Priority = 'Medium',
          Description = faker.randomString(10),
          Subject = 'FAILED_DOC',
          Origin = 'Origination',
          Status = 'Open',
          Fraud_Customer_Details__c = 'Yes',
          Fraud_MiddleNameCheck__c = 'Yes',
          Fraud_Selfie_Comparison_Match__c = 'Yes',
          Fraud_Address_Valid__c = 'Yes',
          Fraud_ID_Legible__c = 'Yes',
          Fraud_ID_Not_Picture__c = 'Yes',
          Fraud_Customer_Photo_Modified__c = 'Yes',
          RecordTypeId = RTCase.trustMeQA
        );
        cases.add(newCase);
      }
      return cases;
    }
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
    Fraud_Address_Valid__c = YES,
    Fraud_ID_Legible__c = YES,
    Fraud_Customer_Photo_Modified__c = YES,
    Fraud_ID_Not_Picture__c = YES,
    Fraud_Security_Features__c = YES
  );

  @isTest
  static void testUpdateTestedDate() {
    Case theCase = caseTrustMeQARecord[0];
    TrustMeCaseActions.updateTestedDate(new List<Case>{ theCase });
    Assert.isNull(theCase.TestedDate__c, 'The Tested Date should be null');

    theCase.Fraud_Security_Features__c = 'Yes';
    TrustMeCaseActions.updateTestedDate(new List<Case>{ theCase });
    Assert.isNotNull(
      theCase.TestedDate__c,
      'The Tested Date should not be null'
    );
  }

  @isTest
  static void testCompleteChecksAsYesSuccess() {
    registerMocks();
    queryMockCls.mock(
      'queryQAChecksByIds',
      new List<Case>{ kycQAForCompletion }
    );

    Test.startTest();
    TrustMeCaseActions.completeChecksAsYes(kycQAForCompletion.Id);
    Test.stopTest();

    Assert.isFalse(
      queryMockCls.getHistories('queryQAChecksByIds').isEmpty(),
      'queryQAChecksByIds should have been called'
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
  }

  @isTest
  static void testCompleteCheckAsYesFailed() {
    registerMocks();
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"success":false,"id":"5008r00000EhhODAAZ","errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"TestErrorMessage","fields":[]}]}'
      )
    };
    dmlRepoMock.mock('doUpdate', saveResults);

    try {
      Test.startTest();
      TrustMeCaseActions.completeChecksAsYes(kycQACompleted.Id);
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'AuraHandledException should have been thrown'
      );
    }
  }
}
