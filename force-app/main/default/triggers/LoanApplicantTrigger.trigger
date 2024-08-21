trigger LoanApplicantTrigger on LoanApplicant(
    after insert,
    after update
  ) {
    LoanApplicantTriggerHandler handler = new LoanApplicantTriggerHandler();
  }