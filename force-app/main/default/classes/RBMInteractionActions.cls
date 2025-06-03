/**
 * @author Vishnu Kasu
 * @since May 2025
 * @description class to handle all the RBM Broker Interaction Actions
 */
public with sharing class RBMInteractionActions {
  private static final Id RBM_INTERACTION_RECORDTYPE = QueryRT.of(
      Interaction.SObjectType
    )
    .getId('RBM_Broker_Interaction');

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
   * @description method to check and create related notes for Interaction
   * @param records List of new interaction records
   */
  public static void createInteractionNotes(List<Interaction> records) {
    try {
      List<Interaction> notesAvailableInteractions = ListUtil.filter(records)
        .isNotNull(Interaction.Optional_Notes__c)
        .toList();
      Map<Id, ContentNote> notes = RBMInteractionActions.generateNotes(
        notesAvailableInteractions,
        'Optional_Notes__c'
      );
      RBMInteractionActions.DML_REPOSITORY.doInsert(notes.values());
      List<ContentDocumentLink> contentDocumentLinks = RBMInteractionActions.generateContentDocumentLink(
        notes
      );
      RBMInteractionActions.DML_REPOSITORY.doInsert(contentDocumentLinks);
    } catch (Exception e) {
      logException(e);
    }
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
  @TestVisible
  private static void logException(Exception e) {
    Logger.error(e.getMessage(), e);
    Logger.saveLog();
    throw e;
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
   * @param oldRecordMap Old Map of Records from Trigger, only in case of Update.
   * @param records Interaction records from trigger
   */
  public static void updateInteractionName(
    Map<Id, SObject> oldRecordMap,
    List<Interaction> records
  ) {
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
        BrokerConstants.INTERACTION_BROKER_ATTENDEE)
        ? brokers.get(record.Broker__c).Name
        : officeGroups.get(record.Office_Group__c).Name;

      record.Name = relatedName + ' - ' + record.Interaction_Type__c;
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
    List<Interaction> interactionsToUpdate = new List<Interaction>();

    if (oldRecordMap.isEmpty()) {
      return records;
    }
    interactionsToUpdate = ListUtil.filter(records, oldRecordMap)
      .changed(Interaction.Interaction_Type__c)
      .equals(Interaction.RecordTypeId, RBM_INTERACTION_RECORDTYPE)
      .toList();

    return interactionsToUpdate;
  }

  /**
   * @description method to check and create related Interaction Attendees from Office Group and Broker
   * @param records List of new interaction Attendee records
   */
  /*public static void createInteractionAttendee(List<Interaction> records) {
    List<InteractionAttendee> attendeesToCreate = new List<InteractionAttendee>();
    Set<Id> groupIds = new Set<Id>();
    Set<Id> brokerIds = new Set<Id>();
    groupIds = ListUtil.getIds(records, Interaction.Office_Group__c);
    brokerIds = ListUtil.getIds(records, Interaction.Broker__c);

    List<Interaction> brokerInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Broker__c)
      .toList();

    List<Interaction> officeInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Office_Group__c)
      .toList();

    List<Contact> contactList = INTERACTION_REPOSITORY.queryBrokersFromOfficeGroups(
      groupIds
    );
    attendeesToCreate = getOfficeAttendeesToCreate(
      contactList,
      officeInteractions
    );
    attendeesToCreate.addAll(
      getBrokerAttendeesToCreate(brokerIds, brokerInteractions)
    );

    if (!attendeesToCreate.isEmpty()) {
      try {
        DML_REPOSITORY.doInsert(
          attendeesToCreate,
          new DmlConfig().allowPartial()
        );
      } catch (exception e) {
        logException(e);
      }
    }
  }*/

  public static void createInteractionAttendee(List<Interaction> records) {
    try {
      List<InteractionAttendee> attendeesToCreate = buildAttendees(records);
      if (!attendeesToCreate.isEmpty()) {
        DML_REPOSITORY.doInsert(
          attendeesToCreate,
          new DmlConfig().allowPartial()
        );
      }
    } catch (Exception e) {
      logException(e);
    }
  }

  private static List<InteractionAttendee> buildAttendees(
    List<Interaction> records
  ) {
    Set<Id> groupIds = ListUtil.getIds(records, Interaction.Office_Group__c);

    List<Interaction> brokerInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Broker__c)
      .toList();

    List<Interaction> officeInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Office_Group__c)
      .toList();

    List<Contact> contactList = INTERACTION_REPOSITORY.queryBrokersFromOfficeGroups(
      groupIds
    );

    List<InteractionAttendee> attendees = new List<InteractionAttendee>();
    attendees.addAll(
      getOfficeAttendeesToCreate(contactList, officeInteractions)
    );
    attendees.addAll(getBrokerAttendeesToCreate(brokerInteractions));
    return attendees;
  }

  /**
   * @description This function to create the InteractionAttendee
   * @param brokerInteraction Interaction records to be updated
   * @return List<InteractionAttendee> of InteractionAttendee records
   */
  public static List<InteractionAttendee> getBrokerAttendeesToCreate(
    List<Interaction> brokerInteraction
  ) {
    if (brokerInteraction.isEmpty()) {
      return new List<InteractionAttendee>();
    }
    List<InteractionAttendee> attendeesToCreate = new List<InteractionAttendee>();
    for (Interaction interactionRec : brokerInteraction) {
      attendeesToCreate.add(
        new InteractionAttendee(
          AttendeeType = 'External',
          Attendee_SubType__c = BrokerConstants.INTERACTION_BROKER_ATTENDEE,
          ContactId = interactionRec.Broker__c,
          InteractionId = interactionRec.Id
        )
      );
    }
    return attendeesToCreate;
  }
  /**
   * @description This function to create the InteractionAttendee
   * @param contactList  set of office group Ids associated with Interactions
   * @param interactionsToUpdate Interaction records to be updated
   * @return List<InteractionAttendee> List of InteractionAttendees
   */
  public static List<InteractionAttendee> getOfficeAttendeesToCreate(
    List<contact> contactList,
    List<Interaction> interactionsToUpdate
  ) {
    Map<Id, List<Contact>> officeToContacts = new Map<Id, List<Contact>>();
    if (contactList.isEmpty() || interactionsToUpdate.isEmpty()) {
      return new List<InteractionAttendee>();
    }

    for (Contact c : contactList) {
      if (!officeToContacts.containsKey(c.Office_Group__c)) {
        officeToContacts.put(c.Office_Group__c, new List<Contact>());
      }
      officeToContacts.get(c.Office_Group__c).add(c);
    }
    List<InteractionAttendee> attendeesToCreate = new List<InteractionAttendee>();
    for (Interaction record : interactionsToUpdate) {
      List<Contact> contacts = officeToContacts.get(record.Office_Group__c);
      attendeesToCreate.addAll(createInteractionAttendee(contacts, record.Id));
    }
    return attendeesToCreate;
  }

  /**
   * @description This function to create the InteractionAttendee
   * @param contacts List of contacts/Brokers for each Office_group associated with Interaction
   * @param recordId Interaction record Id from trigger
   * @return List<InteractionAttendee> List of InteractionAttendees
   */
  public static List<InteractionAttendee> createInteractionAttendee(
    List<contact> contacts,
    Id recordId
  ) {
    List<InteractionAttendee> attendeesToCreate = new List<InteractionAttendee>();
    if (contacts == null) {
      return attendeesToCreate;
    }
    for (Contact c : contacts) {
      attendeesToCreate.add(
        new InteractionAttendee(
          AttendeeType = 'External',
          Attendee_SubType__c = BrokerConstants.INTERACTION_BROKER_ATTENDEE,
          ContactId = c.Id,
          InteractionId = recordId
        )
      );
    }
    return attendeesToCreate;
  }

  /**
   * @description This function creates Associated Loan Application records for the given list of Interactions.
   * @param records List of Interaction records from the trigger
   */
  public static void createAssociatedLoanApplication(
    List<Interaction> records
  ) {
    Map<Id, Id> interactionIdVsRLAMap = getInteractionToAppMap(records);
    List<Associated_Loan_Application__c> recordsToInsert = buildAssociatedLoanApplication(
      interactionIdVsRLAMap
    );

    if (!recordsToInsert.isEmpty()) {
      try {
        DML_REPOSITORY.doInsert(
          recordsToInsert,
          new DmlConfig().allowPartial()
        );
      } catch (exception e) {
        logException(e);
      }
    }
  }

  /**
   * @description This function maps each Interaction Id to its corresponding Loan Application Id.
   * @param interactions List of Interaction records
   * @return Map<Id, Id> Map of Interaction Ids to Loan Application Ids
   */
  @TestVisible
  public static Map<Id, Id> getInteractionToAppMap(
    List<Interaction> interactions
  ) {
    Map<Id, Id> interactionIdVsAppMap = new Map<Id, Id>();
    for (Interaction i : interactions) {
      interactionIdVsAppMap.put(i.Id, i.Loan_Application__c);
    }
    return interactionIdVsAppMap;
  }

  /**
   * @description This function builds a list of Associated Loan Application records from the given mapping.
   * @param interactionToAppMap Map of Interaction Ids to Loan Application Ids
   * @return List<Associated_Loan_Application__c> List of records to insert
   */
  @TestVisible
  public static List<Associated_Loan_Application__c> buildAssociatedLoanApplication(
    Map<Id, Id> interactionToAppMap
  ) {
    List<Associated_Loan_Application__c> appList = new List<Associated_Loan_Application__c>();

    for (Id interactionId : interactionToAppMap.keySet()) {
      appList.add(
        new Associated_Loan_Application__c(
          Interaction__c = interactionId,
          Residential_Loan_Application__c = interactionToAppMap.get(
            interactionId
          )
        )
      );
    }
    return appList;
  }

  /**
   * @description This function updates Associated Loan Application records based on changes to Interactions.
   * @param newRecords New Interaction records
   * @param oldRecordMap Old Interaction record map
   */
  public static void updateAssociatedLoanApplication(
    List<Interaction> newRecords,
    Map<Id, SObject> oldRecordMap
  ) {
    List<Interaction> modifiedInteractions = (List<Interaction>) ListUtil.filter(
        newRecords,
        oldRecordMap
      )
      .changed(Interaction.Loan_Application__c)
      .toList();

    if (modifiedInteractions.isEmpty()) {
      return;
    }

    Map<Id, Id> interactionToNewAppMap = getInteractionToAppMap(
      modifiedInteractions
    );
    List<Associated_Loan_Application__c> existingApps = ASSOCIATED_APP_REPOSITORY.getRelatedLoanApplication(
      interactionToNewAppMap.keySet()
    );

    Map<Id, Associated_Loan_Application__c> associatedApplicationMap = (Map<Id, Associated_Loan_Application__c>) ListUtil.mapBy(
      existingApps,
      Associated_Loan_Application__c.Residential_Loan_Application__c
    );
    AssociatedLoanApplicationChange changes = modifyAssociatedLoanApplication(
      modifiedInteractions,
      oldRecordMap,
      associatedApplicationMap
    );

    try {
      if (!changes.appsToDelete.isEmpty()) {
        DML_REPOSITORY.doDelete(
          changes.appsToDelete,
          new DmlConfig().allowPartial()
        );
      }
      if (!changes.appsToInsert.isEmpty()) {
        DML_REPOSITORY.doInsert(
          changes.appsToInsert,
          new DmlConfig().allowPartial()
        );
      }
    } catch (Exception e) {
      logException(e);
    }
  }

  /**
   * @description This function determines which Associated Loan Application records to insert or delete based on Interaction changes.
   * @param modifiedInteractions Modified Interaction records
   * @param oldRecordMap Old Interaction record map
   * @param associatedApplicationMap Existing Associated Loan Application records map
   * @return AssociatedLoanApplicationChange contains lists of records to insert and delete
   */
  /* public static AssociatedLoanApplicationChange modifyAssociatedLoanApplication(
    List<Interaction> modifiedInteractions,
    Map<Id, SObject> oldRecordMap,
    Map<Id, Associated_Loan_Application__c> associatedApplicationMap
  ) {
    AssociatedLoanApplicationChange changeSet = new AssociatedLoanApplicationChange();

    for (Interaction interaction : modifiedInteractions) {
      Id interactionId = interaction.Id;
      Id oldLoanAppId = ((Interaction) oldRecordMap.get(interactionId))
        .Loan_Application__c;
      Id newLoanAppId = interaction.Loan_Application__c;

      Associated_Loan_Application__c existingApp = associatedApplicationMap.get(
        oldLoanAppId
      );

      Boolean isRemoved = (existingApp != null && newLoanAppId == null);
      Boolean isChanged = (existingApp != null && oldLoanAppId != newLoanAppId);
      Boolean isAdded = (oldLoanAppId == null && newLoanAppId != null);
      if (isRemoved || isChanged) {
        changeSet.appsToDelete.add(existingApp);
      }

      if (isAdded || isChanged) {
        changeSet.appsToInsert.add(
          new Associated_Loan_Application__c(
            Interaction__c = interactionId,
            Residential_Loan_Application__c = newLoanAppId
          )
        );
      }
    }
    return changeSet;
  }*/

  public static AssociatedLoanApplicationChange modifyAssociatedLoanApplication(
    List<Interaction> modifiedInteractions,
    Map<Id, SObject> oldRecordMap,
    Map<Id, Associated_Loan_Application__c> associatedApplicationMap
  ) {
    AssociatedLoanApplicationChange changeSet = new AssociatedLoanApplicationChange();

    for (Interaction interaction : modifiedInteractions) {
      processInteractionChange(
        interaction,
        oldRecordMap,
        associatedApplicationMap,
        changeSet
      );
    }

    return changeSet;
  }

  /*private static void processInteractionChange(
    Interaction interaction,
    Map<Id, SObject> oldRecordMap,
    Map<Id, Associated_Loan_Application__c> associatedAppMap,
    AssociatedLoanApplicationChange changeSet
  ) {
    Id interactionId = interaction.Id;
    Id oldLoanAppId = ((Interaction) oldRecordMap.get(interactionId))
      .Loan_Application__c;
    Id newLoanAppId = interaction.Loan_Application__c;

    Associated_Loan_Application__c existingApp = associatedAppMap.get(
      oldLoanAppId
    );

    if (shouldRemove(existingApp, newLoanAppId)) {
      changeSet.appsToDelete.add(existingApp);
    }

    if (shouldAdd(oldLoanAppId, newLoanAppId, existingApp)) {
      changeSet.appsToInsert.add(
        new Associated_Loan_Application__c(
          Interaction__c = interactionId,
          Residential_Loan_Application__c = newLoanAppId
        )
      );
    }
  }*/

  private static void processInteractionChange(
    Interaction interaction,
    Map<Id, SObject> oldMap,
    Map<Id, Associated_Loan_Application__c> appMap,
    AssociatedLoanApplicationChange changeSet
  ) {
    Id oldLoanAppId = ((Interaction) oldMap.get(interaction.Id))
      .Loan_Application__c;
    Id newLoanAppId = interaction.Loan_Application__c;

    if (oldLoanAppId == newLoanAppId) {
      return;
    }

    Associated_Loan_Application__c existingApp = appMap.get(oldLoanAppId);
    if (existingApp != null) {
      changeSet.appsToDelete.add(existingApp);
    }
    if (newLoanAppId != null) {
      changeSet.appsToInsert.add(
        new Associated_Loan_Application__c(
          Interaction__c = interaction.Id,
          Residential_Loan_Application__c = newLoanAppId
        )
      );
    }
  }

  private static Boolean shouldRemove(
    Associated_Loan_Application__c existingApp,
    Id newLoanAppId
  ) {
    return existingApp != null && newLoanAppId == null;
  }

  private static Boolean shouldAdd(
    Id oldLoanAppId,
    Id newLoanAppId,
    Associated_Loan_Application__c existingApp
  ) {
    Boolean isAdded = oldLoanAppId == null && newLoanAppId != null;
    Boolean isChanged = existingApp != null && oldLoanAppId != newLoanAppId;
    return isAdded || isChanged;
  }

  /**
   * @description This class holds the lists of Associated Loan Application records to insert or delete.
   */
  public class AssociatedLoanApplicationChange {
    public List<Associated_Loan_Application__c> appsToInsert;
    public List<Associated_Loan_Application__c> appsToDelete;
    /**
     * @description AssociatedLoanApplicationChange constructor.
     */
    public AssociatedLoanApplicationChange() {
      appsToInsert = new List<Associated_Loan_Application__c>();
      appsToDelete = new List<Associated_Loan_Application__c>();
    }
  }

  /**
   * @description set interaction date and time for created records
   * @param records List of new interaction records
   */
  public static void createInteractionEvents(List<Interaction> records) {
    try {
      List<Event> eventRecords = manageInteractionEvents(
        records,
        new Map<Id, Event>()
      );

      RBMInteractionActions.DML_REPOSITORY.doInsert(eventRecords);
    } catch (Exception e) {
      logException(e);
    }
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
    try {
      List<Interaction> updatedInteractions = ListUtil.filter(
          records,
          oldRecordMap
        )
        .changed(Interaction.StartTime)
        .toList();

      Map<Id, Event> relatedEvents = RBMInteractionRepository.getEvents(
        oldRecordMap.keySet()
      );

      List<Event> eventRecords = manageInteractionEvents(
        updatedInteractions,
        relatedEvents
      );

      RBMInteractionActions.DML_REPOSITORY.doUpsert(eventRecords);
    } catch (Exception e) {
      logException(e);
    }
  }

  /**
   * @description set interaction date and time
   * @param interactionRecords List of new interaction records
   * @param relatedEvents Map of old interaction records
   * @return List<Event> to upsert
   */
  /*@testVisible
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
  }*/

  private static List<Event> manageInteractionEvents(
    List<Interaction> interactionRecords,
    Map<Id, Event> relatedEvents
  ) {
    List<Event> eventRecords = new List<Event>();

    for (Interaction record : interactionRecords) {
      eventRecords.add(buildEvent(record, relatedEvents));
    }
    return eventRecords;
  }

  private static Event buildEvent(
    Interaction record,
    Map<Id, Event> relatedEvents
  ) {
    Event event = relatedEvents.containsKey(record.Id)
      ? relatedEvents.get(record.Id)
      : new Event(Subject = record.Name, WhatId = record.Id);

    event.StartDateTime = record.StartTime;
    event.EndDateTime = record.StartTime;
    event.IsReminderSet = record.StartTime > System.now() + 1;
    event.ReminderDateTime = event.IsReminderSet ? record.StartTime - 1 : null;

    return event;
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
    try {
      List<Interaction> updatedInteractions = ListUtil.filter(
          records,
          oldRecordMap
        )
        .changed(Interaction.Status__c)
        .toList();

      for (Interaction record : updatedInteractions) {
        record.Closing_Notes__c = record.Status__c ==
          BrokerConstants.INTERACTION_STATUS_OPEN
          ? ''
          : record.Closing_Notes__c;
      }
    } catch (Exception e) {
      logException(e);
    }
  }

  /**
   * @description create note for interaction while closing.
   * @param records List of new interaction records
   */
  public static void createInteractionClosingNotes(List<Interaction> records) {
    try {
      List<Interaction> interactionRecords = ListUtil.filter(records)
        .isNotNull(Interaction.Closing_Notes__c)
        .toList();

      createClosingNotes(interactionRecords);
    } catch (Exception e) {
      logException(e);
    }
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
    try {
      List<Interaction> updatedInteractions = ListUtil.filter(
          records,
          oldRecordMap
        )
        .changed(Interaction.Status__c)
        .toList();

      createClosingNotes(updatedInteractions);
    } catch (Exception e) {
      logException(e);
    }
  }

  /**
   * @description create note for interaction while closing.
   * @param records List of new interaction records to create Closing Notes
   */
  /*@testVisible
  private static void createClosingNotes(List<Interaction> records) {
    try {
      List<Interaction> closingRecords = new List<Interaction>();

      Set<String> closingStatus = new Set<String>{
        BrokerConstants.INTERACTION_STATUS_CLOSED_COMPLETED,
        BrokerConstants.INTERACTION_STATUS_CLOSED_FOLLOWUP,
        BrokerConstants.INTERACTION_STATUS_CLOSED_WITHDRAWN
      };
      for (Interaction record : records) {
        if (closingStatus.contains(record.Status__c)) {
          closingRecords.add(record);
        }
      }
      if (!closingRecords.isEmpty()) {
        Map<Id, ContentNote> notes = RBMInteractionActions.generateNotes(
          closingRecords,
          'Closing_Notes__c'
        );

        RBMInteractionActions.DML_REPOSITORY.doInsert(notes.values());
        List<ContentDocumentLink> contentDocumentLinks = RBMInteractionActions.generateContentDocumentLink(
          notes
        );
        RBMInteractionActions.DML_REPOSITORY.doInsert(contentDocumentLinks);
      }
    } catch (Exception e) {
      logException(e);
    }
  }*/

  @testVisible
  private static void createClosingNotes(List<Interaction> records) {
    try {
      List<Interaction> closingRecords = filterClosingInteractions(records);
      if (closingRecords.isEmpty()) {
        return;
      }

      insertClosingNotes(closingRecords);
    } catch (Exception e) {
      logException(e);
    }
  }

  private static List<Interaction> filterClosingInteractions(
    List<Interaction> records
  ) {
    Set<String> closingStatus = new Set<String>{
      BrokerConstants.INTERACTION_STATUS_CLOSED_COMPLETED,
      BrokerConstants.INTERACTION_STATUS_CLOSED_FOLLOWUP,
      BrokerConstants.INTERACTION_STATUS_CLOSED_WITHDRAWN
    };

    return ListUtil.filter(records)
      .equals(Interaction.Status__c, closingStatus)
      .toList();
  }

  private static void insertClosingNotes(List<Interaction> records) {
    Map<Id, ContentNote> notes = generateNotes(records, 'Closing_Notes__c');
    DML_REPOSITORY.doInsert(notes.values());

    List<ContentDocumentLink> links = generateContentDocumentLink(notes);
    DML_REPOSITORY.doInsert(links);
  }
}
