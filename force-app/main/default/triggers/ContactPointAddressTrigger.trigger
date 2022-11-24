/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description ContactPointAddressTrigger to handle trigger actions.
 */
trigger ContactPointAddressTrigger on ContactPointAddress(
  before insert,
  after insert,
  before update
) {
  ContactPointAddressTriggerHandler handler = new ContactPointAddressTriggerHandler();
}
