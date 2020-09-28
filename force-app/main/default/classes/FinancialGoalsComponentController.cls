/**
 * @author Peter Charalambous
 * @since 2020
 * @description FinancialGoalsComponentController is the apex side controller for the financialGoal LWC
 */
public with sharing class FinancialGoalsComponentController {
  /**
   * @description The FinancialGoals component uses this to fetch the in progress goals to display.
   *
   * @param ownerId the id of the owner of the financial goal
   * @param status the status of the goals to retrieve
   * @param recordLimit the amount of records to retrieve
   * @return List<FinServ__FinancialGoal__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialGoal__c> getFinancialGoals(
    String ownerId,
    String status,
    Integer recordLimit
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
          Recommended_Savings_Amount__c,
          FinServ__CompletionDate__c,
          Icon__c,
          LastModifiedDate
        FROM FinServ__FinancialGoal__c
        WHERE
          FinServ__PrimaryOwner__c = :ownerId
          AND FinServ__Status__c = :status
        ORDER BY Start_Date__c DESC
        LIMIT :recordLimit
      ];
    }

    if (financialGoals.isEmpty()) {
      return null;
    }

    return financialGoals;
  }
}
