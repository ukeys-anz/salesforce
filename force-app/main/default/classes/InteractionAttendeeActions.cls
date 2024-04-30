/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description class for Interaction Attendee Actions
 */
public with sharing class InteractionAttendeeActions {
  /**
   * @description Checks if attendee already exists on record
   * @param attendees list of new interaction attendees
   */
  public static void validateAttendees(List<InteractionAttendee> attendees) {
    for (InteractionAttendee attendee : attendees) {
      attendee.Attendee_Name__c = attendee.Attendee_Name_Formula__c;
      attendee.UniqueKeyForInteractionAttendee__c = updateUniqueKeyForInteraction(
        attendee
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
    Set<Id> interactionIds = getInteractionIdFromAttendee(attendees);

    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>(
      queryInteractionAndRelatedAttendees(interactionIds)
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

    List<Interaction> lstInteractionTobeUpdated = updateAttendeeAndRoleOnInteraction(
      interactionMap,
      interactionAndAttendeeMap,
      createInteractionAndAttendeeRoleMap
    );

    DMLUtil.updateRecords(lstInteractionTobeUpdated, false, false);
  }

  /**
   * @description Create interaction attendee for the newly created interactions.
   * @param interactions List of newly created interactions.
   */
  public static void insertDefaultAttendee(List<Interaction> interactions) {
    List<InteractionAttendee> lstInteractAttend = new List<InteractionAttendee>();
    Set<String> profilenames = new Set<String>();
    Set<Id> recordtypes = new Set<Id>();
    profilenames.add('ANZx Standard User');
    recordtypes.add(GetHelpConstants.INTERACTION_STORE_RT_ID);
    recordtypes.add(GetHelpConstants.INTERACTION_GENERAL_RT_ID);
    recordtypes.add(GetHelpConstants.INTERACTION_MESSAGE_RT_ID);
    User userDetail = [
      SELECT id, profile.name
      FROM user
      WHERE id = :UserInfo.getUserId()
    ];

    // Automatically create attendee only if the created user is of Profile "ANZx Standard User"
    if (profilenames.contains(userDetail.profile.name)) {
      for (Interaction interact : interactions) {
        if (recordtypes.contains(interact.RecordTypeId)) {
          InteractionAttendee intattendee = new InteractionAttendee();
          intattendee.AttendeeType = InteractionConstants.INTERNAL;
          intattendee.UserId = UserInfo.getUserId();
          intattendee.InteractionId = interact.id;
          lstInteractAttend.add(intattendee);
        }
      }
    }
    DMLUtil.insertRecords(lstInteractAttend, false, true);
  }

  /**
   * @description Create interaction attendee when the owner is updated.
   * @param interactions List of interactions with owner's changed.
   */
  public static void insertOwnerChangeAttendee(List<Interaction> interactions) {
    Map<Id, Set<Id>> interActionWithAttendee = new Map<Id, Set<Id>>();
    List<InteractionAttendee> lstInteractAttend = new List<InteractionAttendee>();
    List<Id> interactionOwnerId = new List<Id>();
    Set<Id> recordtypes = new Set<Id>();
    recordtypes.add(GetHelpConstants.INTERACTION_STORE_RT_ID);
    recordtypes.add(GetHelpConstants.INTERACTION_GENERAL_RT_ID);
    recordtypes.add(GetHelpConstants.INTERACTION_MESSAGE_RT_ID);
    //Loop in interaction and filter out all owner ids
    for (Interaction interact : interactions) {
      interactionOwnerId.add(interact.OwnerId);
      interActionWithAttendee.put(interact.Id, new Set<Id>{});
    }

    //Fetch all list of attendees for the current users and current interactions
    List<InteractionAttendee> lstattendee = [
      SELECT UserId, InteractionId
      FROM InteractionAttendee
      WHERE InteractionId IN :interactions AND UserId IN :interactionOwnerId
    ];

    //Lopp in and create a Map of Interaction Id and list of attendees.
    for (InteractionAttendee lstAttendeeFromDatabase : lstattendee) {
      if (
        !interActionWithAttendee.containsKey(
          lstAttendeeFromDatabase.InteractionId
        )
      ) {
        interActionWithAttendee.put(
          lstAttendeeFromDatabase.InteractionId,
          new Set<Id>{ lstAttendeeFromDatabase.UserId }
        );
      } else {
        Set<Id> allInteractionAttendees = interActionWithAttendee.get(
          lstAttendeeFromDatabase.InteractionId
        );
        allInteractionAttendees.add(lstAttendeeFromDatabase.UserId);
      }
    }

    // Now Finally loop on proginal interaction, check if there is any existin interaction attendee with the
    // OwnerId, if yes, ignore it, if not insert the interactionattendee.
    for (Interaction interact : interactions) {
      if (recordtypes.contains(interact.RecordTypeId)) {
        Set<Id> existingAttendeeIds = interActionWithAttendee.get(interact.Id);
        if (
          existingAttendeeIds != null &&
          !existingAttendeeIds.contains(interact.OwnerId)
        ) {
          InteractionAttendee intattendee = new InteractionAttendee();
          intattendee.AttendeeType = InteractionConstants.INTERNAL;
          intattendee.UserId = interact.OwnerId;
          intattendee.InteractionId = interact.id;
          lstInteractAttend.add(intattendee);
        }
      }
    }
    //This code creates interaction attendee in system mode using Twilio API user with limited access
    DMLUtil.insertRecords(lstInteractAttend, false, false);
  }

  /**
   * @description Create interaction attendee when the Customer is getting added to the interaction
   * @param interactions List of updated interactions
   * @param oldMapInteraction Map of old interaction records
   */
  public static void insertCustomerTypeInteractionAttendee(
    List<Interaction> interactions,
    Map<Id, Interaction> oldMapInteraction
  ) {
    List<Interaction> listCallInteractionsWithAccount = filterInteractions(
      interactions
    );
    if (listCallInteractionsWithAccount.isEmpty()) {
      return;
    }
    List<interaction> interactionList = queryInteractions(
      listCallInteractionsWithAccount
    );
    List<InteractionAttendee> lstInteractAttendee = createCustomerTypeInteractionAttendee(
      interactionList,
      oldMapInteraction
    );

    DMLUtil.insertRecords(lstInteractAttendee, false, true);
  }

  /**
   * @description Filter Interactions of Call RecordType and Accounts linked to them
   * @param interactions List of interactions which are updated or inserted.
   * @return List of Interactions Call RecordType and Accounts linked to them
   */
  public static List<Interaction> filterInteractions(
    List<Interaction> interactions
  ) {
    List<Interaction> listCallInteractionsWithAccount = new List<Interaction>();
    for (Interaction interact : interactions) {
      if (
        interact.RecordTypeId != GetHelpConstants.INTERACTION_GENERAL_RT_ID ||
        interact.AccountId == null
      ) {
        continue;
      }
      listCallInteractionsWithAccount.add(interact);
    }
    return listCallInteractionsWithAccount;
  }

  /**
   * @description Query details of Interaction Records
   * @param interactions List of interactions which are updated.
   * @return Interaction info having customer associated with it.
   */
  public static List<Interaction> queryInteractions(
    List<Interaction> interactions
  ) {
    return [
      SELECT
        id,
        Contact_Mobile__c,
        Account.PersonContactId,
        RecordTypeId,
        AccountId
      FROM interaction
      WHERE id IN :interactions
    ];
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
   * @param agentOwnerIdMap agent owner Id Map to set the User Id of the Interaction Attendee when Interaction Type is Internal
   * @return interactionAttendeeList List<InteractionAttendee> to be created
   */
  public static List<InteractionAttendee> insertTwilioConferenceAttendee(
    UpdateInteractionByTwilioPayload twilioContextRequest,
    Map<String, Id> agentOwnerIdMap
  ) {
    List<InteractionAttendee> interactionAttendeeList = new List<InteractionAttendee>();

    if (!TwilioServiceUtil.checkIsConference(twilioContextRequest)) {
      return interactionAttendeeList;
    }

    InteractionAttendee intattendee = new InteractionAttendee();
    intattendee.AttendeeType = fetchAttendeeType(
      twilioContextRequest.agentEmail
    );

    intattendee.UserId = fetchAgentUserId(
      twilioContextRequest.agentEmail,
      agentOwnerIdMap
    );

    intattendee.InteractionId = twilioContextRequest.interactionId;
    intattendee.Attendee_Name__c = twilioContextRequest.attendeeName;
    intattendee.Attendee_Phone__c = twilioContextRequest.attendeePhoneNumber;
    intattendee.Conversation_Sid__c = twilioContextRequest.chatOrCallId;
    interactionAttendeeList.add(intattendee);

    return interactionAttendeeList;
  }
  /**
   * @description fetch attendeeType of the InteractionAttendee
   * @param agentEmail agentEmail from TwilioContextRequest recceived from Twilio
   * @return InteractionAttendeeType
   */
  private static String fetchAttendeeType(String agentEmail) {
    return String.isNotBlank(agentEmail)
      ? InteractionConstants.INTERNAL
      : InteractionConstants.EXTERNAL;
  }

  /**
   * @description fetch user id if the agentemail exist in the system
   * @param agentEmail agentEmail from TwilioContextRequest recceived from Twilio
   * @param agentOwnerIdMap agentEmail and Id map
   * @return AgentUserId if existing in the system
   */
  private static String fetchAgentUserId(
    String agentEmail,
    Map<String, Id> agentOwnerIdMap
  ) {
    return String.isNotBlank(agentEmail)
      ? agentOwnerIdMap.get(agentEmail.toLowerCase())
      : null;
  }

  /**
   * @description Query details of Interaction Records and Related Attendee
   * @param interactionIds set of InteractionId on which update is happening.
   * @return Interaction info along with Attendees details.
   */
  @TestVisible
  private static List<Interaction> queryInteractionAndRelatedAttendees(
    Set<Id> interactionIds
  ) {
    return [
      SELECT
        Id,
        Attendees__c,
        Attendees_and_Roles__c,
        (
          SELECT
            Id,
            InteractionId,
            AttendeeType,
            UserId,
            User.UserRole.Name,
            User.Name,
            ContactId,
            Contact.Name,
            Attendee_Name__c
          FROM Attendees
        )
      FROM Interaction
      WHERE Id IN :interactionIds
    ];
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
   * @description create Set<Id> of Interaction Ids related to Attendees
   * @param attendees list of attendee.
   * @return Set of Interaction Ids
   */
  @TestVisible
  private static Set<Id> getInteractionIdFromAttendee(
    List<InteractionAttendee> attendees
  ) {
    Set<Id> interactionIds = new Set<Id>();
    for (InteractionAttendee attendant : attendees) {
      interactionIds.add(attendant.InteractionId);
    }
    return interactionIds;
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
    List<Interaction> lstInteractionToBeUpdated = new List<Interaction>();
    for (Interaction interact : interactionMap.values()) {
      Set<String> uniqueAttendees = interactionAndAttendeeMap.get(interact.Id);

      String strUniqueAttendees = String.join(
        new List<String>(uniqueAttendees),
        ','
      );
      String strUniqueRoles = JSON.serialize(
        createInteractionAndAttendeeRoleMap
      );

      lstInteractionToBeUpdated.add(
        new Interaction(
          Id = interact.Id,
          Attendees__c = strUniqueAttendees,
          Attendees_and_Roles__c = strUniqueRoles
        )
      );
    }

    return lstInteractionToBeUpdated;
  }

  /**
   * @description Update UniqueKeyForInteractionAttendee__c field for attendees
   * @param attendee list of new interaction attendees
   * @return uniqueKey for restricting duplicate record insertion
   */
  @TestVisible
  private static String updateUniqueKeyForInteraction(
    InteractionAttendee attendee
  ) {
    String uniqueKey;
    switch on attendee.AttendeeType {
      when 'Internal' {
        uniqueKey =
          attendee.InteractionId +
          '_' +
          attendee.UserId +
          '_' +
          attendee.Conversation_Sid__c;
      }
      when 'Customer' {
        uniqueKey =
          attendee.InteractionId +
          '_' +
          attendee.ContactId +
          '_' +
          attendee.Conversation_Sid__c;
      }
      when 'External' {
        uniqueKey =
          attendee.InteractionId +
          '_' +
          attendee.Attendee_Phone__c +
          '_' +
          attendee.Conversation_Sid__c;
      }
    }
    return uniqueKey;
  }
}
