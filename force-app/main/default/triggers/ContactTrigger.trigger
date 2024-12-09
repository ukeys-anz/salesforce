/**
 * @author Tan Phan
 * @since 09/2022
 * @description ContactTrigger to handle trigger actions.
 */
trigger ContactTrigger on Contact(
  before insert,
  after insert,
  before update,
  after update
) {
  RetailBrokerContactTriggerHandler retailBrokerHandler = new RetailBrokerContactTriggerHandler();
  CommercialContactTriggerHandler commercialContactHandler = new CommercialContactTriggerHandler();
}
