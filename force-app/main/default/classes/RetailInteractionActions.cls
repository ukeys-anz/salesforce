/**
 * @author Karen Valeriano
 * @since  January 2026
 * @description Handles all the Retail Interaction Actions
 */
public with sharing class RetailInteractionActions {
  /**
   * @description This method will perform redaction on sensitive data in the provided records.
   * @param records from the trigger
   */
  public static void performRedaction(List<Interaction> records) {
    if (records == null || records.isEmpty()) {
      return;
    }

    Set<String> fieldsToMask = new Set<String>{
      'Name',
      'Comment__c',
      'Optional_Notes__c'
    };
    for (String fieldName : fieldsToMask) {
      TextUtils.maskSObjectDataANZExtended(records, fieldName);
    }
  }

  /**
   * @description publish cloud events for Interactions
   * @param interactions list of Interaction records
   * @param actionCode action code for the cloud event
   **/
  public static void publishCloudEvents(
    List<Interaction> interactions,
    String actionCode
  ) {
    if (interactions == null || interactions.isEmpty()) {
      return;
    }

    try {
      InteractionCEBuilder.InteractionCEWrapper interactionCEWrapper = new InteractionCEBuilder.InteractionCEWrapper(
        interactions
      );

      List<CloudEventModel> cloudEvents = InteractionCEBuilder.createCloudEvents(
        interactions,
        interactionCEWrapper,
        actionCode
      );
      CloudEventController.publishCloudEvents(cloudEvents);
    } catch (Exception e) {
      Logger.error(
          'Errored out while publishing the cloud event for Interactions',
          e
        )
        .save();
      throw e;
    }
  }
}
