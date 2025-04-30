/**
 * @author Fawad Akhtar
 * @since 03/2023
 * @description ContactPointPhoneTrigger to handle trigger actions.
 */
trigger ContactPointPhoneTrigger on ContactPointPhone(
  before insert,
  after insert,
  before update,
  after update
) {
  ContactPointPhoneTriggerHandler handler = new ContactPointPhoneTriggerHandler();
}
