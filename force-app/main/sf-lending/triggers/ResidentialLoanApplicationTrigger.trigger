trigger ResidentialLoanApplicationTrigger on ResidentialLoanApplication(
  before insert,
  after insert,
  before update,
  after update
) {
  ResidentialLoanAppTriggerHandler handler = new ResidentialLoanAppTriggerHandler();
  MobileLendingResidentialLoanTrgHandler objhandler = new MobileLendingResidentialLoanTrgHandler();
  RLSResidentialLoanAppTriggerHandler rlsHandler = new RLSResidentialLoanAppTriggerHandler();
}
