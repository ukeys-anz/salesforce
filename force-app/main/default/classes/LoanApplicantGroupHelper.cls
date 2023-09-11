/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description Helper class for @link LoanApplicationGroupTriggerHandler
 */
public with sharing class LoanApplicantGroupHelper {
  /**
   * @param records Loan Applicant Group records
   * @description Copies the SOP Id from the Applicant Group to the associated Loan App record
   */
  public static void copySOPId(List<Loan_Applicant_Group__c> records) {
    List<ResidentialLoanApplication> resLoanApp = new List<ResidentialLoanApplication>();
    for (Loan_Applicant_Group__c applicantGroup : records) {
      resLoanApp.add(
        new ResidentialLoanApplication(
          Id = applicantGroup.Residential_Loan_Application__c,
          SOP_Id__c = applicantGroup.SOP_ID__c
        )
      );
    }

    update resLoanApp;
  }
}
