/**
 * @author       : Advait Yermalkar
 * @since        : 06-28-2024
 * @description  : This class containspublic repository for all queries used in InteractionCEController
 **/
public with sharing class CCRMInteractionActionsRepository {
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
}
