/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description ContactPointEmailTrigger to handle trigger actions.
 */
trigger ContactPointEmailTrigger on ContactPointEmail(
  before insert,
  after insert,
  before update
) {
  ContactPointEmailTriggerHandler handler = new ContactPointEmailTriggerHandler();
}
