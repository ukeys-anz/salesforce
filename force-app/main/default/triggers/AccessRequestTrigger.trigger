trigger AccessRequestTrigger on Access_Request__c(
  before insert,
  before update,
  after update
) {
  AccessRequestTriggerHandler handler = new AccessRequestTriggerHandler();
}
