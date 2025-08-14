/**
 * @description controller class for Loan Preference
 * @author Pooja Kirtishahi
 * @since Nov 2024
 */
public with sharing class LoanPreferenceController {
  private static final LoanApplicationFinancialRepository LP_SOQL_REPOSITORY = (LoanApplicationFinancialRepository) Lib_InstanceProvider.forType(
    LoanApplicationFinancialRepository.class
  );

  private static final LoanPreferenceAPIRepository LP_API_REPOSITORY = (LoanPreferenceAPIRepository) Lib_InstanceProvider.forType(
    LoanPreferenceAPIRepository.class
  );

  private static final ResidentialLoanApplicationRepository LOAN_APPLICATION_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  /**
   * @description To get Loan Preference details
   * @param loanId Loan record Id
   * @return LoanPreferenceResponseModel
   * @exception
   */
  @AuraEnabled
  public static LoanPreferenceResponseModel getCalculateLoanRepayment(
    Id loanId
  ) {
    try {
      LoanApplicationFinancial loanPrefRec = LP_SOQL_REPOSITORY.queryLAFByRLAId(
        loanId
      );
      if (loanPrefRec == null) {
        throw new IllegalArgumentException(
          'Valid Loan Preference record not found'
        );
      }

      String ocvId = loanPrefRec.LoanApplication?.Account?.OCV_ID__c;

      LoanPreferenceRequestModel requestBody = new LoanPreferenceRequestModel(
        loanPrefRec
      );

      LoanPreferenceResponseModel response = LP_API_REPOSITORY.getCalculateLoanRepayment(
        requestBody,
        ocvId
      );
      return response;
    } catch (Exception e) {
      Logger.info('Failure on Get Calculate Loan Repayment', e);
      Logger.saveLog();
      throw new AuraHandledException(
        'Failed to get Calculate Loan Repayment details'
      );
    }
  }

  /**
   * @description Below method will accept the updated values of from the LWC and turn it into the requestBody and make callout.
   * @param updateLoanPreferenceData LoanPreferenceViewModel
   * @param additionalFundsData AdditionalFundsViewModel
   * @return `LoanPreferenceUpdateResponseModel`
   * @exception
   */
  @AuraEnabled
  public static Boolean updateLoanPreference(
    LoanPreferenceViewModel updateLoanPreferenceData,
    AdditionalFundsViewModel additionalFundsData
  ) {
    try {
      String ocvId = updateLoanPreferenceData.ocvId;
      LoanPreferenceEditModel requestBody = new LoanPreferenceEditModel(
        updateLoanPreferenceData,
        additionalFundsData
      );

      List<Object> urlParams = new List<Object>{
        updateLoanPreferenceData.loanApplicationNumber,
        updateLoanPreferenceData.uid
      };

      Boolean isSuccess = LP_API_REPOSITORY.updateLoanPreference(
        ocvId,
        urlParams,
        requestBody
      );
      if (isSuccess) {
        SOPHelper.setToReassessmentIsRequired(updateLoanPreferenceData.loanId);
      }

      return isSuccess;
    } catch (LoanPreferenceAPIRepository.UserErrorLoanPreferenceException ex) {
      throw new AuraHandledException(ex.errorMessage);
    } catch (Exception e) {
      Logger.info('Failure on Update Loan Preference', e);
      Logger.saveLog();
      throw new AuraHandledException('Failed to update loan preference');
    }
  }

  /**
   * @description To get Loan Preference details
   * @param loanId Loan record Id
   * @return LoanPreferenceViewModel
   * @exception
   */
  @AuraEnabled
  public static LoanPreferenceViewModel getLoanPreference(Id loanId) {
    try {
      LoanApplicationFinancial loanPrefRec = LP_SOQL_REPOSITORY.queryLAFByRLAId(
        loanId
      );
      if (loanPrefRec == null) {
        throw new IllegalArgumentException(
          'Valid Loan Preference record not found'
        );
      }
      return new LoanPreferenceViewModel(loanPrefRec);
    } catch (IllegalArgumentException ex) {
      throw new AuraHandledException(
        'Loan Preferences will be available once the customer(s) has provided the required information within the Loan Preferences section of the loan application.'
      );
    } catch (Exception e) {
      Logger.info('Failure on Get Loan Preference', e);
      Logger.saveLog();
      throw new AuraHandledException(
        'Failed to load Loan Preferences details.'
      );
    }
  }

  /**
   * @description Below method will accept the updated values of from the LWC and make callout.
   * @param loanApplicationNumber Loan Number
   * @param loanPrefData LexLoanappV1b1_loanapplication_types.LoanPreferences
   * @return LexLoanappV1b1_loanapplication_types.LoanApplication
   * @exception
   */
  @AuraEnabled
  public static LexLoanappV1b1_loanapplication_types.LoanApplication updateLoanPreferenceDetails(
    String loanApplicationNumber,
    LexLoanappV1b1_loanapplication_types.LoanPreferences loanPrefData
  ) {
    try {
      ResidentialLoanApplication loanRec = LOAN_APPLICATION_REPOSITORY.queryRLAByIdForLoanPreference(
        loanApplicationNumber
      );
      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      List<Object> urlParams = new List<Object>{
        loanApplicationNumber,
        loanPrefData.uid
      };

      LexLoanappV1b1_loanapplication_types.LoanApplication response = LP_API_REPOSITORY.updateLoanPreference(
        loanRec.Account?.OCV_ID__c,
        urlParams,
        loanPrefData
      );

      SOPHelper.setToReassessmentIsRequired(loanRec.Id);

      return response;
    } catch (LoanPreferenceAPIRepository.UserErrorLoanPreferenceException ex) {
      throw new AuraHandledException(ex.errorMessage);
    } catch (Exception e) {
      Logger.info('Failure on Update Loan Preference', e);
      Logger.saveLog();
      throw new AuraHandledException('Failed to update loan preference');
    }
  }
}
