trigger AssociatedLoanApplicationTrigger on Associated_Loan_Application__c(
  before insert,
  before update,
  after insert,
  after update
) {
  RBMAssociatedLoanApplicationHandler rbmInteractionHandler = new RBMAssociatedLoanApplicationHandler();
}
