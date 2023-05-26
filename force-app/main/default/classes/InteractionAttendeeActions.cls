/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description class for Interaction Attendee Actions
 */

@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class InteractionAttendeeActions {
  public static final String DUPLICATE_ATTENDEE_ERROR = 'Error occurred while adding attendee. This attendee already exists for this interaction.';
  /**
   * @description Checks if attendee already exists on record
   * @param attendees list of new interaction attendees
   * @param oldAttendeesMap old interaction attendees map
   */
  public static void validateAttendees(
    List<InteractionAttendee> attendees,
    Map<Id, InteractionAttendee> oldAttendeesMap
  ) {
    Map<String, InteractionAttendee> newAttendeeMap = new Map<String, InteractionAttendee>();
    Map<Id, Set<Id>> interactionToAttendeeMap = new Map<Id, Set<Id>>();
    for (InteractionAttendee attendee : attendees) {
      // build map of attendees for addError()
      newAttendeeMap.put(
        (String) attendee.InteractionId + attendee.UserId,
        attendee
      );
      // build map of interaction id to user id set
      if (interactionToAttendeeMap.containsKey(attendee.InteractionId)) {
        interactionToAttendeeMap.get(attendee.InteractionId)
          .add(attendee.UserId);
      } else {
        interactionToAttendeeMap.put(
          attendee.InteractionId,
          new Set<Id>{ attendee.UserId }
        );
      }
    }
    for (InteractionAttendee existingAttendee : [
      SELECT InteractionId, UserId
      FROM InteractionAttendee
      WHERE InteractionId IN :interactionToAttendeeMap.keySet()
    ]) {
      if (
        interactionToAttendeeMap.get(existingAttendee.InteractionId)
          .contains(existingAttendee.UserId)
      ) {
        newAttendeeMap.get(
            (String) existingAttendee.InteractionId + existingAttendee.UserId
          )
          .addError(DUPLICATE_ATTENDEE_ERROR);
      }
    }
  }

  /**
   * @description Updates attendees in Interaction.Attendees_c and
   * Interaction.Attendees_and_Roles__c based off the updated
   * Interaction Attendee record
   * @param attendees list of interaction attendees
   * @param oldAttendeesMap old interaction attendees map
   */
  // Suppress warning - complexity is 15, which is the threshold
  @SuppressWarnings('PMD.CognitiveComplexity')
  public static void updateAttendees(
    List<InteractionAttendee> attendees,
    Map<Id, InteractionAttendee> oldAttendeesMap
  ) {
    Set<Id> interactionIds = new Set<Id>();
    // iterate through new interaction attendees and get interaction ids
    for (InteractionAttendee attendant : attendees) {
      interactionIds.add(attendant.InteractionId);
    }
    // get map of interaction id to records
    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>(
      [
        SELECT Id, Attendees_and_Roles__c, Attendees__c
        FROM Interaction
        WHERE Id IN :interactionIds
      ]
    );
    // get list of interactionattendee records with user details
    List<InteractionAttendee> attendeeList = [
      SELECT Id, InteractionId, UserId, User.UserRole.Name, User.Name
      FROM InteractionAttendee
      WHERE InteractionId IN :interactionIds
    ];
    Map<Id, String> userNameMap = new Map<Id, String>();
    for (InteractionAttendee attendant : attendeeList) {
      userNameMap.put(attendant.UserId, attendant.User.Name);
    }
    // for each interaction in the interactionmap
    for (Interaction interact : interactionMap.values()) {
      RoleMapping roleMappingInstance = new RoleMapping();
      // deserialize the attendees and roles field to above object if not empty
      if (String.IsNotEmpty(interact.Attendees_and_Roles__c)) {
        roleMappingInstance = (RoleMapping) JSON.deserialize(
          interact.Attendees_and_Roles__c,
          RoleMapping.class
        );
      } else {
        roleMappingInstance.userIdToDetails = new Map<Id, String>();
      }
      RoleMapping tmpInstance = new RoleMapping();
      tmpInstance.userIdToDetails = new Map<Id, String>();
      // for each attendee in the attendeelist
      for (InteractionAttendee attendant : attendeeList) {
        if (attendant.InteractionId != interact.Id) {
          continue;
        }
        String roleName = '';
        if (attendant.User.UserRole != null) {
          roleName = attendant.User.UserRole.Name;
        } else {
          Logger.error(
            'User ' +
            attendant.UserId +
            ' has no role in Salesforce.'
          );
        }
        if (Trigger.isAfter && Trigger.isInsert) {
          // add the attendee to the map
          roleMappingInstance.addAttendee(attendant.UserId, roleName);
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
          // update the attendee to the map
          InteractionAttendee oldAttendee = (InteractionAttendee) oldAttendeesMap.get(
            attendant.Id
          );
          if (oldAttendee != null) {
            // Null check since after update can be entered twice
            roleMappingInstance.deleteAttendee(oldAttendee.UserId);
            roleMappingInstance.addAttendee(attendant.UserId, roleName);
          }
        }
        if (Trigger.isAfter && Trigger.isDelete) {
          // remove the attendee to the map
          tmpInstance.addAttendee(
            attendant.UserId,
            roleMappingInstance.userIdToDetails.get(attendant.UserId)
          );
        }
      }
      if (Trigger.isDelete) {
        roleMappingInstance = tmpInstance;
      }
      // serialize the object
      interact.Attendees_and_Roles__c = JSON.serialize(roleMappingInstance);
      // print the roles to the
      interact.Attendees__c = roleMappingInstance.printAttendeeNames(
        userNameMap
      );
    }
    Logger.saveLog();
    // update the interaction map
    update interactionMap.values();
  }

  /**
   * @description Role Mapping Object
   */
  public with sharing class RoleMapping {
    public Map<Id, String> userIdToDetails;
    /**
     * @description Add attendee to RoleMap
     * @param userId Id of the new user
     * @param roleName role name of the new user
     */
    public void addAttendee(Id userId, String roleName) {
      this.userIdToDetails.put(userId, roleName);
    }

    /**
     * @description Remove attendee from RoleMap
     * @param userId Id of the new user
     */
    public void deleteAttendee(Id userId) {
      this.userIdToDetails.remove(userId);
    }

    /**
     * @description Print attendee and roles into a String
     * @return Attendees and roles in a string format
     */
    public String printAttendeeRoles() {
      String returnString = '';
      for (String roleName : userIdToDetails.values()) {
        if (String.isNotEmpty(roleName)) {
          returnString += roleName + ', ';
        }
      }
      return returnString.removeEnd(', ');
    }

    /**
     * @description Print attendee user names into a String
     * @param userNameMap user map that contains the id to name pairs
     * @return Attendees' name list into a String
     */
    public String printAttendeeNames(Map<Id, String> userNameMap) {
      String returnString = '';
      for (Id userId : userIdToDetails.keyset()) {
        returnString += userNameMap.get(userId) + ', ';
      }
      return returnString.removeEnd(', ');
    }
  }

  /**
   * @description Create interaction creator as interaction attendee for the newly created interactions.
   * @param interactions List of newly created interactions.
   */
  public static void insertDefaultAttendee(List<Interaction> interactions) {
    List<InteractionAttendee> lstInteractAttend = new List<InteractionAttendee>();
    for (interaction interact : interactions) {
      InteractionAttendee intattendee = new InteractionAttendee();
      intattendee.AttendeeType = InteractionConstants.INTERNAL;
      intattendee.UserId = UserInfo.getUserId();
      intattendee.InteractionId = interact.id;
      lstInteractAttend.add(intattendee);
    }
    DMLUtil.insertRecords(lstInteractAttend, false, true);
  }
}
