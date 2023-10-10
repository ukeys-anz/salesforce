/**
 * @author Peter Charalambous
 * @since June 2023
 * @description Test class for CreditAssessmentActionsController
 */
@isTest
public with sharing class CreditAssessmentActionsControllerTest {
  private static final String TECH_ASSIST_ERROR = 'An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String IN_PROGRESS_ERROR = 'This loan application has already been submitted for assessment. Please wait for assessment to complete before trying again.';
  private static final String REASSESSMENT_CALLOUT_ERROR = 'Failed to complete reassessment.';
  private static final String REASSESS_REQUIRED_ERROR = 'The loan application has been updated and you must resubmit this credit referral case for reassessment.';
  private static final String ASSESSMENT_ERROR = 'This credit referral case is currently being assessed. You can\'t finalise the referral case until this has been completed.';
  private static final String FINALISE_CALLOUT_ERROR = 'Failed to complete finalisation.';

  /**
   * @description Setup data for test classes
   */
  @testSetup
  public static void setup() {
    Faker faker = new Faker('AU');

    Account acc = TestDataFactory.createAccount(true);
    ResidentialLoanApplication[] newRLA = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i)
      );
      rla.Credit_ID__c = '000-000-000-00' + String.valueOf(i);
      rla.AccountId = acc.Id;

      newRLA.add(rla);
    }
    insert newRLA;

    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.CREDIT_REFERRAL_RT_ID,
          Credit_Id__c = '000-000-000-00' + String.valueOf(i),
          AccountId = acc.Id,
          Status = 'Open'
        )
      );
    }
    insert newCases;
  }

  @isTest
  static void testSuccessReassess() {
    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    Test.startTest();
    Boolean resp = CreditAssessmentActionsController.reassess(c.Id);
    c = [
      SELECT Id, Loan_Application__r.Credit_Reassess_Required__c
      FROM Case
      WHERE Id = :c.Id
    ];
    Test.stopTest();
    Assert.isTrue(resp, 'Reassessment should be true');
    Assert.isFalse(
      c.Loan_Application__r.Credit_Reassess_Required__c,
      'Credit reassess required should be false'
    );
  }

  @isTest
  static void testReassessInProgress() {
    List<Case> c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    Test.startTest();
    try {
      //Call method twice, first call will set assessment outcome to in progress, second call should fail
      CreditAssessmentActionsController.reassess(c[0].Id);
      CreditAssessmentActionsController.reassess(c[0].Id);
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(IN_PROGRESS_ERROR),
        'Exception message should be thrown for processing'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testSuccessFinalise() {
    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    c.Assessment_Outcome__c = 'Approved';
    update c;

    Test.startTest();
    Boolean resp = CreditAssessmentActionsController.finalise(c.Id);
    c = [SELECT Id, Status FROM Case WHERE Id = :c.Id];
    Test.stopTest();
    Assert.isTrue(resp, 'Finalise should be true');
    Assert.areEqual(
      'Closed - Approved',
      c.Status,
      'Status should be Closed - Approved'
    );
  }

  @isTest
  static void testReassesRequiredForFinalise() {
    ResidentialLoanApplication rla = [
      SELECT Id
      FROM ResidentialLoanApplication
      LIMIT 1
    ];
    rla.Credit_Reassess_Required__c = true;
    update rla;

    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    Test.startTest();
    try {
      CreditAssessmentActionsController.finalise(c.Id);
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(REASSESS_REQUIRED_ERROR),
        'Exception message should be thrown to reassess'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testFinaliseInProgressOutcome() {
    Case c = [
      SELECT Id, Credit_Id__c, Assessment_Outcome__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.CREDIT_REFERRAL_RT_ID
        AND Credit_Id__c != NULL
      LIMIT 1
    ];

    c.Assessment_Outcome__c = 'Processing';
    update c;

    Test.startTest();
    try {
      CreditAssessmentActionsController.finalise(c.Id);
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(ASSESSMENT_ERROR),
        'Exception message should be thrown for invalid outcome'
      );
    }
    Test.stopTest();
  }
}
