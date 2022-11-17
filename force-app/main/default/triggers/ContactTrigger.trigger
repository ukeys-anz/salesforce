/**
 * @author Tan Phan
 * @since 09/2022
 * @description ContactTrigger to handle trigger actions.
 */
trigger ContactTrigger on Contact(before insert, after insert, before update) {
  ContactTriggerHandler handler = new ContactTriggerHandler();
}
