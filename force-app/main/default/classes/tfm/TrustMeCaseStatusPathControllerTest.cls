/**
 * @author Shivraj Kadam
 * @since Apr 2025
 * @description Test Class for - TrustMeCaseStatusPathController
 */
@isTest
public with sharing class TrustMeCaseStatusPathControllerTest {
  static Faker faker = new Faker('AU');
  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Case> caseRecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Origin = 'Web',
          Type = 'Other',
          Priority = 'Standard',
          IDR_NC_Is_Consent_Obtained__c = false,
          IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
          IDR_Product_Category__c = 'Not product related',
          Description = faker.randomString(10),
          Evaluation_Id__c = '1234',
          Subject = 'TrustMe Manual Review - Document',
          RecordTypeId = RTCase.trustMeManualReview,
          Status = 'ID and Selfie Check Passed'
        );
        cases.add(newCase);
      }
      return cases;
    }
  }
  @isTest
  static void testUpdateStatus() {
    Test.startTest();
    try {
      TrustMeCaseStatusPathController.updateStatus(
        caseRecord[0],
        'test comments'
      );
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Expecting AuraHandledException to be thrown'
      );
    }
    Test.stopTest();
  }
  @isTest
  static void testUpdateStatusInsufficientAccessException() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 401;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('updateCaseStatus', res);
    try {
      Test.startTest();
      TrustMeCaseStatusPathController.updateStatus(
        caseRecord[0],
        'test comments'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'No exception thrown'
      );
    }
  }
  @isTest
  static void testUpdateStatusServerException() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('updateCaseStatus', res);
    try {
      Test.startTest();
      TrustMeCaseStatusPathController.updateStatus(
        caseRecord[0],
        'test comments'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'No exception thrown'
      );
    }
  }
  @isTest
  static void testUpdateStatusException() {
    try {
      Test.startTest();
      TrustMeCaseStatusPathController.updateStatus(null, 'test comments');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'No exception thrown'
      );
    }
  }
  @isTest
  static void testUpdateStatusDMLException() {
    try {
      Lib_MockProvider.forType(DmlRepository.class)
        .mock('doUpdate', TestUtil.getMockSaveResult('{"success":false}'));
      Test.startTest();
      TrustMeCaseStatusPathController.updateStatus(
        caseRecord[0],
        'test comments'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'No exception thrown'
      );
    }
  }
}