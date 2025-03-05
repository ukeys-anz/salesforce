/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description FinancialAccountControllerAction groups and sort the financial accounts
 */
public with sharing class FinancialAccountControllerAction {
  private static final FinancialAccountRepository FINANCIAL_ACCOUNT_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );
  private static final Integer DEFAULT_SORT_ORDER = 999;

  /**
   * @description Groups financial accounts based on product code .
   * @param finAccounts list of financial accounts received from fabric or database.
   * @return map of product code and list of financial accounts associated with that product code.
   */
  public static List<Map<String, Object>> processFinancialAccounts(
    List<UnifiedFinancialAccountModel.AccountList> finAccounts
  ) {
    List<FinancialAccountUIConfiguration__mdt> uiConfigDetails = FINANCIAL_ACCOUNT_REPOSITORY.fetchFinancialAccountUIConfigInfo();

    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap = (Map<String, FinancialAccountUIConfiguration__mdt>) ListUtil.mapBy(
      uiConfigDetails,
      FinancialAccountUIConfiguration__mdt.Product_Code__c
    );

    Map<String, Integer> tileSortOrderMap = new Map<String, Integer>();
    fetchSortingRules(uiConfigMap, tileSortOrderMap);

    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = groupAccounts(
      finAccounts,
      uiConfigMap
    );

    return sortAndFormatResponse(
      groupedAccounts,
      tileSortOrderMap,
      uiConfigMap
    );
  }

  private static void fetchSortingRules(
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap,
    Map<String, Integer> tileSortOrderMap
  ) {
    for (FinancialAccountUIConfiguration__mdt config : uiConfigMap.values()) {
      Integer sortOrder = config.Sort_Order__c.intValue() ?? DEFAULT_SORT_ORDER;

      tileSortOrderMap.put(config.Product_Code__c, sortOrder);
    }
  }

  private static Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupAccounts(
    List<UnifiedFinancialAccountModel.AccountList> finAccounts,
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap
  ) {
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = new Map<String, List<UnifiedFinancialAccountModel.AccountList>>();

    for (UnifiedFinancialAccountModel.AccountList account : finAccounts) {
      String productCode = account.product_details.marketing_code;
      FinancialAccountUIConfiguration__mdt uiConfig = uiConfigMap.get(
        productCode
      );

      if (uiConfig != null && !uiConfig.Is_Active__c) {
        continue;
      }

      if (!groupedAccounts.containsKey(productCode)) {
        groupedAccounts.put(
          productCode,
          new List<UnifiedFinancialAccountModel.AccountList>()
        );
      }

      groupedAccounts.get(productCode).add(account);
    }

    return groupedAccounts;
  }

  @TestVisible
  private static List<Map<String, Object>> sortAndFormatResponse(
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts,
    Map<String, Integer> tileSortOrderMap,
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap
  ) {
    List<Map<String, Object>> sortedGroups = new List<Map<String, Object>>();

    for (String productCode : groupedAccounts.keySet()) {
      FinancialAccountUIConfiguration__mdt uiConfig = uiConfigMap.get(
        productCode
      );

      Integer tileSortOrder = tileSortOrderMap.containsKey(productCode)
        ? tileSortOrderMap.get(productCode)
        : DEFAULT_SORT_ORDER;

      sortedGroups.add(
        prepareUIResponse(
          productCode,
          tileSortOrder,
          uiConfig,
          groupedAccounts.get(productCode)
        )
      );
    }

    sortedGroups.sort(new TileComparator());
    return sortedGroups;
  }

  private static Map<String, Object> prepareUIResponse(
    String productCode,
    Integer tileSortOrder,
    FinancialAccountUIConfiguration__mdt uiConfig,
    List<UnifiedFinancialAccountModel.AccountList> accounts
  ) {
    return new Map<String, Object>{
      'productCode' => productCode,
      'sortOrder' => tileSortOrder,
      'accountType' => uiConfig != null
        ? uiConfig.Account_Type__c
        : 'Non Savings',
      'balanceTitle' => uiConfig != null ? uiConfig.Balance_Title__c : '',
      'sectionHeaderTitle' => uiConfig != null
        ? uiConfig.Section_Header_Title__c
        : '',
      'accounts' => accounts,
      'isSaving' => uiConfig != null &&
      uiConfig.Account_Type__c == 'Savings',
      'isOthers' => uiConfig == null ||
      !(uiConfig.Account_Type__c == 'Savings' ||
      uiConfig.Account_Type__c == 'Loan'),
      'isHomeLoan' => uiConfig != null &&
      uiConfig.Account_Type__c == 'Loan'
    };
  }

  /**
   * @description This class implements the System.Comparator interface for sorting purposes.
   */
  public class TileComparator implements System.Comparator<Map<String, Object>> {
    /**
     * @description Compares two maps based on their "sortOrder" values.
     * @param firstMap the first map to compare
     * @param secondMap the second map to compare
     * @return a negative integer, zero, or a positive integer based on the "sortOrder" comparison
     */
    public Integer compare(
      Map<String, Object> firstMap,
      Map<String, Object> secondMap
    ) {
      return ((Integer) firstMap.get('sortOrder')) -
        ((Integer) secondMap.get('sortOrder'));
    }
  }
}
