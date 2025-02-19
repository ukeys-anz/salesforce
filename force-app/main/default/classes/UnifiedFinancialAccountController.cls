/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description UnifiedFinancialAccountController retrieves financial account details ,add metadata values and group records for LWC
 */
public with sharing class UnifiedFinancialAccountController {
  private static final FinancialAccountRepository FINACC_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );
  public static final String MISSING_FIN_ACCOUNT = 'Failed to retrieve latest account information. Please refresh and try again. If issue persists please contact your System Administrator';

  /**
   * @description This method is an orchestration layer for retrieving financial accounts, grouped accounts , add metadata values and sort grouped records
   *
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return Grouped Financial Accounts based on product code.
   */
  @AuraEnabled
  public static Map<String, Object> fetchAllFinancialAccounts(
    String ocvId,
    List<String> accountNumbers
  ) {
    try {
      List<UnifiedFinancialAccountModel.AccountList> fabricAccountList = getUnifiedAccountFabric(
        ocvId,
        accountNumbers
      );

      List<UnifiedFinancialAccountModel.AccountList> enrichedFinancialAccounts = UnifiedFinancialAccountAction.enrichWithSalesforceData(
        fabricAccountList
      );

      List<UnifiedFinancialAccountModel.AccountList> homeloanaccounts = filterOutNonHomeLoanAccounts(
        enrichedFinancialAccounts
      );
      DataPartitionUtil.storeLoanAccountDetailsCache(
        ocvId,
        filterOutNonHomeLoanAccounts(homeloanaccounts)
      );

      return groupAndSortFinancialAccounts(enrichedFinancialAccounts);
    } catch (Exception e) {
      throw CommonUtil.logAuraException(MISSING_FIN_ACCOUNT);
    }
  }

  /**
   * @description This method is an orchestration layer for retrieving financial accounts from database and then group accounts , add metadata values and sort grouped records
   * Also, fetching the homeloan accounts from the Cache
   * @param ocvId The ocv id of the customer
   * @param ownerId The record id of the customer / primary owner of the financial accounts
   * @param recordTypeDeveloperNames the record type names for which financial accounts are retrieved from database
   * @return Grouped Financial Accounts based on product code.
   */
  @AuraEnabled
  public static Map<String, Object> fetchAllFinancialAccountsDB(
    String ocvId,
    Id ownerId,
    List<String> recordTypeDeveloperNames
  ) {
    try {
      List<UnifiedFinancialAccountModel.AccountList> combinedFinancialAccountList = new List<UnifiedFinancialAccountModel.AccountList>();
      List<UnifiedFinancialAccountModel.AccountList> homeLoanAccountDetailsCache = DataPartitionUtil.getLoanAccountDetailsCache(
        ocvId
      );
      List<UnifiedFinancialAccountModel.AccountList> financialAccountsFromDatabase = UnifiedFinancialAccountAction.getFinancialAccountDB(
        ownerId,
        recordTypeDeveloperNames
      );
      if (
        homeLoanAccountDetailsCache != null &&
        !homeLoanAccountDetailsCache.isEmpty()
      ) {
        combinedFinancialAccountList.addAll(homeLoanAccountDetailsCache);
      }
      if (
        financialAccountsFromDatabase != null &&
        !financialAccountsFromDatabase.isEmpty()
      ) {
        combinedFinancialAccountList.addAll(financialAccountsFromDatabase);
      }
      return groupAndSortFinancialAccounts(combinedFinancialAccountList);
    } catch (Exception e) {
      throw CommonUtil.logAuraException(MISSING_FIN_ACCOUNT);
    }
  }

  /**
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   *
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return list of financial accounts received from fabric
   */

  private static List<UnifiedFinancialAccountModel.AccountList> getUnifiedAccountFabric(
    String ocvId,
    List<String> accountNumbers
  ) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    UnifiedFinancialAccountModel result = coachapi.getFinancialAccounts(
      ocvId,
      accountNumbers
    );
    return result.accounts;
  }

  /**
   * @description roups financial accounts by product code and sorts them
   * @param enrichedFinancialAccounts List of financial accounts with updated information.
   * @return A map of grouped and sorted financial accounts by product code.
   */
  private static Map<String, Object> groupAndSortFinancialAccounts(
    List<UnifiedFinancialAccountModel.AccountList> enrichedFinancialAccounts
  ) {
    if (
      enrichedFinancialAccounts == null || enrichedFinancialAccounts.isEmpty()
    ) {
      return new Map<String, Object>();
    }

    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = UnifiedFinancialAccountHelper.groupByProductCode(
      enrichedFinancialAccounts
    );
    return UnifiedFinancialAccountHelper.processMetadataAndBuildResponse(
      groupedAccounts
    );
  }

  /**
   * @description Filters and returns only Home Loan accounts based on the product code
   * @param financialAccountFrabric List of all accounts to be filtered.
   * @return A list of Home Loan accounts.
   */
  private static List<UnifiedFinancialAccountModel.AccountList> filterOutNonHomeLoanAccounts(
    List<UnifiedFinancialAccountModel.AccountList> financialAccountFrabric
  ) {
    Map<String, FinancialAccountUIConfiguration__mdt> mapOfProductCodeWithFinUIConfig = FINACC_REPOSITORY.mapProductCodeToFinAccounDetails();
    List<UnifiedFinancialAccountModel.AccountList> homeLoanAccounts = new List<UnifiedFinancialAccountModel.AccountList>();
    for (
      UnifiedFinancialAccountModel.AccountList acc : financialAccountFrabric
    ) {
      if (
        mapOfProductCodeWithFinUIConfig.get(acc.product_details?.marketing_code)
          ?.Account_Type__c == 'Loan'
      ) {
        homeLoanAccounts.add(acc);
      }
    }
    return homeLoanAccounts;
  }
}
