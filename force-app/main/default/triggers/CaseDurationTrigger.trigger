trigger CaseDurationTrigger on Case_Duration__c(after update) {
  CaseDurationTriggerHandler handler = new CaseDurationTriggerHandler();
}
