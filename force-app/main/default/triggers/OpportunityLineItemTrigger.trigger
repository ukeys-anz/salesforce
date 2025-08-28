trigger OpportunityLineItemTrigger on OpportunityLineItem(
  before insert,
  before delete
) {
  CommercialOppLineItemTriggerHandler commercialOLIHandler = new CommercialOppLineItemTriggerHandler();
}
