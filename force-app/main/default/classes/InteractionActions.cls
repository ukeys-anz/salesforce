/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Interaction Actions
 * Adding suppression for Excessive Public Count as tech debt to be resolved
 * later in the Epic's development as per request.
 */
public with sharing class InteractionActions {
  /**
   * @description goes through a list of interactions and returns the ones that have been cancelled.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of cancelled interactions
   */
  public List<Interaction> findCancelledInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    return InteractionComparisonHelper.findCancelledInteractions(
      oldMap,
      interactions
    );
  }

  /**
   * @description Goes through a list of Interactions and using an old map, finds the one that ownership has changed.
   * @param oldMap Map<Id, SObject> map of old versions of the interactions
   * @param records List<Interaction> list of the interaction through which to iterate.
   * @return List<Interaction> list of interaction that have had their ownership changed.
   */
  public List<Interaction> findInteractionsOwnershipChanged(
    Map<Id, SObject> oldMap,
    List<Interaction> records
  ) {
    return InteractionComparisonHelper.findInteractionsOwnershipChanged(
      oldMap,
      records
    );
  }

  /**
   * @description Goes through a list of Interactions and assigns the current owner of interaction to the coaching summary.
   * @param interactions List<Interaction> list of the interaction through which to iterate.
   * @return List<Coaching_Summary> list of coaching summary records updated with new owner.
   */
  public List<Coaching_Summary__c> assignCoachingSummaryOwner(
    List<Interaction> interactions
  ) {
    List<Coaching_Summary__c> coachingSummaryList = new List<Coaching_Summary__c>();
    for (Interaction interact : interactions) {
      Coaching_Summary__c coachSummary = new Coaching_Summary__c(
        Id = interact.Coaching_Summary__c
      );
      coachSummary.OwnerId = interact.OwnerId;
      coachingSummaryList.add(coachSummary);
    }
    return coachingSummaryList;
  }

  /**
   * @description Method to updated interactions without end time
   * @param interactions List<Interaction> list of interaction records without end time.
   */
  public void updateEndTime(List<Interaction> interactions) {
    ContactRequestActions crActions = new ContactRequestActions();
    for (Interaction interact : interactions) {
      Integer duration = interact.Interaction_Purpose__c != null
        ? crActions.getDuration(interact.Interaction_Purpose__c)
        : 0;
      interact.EndTime = interact.StartTime != null
        ? interact.StartTime.addMinutes(duration)
        : null;
    }
  }

  /**
   * @description Gets the list of interactions and returns the ones where the reason or starttime has been updated.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of interactions where end time needs to be updated.
   */
  public List<Interaction> getInteractionsRequiringEndTimeUpdate(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> interactionList = new List<Interaction>();

    for (Interaction interact : interactions) {
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        oldInteraction.Interaction_Purpose__c !=
        interact.Interaction_Purpose__c ||
        oldInteraction.StartTime != interact.StartTime
      ) {
        interactionList.add(interact);
      }
    }
    return interactionList;
  }

  /**
   * @description goes through a list of Interactions and if they have moved status to unassigned set the owner to the queue
   * @param oldMap Map<Id,SObject> old map of interactions
   * @param records List<Interaction> list of interactions of which to search
   * @return List<Interaction> interactions that have been updated
   */
  public List<Interaction> unassignInteractions(
    Map<Id, sObject> oldMap,
    List<Interaction> records
  ) {
    Id groupId = CommonUtil.getGroupId(InteractionConstants.APPOINTMENTS_QUEUE);
    List<Interaction> results = new List<Interaction>();
    for (Interaction currentInteraction : records) {
      if (
        InteractionComparisonHelper.hasBeenUnassigned(
          oldMap,
          currentInteraction
        )
      ) {
        continue;
      }

      Interaction oldInteraction = (Interaction) oldMap.get(
        currentInteraction.Id
      );

      if (oldInteraction.Status__c == InteractionConstants.UNASSIGNED_STATUS) {
        continue;
      }

      currentInteraction.OwnerId = groupId;
      results.add(currentInteraction);
    }
    return results;
  }

  /**
   * @description gets accounts related to an list of interactions in a map.
   * @param interactions List<Interaction> interactions for which to get the accounts
   * @return Map<Id,Account> map of accounts.
   */
  public Map<Id, Account> getAccountMapFromInteractions(
    List<Interaction> interactions
  ) {
    Map<Id, Account> result = new Map<Id, Account>();

    Set<Id> accountIds = new Set<Id>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        accountIds.add(currentInteraction.AccountId);
      }
    }
    if (!accountIds.isEmpty()) {
      AccountQueryHelper accountHelper = new AccountQueryHelper();
      result = new Map<Id, Account>(
        accountHelper.findAccountsByAccountIds(accountIds)
      );
    }
    return result;
  }

  /**
   * @description gets leads related to a list of interactions in a map.
   * @param interactions List<Interaction> interactions for which to get the leads
   * @return Map<Id,Lead> map of leads.
   */
  public Map<Id, Lead> getLeadMapFromInteractions(
    List<Interaction> interactions
  ) {
    Map<Id, Lead> result = new Map<Id, Lead>();

    Set<Id> leadIds = new Set<Id>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        if (currentInteraction.Lead__c != null) {
          leadIds.add(currentInteraction.Lead__c);
        }
      }
    }
    if (!leadIds.isEmpty()) {
      result = LeadDMLHelper.getLeadInfoMap(leadIds);
    }
    return result;
  }

  /**
   * @description deletes events linked to a list of interactions
   * @param interactions List of interactions to search through and delete related events.
   */
  public void deleteInteractionEvents(List<Interaction> interactions) {
    InteractionEventHelper.deleteInteractionEvents(interactions);
  }

  /** @description Method to get the list of existing scheduled interactions for the coach
   * @param coachIds Set of coach ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of owner ids and list of scheduled interactions creared for the corresponding coach
   */
  public Map<Id, List<Interaction>> getCoachExistingInteractions(
    Set<Id> coachIds
  ) {
    return InteractionValidations.getCoachExistingInteractions(coachIds);
  }
}
