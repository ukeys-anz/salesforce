/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description class for Interaction Attendee Actions
 */
public with sharing class InteractionAttendeeActions {
  private static final InteractionRepository INTERACTION_REPOSITORY = (InteractionRepository) Lib_InstanceProvider.forType(
    InteractionRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final Set<String> CALL_MESSAGE_INPERSON_RT_ID = new Set<String>{
    RTInteraction.call,
    RTInteraction.message,
    RTInteraction.inPerson
  };

  /**
   * @description Checks if attendee already exists on record
   * @param attendees list of new interaction attendees
   */
  public static void validateAttendees(List<InteractionAttendee> attendees) {
    Set<Id> interactionIds = ListUtil.getIds(
      attendees,
      InteractionAttendee.InteractionId
    );
    List<Interaction> interactionList = (List<Interaction>) ListUtil.filter(
        INTERACTION_REPOSITORY.queryInteractionAndRelatedAttendees(
          interactionIds
        )
      )
      .equals(Interaction.RecordTypeId, RTInteraction.rbmBrokerInteraction)
      .toList();

    Set<Id> rbmInteractionIds = ListUtil.getIds(
      interactionList,
      Interaction.Id
    );
    for (InteractionAttendee attendee : attendees) {
      attendee.Attendee_Name__c = attendee.Attendee_Name_Formula__c;
      attendee.UniqueKeyForInteractionAttendee__c = updateUniqueKeyForInteraction(
        attendee,
        rbmInteractionIds.contains(attendee.InteractionId)
      );
    }
  }

  /**
   * @description Updates attendees in Interaction.Attendees_c and
   * Interaction.Attendees_and_Roles__c based off the updated
   * Interaction Attendee record
   * @param attendees list of interaction attendees
   * @param oldAttendeesMap old interaction attendees map
   */
  public static void updateAttendees(
    List<InteractionAttendee> attendees,
    Map<Id, InteractionAttendee> oldAttendeesMap
  ) {
    Set<Id> interactionIds = ListUtil.getIds(
      attendees,
      InteractionAttendee.InteractionId
    );

    List<Interaction> interactionList = INTERACTION_REPOSITORY.queryInteractionAndRelatedAttendees(
      interactionIds
    );

    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>(
      interactionList
    );

    List<InteractionAttendee> attendeeList = getInteractionAttendeeFromInteraction(
      interactionMap
    );

    Map<Id, Set<String>> interactionAndAttendeeMap = createInteractionAttendeeMap(
      attendeeList
    );
    Map<Id, String> createInteractionAndAttendeeRoleMap = createInteractionAndAttendeeRoleMap(
      attendeeList
    );

    List<Interaction> listOfInteractionTobeUpdated = updateAttendeeAndRoleOnInteraction(
      interactionMap,
      interactionAndAttendeeMap,
      createInteractionAndAttendeeRoleMap
    );

    DML_REPOSITORY.doUpdate(
      listOfInteractionTobeUpdated,
      new DMLConfig().allowPartial().systemMode()
    );
  }

  /**
   * @description Create interaction attendee for the newly created interactions.
   * @param interactions List of newly created interactions.
   */
  public static void insertDefaultAttendee(List<Interaction> interactions) {
    List<InteractionAttendee> listOfInteractAttendeeToInsert = new List<InteractionAttendee>();

    // Automatically create attendee only if the created user is of Profile "ANZx Standard User"
    if (!USER_INFO.checkProfile('ANZx Standard User')) {
      return;
    }
    for (Interaction interact : interactions) {
      if (!CALL_MESSAGE_INPERSON_RT_ID.contains(interact.RecordTypeId)) {
        continue;
      }

      InteractionAttendee intattendee = new InteractionAttendee();
      intattendee.AttendeeType = InteractionConstants.INTERNAL;
      intattendee.UserId = USER_INFO.getUser().Id;
      intattendee.InteractionId = interact.id;
      listOfInteractAttendeeToInsert.add(intattendee);
    }
    DML_REPOSITORY.doInsert(
      listOfInteractAttendeeToInsert,
      new DMLConfig().allowPartial()
    );
  }

  /**
   * @description Create interaction attendee when the owner is updated.
   * @param interactions List of interactions with owner's changed.
   */
  public static void insertOwnerChangeAttendee(List<Interaction> interactions) {
    //Loop in interaction and filter out all owner ids
    Set<Id> interactionOwnerIds = ListUtil.getIds(
      interactions,
      Interaction.OwnerId
    );

    //Fetch all list of attendees for the current users and current interactions
    List<InteractionAttendee> listOfInteractionAttendee = INTERACTION_REPOSITORY.queryInteractionAttendees(
      interactions,
      interactionOwnerIds
    );
    //Loop in and create a Map of Interaction Id and list of attendees.
    Map<Id, Set<Id>> interactionIdWithAttendeeIdsMap = getInteractionIdWithAttendeesIdsMap(
      listOfInteractionAttendee
    );
    // Now Finally loop on proginal interaction, check if there is any existin interaction attendee with the
    // OwnerId, if yes, ignore it, if not insert the interactionattendee.
    List<InteractionAttendee> interactAttendeesToInsertList = createInteractionAttendeesToInsert(
      interactions,
      interactionIdWithAttendeeIdsMap
    );
    //This code creates interaction attendee in system mode using Twilio API user with limited access
    DML_REPOSITORY.doInsert(
      interactAttendeesToInsertList,
      new DmlConfig().allowPartial().systemMode()
    );
  }

  /**
   * @description Create interaction attendee when the Customer is getting added to the interaction
   * @param interactions List of updated interactions
   * @param oldMapInteraction Map of old interaction records.
   */
  public static void insertCustomerTypeInteractionAttendee(
    List<Interaction> interactions,
    Map<Id, Interaction> oldMapInteraction
  ) {
    List<Interaction> listCallInteractionsWithAccount = ListUtil.filter(
        interactions
      )
      .equals(Interaction.RecordTypeId, RTInteraction.call)
      .isNotNull(Interaction.AccountId)
      .toList();

    if (listCallInteractionsWithAccount.isEmpty()) {
      return;
    }

    List<interaction> interactionList = INTERACTION_REPOSITORY.queryInteractions(
      listCallInteractionsWithAccount
    );
    List<InteractionAttendee> listOfInteractAttendee = createCustomerTypeInteractionAttendee(
      interactionList,
      oldMapInteraction
    );

    DML_REPOSITORY.doInsert(
      listOfInteractAttendee,
      new DMLConfig().allowPartial()
    );
  }

  /**
   * @description Create List of customer type Interaction Attendee
   * @param interactions List of interactions of call record type , customer linked to them and queried with some more fields
   * @param oldMapInteraction List of interactions which are updated or inserted.
   * @return List of Interaction Attendee to be inserted
   */
  public static List<InteractionAttendee> createCustomerTypeInteractionAttendee(
    List<Interaction> interactions,
    Map<Id, Interaction> oldMapInteraction
  ) {
    List<String> listOfFieldApiNameAccount = new List<String>{ 'AccountId' };
    List<InteractionAttendee> lstInteractAttendee = new List<InteractionAttendee>();
    for (Interaction interact : interactions) {
      if (
        oldMapInteraction.containsKey(interact.Id) &&
        !(InteractionActions.hasAnyFieldChanged(
          interact,
          oldMapInteraction.get(interact.id),
          listOfFieldApiNameAccount
        ))
      ) {
        continue;
      }
      InteractionAttendee intattendee = new InteractionAttendee();
      intattendee.AttendeeType = InteractionConstants.CUSTOMER;
      intattendee.Attendee_Phone__c = interact.Contact_Mobile__c;
      intattendee.ContactId = interact.account.PersonContactId;
      intattendee.InteractionId = interact.id;
      lstInteractAttendee.add(intattendee);
    }
    return lstInteractAttendee;
  }
  /**
   * @description Create Interaction Attendee when there is conference happened in Twilio Call Conference
   * @param twilioContextRequest TwilioContextRequest containing data for InteractionAttendee Creation
   * @return List<InteractionAttendee> InteractionAttendee List to be created
   */
  public static List<InteractionAttendee> insertTwilioConferenceAttendee(
    UpdateInteractionByTwilioPayload twilioContextRequest
  ) {
    List<InteractionAttendee> interactionAttendeeList = new List<InteractionAttendee>();

    if (!TwilioServiceUtil.checkIsConference(twilioContextRequest)) {
      return interactionAttendeeList;
    }

    InteractionAttendee intattendee = new InteractionAttendee();
    intattendee.AttendeeType = InteractionConstants.EXTERNAL;
    intattendee.UserId = twilioContextRequest.agentUserId;
    intattendee.InteractionId = twilioContextRequest.interactionId;
    intattendee.Attendee_Name__c = twilioContextRequest.attendeeName;
    intattendee.Attendee_Phone__c = twilioContextRequest.attendeePhoneNumber;
    intattendee.Conversation_Sid__c = twilioContextRequest.chatOrCallId;

    if (String.isNotBlank(twilioContextRequest.agentEmail)) {
      intattendee.AttendeeType = InteractionConstants.INTERNAL;
    }
    interactionAttendeeList.add(intattendee);

    return interactionAttendeeList;
  }

  /**
   * @description create InteractionAttendee map based on AttendeeType
   * @param attendeeList list of attendeelist.
   * @return Map of Interaction Id and Set of InteractionAttendee of Interaction.
   */
  @TestVisible
  private static Map<Id, Set<String>> createInteractionAttendeeMap(
    List<InteractionAttendee> attendeeList
  ) {
    Map<Id, Set<String>> interactionAndAttendeeMap = new Map<Id, Set<String>>();
    for (InteractionAttendee attendant : attendeeList) {
      if (!interactionAndAttendeeMap.containsKey(attendant.InteractionId)) {
        interactionAndAttendeeMap.put(
          attendant.InteractionId,
          new Set<String>()
        );
      }

      //Added to check AttendeeType and based on that adding Attendee values in Interaction
      switch on attendant.AttendeeType {
        when 'Internal' {
          interactionAndAttendeeMap.get(attendant.InteractionId)
            .add(attendant.User.Name);
        }
        when 'Customer' {
          interactionAndAttendeeMap.get(attendant.InteractionId)
            .add(attendant.Contact.Name);
        }
        when else {
          interactionAndAttendeeMap.get(attendant.InteractionId)
            .add(attendant.Attendee_Name__c);
        }
      }
    }
    return interactionAndAttendeeMap;
  }

  /**
   * @description create InteractionAttendeeRole map only for IntenalAttendeeType
   * @param attendeeList list of attendeelist.
   * @return Map of Interaction Id and Set of InteractionAttendee of Interaction.
   */
  @TestVisible
  private static Map<Id, String> createInteractionAndAttendeeRoleMap(
    List<InteractionAttendee> attendeeList
  ) {
    Map<Id, String> internalUserIdAndAttendeeRoleMap = new Map<Id, String>();
    for (InteractionAttendee attendant : attendeeList) {
      if (attendant.AttendeeType != InteractionConstants.INTERNAL) {
        continue;
      }

      internalUserIdAndAttendeeRoleMap.put(
        attendant.UserId,
        attendant.User.UserRole.Name
      );
    }
    return internalUserIdAndAttendeeRoleMap;
  }

  /**
   * @description create List<InteractionAttendee> related to the Interaction which already exist
   * @param interactionMap Map of Interaction with Attendee Details
   * @return List<InteractionAttendee>
   */
  @TestVisible
  private static List<InteractionAttendee> getInteractionAttendeeFromInteraction(
    Map<Id, Interaction> interactionMap
  ) {
    List<InteractionAttendee> interactionAttendees = new List<InteractionAttendee>();
    for (Interaction interact : interactionMap.values()) {
      interactionAttendees.addAll(interactionMap.get(interact.Id).Attendees);
    }
    return interactionAttendees;
  }

  /**
   * @description create List<Interaction> to be updated for adding new attendees and attendees role
   * @param interactionMap Map of Interaction with Attendee Details
   * @param interactionAndAttendeeMap Map of Interaction Id and Set of Attendees
   * @param createInteractionAndAttendeeRoleMap Map of User Id and Attendees Role
   * @return List<Interaction> to be updated
   */
  @TestVisible
  private static List<Interaction> updateAttendeeAndRoleOnInteraction(
    Map<Id, Interaction> interactionMap,
    Map<Id, Set<String>> interactionAndAttendeeMap,
    Map<Id, String> createInteractionAndAttendeeRoleMap
  ) {
    List<Interaction> interactionToBeUpdatedList = new List<Interaction>();
    for (Interaction interact : interactionMap.values()) {
      Set<String> uniqueAttendees = interactionAndAttendeeMap.get(interact.Id);

      String strUniqueAttendees = String.join(
        new List<String>(uniqueAttendees),
        ','
      );
      String strUniqueRoles = JSON.serialize(
        createInteractionAndAttendeeRoleMap
      );

      interactionToBeUpdatedList.add(
        new Interaction(
          Id = interact.Id,
          Attendees__c = strUniqueAttendees,
          Attendees_and_Roles__c = strUniqueRoles
        )
      );
    }

    return interactionToBeUpdatedList;
  }

  /**
   * @description Update UniqueKeyForInteractionAttendee__c field for attendees
   * @param attendee list of new interaction attendees
   * @param rbmInteractionExists true if interaction with Record Type RBM_Broker_Interaction exists with Id as Attendee.InterationId
   * @return uniqueKey for restricting duplicate record insertion
   */
  @TestVisible
  private static String updateUniqueKeyForInteraction(
    InteractionAttendee attendee,
    Boolean rbmInteractionExists
  ) {
    String middleKey = '';
    String attendeeType = attendee.AttendeeType;
    Boolean isBroker = 'Broker'.equals(attendee.Attendee_SubType__c);

    if (attendeeType == 'Internal') {
      middleKey = attendee.UserId;
    }
    if (
      (attendeeType == 'Customer') ||
      (attendeeType == 'External' &&
      isBroker &&
      rbmInteractionExists)
    ) {
      middleKey = attendee.ContactId;
    }
    if (attendeeType == 'External' && (!isBroker || !rbmInteractionExists)) {
      middleKey = attendee.Attendee_Phone__c;
    }
    if (attendeeType == 'VirtualAgent') {
      return attendee.InteractionId + '_' + attendee.Attendee_Name__c;
    }

    String uniqueKey =
      attendee.InteractionId +
      '_' +
      middleKey +
      '_' +
      attendee.Conversation_Sid__c;
    return uniqueKey;
  }

  /**
   * @description Create Map of Interaction Id with Set Of Attendee Ids.
   * @param listOfInteractionAttendee list of interaction attendees
   * @return Map<Id, Set<Id>> Interaction Id and related Attendee Ids Map
   */
  private static Map<Id, Set<Id>> getInteractionIdWithAttendeesIdsMap(
    List<InteractionAttendee> listOfInteractionAttendee
  ) {
    Map<Id, Set<Id>> interactionWithAttendee = new Map<Id, Set<Id>>();
    for (InteractionAttendee attendee : listOfInteractionAttendee) {
      if (!interactionWithAttendee.containsKey(attendee.InteractionId)) {
        interactionWithAttendee.put(attendee.InteractionId, new Set<Id>());
      }
      interactionWithAttendee.get(attendee.InteractionId).add(attendee.UserId);
    }
    return interactionWithAttendee;
  }

  /**
   * @description Create List of Interactio Attendees to insert
   * @param interactions list of interaction
   * @param interactionWithAttendee Interaction Id and related Attendee Ids Map
   * @return List<InteractionAttendee> list of interaction attendees to insert
   */
  private static List<InteractionAttendee> createInteractionAttendeesToInsert(
    List<Interaction> interactions,
    Map<Id, Set<Id>> interactionWithAttendee
  ) {
    List<InteractionAttendee> interactAttendeesToInsertList = new List<InteractionAttendee>();
    for (Interaction interact : interactions) {
      if (!CALL_MESSAGE_INPERSON_RT_ID.contains(interact.RecordTypeId)) {
        continue;
      }
      Set<Id> existingAttendeeIds = interactionWithAttendee.get(interact.Id);
      if (
        existingAttendeeIds != null &&
        existingAttendeeIds.contains(interact.OwnerId)
      ) {
        continue;
      }
      InteractionAttendee intattendee = new InteractionAttendee();
      intattendee.AttendeeType = InteractionConstants.INTERNAL;
      intattendee.UserId = interact.OwnerId;
      intattendee.InteractionId = interact.id;
      interactAttendeesToInsertList.add(intattendee);
    }

    return interactAttendeesToInsertList;
  }
}
