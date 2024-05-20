trigger ResidentialLoanApplicationTrigger on ResidentialLoanApplication(
  before insert,
  before update,
  after update
) {
  ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
}
