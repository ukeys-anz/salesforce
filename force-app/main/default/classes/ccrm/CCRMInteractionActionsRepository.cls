/**
 * @author       : Advait Yermalkar
 * @since        : 06-28-2024
 * @description  : This class containspublic repository for all queries used in InteractionCEController
 **/
public with sharing class CCRMInteractionActionsRepository {
  private static final String CLG = 'Customer Lending Group';
  /**
   * @description get Customers data based on Ids
   * @param relatedCustomerIds
   * @return List<Account>
   **/
  public List<Account> getCustomers(Set<id> relatedCustomerIds) {
    if (relatedCustomerIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Name, Source_System_ID__c, Source_System_Name__c, OCV_ID__c
      FROM Account
      WHERE Id IN :relatedCustomerIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get Opportunities records based on Ids
   * @param relatedOppIds
   * @return List<Opportunity>
   **/
  public List<Opportunity> getOpportunities(Set<Id> relatedOppIds) {
    if (relatedOppIds.isEmpty()) {
      return new List<Opportunity>();
    }
    return [
      SELECT Id, Opp_Id__c, AccountId
      FROM Opportunity
      WHERE Id IN :relatedOppIds
      WITH USER_MODE
    ];
  }

  /**
   * @description
   * @param relatedFinAccountIds
   * @return List<FinServ__FinancialAccount__c>
   **/
  public List<FinServ__FinancialAccount__c> getFinAccounts(
    Set<Id> relatedFinAccountIds
  ) {
    if (relatedFinAccountIds.isEmpty()) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT
        Id,
        Name,
        FinServ__FinancialAccountNumber__c,
        FinServ__FinancialAccountType__c,
        Product_Code_Display__c,
        Branch_Code__c
      FROM FinServ__FinancialAccount__c
      WHERE Id IN :relatedFinAccountIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get the user records based on Ids
   * @param relatedUserIds
   * @return List<User>
   **/
  public List<User> getUsers(Set<Id> relatedUserIds) {
    if (relatedUserIds.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Email, UserName, Lan_Id__c
      FROM User
      WHERE Id IN :relatedUserIds
      WITH USER_MODE
    ];
  }

  /**
   * @description to query account account relationship records
   * @name getAccountAccountRelations
   * @param accountIdsSet set of Account Ids
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getRelatedCLGAccounts(
    Set<Id> accountIdsSet
  ) {
    if (accountIdsSet.isEmpty()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }

    return [
      SELECT
        Id,
        Name,
        Relationship__c,
        FinServ__Account__c,
        FinServ__Account__r.RecordTypeId,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.CLG__c,
        FinServ__RelatedAccount__r.CPID__c,
        FinServ__RelatedAccount__r.RecordTypeId,
        FinServ__RelatedAccount__r.Controlling_Post__r.OwnerId
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__c IN :accountIdsSet
        AND Relationship__c = :CLG
        AND FinServ__RelatedAccount__r.RecordTypeId = :RTAccount.clgAccount
      WITH USER_MODE
    ];
  }

  /**
   * @description To get a list of account with record types
   * @param accountIds
   * @return Map<Id, Account>
   */
  public Map<Id, Account> getAccountsWithRecordTypes(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new Map<Id, Account>();
    }

    return new Map<Id, Account>(
      [
        SELECT Id, RecordTypeId
        FROM Account
        WHERE Id IN :accountIds
        WITH USER_MODE
      ]
    );
  }
}
