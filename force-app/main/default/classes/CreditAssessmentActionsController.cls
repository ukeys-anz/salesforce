/**
 * @author Peter Charalambous
 * @since June 2023
 * @description Controller for Credit Assessment actions such as reassess or finalise
 */
public with sharing class CreditAssessmentActionsController {
  private static final String TECH_ASSIST_ERROR = 'An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String IN_PROGRESS_ERROR = 'This loan application has already been submitted for assessment. Please wait for assessment to complete before trying again.';
  private static final String COMPLETE_ERROR = 'The assessment outcome is in a complete status.';
  private static final String REASSESSMENT_CALLOUT_ERROR = 'Failed to complete reassessment.';
  private static final String REASSESS_REQUIRED_ERROR = 'The loan application has been updated and you must resubmit this credit referral case for reassessment.';
  private static final String ASSESSMENT_ERROR = 'This credit referral case is currently being assessed. You can\'t finalise the referral case until this has been completed.';
  private static final String FINALISE_CALLOUT_ERROR = 'Failed to complete finalisation.';

  /**
   * @param recordId case id
   * @return Boolean returns true or false for success of reassessment
   * @description submits the customer credit assessment for reassessment
   */
  @AuraEnabled
  public static Boolean reassess(String recordId) {
    //Check if user can query case
    PermissionUtils.canQuery('Case');

    //Retrieve fields from case record
    Case c = [
      SELECT
        Credit_Id__c,
        Assessment_Outcome__c,
        Loan_Application__r.Credit_Reassess_Required__c
      FROM Case
      WHERE Id = :recordId
    ];

    //Ensure a credit id is on the record
    if (String.isBlank(c.Credit_Id__c)) {
      Logger.error('Missing Credit Id on Credit assessment case: ' + recordId);
      Logger.saveLog();
      AuraHandledException e = new AuraHandledException(TECH_ASSIST_ERROR);
      e.setMessage(TECH_ASSIST_ERROR);
      throw e;
    }

    if (c.Assessment_Outcome__c == 'Processing') {
      AuraHandledException e = new AuraHandledException(IN_PROGRESS_ERROR);
      e.setMessage(IN_PROGRESS_ERROR);
      throw e;
    } else if (
      !c.Loan_Application__r.Credit_Reassess_Required__c &&
      (c.Assessment_Outcome__c == 'Approved' ||
      c.Assessment_Outcome__c == 'Declined')
    ) {
      AuraHandledException e = new AuraHandledException(COMPLETE_ERROR);
      e.setMessage(COMPLETE_ERROR);
      throw e;
    }

    try {
      CreditAssessmentAPIRepository creditApi = new CreditAssessmentAPIRepository();
      creditApi.submitReassessment(c.Credit_Id__c);
      c.Assessment_Outcome__c = 'Processing';
      DMLUtil.updateRecords(new List<Case>{ c }, false, false);
      ResidentialLoanApplication rla = [
        SELECT Id
        FROM ResidentialLoanApplication
        WHERE Id = :c.Loan_Application__c
      ];
      rla.Credit_Reassess_Required__c = false;
      DMLUtil.updateRecords(
        new List<ResidentialLoanApplication>{ rla },
        false,
        false
      );
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      e.setMessage(REASSESSMENT_CALLOUT_ERROR);
      throw e;
    }

    return true;
  }

  /**
   * @param recordId case id
   * @return Boolean returns true or false for success of finalisation
   * @description submits the customer credit assessment for finalisation
   */
  @AuraEnabled
  public static Boolean finalise(String recordId) {
    //Check if user can query case
    PermissionUtils.canQuery('Case');

    //Retrieve fields from case record
    Case c = [
      SELECT
        Credit_Id__c,
        Assessment_Outcome__c,
        Assessment_Id__c,
        Loan_Application__r.Credit_Reassess_Required__c
      FROM Case
      WHERE Id = :recordId
    ];

    if (c.Loan_Application__r.Credit_Reassess_Required__c) {
      AuraHandledException e = new AuraHandledException(
        REASSESS_REQUIRED_ERROR
      );
      e.setMessage(REASSESS_REQUIRED_ERROR);
      throw e;
    }

    if (
      c.Assessment_Outcome__c != 'Approved' &&
      c.Assessment_Outcome__c != 'Declined'
    ) {
      AuraHandledException e = new AuraHandledException(ASSESSMENT_ERROR);
      e.setMessage(ASSESSMENT_ERROR);
      throw e;
    }

    try {
      CreditAssessmentAPIRepository creditApi = new CreditAssessmentAPIRepository();
      creditApi.finaliseAssessment(c.Credit_Id__c, c.Assessment_Id__c);

      //Add checks to ensure we only update status based on correct outcome
      if (c.Assessment_Outcome__c == 'Approved') {
        c.Status = 'Closed - Approved';
      } else if (c.Assessment_Outcome__c == 'Declined') {
        c.Status = 'Closed - Declined';
      }
      c.System_Action__c = true;
      DMLUtil.updateRecords(new List<Case>{ c }, false, false);
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      e.setMessage(FINALISE_CALLOUT_ERROR);
      throw e;
    }

    return true;
  }
}
