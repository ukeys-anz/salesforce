/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Interaction Actions
 */
public with sharing class InteractionActions {
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
}
