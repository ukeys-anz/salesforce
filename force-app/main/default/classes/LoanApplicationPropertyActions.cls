/**
 * @description  Actions for Loan Application Property trigger handler
 * @author @fangl6
 * @since 12//06/2024
 */
public with sharing class LoanApplicationPropertyActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final LoanApplicationPropertyRepository LOAN_REPOSITORY = (LoanApplicationPropertyRepository) Lib_InstanceProvider.forType(
    LoanApplicationPropertyRepository.class
  );
  /**
   * @description update related case
   * @param records List of LoanApplicationProperty from trigger.new
   * @param oldMap map of LoanApplicationProperty from trigger.oldMap
   */
  public static void updateRelatedCases(
    List<LoanApplicationProperty> records,
    Map<Id, LoanApplicationProperty> oldMap
  ) {
    PermissionUtils.canUpdate('Case');
    Map<Id, LoanApplicationProperty> filteredProperties = LoanApplicationPropertyHelper.updatedAssessmentIdProperties(
      records,
      oldMap
    );
    List<Case> caseToUpdate = LOAN_REPOSITORY.queryRelatedCase(
      GetHelpConstants.CREDIT_REFERRAL_RT_ID,
      filteredProperties.keySet()
    );

    List<Case> casewithNewValues = LoanApplicationPropertyHelper.updateCaseValues(
      caseToUpdate,
      filteredProperties
    );
    DML_REPOSITORY.updateRecords(
      casewithNewValues,
      DmlRepository.ALL_OR_NONE,
      DmlRepository.USER_MODE
    );
  }
}
