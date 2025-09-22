trigger InteractionTrigger on Interaction(
  before insert,
  before update,
  after insert,
  after update
) {
  InteractionTriggerHandler handler = new InteractionTriggerHandler();
  CommercialInteractionTriggerHandler commercialHandler = new CommercialInteractionTriggerHandler();
  MobileLendingInteractionTriggerHandler mlcrmHandler = new MobileLendingInteractionTriggerHandler();
  RBMInteractionHandler rbmHandler = new RBMInteractionHandler();
}
