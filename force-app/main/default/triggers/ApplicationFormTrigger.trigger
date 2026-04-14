/**
 * @description       : Trigger on ApplicationForm object
 * @author            : Akanksha Kulkarni | Salesforce
 * @group             :
 * @last modified on  :  10-2025
 * @last modified by  :  Ali Mujtaba | 31-10-2025
 **/
trigger ApplicationFormTrigger on ApplicationForm(
  before insert,
  before update,
  after insert,
  after update
) {
  new ApplicationFormTriggerHandler();
}
