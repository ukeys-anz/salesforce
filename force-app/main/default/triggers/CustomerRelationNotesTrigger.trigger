trigger CustomerRelationNotesTrigger on Customer_Relationship__c(
  before insert,
  before update,
  after insert,
  after update
) {
  CommercialCRTriggerHandler customerRelationshipHandler = new CommercialCRTriggerHandler();
  CustomerRelationNotesTriggerHandler objHandler = new CustomerRelationNotesTriggerHandler();
}
