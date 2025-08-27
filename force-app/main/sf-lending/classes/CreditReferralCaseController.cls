/**
 * @description Credit referral case controller class
 * @author Raman Gupta
 * @since Jul 2025
 */
public with sharing class CreditReferralCaseController {
  private static final LendingCaseRepository CASE_SOQL_REPOSITORY = (LendingCaseRepository) Lib_InstanceProvider.forType(
    LendingCaseRepository.class
  );
  private static final String FRAUD_AUTHORITY_LEVEL = 'FRAUD';
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
      CreditReferralCaseHelper.updateCaseStatus(caseId, escalateTo);

      Case caseWithRLA = CASE_SOQL_REPOSITORY.queryCaseRLAById(caseId);

      if (caseWithRLA.Loan_Application__c != null) {
        CreditReferralCaseHelper.updateRLAStatus(caseId, caseWithRLA);
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
      Logger.info('Failure on update details for case', e);
      Logger.saveLog();
      throw new AuraHandledException('Failure on update details for case');
    }
  }
}
