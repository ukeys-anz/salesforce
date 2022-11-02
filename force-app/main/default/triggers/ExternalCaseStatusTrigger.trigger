trigger ExternalCaseStatusTrigger on External_Case_Status__c(after insert) {
  ExternalCaseStatusTriggerHandler handler = new ExternalCaseStatusTriggerHandler();
}
