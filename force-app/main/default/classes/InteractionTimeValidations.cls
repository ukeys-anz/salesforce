/**
 * @author Adam Smith
 * @since 20220627
 * @description  Class to Check if interactions overlap.
 */
public with sharing class InteractionTimeValidations {
  /** @description Method to identify if the customer has any existing interactions at the same time.
   * @param accountInteractionMap Map of account id and the existing list of scheduled interactions
   * @param leadInteractionMap Map of lead id and the existing list of scheduled interactions
   * @param interactions list of new interactions created.
   */
  public static void validateOverlappingInteractions(
    Map<Id, List<Interaction>> accountInteractionMap,
    Map<Id, List<Interaction>> leadInteractionMap,
    List<Interaction> interactions
  ) {
    Set<Id> customersWithExistingInteractions = new Set<Id>();
    for (Interaction interact : interactions) {
      List<Interaction> customersInteractions = new List<Interaction>();

      if (accountInteractionMap.containsKey(interact.AccountId)) {
        customersInteractions.addAll(
          accountInteractionMap.get(interact.AccountId)
        );
      }
      if (leadInteractionMap.containsKey(interact.Lead__c)) {
        customersInteractions.addAll(leadInteractionMap.get(interact.Lead__c));
      }
      if (!customersInteractions.isEmpty()) {
        Interaction existingInteraction = getInteractionAtSameTime(
          interact,
          customersInteractions
        );
        Boolean existingInteractionAvailable = existingInteraction != null;
        if (existingInteractionAvailable) {
          if (!String.isEmpty(interact.ContactRequestId__c)) {
            interact.addError(
              System.Label.Interaction_User_Created_Error_Message +
              existingInteraction.Interaction_External_Id__c
            );
          } else {
            interact.addError(
              System.Label.Interaction_Coach_Created_Error_Message
            );
          }
        }
      }
    }
  }

  /** @description Method to loop through list of existing interactions to identify if there are any overlaps
   * @param newinteraction The new interaction record created
   * @param interactions list of existing interactions for the customer
   * @return Boolean Returns true or false if there are conflicting
   */
  public static Boolean verifyTimeSlots(
    Interaction newinteraction,
    List<Interaction> interactions
  ) {
    Boolean existingInteractionAvailable = false;
    existingInteractionAvailable =
      getInteractionAtSameTime(newinteraction, interactions) != null;
    return existingInteractionAvailable;
  }

  /** @description Method to loop through list of existing interactions to identify if there are any overlaps
   * @param newInteraction The new interaction record created
   * @param interactions list of existing interactions for the customer
   * @return Interaction Returns the conflicting interaction if one exists or null
   */
  public static Interaction getInteractionAtSameTime(
    Interaction newInteraction,
    List<Interaction> interactions
  ) {
    for (Interaction interact : interactions) {
      Boolean doDatesIntersect = Lib_SystemLog.doPeriodsIntersect(
        newInteraction.StartTime,
        newInteraction.EndTime,
        interact.StartTime,
        interact.EndTime
      );
      if (doDatesIntersect && interact.Id != newInteraction.Id) {
        return interact;
      }
    }
    return null;
  }

  /** @description Method to identify if the coach has any existing interactions at the same time.
   * @param existingCoachInteractions  Map of owner id and the existing list of scheduled interactions
   * @param interactions list of new interactions created.
   */
  public static void validateOverlappingCoachInteractions(
    Map<Id, List<Interaction>> existingCoachInteractions,
    List<Interaction> interactions
  ) {
    for (Interaction interact : interactions) {
      Boolean hasOwnerExistingInteractions = existingCoachInteractions.containsKey(
        interact.OwnerId
      );
      if (hasOwnerExistingInteractions) {
        Boolean existingInteractionAvailable = InteractionTimeValidations.verifyTimeSlots(
          interact,
          existingCoachInteractions.get(interact.OwnerId)
        );
        if (existingInteractionAvailable) {
          interact.addError(
            System.Label.Coach_Existing_Interaction_Error_Message
          );
        }
      }
    }
  }
}
