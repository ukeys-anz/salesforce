trigger ResidentialLoanApplicationTrigger on ResidentialLoanApplication(
  before insert,
  after insert,
  before update,
  after update
) {
  ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
}
