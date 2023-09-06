/**
 * @description Trigger Handler for Interaction Context Tags Junction Object
 * @author Nilesh Kalal
 * @since 07/2020
 */
public with sharing class InteractionContextTagAction {
  /**
   * @description perfom final update on Interaction records
   * @param listOfInteractionContextTags through which to iterate.
   */

  public static void processAndUpdateTopicFields(
    List<Interaction_Context_Tag__c> listOfInteractionContextTags
  ) {
    try {
      Set<Id> setOfInteractionsId = new Set<Id>();
      List<Interaction> listOfInteractionsToUpdate = new List<Interaction>();
      for (
        Interaction_Context_Tag__c eachIctRecord : listOfInteractionContextTags
      ) {
        setOfInteractionsId.add(eachIctRecord.Interaction__c);
      }
      List<Interaction_Context_Tag__c> listOfAllInteractionContextFromDb = [
        SELECT Id, Type__c, Tag_Name__c, Interaction__c
        FROM Interaction_Context_Tag__c
        WHERE Interaction__c IN :setOfInteractionsId
      ];
      Map<Id, Map<String, List<String>>> mapOfInteractionIdWithTopicDetails = getMapOfInteractionIdWithTopicDetails(
        listOfAllInteractionContextFromDb
      );
      listOfInteractionsToUpdate = concatenationOfTopicFieldValues(
        setOfInteractionsId,
        mapOfInteractionIdWithTopicDetails
      );
      DMLUtil.updateRecords(listOfInteractionsToUpdate, false, true);
    } catch (Exception objException) {
      Logger.error('Exception in processAndUpdateTopicFields', objException);
      Logger.saveLog();
    }
  }

  /**
   * @description to build map which contains interaction id with list of topic fields details
   * @param listOfAllInteractionContextFromDb through which to iterate.
   * @return Map<Id, Map<String, List<String>>> master map holds interaction id with list of topic fields details
   */
  private static Map<Id, Map<String, List<String>>> getMapOfInteractionIdWithTopicDetails(
    List<Interaction_Context_Tag__c> listOfAllInteractionContextFromDb
  ) {
    Map<Id, Map<String, List<String>>> mapOfInteractionIdWithTopicDetails = new Map<Id, Map<String, List<String>>>();
    for (
      Interaction_Context_Tag__c contextTag : listOfAllInteractionContextFromDb
    ) {
      if (
        !mapOfInteractionIdWithTopicDetails.containsKey(
          contextTag.Interaction__c
        )
      ) {
        mapOfInteractionIdWithTopicDetails.put(
          contextTag.Interaction__c,
          new Map<String, List<String>>()
        );
      }
      Map<String, List<String>> mapOfTopicDetails = mapOfInteractionIdWithTopicDetails.get(
        contextTag.Interaction__c
      );
      if (!mapOfTopicDetails.containsKey(contextTag.Type__c)) {
        mapOfTopicDetails.put(contextTag.Type__c, new List<String>());
      }
      mapOfTopicDetails.get(contextTag.Type__c).add(contextTag.Tag_Name__c);
    }
    return mapOfInteractionIdWithTopicDetails;
  }

  /**
   * @description concatinate fields value seperated by comma and add final list of interactions to update
   * @param setOfInteractionsId
   * @param mapOfInteractionIdWithTopicDetails
   * @return List<Interaction> list of interactions to update
   */
  private static List<Interaction> concatenationOfTopicFieldValues(
    Set<Id> setOfInteractionsId,
    Map<Id, Map<String, List<String>>> mapOfInteractionIdWithTopicDetails
  ) {
    List<Interaction> listOfInteractionsToUpdate = new List<Interaction>();
    for (Id eachInteraction : setOfInteractionsId) {
      Map<String, List<String>> mapOfTopicDetails = mapOfInteractionIdWithTopicDetails.get(
        eachInteraction
      );
      String truncatedValueForProduct = LogEventBuilderHelper.truncateFieldValue(
        Interaction.Products__c,
        String.join(
          extractListOfValuesBasedOnKey('Product', mapOfTopicDetails),
          ','
        )
      );
      String truncatedValueForReasonForVisit = LogEventBuilderHelper.truncateFieldValue(
        Interaction.Reason_for_Visit__c,
        String.join(
          extractListOfValuesBasedOnKey('Reason', mapOfTopicDetails),
          ','
        )
      );
      String truncatedValueForActualTopic = LogEventBuilderHelper.truncateFieldValue(
        Interaction.Actual_Topics__c,
        String.join(
          extractListOfValuesBasedOnKey('Topic', mapOfTopicDetails),
          ','
        )
      );
      listOfInteractionsToUpdate.add(
        new Interaction(
          Id = eachInteraction,
          Products__c = truncatedValueForProduct,
          Reason_for_Visit__c = truncatedValueForReasonForVisit,
          Actual_Topics__c = truncatedValueForActualTopic
        )
      );
    }
    return listOfInteractionsToUpdate;
  }
  /**
   * @description extract list of topic field values (Product, Actual Topic, Reason)
   * @param key as topic field
   * @param mapOfTopicDetails as topic field Vs list of values
   * @return List<String> list of field values
   */
  private static List<String> extractListOfValuesBasedOnKey(
    String key,
    Map<String, List<String>> mapOfTopicDetails
  ) {
    return mapOfTopicDetails.get(key) == null
      ? new List<String>{}
      : mapOfTopicDetails.get(key);
  }
}
