/**
 * @author Vishnu Kasu
 * @since May 2025
 * @description class to handle all the RBM Broker Interaction Actions
 */

public with sharing class RBMInteractionActions {
  private static final RBMInteractionRepository INTERACTION_REPOSITORY = (RBMInteractionRepository) Lib_InstanceProvider.forType(
    RBMInteractionRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final AssociatedLoanApplicationRepository ASSOCIATED_APP_REPOSITORY = (AssociatedLoanApplicationRepository) Lib_InstanceProvider.forType(
    AssociatedLoanApplicationRepository.class
  );
  /**
   * @description Define custom exceptions
   */
  public class RBMInteractionCustomException extends Exception {
  }
  /**
   * @description method to check and create related notes for Interaction
   * @param records List of new interaction records
   */
  public static void createInteractionNotes(List<Interaction> records) {
    List<Interaction> notesAvailableInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Optional_Notes__c)
      .toList();
    Map<Id, ContentNote> notes = RBMInteractionActions.generateNotes(
      notesAvailableInteractions,
      'Optional_Notes__c'
    );
    DML_REPOSITORY.doInsert(notes.values());
    List<ContentDocumentLink> contentDocumentLinks = RBMInteractionActions.generateContentDocumentLink(
      notes
    );
    DML_REPOSITORY.doInsert(contentDocumentLinks);
  }

  /**
   * @description method to check and create related notes for Interaction
   * @param records List of new interaction records
   */
  public static void validAndSetStartTime(List<Interaction> records) {
    List<Interaction> unsetStartTime = ListUtil.filter(records)
      .isNull(Interaction.StartTime)
      .toList();
    RBMInteractionActions.setStartTimeValue(unsetStartTime);
  }
  /**
   * @description method to update StartTime to current datetime
   * @param records List of new interaction records which StartTime is blank
   */
  @TestVisible
  private static void setStartTimeValue(List<Interaction> records) {
    for (Interaction currentRecord : records) {
      currentRecord.StartTime = System.now();
    }
  }

  /**
   * @description This function is created a list of BrokerCaseCloudEventModel.
   * @param notesAvailableInteractions The Interaction records
   * @param fieldName the field need to consider for notes creation
   * @return Map<Id, ContentNote> map of generateNotes
   */
  @TestVisible
  private static Map<Id, ContentNote> generateNotes(
    List<Interaction> notesAvailableInteractions,
    String fieldName
  ) {
    Map<Id, ContentNote> contentNotesMap = new Map<Id, ContentNote>();
    Schema.SObjectField field = Schema.SObjectType.Interaction.fields.getMap()
      .get(fieldName);
    for (Interaction record : notesAvailableInteractions) {
      contentNotesMap.put(
        record.Id,
        new ContentNote(
          Title = record.Status__c + ' Note',
          Content = Blob.valueOf(String.valueOf(record.get(field)))
        )
      );
    }
    return contentNotesMap;
  }
  /**
   * @description This function is created a list of BrokerCaseCloudEventModel.
   * @param notes map of content notes to generate ContentDocumentLink
   * @return List of ContentDocumentLink records
   */
  @TestVisible
  private static List<ContentDocumentLink> generateContentDocumentLink(
    Map<Id, ContentNote> notes
  ) {
    List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
    for (Id key : notes.keySet()) {
      contentDocumentLinks.add(
        new ContentDocumentLink(
          LinkedEntityId = key,
          ContentDocumentId = notes.get(key).Id,
          ShareType = 'I'
        )
      );
    }
    return contentDocumentLinks;
  }

  /**
   * @description This function is Update the Name of the Interaction with format "Broker Name - Interaction Type" or "Office Group Name - Interaction Type"
   * @param records Interaction records from trigger
   * @param oldRecordMap Old Map of Records from Trigger, only in case of Update.
   */
  public static void updateInteractionName(
    List<Interaction> records,
    Map<Id, SObject> oldRecordMap
  ) {
    try {
      Set<Id> brokerIds = ListUtil.getIds(records, Interaction.Broker__c);
      Set<Id> officeGroupIds = ListUtil.getIds(
        records,
        Interaction.Office_Group__c
      );

      Map<Id, Broker_Relation__c> officeGroups = new Map<Id, Broker_Relation__c>(
        INTERACTION_REPOSITORY.queryOfficeGroups(officeGroupIds)
      );

      Map<Id, Contact> brokers = new Map<Id, Contact>(
        INTERACTION_REPOSITORY.queryBrokerContacts(brokerIds)
      );

      List<Interaction> interactionsToUpdate = getInteractionListToUpdate(
        oldRecordMap,
        records
      );

      for (Interaction record : interactionsToUpdate) {
        String relatedName = (record.Attendee_Category__c ==
          RBMInteractionConstants.INTERACTION_BROKER_ATTENDEE)
          ? brokers.get(record.Broker__c).Name
          : officeGroups.get(record.Office_Group__c).Name;

        record.Name = relatedName + ' - ' + record.Interaction_Type__c;
      }
    } catch (Exception ex) {
      Logger.error('Name Update failed due to: ', ex).save();
    }
  }

  /**
   * @description This function is Update the Name of the Interaction with format "Broker Name - Interaction Type" or "Office Group Name - Interaction Type"
   * @param oldRecordMap Old Map of Records from Trigger, only in case of Update.
   * @param records Interaction records from trigger
   * @return List<Interaction> List of records to update
   */
  public static List<Interaction> getInteractionListToUpdate(
    Map<Id, SObject> oldRecordMap,
    List<Interaction> records
  ) {
    if (oldRecordMap.isEmpty()) {
      return records;
    }
    Set<SObjectField> fieldsToTrack = new Set<SObjectField>{
      Interaction.Interaction_Type__c,
      Interaction.attendee_category__c,
      Interaction.Broker__c,
      Interaction.Office_Group__c
    };

    List<Interaction> interactionsToUpdate = ListUtil.filter(
        records,
        oldRecordMap
      )
      .anyChanged(fieldsToTrack)
      .equals(Interaction.RecordTypeId, RTInteraction.rbmBrokerInteraction)
      .toList();

    return interactionsToUpdate;
  }

  /**
   * @description set interaction date and time for created records
   * @param records List of new interaction records
   */
  public static void createInteractionEvents(List<Interaction> records) {
    List<Event> eventRecords = manageInteractionEvents(
      records,
      new Map<Id, Event>()
    );
    DML_REPOSITORY.doInsert(eventRecords);
  }

  /**
   * @description set interaction date and time for updated records
   * @param records List of new interaction records
   * @param oldRecordMap of old interaction records
   */
  public static void upsertInteractionEvents(
    List<Interaction> records,
    Map<Id, SObject> oldRecordMap
  ) {
    List<Interaction> updatedInteractions = ListUtil.filter(
        records,
        oldRecordMap
      )
      .changed(Interaction.StartTime)
      .toList();
    List<Event> eventRecords = new List<Event>();
    try {
      Map<Id, Event> relatedEvents = (Map<Id, Event>) ListUtil.mapBy(
        (RBMInteractionRepository.getEvents(oldRecordMap.keySet())),
        Event.WhatId
      );

      eventRecords = manageInteractionEvents(
        updatedInteractions,
        relatedEvents
      );
    } catch (Exception ex) {
      Logger.error('Failed to fetch Interaction Events due to: ', ex).save();
    }
    DML_REPOSITORY.doUpsert(eventRecords);
  }

  /**
   * @description set interaction date and time
   * @param interactionRecords List of new interaction records
   * @param relatedEvents Map of old interaction records
   * @return List<Event> to upsert
   */
  @testVisible
  private static List<Event> manageInteractionEvents(
    List<Interaction> interactionRecords,
    Map<Id, Event> relatedEvents
  ) {
    List<Event> eventRecords = new List<Event>();

    for (Interaction record : interactionRecords) {
      Event eventRecord = new Event();
      if (relatedEvents.containsKey(record.Id)) {
        eventRecord = relatedEvents.get(record.Id);
      } else {
        eventRecord.Subject = record.Name;
        eventRecord.WhatId = record.Id;
      }

      eventRecord.StartDateTime = record.StartTime;
      eventRecord.EndDateTime = record.StartTime;
      eventRecord.IsReminderSet = false;
      eventRecord.ReminderDateTime = null;

      if (record.StartTime > System.now() + 1) {
        eventRecord.IsReminderSet = true;
        eventRecord.ReminderDateTime = record.StartTime - 1;
      }
      eventRecords.add(eventRecord);
    }

    return eventRecords;
  }

  /**
   * @description clear optional notes when status changed to Open
   * @param records List of new interaction records
   * @param oldRecordMap of old interaction records
   */
  public static void clearClosingNotes(
    List<Interaction> records,
    Map<Id, SObject> oldRecordMap
  ) {
    List<Interaction> updatedInteractions = ListUtil.filter(
        records,
        oldRecordMap
      )
      .changed(Interaction.Status__c)
      .toList();

    for (Interaction record : updatedInteractions) {
      record.Closing_Notes__c = record.Status__c ==
        RBMInteractionConstants.INTERACTION_STATUS_OPEN
        ? ''
        : record.Closing_Notes__c;
    }
  }

  /**
   * @description create note for interaction while closing.
   * @param records List of new interaction records
   */
  public static void createInteractionClosingNotes(List<Interaction> records) {
    List<Interaction> interactionRecords = ListUtil.filter(records)
      .isNotNull(Interaction.Closing_Notes__c)
      .toList();
    createClosingNotes(interactionRecords);
  }

  /**
   * @description create note for interaction while closing.
   * @param records List of new interaction records
   * @param oldRecordMap of old interaction records
   */
  public static void createInteractionClosingNotes(
    List<Interaction> records,
    Map<Id, SObject> oldRecordMap
  ) {
    List<Interaction> updatedInteractions = ListUtil.filter(
        records,
        oldRecordMap
      )
      .changed(Interaction.Status__c)
      .toList();
    createClosingNotes(updatedInteractions);
  }

  /**
   * @description create note for interaction while closing.
   * @param records List of new interaction records to create Closing Notes
   */
  @testVisible
  private static void createClosingNotes(List<Interaction> records) {
    List<Interaction> closingRecords = new List<Interaction>();

    Set<String> closingStatus = new Set<String>{
      RBMInteractionConstants.INTERACTION_STATUS_CLOSED_COMPLETED,
      RBMInteractionConstants.INTERACTION_STATUS_CLOSED_FOLLOWUP,
      RBMInteractionConstants.INTERACTION_STATUS_CLOSED_WITHDRAWN
    };
    for (Interaction record : records) {
      if (closingStatus.contains(record.Status__c)) {
        closingRecords.add(record);
      }
    }
    Map<Id, ContentNote> notes = RBMInteractionActions.generateNotes(
      closingRecords,
      'Closing_Notes__c'
    );
    DML_REPOSITORY.doInsert(notes.values());
    List<ContentDocumentLink> contentDocumentLinks = RBMInteractionActions.generateContentDocumentLink(
      notes
    );
    DML_REPOSITORY.doInsert(contentDocumentLinks);
  }
}
