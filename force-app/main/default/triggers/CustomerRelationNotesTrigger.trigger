trigger CustomerRelationNotesTrigger on Customer_Relationship__c(
  before insert,
  before update,
  after insert,
  after update
) {
  CustomerRelationNotesTriggerHandler objHandler = new CustomerRelationNotesTriggerHandler();
}
