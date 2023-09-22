/**
 * @author cruzb
 * @since August 2023
 * @description Test class for CaseToastService
 * @group Services
 */
@isTest
public with sharing class ToastAlertServiceTest {
  @isTest
  static void testToastAlertCreditAssessment() {
    Faker faker = new Faker('AU');

    Account acc = TestDataFactory.createAccount(true);
    ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication();
    rla.AccountId = acc.Id;
    rla.Credit_Reassess_Required__c = false;
    insert rla;

    Case caseCR = new Case(
      RecordTypeId = GetHelpConstants.CREDIT_REFERRAL_RT_ID,
      Credit_Id__c = faker.randomString(15),
      Loan_Application__c = rla.Id,
      Status = 'Open',
      Assessment_Outcome__c = 'Processing'
    );

    insert caseCR;

    Test.startTest();
    Map<Id, Case> oldMap = new Map<Id, Case>(
      [SELECT Id, Assessment_Outcome__c FROM Case WHERE Id = :caseCR.id]
    );

    List<Case> records = new List<Case>{
      new Case(Id = caseCR.id, Assessment_Outcome__c = 'Approved')
    };

    System.assert(
      !ToastAlertService.checkCRAssessmentResults(records, oldMap).isEmpty(),
      'Assessment_Outcome__c did not change'
    );

    Test.stopTest();
  }

  @isTest
  static void testToastAlertRLAReassessment() {
    Account acc = TestDataFactory.createAccount(true);
    ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication();
    rla.AccountId = acc.Id;
    rla.Credit_Reassess_Required__c = false;
    insert rla;

    Test.startTest();
    Map<Id, ResidentialLoanApplication> oldMap = new Map<Id, ResidentialLoanApplication>(
      [
        SELECT Id, Credit_Reassess_Required__c
        FROM ResidentialLoanApplication
        WHERE Id = :rla.id
      ]
    );

    List<ResidentialLoanApplication> records = new List<ResidentialLoanApplication>{
      new ResidentialLoanApplication(
        Id = rla.id,
        Credit_Reassess_Required__c = true
      )
    };

    System.assert(
      !ToastAlertService.checkRLAReassessmentRequirement(records, oldMap)
        .isEmpty(),
      'Credit_Reassess_Required__c was not updated'
    );

    Test.stopTest();
  }

  @isTest
  static void testPlatEventPublish() {
    Account acc = TestDataFactory.createAccount(true);
    Test.startTest();

    List<SObject> eventBusMembers = ToastAlertService.publishRecordMonitoringEvent(
      new Map<String, Object>(),
      new Set<Id>{ acc.Id }
    );

    System.assert(eventBusMembers.size() == 1, 'No Platform event published');

    Test.stopTest();
  }
}
