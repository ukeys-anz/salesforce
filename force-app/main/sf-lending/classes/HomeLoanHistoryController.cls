/**
 * @author ramvilas
 * @since 2025
 * @description HomeLoanHistoryController retrieves Home loan History details
 */
public with sharing class HomeLoanHistoryController {
  private static final HomeLoanHistoryAPIRepository HL_API_REPOSITORY = (HomeLoanHistoryAPIRepository) Lib_InstanceProvider.forType(
    HomeLoanHistoryAPIRepository.class
  );

  private static final LendingCaseRepository CASE_REPOSITORY = (LendingCaseRepository) Lib_InstanceProvider.forType(
    LendingCaseRepository.class
  );

  /**
   * @description To get the list of loan account changes
   * @param ocvId ocv id
   * @param loanAccNumber loan account number
   * @return LoanAccountChangesViewModel
   */
  @AuraEnabled
  public static LoanAccountChangesViewModel getListOfLoanAccountChanges(
    String ocvId,
    String loanAccNumber
  ) {
    try {
      LoanAccountChangesModel result = HL_API_REPOSITORY.getListOfLoanAccountChanges(
        ocvId,
        loanAccNumber
      );

      //If there is no change requested then result.changes will be null.
      //In this scnario on UI, will show no record found message in Changes history datatable
      if (result?.changes?.isEmpty() ?? true) {
        return null;
      }

      List<LoanAccountChangesModel.LoanAccountChange> approvedChanges = (List<LoanAccountChangesModel.LoanAccountChange>) ListUtil.filter(
          result?.changes
        )
        .equals('state', 'STATE_APPROVED')
        .toList();

      List<String> changeNames = (List<String>) ListUtil.getValues(
        approvedChanges,
        'name',
        String.class
      );

      List<Case> caseRecords = CASE_REPOSITORY.queryCaseByChangeName(
        changeNames
      );

      Map<String, Case> caseMap = (Map<String, Case>) ListUtil.mapBy(
        caseRecords,
        Case.Loan_Account_Change_Number__c
      );

      LoanAccountChangesViewModel viewModel = new LoanAccountChangesViewModel(
        approvedChanges,
        caseMap
      );

      return viewModel;
    } catch (Exception ex) {
      Logger.info('Failure on Get LoanAccount Changes', ex);
      Logger.saveLog();

      AuraHandledException err = new AuraHandledException(
        'Failed to retrieve account history. Please refresh and try again. If the problem persists, please contact your System Administrator.'
      );
      throw err;
    }
  }
}
