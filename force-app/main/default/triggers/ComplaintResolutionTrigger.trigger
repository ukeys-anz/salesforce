trigger ComplaintResolutionTrigger on Complaint_Resolution__c(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  ComplaintResolutionTriggerHandler handler = new ComplaintResolutionTriggerHandler();
}
