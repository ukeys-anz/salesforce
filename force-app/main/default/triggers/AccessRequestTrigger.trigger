trigger AccessRequestTrigger on Access_Request__c(before insert, after update) {
  AccessRequestTriggerHandler handler = new AccessRequestTriggerHandler();
}
