/**
 * @description controller class for Loan Application
 * @author ramvilas
 * @since May 2025
 */
public with sharing class LoanApplicationController {
  private static final LoanApplicationAPIRepository LOAN_APP_API_REPOSITORY = (LoanApplicationAPIRepository) Lib_InstanceProvider.forType(
    LoanApplicationAPIRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

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
      throw new AuraHandledException('The application could not be withdrawn');
    }
  }
}
