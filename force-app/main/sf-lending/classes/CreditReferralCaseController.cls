/**
 * @description Credit referral case controller class
 * @author Raman Gupta
 * @since Jul 2025
 */
public with sharing class CreditReferralCaseController {
  private static final LendingCaseRepository CASE_SOQL_REPOSITORY = (LendingCaseRepository) Lib_InstanceProvider.forType(
    LendingCaseRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final String ESCALATED_STATUS = 'Escalated';
  private static final String FRAUD_AUTHORITY_LEVEL = 'FRAUD';
  private static Group fraudCreditRefQueue = QueryQueue.get(
    'Fraud_Credit_Referral_Case_Queue'
  );
  private static Group cadCreditRefQueue = QueryQueue.get(
    'CAD_Credit_Referral_Case_Queue'
  );
  private static final Map<String, Id> OWNER_TO_UPDATE_MAP = new Map<String, Id>{
    'FRAUD' => fraudCreditRefQueue.Id,
    'CAD' => cadCreditRefQueue.Id
  };
  public static Boolean allowEscalateStatusUpdate = false;

  /**
   * @description Escalate case to Fraud and add comment on chatter post
   * @param caseId Case Id to Escalate
   * @param comments String comment to post on chatter
   * @param escalateTo String use to assign queue
   * @return Boolean
   * @exception
   */
  @AuraEnabled
  public static Boolean escalateCase(
    Id caseId,
    String comments,
    String escalateTo
  ) {
    try {
      Case caseWithRLA = CASE_SOQL_REPOSITORY.queryCaseRLAById(caseId);

      Case caseRecord = new Case(
        Id = caseId,
        OwnerId = OWNER_TO_UPDATE_MAP.get(escalateTo),
        status = ESCALATED_STATUS
      );
      allowEscalateStatusUpdate = true; // assigning static variable to true to bypass trigger validation for status change
      DML_REPOSITORY.doUpdate(caseRecord);

      if (caseWithRLA.Loan_Application__c != null) {
        ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication(
          Id = caseWithRLA.Loan_Application__c,
          Application_Progress__c = ESCALATED_STATUS
        );
        DML_REPOSITORY.doUpdate(rlaRecord);
      }
      if (escalateTo == FRAUD_AUTHORITY_LEVEL && comments != '') {
        ChatterUtils.makeAPost(
          caseId,
          comments,
          ChatterUtils.POST_TYPE_RICH_TEXT
        );
      }
      return true;
    } catch (Exception e) {
      Logger.info('Failure on upadate details for case', e);
      Logger.saveLog();
      throw new AuraHandledException('Failure on upadate details for case');
    }
  }
}
