trigger LoanApplicationPropertyTrigger on LoanApplicationProperty(
  after update
) {
  LoanApplicationPropertyTriggerHandler handler = new LoanApplicationPropertyTriggerHandler();
}
