/**
 * @author Peter Charalambous
 * @since Wed Jun 05 2024
 * @description Controller class for Loan Application Property
 */
public with sharing class LoanApplicationPropertyController {
  private static final LoanApplicationPropertyRepository LOAN_REPOSITORY = (LoanApplicationPropertyRepository) Lib_InstanceProvider.forType(
    LoanApplicationPropertyRepository.class
  );

  private static final LoanApplicationPropertyAPIRepository LOAN_PROPERTY_API = (LoanApplicationPropertyAPIRepository) Lib_InstanceProvider.forType(
    LoanApplicationPropertyAPIRepository.class
  );

  /**
   * @description reassess collateral assessment
   * @param recordId property record id
   * @return `Boolean` confirms whether reassessment was successful
   */
  @AuraEnabled
  public static Boolean reassessCollateralAssessment(String recordId) {
    LoanApplicationProperty property = LOAN_REPOSITORY.getLoanAppProperty(
      recordId
    );

    Boolean result = LOAN_PROPERTY_API.reassessCollateralAssessment(
      property.LoanApplication.Account.OCV_ID__c,
      recordId,
      property.Collateral_Assessment_ID__c
    );

    return result;
  }
}
