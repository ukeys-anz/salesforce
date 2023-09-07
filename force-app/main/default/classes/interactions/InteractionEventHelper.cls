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
      EventHelper.updateEvents(eventsToUpdate);
    }
  }
}
