trigger CaseProductTrigger on Case_Product__c(before insert, before update) {
  CaseProductTriggerHandler handler = new CaseProductTriggerHandler();
}
