trigger LoanApplicantTrigger on LoanApplicant(after insert) {
  LoanApplicantTriggerHandler handler = new LoanApplicantTriggerHandler();
}
