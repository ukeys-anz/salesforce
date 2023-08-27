trigger LoanApplicantGroupTrigger on Loan_Applicant_Group__c(after insert) {
  LoanApplicantGroupTriggerHandler handler = new LoanApplicantGroupTriggerHandler();
}
