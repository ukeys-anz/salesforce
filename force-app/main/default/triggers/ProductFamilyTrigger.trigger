trigger ProductFamilyTrigger on Product_Family__c(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  ProductFamilyTriggerHandler handler = new ProductFamilyTriggerHandler();
}
