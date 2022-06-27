/**
 * @author Adam Smith
 * @since 20220411
 * @description  Class to help DML Operations for Interactions
 */
public with sharing class InteractionDMLHelper {
  /**
   * @description Method to update the interactions record
   * @param interactions The list of interactions to be updated
   */
  public static void updateInteractions(List<Interaction> interactions) {
    if (PermissionUtils.canUpdate('Interaction')) {
      List<Database.SaveResult> results = Database.Update(interactions);
      lib_systemLog log = new lib_systemLog(
        'InteractionsDMLHelper',
        'updateInteractions'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Interaction',
        results,
        interactions
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionsDMLHelper',
        'updateInteractions',
        'Not enough permissions to update Interactions.'
      );
    }
  }

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

  /**
   * @description Get the list of contact requests of those interactions which are cancelled
   * @param interactions The list of interactions which were cancelled
   * @return List<ContactRequest> List of ContactRequest records related to the interaction which were cancelled.
   */
  public static List<ContactRequest> getRelatedContactRequest(
    List<Interaction> interactions
  ) {
    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    Set<Id> contactRequestIds = new Set<Id>();
    for (Interaction interact : interactions) {
      contactRequestIds.add(interact.ContactRequestId__c);
    }

    if (ContactRequest.SObjectType.getDescribe().isQueryable()) {
      contactRequestList = [
        SELECT Id, Appointment_Commitment__c
        FROM ContactRequest
        WHERE ID IN :contactRequestIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionDMLHelper',
        'getRelatedContactRequest',
        'Not enough permissions to query Contact Request.'
      );
    }
    return contactRequestList;
  }

  /**
   * @description gets a map of Account Id and a List of the Interactions
   * @param accountIds Set of Account Ids
   * @return Map<Id, List<Interaction>> map of Account Id and a List of the Interactions
   */
  public static Map<Id, List<Interaction>> getAccountInteractionMap(
    Set<Id> accountIds
  ) {
    Map<Id, List<Interaction>> accountInteractionMap = new Map<Id, List<Interaction>>();
    List<Interaction> interactionsForAccounts = existingUniqueInteractions(
      accountIds
    );
    for (Interaction interact : interactionsForAccounts) {
      List<Interaction> tempInteractionList = new List<Interaction>();
      if (accountInteractionMap.containsKey(interact.AccountId)) {
        tempInteractionList = accountInteractionMap.get(interact.AccountId);
      }
      tempInteractionList.add(interact);
      accountInteractionMap.put(interact.AccountId, tempInteractionList);
    }
    return accountInteractionMap;
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
   * @description gets interactions related to a set of Ids
   * @param leadIds Set of Ids to search
   * @return List<Interaction> resultant list of interactions
   */
  public static List<Interaction> getInteractionsByLead(Set<Id> leadIds) {
    List<Interaction> interactionsForLeads = new List<Interaction>();
    if (PermissionUtils.canQuery('Interaction')) {
      interactionsForLeads = [
        SELECT
          Id,
          Lead__c,
          StartTime,
          Endtime,
          OwnerId,
          Interaction_External_Id__c
        FROM Interaction
        WHERE
          Lead__c IN :leadIds
          AND Status__c IN :InteractionConstants.UNIQUE_STATUSES
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'existingInteractions',
        'Not enough permissions to query Interaction object.'
      );
    }
    return interactionsForLeads;
  }

  /**
   * @description does the database call to insert Interactions
   * @param interactions List<Interaction> list of interactions.
   */
  public static void insertInteractions(List<Interaction> interactions) {
    if (PermissionUtils.canCreate('Interaction')) {
      List<Database.SaveResult> results = Database.Insert(interactions);
      lib_systemLog log = new lib_systemLog(
        'InteractionDMLHelper',
        'insertInteractions'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Interaction',
        results,
        interactions
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionDMLHelper',
        'insertInteractions',
        'Not enough permissions to create Interactions.'
      );
    }
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
}
