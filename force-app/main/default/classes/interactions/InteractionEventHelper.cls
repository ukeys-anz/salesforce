/**
 * @author Adam Smith
 * @since 20220627
 * @description Class providing helpers regarding Events & Interactions
 */
public with sharing class InteractionEventHelper {
  /**
   * @description deletes events linked to a list of interactions
   * @param interactions List of interactions to search through and delete related events.
   */
  public static void deleteInteractionEvents(List<Interaction> interactions) {
    Set<Id> interactionIds = (new Map<Id, Interaction>(interactions)).keySet();
    if (interactionIds.isEmpty()) {
      return;
    }

    List<Event> linkedEvents = EventHelper.queryRelatedEvents(interactionIds);

    if (!linkedEvents.isEmpty()) {
      EventDeleteHelper.deleteEvents(linkedEvents);
    }
  }

  /**
   * @description Get the list of events related to Interaction which was rescheduled
   * @param interactions The list of interactions which were rescheduled
   * @return List<Event> List of event records related to the interaction which were rescheduled.
   */
  public static List<Event> getRelatedEvents(List<Interaction> interactions) {
    Set<Id> interactionIds = new Set<Id>();
    for (Interaction interact : interactions) {
      interactionIds.add(interact.Id);
    }
    return EventHelper.queryRelatedEvents(interactionIds);
  }

  /**
   * @description Update the events date and time to match with the interaction
   * @param eventRecords The list of events to be updated
   * @param interactions The interactions which are rescheduled
   */
  public static void updateEventSchedule(
    List<Event> eventRecords,
    List<Interaction> interactions
  ) {
    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>();
    for (Interaction interact : interactions) {
      interactionMap.put(interact.Id, interact);
    }

    List<Event> eventsToUpdate = new List<Event>();

    for (Event evt : eventRecords) {
      Interaction eventsInteraction = interactionMap.get(evt.WhatId);
      if (eventsInteraction == null) {
        continue;
      }
      if (
        evt.StartDateTime != eventsInteraction.StartTime ||
        evt.EndDateTime != eventsInteraction.EndTime
      ) {
        evt.StartDateTime = eventsInteraction.StartTime;
        evt.EndDateTime = eventsInteraction.EndTime;
        eventsToUpdate.add(evt);
      }
    }

    if (!eventsToUpdate.isEmpty()) {
      try {
        EventHelper.updateEvents(eventsToUpdate);
      } catch (Exception e) {
        Logger.error('Error - ' + e.getMessage(), e);
        Logger.saveLog();
        interactions[0].AddError('Unable to update the related Events.');
      }
    }
  }

  /**
   * @description This method to assign default territory same as parent record' territory
   * @name assignDefaultTerritory
   * @param lstOfInteraction list of new interaction records
   * @author Ashish Kumar
   * @US CC-5207
   */
  public static void assignDefaultTerritory(
    List<Interaction> lstOfInteraction
  ) {
    Map<String, Set<Id>> mapOfParentNameToIds = new Map<String, Set<Id>>();
    Map<Id, Sobject> mapOfSobject = new Map<Id, SObject>();
    Territory_Based_Sharing_Config__mdt objMetadata = MLCRMSharingUtil.getTerritoryRecords(
      'Interaction'
    );
    if (objMetadata.Lookup_Fields__c != null) {
      List<String> lstOfLookUpFields = objMetadata.Lookup_Fields__c.split(';');
      for (Interaction objInteraction : lstOfInteraction) {
        if (
          objInteraction.recordTypeId == MLCRMConstants.ML_INTERACTION_RT_ID
        ) {
          for (String str : lstOfLookUpFields) {
            Id strLookupId = (Id) objInteraction.get(str);
            String strObjectName = strLookupId
              ?.getSObjectType()
              ?.getDescribe()
              ?.getName();
            if (
              strLookupId != null &&
              !mapOfParentNameToIds.containsKey(strObjectName)
            ) {
              mapOfParentNameToIds.put(
                strObjectName,
                new Set<Id>{ strLookupId }
              );
              break;
            } else if (
              strLookupId != null &&
              mapOfParentNameToIds.containsKey(strObjectName)
            ) {
              mapOfParentNameToIds.get(strObjectName).add(strLookupId);
              break;
            }
          }
        }
      }

      if (!mapOfParentNameToIds.isEmpty()) {
        for (String strObjectName : mapOfParentNameToIds.keySet()) {
          Set<Id> setOfParentId = mapOfParentNameToIds.get(strObjectName);
          String strQuery =
            'SELECT Id,Territory__c FROM ' +
            strObjectName +
            ' WHERE Id IN: setOfParentId';
          mapOfSobject.putAll(new Map<Id, Sobject>(Database.query(strQuery)));
        }
      }
      for (Interaction objInteraction : lstOfInteraction) {
        if (
          objInteraction.recordTypeId == MLCRMConstants.ML_INTERACTION_RT_ID
        ) {
          for (String str : lstOfLookUpFields) {
            if (
              mapOfSobject != null &&
              objInteraction.get(str) != null &&
              mapOfSobject.containsKey((Id) objInteraction.get(str))
            ) {
              objInteraction.Territory__c = (Id) mapOfSobject.get(
                  (Id) objInteraction.get(str)
                )
                .get('Territory__c');
              break;
            }
          }
        }
      }
    }
  }
}
