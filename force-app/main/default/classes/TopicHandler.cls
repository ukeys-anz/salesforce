/**
 * @author Aman
 * @since 04/2025
 * @description This acts as a tigger handler for topics.
 */
public with sharing class TopicHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public TopicHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    TopicActions.validatePermissionForTopicCreation(records);
  }
}
