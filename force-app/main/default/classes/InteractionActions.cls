/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Interaction Actions
 */
public with sharing class InteractionActions {
  public static final String APPOINTMENTS_QUEUE = 'Appointments_Queue';
  public static final String SCHEDULED_STATUS = 'Scheduled';
  public static final String UNASSIGNED_STATUS = 'Unassigned';

  /**
   * @description goes through a list of interactions and returns the ones that have been cancelled.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of cancelled interactions
   */
  public List<Interaction> findCancelledInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> result = new List<Interaction>();

    if (interactions.isEmpty()) {
      return result;
    }

    for (Interaction currentInteraction : interactions) {
      if (
        currentInteraction.Status__c != 'Cancelled' ||
        !oldMap.containsKey(currentInteraction.Id)
      ) {
        continue;
      }
      Interaction oldInteraction = (Interaction) oldMap.get(
        currentInteraction.Id
      );
      if (oldInteraction.Status__c != 'Cancelled') {
        result.add(currentInteraction);
      }
    }
    return result;
  }

  /**
   * @description deletes events linked to a list of interactions
   * @param interactions List of interactions to search through and delete related events.
   */
  public void deleteInteractionEvents(List<Interaction> interactions) {
    Set<Id> interactionIds = (new Map<Id, Interaction>(interactions)).keySet();
    if (interactionIds.isEmpty()) {
      return;
    }

    if (Event.SObjectType.getDescribe().isQueryable()) {
      List<Event> linkedEvents = [
        SELECT Id
        FROM Event
        WHERE WhatId IN :interactionIds
      ];

      if (linkedEvents.isEmpty()) {
        return;
      }

      if (Event.SObjectType.getDescribe().isDeletable()) {
        List<Database.DeleteResult> results = Database.Delete(linkedEvents);
        lib_systemLog log = new lib_systemLog(
          'InteractionActions',
          'deleteInteractionEvents'
        );
        Boolean hasError = log.addDatabaseDeleteResult(
          'Events',
          results,
          linkedEvents
        );
        if (hasError) {
          //log errors to application log
          log.insertLog();
        }
      } else {
        CommonUtil.logAndThrowIAE(
          'InteractionActions',
          'deleteInteractionEvents',
          'Not enough permissions to delete Events'
        );
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'deleteInteractionEvents',
        'Not enough permissions to query Events.'
      );
    }
  }

  /**
   * @description Assign the ownership of newly created interactions to the Interaction Queue
   * @param interactions List of newly created interactions.
   */

  public void updateOwnerNewInteractions(List<Interaction> interactions) {
    List<Group> interactionQueue = new List<Group>();
    if (Group.SObjectType.getDescribe().isAccessible()) {
      interactionQueue = [
        SELECT ID
        FROM Group
        WHERE Type = 'Queue' AND Name = :APPOINTMENTS_QUEUE
      ];

      if (interactionQueue.size() > 0) {
        for (Interaction interact : interactions) {
          interact.OwnerID = interactionQueue[0].Id;
          interact.Status__c = UNASSIGNED_STATUS;
        }
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'updateOwnerNewInteractions',
        'Not enough permissions to query Group object.'
      );
    }
  }

  /**
   * @description Get the list of updated Interactions where a Coach has taken ownership from the queue
   * @param oldMap The oldValues before the update.
   * @param interactions The new values of the interaction after update.
   * @return List<Interaction> The list of interactions where the owner has been updated
   */

  public List<Interaction> getAcceptedInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> acceptedInteractions = new List<Interaction>();
    Id oldInteractionId = CommonUtil.getGroupId(APPOINTMENTS_QUEUE);
    for (Interaction interact : interactions) {
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        oldInteraction.OwnerId != interact.OwnerId &&
        oldInteraction.OwnerId == oldInteractionId
      ) {
        acceptedInteractions.add(interact);
      }
    }
    return acceptedInteractions;
  }

  /**
   * @description Update the status of the interactions to scheduled if the owner is updated
   * @param interactions The list of interactions where the owner is updated from Queue to Coach
   */

  public void updateStatustoScheduled(List<Interaction> interactions) {
    if (Interaction.SObjectType.getDescribe().isUpdateable()) {
      for (Interaction interact : interactions) {
        interact.Status__c = SCHEDULED_STATUS;
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'updateStatustoScheduled',
        'Not enough permissions to update Interaction.'
      );
    }
  }

  /**
   * @description Get the list of contact requests of those interactions which are cancelled
   * @param interactions The list of interactions which were cancelled
   * @return List<ContactRequest> List of ContactRequest records related to the interaction which were cancelled.
   */

  public List<ContactRequest> getRelatedContactRequest(
    List<Interaction> interactions
  ) {
    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    Set<Id> contactRequestIds = new Set<Id>();
    for (Interaction interact : interactions) {
      contactRequestIds.add(interact.ContactRequestId__c);
    }

    if (
      ContactRequest.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.ContactRequest.fields.Appointment_Commitment__c.isAccessible()
    ) {
      contactRequestList = [
        SELECT Id, Appointment_Commitment__c
        FROM ContactRequest
        WHERE ID IN :contactRequestIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'getRelatedContactRequest',
        'Not enough permissions to query Contact Request.'
      );
    }
    return contactRequestList;
  }
}
