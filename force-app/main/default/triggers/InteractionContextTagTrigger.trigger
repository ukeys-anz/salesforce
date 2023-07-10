/**
 * @description Trigger on Interaction Context Tag Junction Object
 * @author Nilesh Kalal
 * @since 07/2020
 */
trigger InteractionContextTagTrigger on Interaction_Context_Tag__c(
  after insert,
  after delete
) {
  InteractionContextTagTriggerHandler handlerInstance = new InteractionContextTagTriggerHandler();
}
