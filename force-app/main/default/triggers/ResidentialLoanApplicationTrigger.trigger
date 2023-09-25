trigger ResidentialLoanApplicationTrigger on ResidentialLoanApplication(
  before insert,
  after update
) {
  ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
}
