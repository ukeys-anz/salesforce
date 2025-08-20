trigger ResidentialLoanApplicationTrigger on ResidentialLoanApplication(
  before insert,
  after insert,
  before update,
  after update
) {
  ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
  AnzxLoanApplicationTriggerHandler loanApplicationHandler = new AnzxLoanApplicationTriggerHandler();
  RLSResidentialLoanAppTriggerHandler rlsHandler = new RLSResidentialLoanAppTriggerHandler();
}
