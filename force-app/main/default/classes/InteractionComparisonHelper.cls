/**
 * @author Adam Smith
 * @since 20220624
 * @description  Class to help compare interactions to other objects and interactions
 */
public with sharing class InteractionComparisonHelper {
  /**
   * @description Gets the list of interactions and returns the ones where the owner has been assigned back to Queue.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of interactions assigned back to Queue
   */
  public static List<Interaction> getInteractionsAssignedBacktoQueue(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    List<Interaction> assignedToQueueInteractions = new List<Interaction>();

    for (Interaction interact : interactions) {
      if (interact.RecordTypeId != appointmentRTID) {
        continue;
      }
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        interact.OwnerId != oldInteraction.OwnerId &&
        interact.OwnerId == InteractionConstants.APPOINTMENT_QUEUE_ID
      ) {
        assignedToQueueInteractions.add(interact);
      }
    }

    return assignedToQueueInteractions;
  }

  /**
   * @description Gets the list of interactions and returns the ones where the status is updated as No show
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of interactions updated as No show
   */
  public static List<Interaction> getNoShowInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    List<Interaction> noShowInteractions = new List<Interaction>();
    for (Interaction interact : interactions) {
      if (interact.RecordTypeId != appointmentRTID) {
        continue;
      }
      Interaction oldInteraction = (Interaction) Trigger.oldMap
        .get(interact.Id);
      if (
        oldInteraction.Status__c != interact.Status__c &&
        interact.Status__c == InteractionConstants.NO_SHOW_STATUS
      ) {
        noShowInteractions.add(interact);
      }
    }

    return noShowInteractions;
  }

  /**
   * @description goes through a list of interactions and returns the ones that have been cancelled.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of cancelled interactions
   */
  public static List<Interaction> findCancelledInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> result = new List<Interaction>();
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    if (interactions.isEmpty()) {
      return result;
    }

    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.RecordTypeId != appointmentRTID) {
        continue;
      }
      if (
        currentInteraction.Status__c != InteractionConstants.CANCELLED_STATUS ||
        !oldMap.containsKey(currentInteraction.Id)
      ) {
        continue;
      }
      Interaction oldInteraction = (Interaction) oldMap.get(
        currentInteraction.Id
      );
      if (oldInteraction.Status__c != InteractionConstants.CANCELLED_STATUS) {
        result.add(currentInteraction);
      }
    }
    return result;
  }

  /**
   * @description Get the list of updated Interactions where a Coach has taken ownership from the queue
   * @param oldMap The oldValues before the update.
   * @param interactions The new values of the interaction after update.
   * @return List<Interaction> The list of interactions where the owner has been updated
   */
  public static List<Interaction> getAcceptedInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    List<Interaction> acceptedInteractions = new List<Interaction>();
    for (Interaction interact : interactions) {
      if (interact.RecordTypeId != appointmentRTID) {
        continue;
      }
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        oldInteraction.OwnerId != interact.OwnerId &&
        oldInteraction.OwnerId == InteractionConstants.APPOINTMENT_QUEUE_ID
      ) {
        acceptedInteractions.add(interact);
      }
    }
    return acceptedInteractions;
  }

  /**
   * @description Get the list of updated Interactions where the status has been updated to Rescheduled
   * @param oldMap The oldValues before the update.
   * @param interactions The new values of the interaction after update.
   * @return List<Interaction> The list of interactions where the status has been updated to rescheduled
   */
  public static List<Interaction> getRescheduledInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    List<Interaction> rescheduledInteractions = new List<Interaction>();
    for (Interaction interact : interactions) {
      if (interact.RecordTypeId != appointmentRTID) {
        continue;
      }
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        oldInteraction.Status__c != interact.Status__c &&
        interact.Status__c == InteractionConstants.RESCHEDULED_STATUS
      ) {
        rescheduledInteractions.add(interact);
      }
    }
    return rescheduledInteractions;
  }

  /**
   * @description Goes through a list of Interactions and using an old map, finds the one that ownership has changed.
   * @param oldMap Map<Id, SObject> map of old versions of the interactions
   * @param records List<Interaction> list of the interaction through which to iterate.
   * @return List<Interaction> list of interaction that have had their ownership changed.
   */
  public static List<Interaction> findInteractionsOwnershipChanged(
    Map<Id, SObject> oldMap,
    List<Interaction> records
  ) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    List<Interaction> result = new List<Interaction>();
    for (Interaction currentInteraction : records) {
      if (currentInteraction.RecordTypeId != appointmentRTID) {
        continue;
      }
      if (oldMap.containsKey(currentInteraction.Id)) {
        Interaction oldInteraction = (Interaction) oldMap.get(
          currentInteraction.Id
        );
        if (oldInteraction.OwnerId != currentInteraction.OwnerId) {
          result.add(currentInteraction);
        }
      }
    }
    return result;
  }

  /**
   * @description checks to see if an interaction has been changed to unassigned
   * @param oldMap Map of SObjects contain old versions of Interactions
   * @param currentInteraction the interaction to check
   * @return true if the interaction has changed to unassigned.
   */
  public static Boolean hasBeenUnassigned(
    Map<Id, sObject> oldMap,
    Interaction currentInteraction
  ) {
    return !oldMap.containsKey(currentInteraction.Id) ||
      currentInteraction.Status__c != InteractionConstants.UNASSIGNED_STATUS ||
      currentInteraction.RecordTypeId !=
      InteractionConstants.APPOINTMENT_RECORD_TYPE_ID;
  }
}
