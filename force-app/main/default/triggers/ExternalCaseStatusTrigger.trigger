trigger ExternalCaseStatusTrigger on External_Case_Status__c(
  before insert,
  after insert
) {
  ExternalCaseStatusTriggerHandler handler = new ExternalCaseStatusTriggerHandler();
}
