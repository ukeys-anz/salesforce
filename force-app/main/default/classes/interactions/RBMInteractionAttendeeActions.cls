/**
 * @author Smruti
 * @since June 2025
 * @description class to handle all the RBM Broker Interaction Attendee Actions
 */
public with sharing class RBMInteractionAttendeeActions {
  private static final RBMInteractionRepository INTERACTION_REPOSITORY = (RBMInteractionRepository) Lib_InstanceProvider.forType(
    RBMInteractionRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description method to check and create related Interaction Attendees from Office Group and Broker
   * @param records List of new interaction Attendee records
   */
  public static void createInteractionAttendee(List<Interaction> records) {
    List<Interaction> brokerInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Broker__c)
      .toList();

    List<Interaction> officeInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Office_Group__c)
      .toList();
    Set<Id> groupIds = ListUtil.getIds(
      officeInteractions,
      Interaction.Office_Group__c
    );
    try {
      List<Contact> contactList = INTERACTION_REPOSITORY.queryBrokersFromOfficeGroups(
        groupIds
      );
      List<InteractionAttendee> attendeesToCreate = getOfficeAttendeesToCreate(
        contactList,
        officeInteractions
      );
      attendeesToCreate.addAll(getBrokerAttendeesToCreate(brokerInteractions));
      DML_REPOSITORY.doInsert(attendeesToCreate);
    } catch (exception ex) {
      Logger.error('Interaction Attendee creation failed due to: ', ex).save();
      throw ex;
    }
  }

  /**
   * @description This function to create the InteractionAttendee
   * @param brokerInteraction Interaction records to be updated
   * @return List<InteractionAttendee> of InteractionAttendee records
   */
  public static List<InteractionAttendee> getBrokerAttendeesToCreate(
    List<Interaction> brokerInteraction
  ) {
    List<InteractionAttendee> attendeesToCreate = new List<InteractionAttendee>();
    for (Interaction interactionRec : brokerInteraction) {
      attendeesToCreate.add(
        new InteractionAttendee(
          AttendeeType = 'External',
          Attendee_SubType__c = RBMInteractionConstants.INTERACTION_BROKER_ATTENDEE,
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
    if (contacts == null || contacts.isEmpty()) {
      return attendeesToCreate;
    }
    for (Contact c : contacts) {
      attendeesToCreate.add(
        new InteractionAttendee(
          AttendeeType = 'External',
          Attendee_SubType__c = RBMInteractionConstants.INTERACTION_BROKER_ATTENDEE,
          ContactId = c.Id,
          InteractionId = recordId
        )
      );
    }
    return attendeesToCreate;
  }
}
