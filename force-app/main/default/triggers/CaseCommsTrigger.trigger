trigger CaseCommsTrigger on Case_Comms__c (
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
	CaseCommsTriggerHandler handler = new CaseCommsTriggerHandler();
}