trigger ProofOfInsuranceTrigger on Proof_of_Insurance__c(
  before insert,
  before update
) {
  ProofOfInsuranceTriggerHandler handler = new ProofOfInsuranceTriggerHandler();
}
