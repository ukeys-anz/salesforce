/**
 * @description Trigger Handler for Interaction Context Tag Junction Object
 * @author Nilesh Kalal
 * @since 20230704
 */
public with sharing class InteractionContextTagTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Override this to perform processing during the after insert phase, this is called by the handleAfterInsert method
   **/
  public override void onAfterInsert() {
    List<Interaction_Context_Tag__c> listOfInteractionContextTags = records;
    /**
     * @description update topics fields: Actual Topic, Product from Topic Details & Reason for Visit of Interaction Object after Creation of ICT.
     * @param listOfInteractionContextTags through which to iterate.
     */
    InteractionContextTagAction.processAndUpdateTopicFields(
      listOfInteractionContextTags
    );
  }
  /**
   * @description Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
   */
  public override void onAfterDelete() {
    List<Interaction_Context_Tag__c> listOfInteractionContextTags = records;
    /**
     * @description update topics fields: Actual Topic, Product from Topic Details & Reason for Visit of Interaction Object after Deletion of ICT.
     * @param listOfInteractionContextTags through which to iterate.
     */
    InteractionContextTagAction.processAndUpdateTopicFields(
      listOfInteractionContextTags
    );
  }
}
