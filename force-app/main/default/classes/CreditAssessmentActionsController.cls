/**
 * @author Peter Charalambous
 * @since June 2023
 * @description Controller for Credit Assessment actions such as reassess or finalise
 */
public with sharing class CreditAssessmentActionsController {
  private static final String TECH_ASSIST_ERROR = 'An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String REASSESSMENT_CALLOUT_ERROR = 'Failed to complete reassessment.';
  private static final String REASSESS_REQUIRED_ERROR = 'The loan application has been updated and you must resubmit this credit referral case for reassessment.';
  private static final String ASSESSMENT_ERROR = 'This credit referral case is currently being assessed. You can\'t finalise the referral case until this has been completed.';
  private static final String FINALISE_CALLOUT_ERROR = 'Failed to complete finalisation.';
  private static final String FRAUD_RELATED_ERROR = 'There’s a fraud case related to this credit referral case still open. You can’t finalise this case until the fraud case is closed.';

  private static final CreditAsssessmentRepository CREDIT_REPOSITORY = (CreditAsssessmentRepository) Lib_InstanceProvider.forType(
    CreditAsssessmentRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
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
    Case c = CREDIT_REPOSITORY.getCaseRecord(recordId);

    //Ensure a credit id is on the record
    if (String.isBlank(c.Credit_Id__c)) {
      Logger.error('Missing Credit Id on Credit assessment case: ' + recordId);
      Logger.saveLog();
      throw ExceptionHelper.createAuraHandledException(TECH_ASSIST_ERROR);
    }

    try {
      CreditAssessmentAPIRepository creditApi = new CreditAssessmentAPIRepository();
      Map<String, String> payload = new Map<String, String>();
      payload.put('creditId', c.Credit_Id__c);
      payload.put('recordId', recordId);
      payload.put('collateralAssessmentId', c.Property_Valuation_Id__c);
      payload.put('ocvId', c.Account.OCV_ID__c);
      payload.put('titleReferenceNumber', c.Title_Reference_Number__c);

      //If outcome is processing, then we are retrying the assessment, update log status for new request id
      if (c.Assessment_Outcome__c == 'Processing') {
        //There will only ever be one log in progress associated to case
        List<UUID_Log_Entry__c> log = CREDIT_REPOSITORY.getInProgressUUIDLogs(
          recordId
        );
        if (!log.isEmpty()) {
          log[0].Status__c = 'Attempted Retry';
          DML_REPOSITORY.doUpdate(log[0]);
        }
      }
      creditApi.submitReassessment(payload);
      c.Assessment_Outcome__c = 'Processing';
      DMLUtil.updateRecords(new List<Case>{ c }, false, false);
      ResidentialLoanApplication rla = CREDIT_REPOSITORY.getResidentialLoanApplicationRecord(
        c.Loan_Application__c
      );
      rla.Credit_Reassess_Required__c = false;
      DML_REPOSITORY.doUpdate(rla);
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      e.setMessage(REASSESSMENT_CALLOUT_ERROR);
      throw e;
    }

    //Set reassess time to allow reassess to occur again after an elapsed period of time
    c.Credit_Reassessment_Time__c = Datetime.now();
    DML_REPOSITORY.doUpdate(c);

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
    Boolean hasFraudCase = false;
    Case caseToFinalise;
    //Retrieve case records for validation
    List<Case> cList = [
      SELECT
        Id,
        Type,
        ParentId,
        RecordTypeId,
        Credit_Id__c,
        Assessment_Outcome__c,
        Assessment_Id__c,
        IDR_Subsequent_Issue__c,
        Account.OCV_ID__c,
        Loan_Application__r.Credit_Reassess_Required__c
      FROM Case
      WHERE
        Id = :recordId
        OR (ParentId = :recordId
        AND RecordTypeId = :GetHelpConstants.GENERAL_INQUIRY_RT_ID
        AND Type = 'Fraud'
        AND Sub_Type__c = 'Home loan document verification'
        AND Status != 'Closed')
    ];
    for (Case c : cList) {
      if (c.ParentId == recordId && c.Type == 'Fraud') {
        hasFraudCase = true;
      } else if (c.Id == recordId) {
        caseToFinalise = c;
      }
    }
    if (caseToFinalise?.Loan_Application__r?.Credit_Reassess_Required__c) {
      throw ExceptionHelper.createAuraHandledException(REASSESS_REQUIRED_ERROR);
    }

    if (
      caseToFinalise.Assessment_Outcome__c != 'Approved' &&
      caseToFinalise.Assessment_Outcome__c != 'Declined'
    ) {
      throw ExceptionHelper.createAuraHandledException(ASSESSMENT_ERROR);
    }
    // less priority error, only throw when there is no above errors
    if (hasFraudCase) {
      throw ExceptionHelper.createAuraHandledException(FRAUD_RELATED_ERROR);
    }

    try {
      CreditAssessmentAPIRepository creditApi = new CreditAssessmentAPIRepository();
      creditApi.finaliseAssessment(
        caseToFinalise.Credit_Id__c,
        caseToFinalise.Assessment_Id__c,
        caseToFinalise.Account.OCV_ID__c
      );

      //Add checks to ensure we only update status based on correct outcome
      if (caseToFinalise.Assessment_Outcome__c == 'Approved') {
        caseToFinalise.Status = 'Closed - Approved';
      } else if (caseToFinalise.Assessment_Outcome__c == 'Declined') {
        caseToFinalise.Status = 'Closed - Declined';
      }
      caseToFinalise.System_Action__c = true;
      DMLUtil.updateRecords(new List<Case>{ caseToFinalise }, false, false);
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      e.setMessage(FINALISE_CALLOUT_ERROR);
      throw e;
    }

    return true;
  }
}
