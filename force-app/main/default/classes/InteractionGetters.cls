/**
 * @author Adam Smith
 * @since 20220628
 * @description Class to query for Interactions
 */
public with sharing class InteractionGetters {
  /**
   * @description gets Interactions
   * @param interactionIds List of Ids of the interactions you wish to return
   * @return List<Interaction> List of Interactions
   */
  public static List<Interaction> getInteractions(Set<Id> interactionIds) {
    List<Interaction> interactions = new List<Interaction>();
    if (Interaction.SObjectType.getDescribe().isQueryable()) {
      interactions = [
        SELECT Id, Interaction_External_Id__c, Interaction_Auto_Number__c
        FROM Interaction
        WHERE Id IN :interactionIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionDMLHelper',
        'getInteractions',
        'Not enough permissions to query Interaction.'
      );
    }
    return interactions;
  }

  /** @description Method to get the list of existing scheduled interactions for the customer
   * @param relatedIds Set of account, owner, and lead ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of account ids and list of scheduled interactions creared for the customer
   */
  public static List<Interaction> existingUniqueInteractions(
    Set<Id> relatedIds
  ) {
    List<Interaction> interactionsForAccounts = new List<Interaction>();
    if (PermissionUtils.canQuery('Interaction')) {
      interactionsForAccounts = [
        SELECT
          Id,
          AccountId,
          StartTime,
          Endtime,
          OwnerId,
          Interaction_External_Id__c
        FROM Interaction
        WHERE
          (AccountId IN :relatedIds
          OR Lead__c IN :relatedIds
          OR OwnerId IN :relatedIds)
          AND Status__c IN :InteractionConstants.UNIQUE_STATUSES
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'existingInteractions',
        'Not enough permissions to query Interaction object.'
      );
    }
    return interactionsForAccounts;
  }

  /**
   * @description gets all interactions for leads and contacts
   * @param whoIds list of WhoIds
   * @return List of Interactions
   */
  public static List<Interaction> getInteractionsForLeadsAndContacts(
    Set<Id> whoIds
  ) {
    List<Interaction> interactions = new List<Interaction>();
    if (PermissionUtils.canQuery('Interaction')) {
      interactions = [
        SELECT
          Id,
          StartTime,
          EndTime,
          Interaction_External_Id__c,
          AccountId,
          Lead__c
        FROM Interaction
        WHERE AccountId IN :whoIds OR Lead__c IN :whoIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'existingInteractions',
        'Not enough permissions to query Interaction object.'
      );
    }
    return interactions;
  }

  /**
   * @description gets cancelled interactions
   * @param interactionIds Set of InteractionIds
   * @return List<Interaction> Cancelled interactions
   */
  public static List<Interaction> getCancelledInteractions(
    Set<Id> interactionIds
  ) {
    List<Interaction> interactions = new List<Interaction>();
    if (PermissionUtils.canQuery('Interaction')) {
      interactions = [
        SELECT Id, Status__c
        FROM Interaction
        WHERE
          Id IN :interactionIds
          AND Status__c != :InteractionConstants.CANCELLED
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'getCancelledInteractions',
        'Not enough permissions to query Interaction object.'
      );
    }
    return interactions;
  }
}
