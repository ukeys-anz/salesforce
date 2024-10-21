trigger ApplicationFormTrigger on ApplicationForm(
  before insert,
  before update,
  after insert,
  after update
) {
  CommercialAppFormTriggerHandler handler = new CommercialAppFormTriggerHandler();
}
