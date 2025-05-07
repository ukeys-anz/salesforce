/**
 * @author Hrushikesh
 * @since 04/2025
 * @description This acts as a tigger handler for Interactions topic assignemnt
 */
public with sharing class InteractionTopicAssignmentHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public InteractionTopicAssignmentHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of topic assignments for Interactions
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((TopicAssignment) record).EntityId.getSObjectType() ==
      Interaction.sObjectType;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    InteractionTopicAssignmentActions.tagCategoryValidation(records);
    Logger.saveLog();
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    Logger.debug('On_After_Insert started: ' + System.now());
    InteractionTopicAssignmentActions.validateTagCount(records);
    InteractionTopicAssignmentActions.populateFieldOnInteraction(records);
    Logger.saveLog();
  }

  /**
   * @description onBeforeDelete to handle before delete trigger actions.
   */
  public override void onBeforeDelete() {
    Logger.debug('On_Before_Delete started: ' + System.now());
    InteractionTopicAssignmentActions.restrictInterestTagDeletion(records);
    Logger.saveLog();
  }

  /**
   * @description onAfterDelete to handle after delete trigger actions.
   */
  public override void onAfterDelete() {
    Logger.debug('On_After_Delete started: ' + System.now());
    InteractionTopicAssignmentActions.populateFieldOnInteraction(records);
    Logger.saveLog();
  }
}
