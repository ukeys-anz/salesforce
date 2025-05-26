/**
 * @author Adam Smith
 * @since 20220411
 * @description class for helper methods to set interaction properties
 */
public with sharing class InteractionSetters {
  /**
   * @description goes through a list of interactions and sets the external Id to the autonumber if it is not already set
   * @param interactions list of interactions to cycle
   */
  private static void setExternalIds(List<Interaction> interactions) {
    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.Interaction_External_Id__c == null) {
        currentInteraction.Interaction_External_Id__c = currentInteraction.Interaction_Auto_Number__c;
      }
    }
  }

  /**
   * @description future method to set the external Id after creation
   * @param interactionIds the Ids to update
   */
  @future
  public static void setExternalIds(Set<Id> interactionIds) {
    List<Interaction> interactions = InteractionGetters.getInteractions(
      interactionIds
    );
    if (!interactions.isEmpty()) {
      List<Interaction> interactionsToSet = new List<Interaction>();
      for (Interaction currentInteraction : interactions) {
        if (currentInteraction.Interaction_External_Id__c == null) {
          interactionsToSet.add(currentInteraction);
        }
      }

      if (!interactionsToSet.isEmpty()) {
        setExternalIds(interactions);
        InteractionDMLHelper.updateInteractions(interactions);
      }
    }
  }

  /**
   * @description method to set the external Id after creation
   * of general interactions
   * @param interactionIds the Ids to update
   */
  public static void setGeneralExternalIds(Set<Id> interactionIds) {
    List<Interaction> interactions = InteractionGetters.getInteractions(
      interactionIds
    );
    if (!interactions.isEmpty()) {
      List<Interaction> interactionsToSet = new List<Interaction>();
      for (Interaction currentInteraction : interactions) {
        if (currentInteraction.Interaction_External_Id__c == null) {
          interactionsToSet.add(currentInteraction);
        }
      }
      if (!interactionsToSet.isEmpty()) {
        setExternalIds(interactionsToSet);
        //not doing permission checks as the integration user fails on POST
        update interactionsToSet;
      }
    }
  }

  /**
   * @description goes through a list of interactions and sets the Interaction Id
   * on the linked Contact Request by searching the database for requests related to the Interactionss.
   * @param interactions List<Interaction> list of interactions to cycle through
   */
  public static void setInteractionIds(List<Interaction> interactions) {
    Set<Id> requestIds = new Set<Id>();
    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.ContactRequestId__c == null) {
        continue;
      }
      requestIds.add(currentInteraction.ContactRequestId__c);
    }
    if (!requestIds.isEmpty()) {
      List<ContactRequest> contactRequests = ContactRequestDMLHelper.getContactRequest(
        requestIds
      );
      setInteractionIds(contactRequests, interactions);
      ContactRequestDMLHelper.updateContactRequests(contactRequests);
    }
  }
  /**
   * @description goes through a list of requests and sets the Interaction Id
   * based upon a list of interactions
   * @param requests List<ContactRequest> list of contact requests to cycle through
   * @param interactions List<Interaction> list of interactions to draw from.
   */
  private static void setInteractionIds(
    List<ContactRequest> requests,
    List<Interaction> interactions
  ) {
    if (requests.isEmpty() || interactions.isEmpty()) {
      return;
    }
    Map<Id, Id> contactRequestInteractionIdMap = new Map<Id, Id>();
    for (Interaction currentInteraction : interactions) {
      contactRequestInteractionIdMap.put(
        currentInteraction.ContactRequestId__c,
        currentInteraction.Id
      );
    }
    for (ContactRequest request : requests) {
      if (contactRequestInteractionIdMap.containsKey(request.Id)) {
        request.Interaction__c = contactRequestInteractionIdMap.get(request.Id);
      }
    }
  }

  /** @description Method to set the Interaction Name for manual appointment rt creations
   * and all general rt creations
   * @param interactions list of new interactions created.
   * @param oldMap map of old interactions
   */
  public static void setNameOfInteractions(
    List<Interaction> interactions,
    Map<Id, SObject> oldMap
  ) {
    List<String> listOfFieldApiNamesForChatAndCall = new List<String>{
      'Direction__c',
      'InteractionType',
      'Actual_Topic_Formula__c'
    };
    List<String> listOfFieldApiNameForStore = new List<String>{
      'Reason_for_Visit_Formula__c'
    };
    for (Interaction newInteraction : interactions) {
      Interaction oldInteraction = (Interaction) oldMap?.get(newInteraction.Id);
      String concatinatedDirectionAndChannel =
        newInteraction.Direction__c +
        ' ' +
        newInteraction.InteractionType;
      switch on newInteraction.Record_Type__c {
        when 'Call', 'Message' {
          // Hard Coded here as Static variables are not accessible in switch case
          if (
            InteractionActions.hasAnyFieldChanged(
              newInteraction,
              oldInteraction,
              listOfFieldApiNamesForChatAndCall
            )
          ) {
            newInteraction.Name = concatinatedDirectionAndChannel;
            if (String.isNotBlank(newInteraction.Actual_Topic_Formula__c)) {
              newInteraction.Name +=
                ' - ' + newInteraction.Actual_Topic_Formula__c.split(',')[0];
            } else if (String.isNotBlank(newInteraction.Support_Topics__c)) {
              newInteraction.Name += ' - ' + newInteraction.Support_Topics__c;
            }
          }
        }
        when 'In Person' {
          if (
            InteractionActions.hasAnyFieldChanged(
              newInteraction,
              oldInteraction,
              listOfFieldApiNameForStore
            )
          ) {
            newInteraction.Name =
              GetHelpConstants.COACHING_LAB +
              ' - ' +
              newInteraction.Reason_for_Visit_Formula__c;
          }
        }
        when else {
          if (
            AutomatedRequestMetadataProvider.getInstance()
              .getMap()
              .containsKey(newInteraction.Interaction_Purpose__c)
          ) {
            newInteraction.Name =
              newInteraction.Interaction_Purpose__c + ' Appointment';
          }
        }
      }
    }
  }

  /**
   * @description Assign the ownership of newly created interactions to the Interaction Queue and update status to Unassigned
   * @param interactions List of newly created interactions.
   */
  public static void setOwnerNewInteractions(List<Interaction> interactions) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    for (Interaction interact : interactions) {
      if (interact.RecordTypeId == appointmentRTID) {
        interact.OwnerID = InteractionConstants.APPOINTMENT_QUEUE_ID;
        interact.Status__c = InteractionConstants.UNASSIGNED_STATUS;
      }
    }
  }

  /**
   * @description Update the status of the interactions to scheduled if the owner is updated
   * @param interactions The list of interactions where the owner is updated from Queue to Coach
   */
  public static void setStatustoScheduled(List<Interaction> interactions) {
    Id appointmentRTID = GetHelpConstants.INTERACTION_APPT_RT_ID;
    for (Interaction interact : interactions) {
      if (interact.RecordTypeId == appointmentRTID) {
        interact.Status__c = InteractionConstants.SCHEDULED_STATUS;
      }
    }
  }
}
