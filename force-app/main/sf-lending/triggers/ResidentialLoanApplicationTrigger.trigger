trigger ResidentialLoanApplicationTrigger on ResidentialLoanApplication(
  before insert,
  after insert,
  before update,
  after update
) {
  ResidentialLoanAppTriggerHandler loanApplicationHandler = new ResidentialLoanAppTriggerHandler();
}
