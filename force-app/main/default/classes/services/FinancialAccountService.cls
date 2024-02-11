/**
 * @author Shivam Swaraj
 * @since September 2023
 * @description Helper class for financial accounts DML operations.
 */
public with sharing class FinancialAccountService {
  /**
   * @description fetch financial accounts based on the financial account status
   * @param ocvId String containing reason to replace the card
   * @param statusList List of status to fetch the financial accounts
   * @return List<FinServ__FinancialAccount__c> List of FinancialAccounts based on status
   */
  public static List<FinServ__FinancialAccount__c> fetchFinancialAccountsByStatus(
    String ocvId,
    List<String> statusList
  ) {
    //fetching the financial account details which are not closed for the ocv id.
    List<FinServ__FinancialAccount__c> financialAccountList;
    String financialAccountQuery = 'SELECT FinServ__FinancialAccountNumber__c,Ownership__c, FinServ__Status__c from FinServ__FinancialAccount__c WHERE Id IN (Select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c WHERE FinServ__RelatedAccount__r.OCV_ID__c =:ocvId AND FinServ__Active__c =true)';

    if (statusList != null && !statusList.isEmpty()) {
      financialAccountQuery += ' AND FinServ__Status__c IN :statusList';
    }

    if (PermissionUtils.canQuery('FinServ__FinancialAccount__c')) {
      financialAccountList = Database.query(financialAccountQuery);
    }
    return financialAccountList;
  }

  /**
   * @description fetch financial accounts numbers list based on the financial account list received based on status
   * @param financialAccountList List of financial accounts filtered based on status
   * @return  List<String>  List of FinancialAccounts Account Number based on financial accounts list received.
   */
  public static Map<String, List<String>> getAccountNumbersByStatusMap(
    List<FinServ__FinancialAccount__c> financialAccountList
  ) {
    Map<String, List<String>> accountNumbersByStatusMap = new Map<String, List<String>>();

    //creating map of list of account numbers by status
    for (FinServ__FinancialAccount__c finAcc : financialAccountList) {
      if (!accountNumbersByStatusMap.containsKey(finAcc.FinServ__Status__c)) {
        accountNumbersByStatusMap.put(
          finAcc.FinServ__Status__c,
          new List<String>()
        );
      }
      accountNumbersByStatusMap.get(finAcc.FinServ__Status__c)
        .add(finAcc.FinServ__FinancialAccountNumber__c);
    }
    return accountNumbersByStatusMap;
  }
}
