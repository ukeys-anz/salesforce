/**
 * @author Adam Smith
 * @since 20220627
 * @description Methods for validating Interactions
 */
public with sharing class InteractionValidations {
  /** @description Loop through list of new interactions and validate the data.
   * @param interactions New interaction records to be created.
   */
  public static void validateInteractions(List<Interaction> interactions) {
    Set<Id> accountIds = new Set<Id>();
    Set<Id> leadIds = new Set<Id>();
    for (Interaction interact : interactions) {
      if (interact.AccountId != null) {
        accountIds.add(interact.AccountId);
      }
      if (interact.Lead__c != null) {
        leadIds.add(interact.Lead__c);
      }
    }
    Map<Id, List<Interaction>> accountInteractionMap = InteractionDMLHelper.getAccountInteractionMap(
      accountIds
    );
    Map<Id, List<Interaction>> leadInteractionMap = existingLeadInteractions(
      leadIds
    );
    InteractionTimeValidations.validateOverlappingInteractions(
      accountInteractionMap,
      leadInteractionMap,
      interactions
    );

    validateLocations(interactions);
  }

  /**
   * @description goes through a list of interactions and adds an error if any have a channel of store, but no location
   * @param interactions List<Interaction> to search through for offenders.
   */
  public static void validateLocations(List<Interaction> interactions) {
    for (Interaction currentInteraction : interactions) {
      if (
        currentInteraction.InteractionType == 'Store' &&
        currentInteraction.LocationId == null
      ) {
        currentInteraction.addError(System.Label.Interaction_Store_Required);
      }
    }
  }

  /** @description Method to validate if the coach has an existing appointment while accepting a new one
   * @param interactions List of new interactions accepted by the coach
   */
  public static void validateCoachAssignment(List<Interaction> interactions) {
    Set<Id> coachIds = new Set<Id>();
    for (Interaction interact : interactions) {
      coachIds.add(interact.OwnerId);
    }

    Map<Id, List<Interaction>> existingCoachInteractions = new Map<Id, List<Interaction>>();
    existingCoachInteractions = getCoachExistingInteractions(coachIds);
    InteractionTimeValidations.validateOverlappingCoachInteractions(
      existingCoachInteractions,
      interactions
    );
  }

  /** @description Method to get the list of existing scheduled interactions for the lead
   * @param leadIds Set of lead ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of lead ids and list of scheduled interactions creared for the customer
   */
  public static Map<Id, List<Interaction>> existingLeadInteractions(
    Set<Id> leadIds
  ) {
    Map<Id, List<Interaction>> leadInteractionMap = new Map<Id, List<Interaction>>();
    List<Interaction> interactionsForLeads = InteractionDMLHelper.getInteractionsByLead(
      leadIds
    );

    for (Interaction interact : interactionsForLeads) {
      List<Interaction> tempInteractionList = new List<Interaction>();
      if (leadInteractionMap.containsKey(interact.Lead__c)) {
        tempInteractionList = leadInteractionMap.get(interact.Lead__c);
      }
      tempInteractionList.add(interact);
      leadInteractionMap.put(interact.Lead__c, tempInteractionList);
    }
    return leadInteractionMap;
  }

  /** @description Method to get the list of existing scheduled interactions for the coach
   * @param coachIds Set of coach ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of owner ids and list of scheduled interactions creared for the corresponding coach
   */
  public static Map<Id, List<Interaction>> getCoachExistingInteractions(
    Set<Id> coachIds
  ) {
    Map<Id, List<Interaction>> coachInteractionsMap = new Map<Id, List<Interaction>>();
    List<Interaction> coachInteractions = InteractionGetters.existingUniqueInteractions(
      coachIds
    );
    for (Interaction interact : coachInteractions) {
      List<Interaction> tempInteractionList = new List<Interaction>();
      if (coachInteractionsMap.containsKey(interact.OwnerId)) {
        tempInteractionList = coachInteractionsMap.get(interact.OwnerId);
      }
      tempInteractionList.add(interact);
      coachInteractionsMap.put(interact.OwnerId, tempInteractionList);
    }
    return coachInteractionsMap;
  }
}
