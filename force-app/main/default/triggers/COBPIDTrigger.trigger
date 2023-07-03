trigger COBPIDTrigger on COBPrimaryIDDocument__c(before insert, before update) {
  COBPIDTriggerHandler handler = new COBPIDTriggerHandler();
}
