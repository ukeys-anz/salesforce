/**
 * @author Peter Charalambous
 * @since December 2021
 * @description AccountBucketsController is the controller for the Buckets LWC
 */
public with sharing class AccountBucketsController {
  private static final FinancialAccountRepository FINACC_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );

  /**
   * @description  The getAccountBuckets(ocvId) is the method to make the Http callout to Mulesoft to fetch the accounts and goals details from Fabric.
   * @param ocvId Ocv id for which buckets needs to be fetched
   * @param pageSize The amount of buckets to return with the call
   * @param nextPageToken The token used to get the next page of data from the api
   * @param accountNumber accountNumber to fetch the goals for
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled
  public static AccountBucketsModel getAccountBuckets(
    String ocvId,
    Integer pageSize,
    String nextPageToken,
    String accountNumber
  ) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    AccountBucketsModel result = coachapi.getAccountBuckets(
      ocvId,
      pageSize,
      nextPageToken,
      accountNumber
    );

    if(String.isNotBlank(accountNumber))
    {
      return result;
    }
  
    List<FinServ__FinancialAccount__c> finanancialAccountList = FINACC_REPOSITORY.fetchFinancialAccountsByStatus(
        ocvId
    );
    
    if(finanancialAccountList.isEmpty())
    {
      return null;
    }

    Map<String,FinancialAccountUIConfiguration__mdt> productCodeToFinancialConfigMap = FINACC_REPOSITORY.mapProductCodeToFinAccountConfiguration();

    Map<String,FinancialAccountUIConfiguration__mdt> accountNumberToFinancialConfigMap = new Map<String,FinancialAccountUIConfiguration__mdt>();

    Map<String, FinServ__FinancialAccount__c> accountsToShowGoalsMap = fetchAccountsToShowGoals(finanancialAccountList,
    productCodeToFinancialConfigMap,
    accountNumberToFinancialConfigMap);

    return filterGoalsToShow(result,accountsToShowGoalsMap,accountNumberToFinancialConfigMap);
    
  }

   /**
   * @description this method will prepare map of financial accounts for which we need to show goals
   * @param finanancialAccountList list of failure actions
   * @param productCodeToFinancialConfigMap map of product code with the fin account configuration
   * @param accountNumberToFinancialConfigMap map of account number and fin accountconfiguration
   * @return Map<String, FinServ__FinancialAccount__c> map of account number and their details to show goals
   */
  private static Map<String, FinServ__FinancialAccount__c> fetchAccountsToShowGoals(
    List<FinServ__FinancialAccount__c> finanancialAccountList,
    Map<String,FinancialAccountUIConfiguration__mdt> productCodeToFinancialConfigMap,
    Map<String,FinancialAccountUIConfiguration__mdt> accountNumberToFinancialConfigMap
  )
  {
    Map<String, FinServ__FinancialAccount__c> accountsToShowGoalsMap = new Map<String, FinServ__FinancialAccount__c>();
    for(FinServ__FinancialAccount__c account : finanancialAccountList)
    {
      String key = account.FinServ__ProductName__r.ANZ_Product_Code__c+'-'+account.Ownership__c;
      if(!productCodeToFinancialConfigMap.containsKey(key) ||
      productCodeToFinancialConfigMap.get(key).Show_Goals__c) 
      {
        accountsToShowGoalsMap.put(account.FinServ__FinancialAccountNumber__c,account);
        accountNumberToFinancialConfigMap.put(account.FinServ__FinancialAccountNumber__c,productCodeToFinancialConfigMap.get(key));
      }
    }
    return accountsToShowGoalsMap;
  }

  /**
   * @description this method will prepare filtered response with goals
   * @param result AccountBucketsModel response from API Callout
   * @param accountsToShowGoalsMap map of account number and details for which we need to show goals
   * @param accountNumberToFinancialConfigMap map of account number and financial account details config data
   * @return AccountBucketsModel return final response with filtered goals
   */
  private static AccountBucketsModel filterGoalsToShow(AccountBucketsModel result , 
  Map<String, FinServ__FinancialAccount__c> accountsToShowGoalsMap,
  Map<String,FinancialAccountUIConfiguration__mdt> accountNumberToFinancialConfigMap){
    List<AccountBucketsModel.AccountBuckets> filteredAccountbuckets = new  List<AccountBucketsModel.AccountBuckets>();
    for(AccountBucketsModel.AccountBuckets  bucket : result.account_buckets)
    {
      if(accountsToShowGoalsMap.keyset().contains(bucket.account_number))
      {
        FinancialAccountUIConfiguration__mdt uiConfig = accountNumberToFinancialConfigMap.get(bucket.account_number);
        FinServ__FinancialAccount__c finAccount = accountsToShowGoalsMap.get(bucket.account_number);
        bucket.financial_account_name = finAccount.Name;
        bucket.ownershipType =finAccount.Ownership__c;
        bucket.financial_account_id = finAccount.Id;
        bucket.sortOrder = uiConfig?.Sort_Order__c;
        bucket.product_name = uiConfig?.Product_Name__c;
        bucket.header_title = uiConfig?.Section_Header_Title__c;
        bucket.balance_title = uiConfig?.Balance_Title__c;
        bucket.product_code = uiConfig?.Product_Code__c;
        filteredAccountbuckets.add(bucket);
      }
    }
    result.account_buckets = filteredAccountbuckets;
    return result;
  }
}