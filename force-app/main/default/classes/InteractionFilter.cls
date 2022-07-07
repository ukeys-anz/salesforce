/**
 * @author Adam Smith
 * @since 20220621
 * @description Provides methods to filter lists of Interactions
 */
public with sharing class InteractionFilter {
  /**
   * @description Goes through a list of Interactions and using an old map, finds the one that does not have coaching summary.
   * @param records List<Interaction> list of the interaction through which to iterate.
   * @return List<Interaction> list of interaction that does not have coaching summary linked to it.
   */
  public static List<Interaction> getInteractionswithoutCoachingSummary(
    List<Interaction> records
  ) {
    List<Interaction> interactionWithoutSummary = new List<Interaction>();
    for (Interaction interact : records) {
      if (interact.Coaching_Summary__c == null) {
        interactionWithoutSummary.add(interact);
      }
    }

    return interactionWithoutSummary;
  }

  /**
   * @description Goes through a list of Interactions and using an old map, finds the one that has coaching summary.
   * @param records List<Interaction> list of the interaction through which to iterate.
   * @return List<Interaction> list of interaction that has coaching summary linked to it.
   */
  public static List<Interaction> getInteractionswithCoachingSummary(
    List<Interaction> records
  ) {
    List<Interaction> interactionWithSummary = new List<Interaction>();
    for (Interaction interact : records) {
      if (interact.Coaching_Summary__c != null) {
        interactionWithSummary.add(interact);
      }
    }

    return interactionWithSummary;
  }

  /**
   * @description Returns the list of new interactions without End time
   * @param interactions List<Interaction> list of new interaction records.
   * @return List<Interaction> list of interactions without end time.
   */
  public static List<Interaction> getInteractionsWithoutEnddate(
    List<Interaction> interactions
  ) {
    List<Interaction> interactionList = new List<Interaction>();
    for (Interaction interact : interactions) {
      if (interact.EndTime == null) {
        interactionList.add(interact);
      }
    }
    return interactionList;
  }

  /**
   * @description finds & returns interactions without a mobile number
   * @param interactions List<Interaction> list of interactions through which to search
   * @return List<Interaction> List of interactions without mobile number.
   */
  public static List<Interaction> findInteractionsWithoutMobile(
    List<Interaction> interactions
  ) {
    List<Interaction> result = new List<Interaction>();

    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.Contact_Mobile__c == null) {
        result.add(currentInteraction);
      }
    }

    return result;
  }

  /**
   * @description goes through a list of interactions and returns the ones that have an automated purpose
   * @param interactions List<Interaction> list of interactions to search through.
   * @return List<Interaction> List of interactions that have an automated purpose
   */
  public static List<Interaction> returnInteractionsWithAutomatedPurpose(
    List<Interaction> interactions
  ) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    List<Interaction> result = new List<Interaction>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        if (
          AutomatedRequestMetadataProvider.getInstance()
            .getMap()
            .containsKey(currentInteraction.Interaction_Purpose__c) &&
          currentInteraction.RecordTypeId == appointmentRTID
        ) {
          result.add(currentInteraction);
        }
      }
    }
    return result;
  }
}
