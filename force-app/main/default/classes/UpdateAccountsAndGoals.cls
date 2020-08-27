/**
 * @author Peter Charalambous
 * @since 2020
 * @description UpdateAccountsAndGoals takes the accounts and goals data returned from API
 * and updates our SF records with the latest data
 */
public with sharing class UpdateAccountsAndGoals {
  /**
   * @description The AccountsAndGoalsRefresh component uses this to update the
   * accounts records based on the data returned from the API.
   *
   * @param ownerId the id of the owner of the financial account
   * @param accountNumbers the account numbers from the API
   * @param accountData the account data from the API
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> updateAccounts(
    Id ownerId,
    String[] accountNumbers,
    List<FinServ__FinancialAccount__c> accountData
  ) {
    List<FinServ__FinancialAccount__c> financialAccounts;
    if (FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable()) {
      financialAccounts = [
        SELECT
          Id,
          Name,
          FinServ__Balance__c,
          FinServ__CurrentPostedBalance__c,
          FinServ__FinancialAccountNumber__c
        FROM FinServ__FinancialAccount__c
        WHERE
          FinServ__PrimaryOwner__c = :ownerId
          AND FinServ__FinancialAccountNumber__c IN :accountNumbers
      ];
    }

    //Map the account data from the API with the account number as the key
    Map<String, FinServ__FinancialAccount__c> accountMap = new Map<String, FinServ__FinancialAccount__c>();
    for (FinServ__FinancialAccount__c a : accountData) {
      accountMap.put(a.FinServ__FinancialAccountNumber__c, a);
    }

    //Update the financial account details
    for (FinServ__FinancialAccount__c accnt : financialAccounts) {
      accnt.Name = accountMap.get(accnt.FinServ__FinancialAccountNumber__c)
        .Name;
      accnt.FinServ__Balance__c = accountMap.get(
          accnt.FinServ__FinancialAccountNumber__c
        )
        .FinServ__Balance__c;
      accnt.FinServ__CurrentPostedBalance__c = accountMap.get(
          accnt.FinServ__FinancialAccountNumber__c
        )
        .FinServ__CurrentPostedBalance__c;
    }

    if (FinServ__FinancialAccount__c.sObjectType.getDescribe().isUpdateable()) {
      update financialAccounts;
    }

    return financialAccounts;
  }

  @AuraEnabled
  /**
   * @description The AccountsAndGoalsRefresh component uses this to update the
   * goals records based on the data returned from the API.
   *
   * @param ownerId the id of the owner of the financial account
   * @param accountNumbers the account numbers from the API
   * @param goalData the goal data from the API
   * @return List<FinServ__FinancialAccount__c>
   */
  public static List<FinServ__FinancialGoal__c> updateGoals(
    Id ownerId,
    String[] accountNumbers,
    List<FinServ__FinancialGoal__c> goalData
  ) {
    List<FinServ__FinancialGoal__c> financialGoals;
    if (FinServ__FinancialGoal__c.sObjectType.getDescribe().isQueryable()) {
      financialGoals = [
        SELECT
          Id,
          Name,
          FinServ__TargetValue__c,
          FinServ__ActualValue__c,
          FinServ__TargetDate__c,
          Icon__c,
          Start_Date__c,
          Financial_Account_Number__c
        FROM FinServ__FinancialGoal__c
        WHERE
          FinServ__PrimaryOwner__c = :ownerId
          AND Financial_Account__r.FinServ__FinancialAccountNumber__c IN :accountNumbers
      ];
    }

    //Map the goal data from the API with the account number as the key
    Map<String, FinServ__FinancialGoal__c> goalMap = new Map<String, FinServ__FinancialGoal__c>();
    for (FinServ__FinancialGoal__c goal : goalData) {
      goalMap.put(goal.Financial_Account_Number__c, goal);
    }

    //Update the financial goal details
    for (FinServ__FinancialGoal__c goal : financialGoals) {
      goal.Name = goalMap.get(goal.Financial_Account_Number__c).Name;
      goal.FinServ__TargetValue__c = goalMap.get(
          goal.Financial_Account_Number__c
        )
        .FinServ__TargetValue__c;
      goal.FinServ__ActualValue__c = goalMap.get(
          goal.Financial_Account_Number__c
        )
        .FinServ__ActualValue__c;
      goal.Icon__c = goalMap.get(goal.Financial_Account_Number__c).Icon__c;
      goal.Start_Date__c = goalMap.get(goal.Financial_Account_Number__c)
        .Start_Date__c;
      goal.FinServ__TargetDate__c = goalMap.get(
          goal.Financial_Account_Number__c
        )
        .FinServ__TargetDate__c;
    }

    if (FinServ__FinancialGoal__c.sObjectType.getDescribe().isUpdateable()) {
      update financialGoals;
    }

    return financialGoals;
  }
}
