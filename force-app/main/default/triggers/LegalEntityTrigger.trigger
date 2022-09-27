trigger LegalEntityTrigger on Legal_Entity__c(
  before delete,
  before insert,
  after insert,
  before update,
  after update
) {
  LegalEntityTriggerHandler handler = new LegalEntityTriggerHandler();
}
