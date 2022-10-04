trigger OpportunityLineItemTrigger on OpportunityLineItem(
  before delete,
  before insert,
  after insert,
  before update,
  after update
) {
  OpportunityLineItemTriggerHandler handler = new OpportunityLineItemTriggerHandler();
}
