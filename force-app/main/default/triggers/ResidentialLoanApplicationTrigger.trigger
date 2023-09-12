trigger ResidentialLoanApplicationTrigger on ResidentialLoanApplication(
  before insert
) {
  ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
}
