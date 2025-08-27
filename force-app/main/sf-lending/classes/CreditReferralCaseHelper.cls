/**
 * @description Helper class for Credit Referral Case Controller
 * @author Pooja Kirtishahi
 * @since Aug 2025
 */
public with sharing class CreditReferralCaseHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final Map<String, Id> OWNER_TO_UPDATE_MAP = new Map<String, Id>{
    'FRAUD' => QueryQueue.fraudRefQueue.Id,
    'CAD' => QueryQueue.cadReferralQueue.Id
  };
  private static final String ESCALATED_STATUS = 'Escalated';
  public static Boolean allowEscalateStatusUpdate = false;

  /**
   * @description Update case status to Escalated
   * @param caseId Id,
   * @param escalateTo String
   * @exception
   */
  public static void updateCaseStatus(Id caseId, String escalateTo) {
    try {
      Case caseRecord = new Case(
        Id = caseId,
        OwnerId = OWNER_TO_UPDATE_MAP.get(escalateTo),
        status = ESCALATED_STATUS
      );
      allowEscalateStatusUpdate = true; // assigning static variable to true to bypass trigger validation for status change
      DML_REPOSITORY.doUpdate(caseRecord);
    } catch (Exception e) {
      Logger.info('Failure on upadate details for case', e);
      Logger.saveLog();
    }
  }

  /**
   * @description Update RLA field with Escalated status
   * @param caseId Id,
   * @param caseWithRLA Case
   * @exception
   */
  public static void updateRLAStatus(Id caseId, Case caseWithRLA) {
    try {
      ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication(
        Id = caseWithRLA.Loan_Application__c,
        Application_Progress__c = ESCALATED_STATUS
      );
      DML_REPOSITORY.doUpdate(rlaRecord);
    } catch (Exception e) {
      Logger.info('Failure on upadate details for RLA', e);
      Logger.saveLog();
    }
  }
}
