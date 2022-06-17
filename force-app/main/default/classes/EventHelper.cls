/**
 * @author Adam Smith
 * @since 20220617
 * @description Helper class for working with events
 */
public with sharing class EventHelper {
  /**
   * @description does the database call to insert Events
   * @param events List<Event> list of events.
   */
  public static void insertEvents(List<Event> events) {
    if (events != null && Event.SObjectType.getDescribe().isCreateable()) {
      List<Database.SaveResult> results = Database.Insert(events);

      lib_systemLog log = new lib_systemLog('EventHelper', 'insertEvents');
      Boolean hasError = log.addDatabaseSaveResult('Events', results, events);
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'EventHelper',
        'insertEvents',
        'Not enough permissions to create Events.'
      );
    }
  }

  /**
   * @description creates events from Interactions
   * @param interactions List<Interaction> subject from which to create Events
   * @return List<Event> newly created Events.
   */
  public static List<Event> createEventsFromInteractions(
    List<Interaction> interactions
  ) {
    InteractionActions actions = new InteractionActions();
    Map<Id, Account> accountMap = actions.getAccountMapFromInteractions(
      interactions
    );
    Map<Id, Lead> leadMap = actions.getLeadMapFromInteractions(interactions);
    List<Event> result = new List<Event>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        result.add(
          createEventFromInteraction(currentInteraction, accountMap, leadMap)
        );
      }
    }
    return result;
  }

  /**
   * @description creates an event from an Interaction
   * @param interactionSubject Interaction subject from which to create an Event
   * @return Event newly created Event.
   */
  public static Event createEventFromInteraction(
    Interaction interactionSubject
  ) {
    InteractionActions actions = new InteractionActions();
    Map<Id, Account> accountMap = actions.getAccountMapFromInteractions(
      new List<Interaction>{ interactionSubject }
    );
    Map<Id, Lead> leadMap = actions.getLeadMapFromInteractions(
      new List<Interaction>{ interactionSubject }
    );
    return createEventFromInteraction(interactionSubject, accountMap, leadMap);
  }

  /**
   * @description creates an event from an Interaction
   * @param interactionSubject Interaction subject from which to create an Event
   * @param accountMap Map<Id,Account> map of Accounts to their Id.
   * @param leadMap Map<Id,Lead> map of leads to their Id.
   * @return Event newly created Event.
   */
  public static Event createEventFromInteraction(
    Interaction interactionSubject,
    Map<Id, Account> accountMap,
    Map<Id, Lead> leadMap
  ) {
    Account interactionAccount = accountMap.get(interactionSubject.AccountId);
    Event result = new Event();
    result.StartDateTime = interactionSubject.StartTime;
    result.WhatId = interactionSubject.Id;
    if (interactionAccount != null) {
      result.WhoId = interactionAccount.PersonContactId;
      result.Subject = 'Appointment with ' + interactionAccount.Name;
    } else {
      result.Lead__c = interactionSubject.Lead__c;
      Lead interactionLead = leadMap.get(interactionSubject.Lead__c);
      result.Subject = 'Appointment with ' + interactionLead.Name;
    }
    result.EndDateTime = interactionSubject.EndTime;
    result.IsReminderSet = true;
    result.ReminderDateTime = result.StartDateTime.addMinutes(-15);
    return result;
  }
}
