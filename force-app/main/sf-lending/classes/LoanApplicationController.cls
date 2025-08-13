/**
 * @description controller class for Loan Application
 * @author ramvilas
 * @since May 2025
 */
public with sharing class LoanApplicationController {
  private static final ResidentialLoanApplicationRepository LOAN_APPLICATION_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  private static final LoanApplicationAPIRepository LOAN_APP_API_REPOSITORY = (LoanApplicationAPIRepository) Lib_InstanceProvider.forType(
    LoanApplicationAPIRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description To get Loan Preference details
   * @param loanId Loan record Id
   * @param skipCacheForCallout skipCacheForCallout is true then direct callout is made to API else first check for cache
   * @return LexLoanappV1b1_loanapplication_types.LoanApplication
   * @exception
   */
  @AuraEnabled
  public static LexLoanappV1b1_loanapplication_types.LoanApplication getLoanPreferenceDetails(
    Id loanId,
    Boolean skipCacheForCallout
  ) {
    try {
      ResidentialLoanApplication loanRec = LOAN_APPLICATION_REPOSITORY.queryRLAByIdForLoanPreference(
        loanId
      );
      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      LexLoanappV1b1_loanapplication_types.LoanApplication result = LOAN_APP_API_REPOSITORY.getLoanApplicationDetails(
        loanRec.Account?.OCV_ID__c,
        loanRec.ApplicationExtIdentifier,
        skipCacheForCallout
      );
      return result;
    } catch (Exception ex) {
      Logger.info('Failure on Get LoanPreference Details', ex);
      Logger.saveLog();
      throw new AuraHandledException(
        'Failed to retrieve loan preference details Please refresh and try again. If the problem persists, please contact your System Administrator'
      );
    }
  }

  /** @description cancelResidentialLoanApplication cancels residential loan application
   * @param rlaObject map of residential loan application fields
   * @return response from mule
   */
  @AuraEnabled
  public static Boolean cancelResidentialLoanApplication(
    Map<String, String> rlaObject
  ) {
    try {
      LOAN_APP_API_REPOSITORY.cancelResidentialLoanApp(
        rlaObject.get('requestId'),
        rlaObject.get('ocvId')
      );
      ResidentialLoanApplication rlaRecord = ResidentialLoanApplicationHelper.updateFieldsOnLoanCancellation(
        rlaObject
      );

      DML_REPOSITORY.doUpdate(rlaRecord);

      String postContent = ResidentialLoanApplicationHelper.postNotesToChatter(
        rlaObject
      );

      ChatterUtils.makeAPost(
        rlaObject.get('recordId'),
        postContent,
        ChatterUtils.POST_TYPE_RICH_TEXT
      );

      return true;
    } catch (Exception objException) {
      Logger.info(objException.getMessage(), objException);
      Logger.saveLog();
      throw new AuraHandledException(objException.getMessage());
    }
  }
}
