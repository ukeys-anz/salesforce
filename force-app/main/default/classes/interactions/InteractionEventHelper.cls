/**
 * @author Adam Smith
 * @since 20220627
 * @description Class providing helpers regarding Events & Interactions
 * Note Dynamic query in querySobjects method will run max 3 times.
 */
public with sharing class InteractionEventHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final InteractionActionsRepository INTERACTION_ACTION_REPOSITORY = (InteractionActionsRepository) Lib_InstanceProvider.forType(
    InteractionActionsRepository.class
  );
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
    DmlConfig dmlConfigRecord = new DmlConfig();
    dmlConfigRecord.systemMode();
    dmlConfigRecord.withoutSharing();

    if (!linkedEvents.isEmpty()) {
      DML_REPOSITORY.doDelete(linkedEvents, dmlConfigRecord);
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
    Territory_Based_Sharing_Config__mdt objMetadata = QueryTerritoryBasedSharingConfig.get(
      'Interaction'
    );
    Map<String, Set<Id>> mapOfParentNameToIds = collectParentIds(
      lstOfInteraction,
      objMetadata
    );
    Map<Id, Sobject> mapOfSobject = collectSobjectsRecords(
      mapOfParentNameToIds
    );
    updateTerritoryForInteractions(lstOfInteraction, mapOfSobject, objMetadata);
  }

  /**
   * @description This method is used to prepare map of object name to corresponding lookup ids
   * @name collectParentIds
   * @param lstOfMlInteraction list of ML interaction
   * @param objMetadata territory metadata record
   * @return Map<String, Set<Id>> map of object name to corresponding lookup ids
   * @author Ashish Kumar
   * @US CC-1058
   */
  @testVisible
  private static Map<String, Set<Id>> collectParentIds(
    List<Interaction> lstOfMlInteraction,
    Territory_Based_Sharing_Config__mdt objMetadata
  ) {
    Map<String, Set<Id>> mapOfParentNameToIds = new Map<String, Set<Id>>();
    if (objMetadata.Lookup_Fields__c == null) {
      return mapOfParentNameToIds;
    }

    List<String> lstOfLookUpFields = objMetadata.Lookup_Fields__c.split(';');

    for (Interaction objInteraction : lstOfMlInteraction) {
      for (String strField : lstOfLookUpFields) {
        Id strLookupId = (Id) objInteraction.get(strField);
        if (strLookupId == null) {
          continue;
        }
        String strObjectName = strLookupId.getSObjectType().toString();
        if (!mapOfParentNameToIds.containsKey(strObjectName)) {
          mapOfParentNameToIds.put(strObjectName, new Set<Id>{ strLookupId });
          break;
        }
        mapOfParentNameToIds.get(strObjectName).add(strLookupId);
        break;
      }
    }
    return mapOfParentNameToIds;
  }

  /**
   * @description This method is used to prepare query and return map of corresponding sobject records
   * @name collectSobjectsRecords
   * @param mapOfParentNameToIds map of object name to corresponding lookup ids
   * @return Map<Id, Sobject> map of sobject records
   * @author Ashish Kumar
   * @US CC-1058
   */
  @testVisible
  private static Map<Id, Sobject> collectSobjectsRecords(
    Map<String, Set<Id>> mapOfParentNameToIds
  ) {
    Map<Id, Sobject> mapOfSobject = new Map<Id, SObject>();
    if (mapOfParentNameToIds.isEmpty()) {
      return mapOfSobject;
    }
    for (String strObjectName : mapOfParentNameToIds.keySet()) {
      Set<Id> setOfParentId = mapOfParentNameToIds.get(strObjectName);
      if (setOfParentId == null) {
        continue;
      }
      mapOfSobject.putAll(
        INTERACTION_ACTION_REPOSITORY.executeQuery(strObjectName, setOfParentId)
      );
    }
    return mapOfSobject;
  }

  /**
   * @description This method is used to update ML interaction record with their valid territory
   * @name updateTerritoryForInteractions
   * @param lstOfMlInteraction list of ML interaction
   * @param mapOfSobject map of sobject
   * @param objMetadata territory metadata record
   * @author Ashish Kumar
   * @US CC-1058
   */
  @testVisible
  private static void updateTerritoryForInteractions(
    List<Interaction> lstOfMlInteraction,
    Map<Id, Sobject> mapOfSobject,
    Territory_Based_Sharing_Config__mdt objMetadata
  ) {
    if (objMetadata.Lookup_Fields__c == null) {
      return;
    }
    List<String> lstOfLookUpFields = objMetadata.Lookup_Fields__c.split(';');
    for (Interaction objInteraction : lstOfMlInteraction) {
      for (String strField : lstOfLookUpFields) {
        Id strLookupId = (Id) objInteraction.get(strField);
        if (
          strLookupId == null ||
          !mapOfSobject.containsKey((Id) objInteraction.get(strField))
        ) {
          continue;
        }
        objInteraction.Territory__c = (Id) mapOfSobject.get(
            (Id) objInteraction.get(strField)
          )
          .get('Territory__c');
        break;
      }
    }
  }
}
