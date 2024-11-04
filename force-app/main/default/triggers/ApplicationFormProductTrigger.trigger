trigger ApplicationFormProductTrigger on ApplicationFormProduct(
  before insert,
  before update,
  after insert,
  after update
) {
  CommercialAppFormProductTriggerHandler handler = new CommercialAppFormProductTriggerHandler();
}
