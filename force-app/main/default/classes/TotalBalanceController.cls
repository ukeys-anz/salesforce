/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TotalBalanceController is the apex side controller for the totalBalance LWC
 */
public with sharing class TotalBalanceController {
  /**
   * @description The total balance component uses this to fetch the records to display.
   *
   * @param ownerId the id of the owner of the financial account
   * @return AggregateResult
   */
  @AuraEnabled
  public static AggregateResult getTotalBalance(Id ownerId) {
    AggregateResult totalBalance;
    if (
      FeatureManagement.checkPermission('ANZx_Accounts_and_Goals') &&
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable()
    ) {
      List<String> listOfAccountNumbers = FinancialAccountUtil.getAllAccountNumberFromFAR(
        ownerId
      );
      Id savingsRecordType = GetHelpConstants.SAVINGS_ACCOUNT_RT_ID;
      Id checkingRecordType = GetHelpConstants.CHECKING_ACCOUNT_RT_ID;

      String financialAccountQuery =
        'SELECT SUM(FinServ__Balance__c) totalBalance FROM FinServ__FinancialAccount__c' +
        ' WHERE FinServ__Balance__c != NULL AND FinServ__FinancialAccountNumber__c =: listOfAccountNumbers AND ' +
        '(RecordTypeId = :savingsRecordType OR RecordTypeId = :checkingRecordType) AND ' +
        '(FinServ__Status__c IN (\'Active\',\'Open\'))';

      if (System.Label.S2AccountEnabled.toLowerCase() == 'false') {
        financialAccountQuery += ' AND Marketing_Code__c != \'SAVING02\'';
      }

      totalBalance = (AggregateResult) Database.query(financialAccountQuery);
    }
    return totalBalance;
  }

  /**
   * @description The total balance component uses this to fetch the records to display.
   *
   * @param ownerId the id of the owner of the financial account
   * @return AggregateResult
   */
  @AuraEnabled
  public static AggregateResult getTotalSaved(Id ownerId) {
    AggregateResult totalSaved;
    if (
      FeatureManagement.checkPermission('ANZx_Accounts_and_Goals') &&
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable()
    ) {
      List<String> listOfAccountNumbers = FinancialAccountUtil.getAllAccountNumberFromFAR(
        ownerId
      );
      Id savingsRecordType = GetHelpConstants.SAVINGS_ACCOUNT_RT_ID;

      String financialAccountQuery =
        'SELECT SUM(FinServ__Balance__c) totalSaved FROM FinServ__FinancialAccount__c' +
        ' WHERE FinServ__Balance__c != NULL AND FinServ__FinancialAccountNumber__c =: listOfAccountNumbers AND ' +
        'RecordTypeId = :savingsRecordType AND ' +
        '(FinServ__Status__c IN (\'Active\',\'Open\'))';

      if (System.Label.S2AccountEnabled.toLowerCase() == 'false') {
        financialAccountQuery += ' AND Marketing_Code__c != \'SAVING02\'';
      }

      totalSaved = (AggregateResult) Database.query(financialAccountQuery);
    }

    return totalSaved;
  }
}
