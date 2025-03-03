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
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap = new Map<String, FinancialAccountUIConfiguration__mdt>();
    Map<String, Boolean> productCodeExistsMap = new Map<String, Boolean>();
    processUIConfigurations(uiConfigMap, productCodeExistsMap);

    Map<String, Integer> tileSortOrderMap = new Map<String, Integer>();
    Map<String, Map<String, Integer>> ownershipSortOrderMap = new Map<String, Map<String, Integer>>();
    fetchSortingRules(uiConfigMap, tileSortOrderMap, ownershipSortOrderMap);

    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = groupAccounts(
      finAccounts,
      uiConfigMap
    );

    return sortAndFormatResponse(
      groupedAccounts,
      tileSortOrderMap,
      ownershipSortOrderMap,
      uiConfigMap
    );
  }

  private static void processUIConfigurations(
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap,
    Map<String, Boolean> productCodeExistsMap
  ) {
    List<FinancialAccountUIConfiguration__mdt> uiConfigDetails = FINANCIAL_ACCOUNT_REPOSITORY.fetchFinancialAccountUIConfigInfo();

    for (FinancialAccountUIConfiguration__mdt config : uiConfigDetails) {
      productCodeExistsMap.put(config.Product_Code__c, true);

      if (config.Is_Active__c == true) {
        uiConfigMap.put(config.Product_Code__c, config);
      }
    }
  }

  private static void fetchSortingRules(
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap,
    Map<String, Integer> tileSortOrderMap,
    Map<String, Map<String, Integer>> ownershipSortOrderMap
  ) {
    for (FinancialAccountUIConfiguration__mdt config : uiConfigMap.values()) {
      tileSortOrderMap.put(
        config.Product_Code__c,
        config.Sort_Order__c.intValue() ?? DEFAULT_SORT_ORDER
      );

      if (!ownershipSortOrderMap.containsKey(config.Product_Code__c)) {
        ownershipSortOrderMap.put(
          config.Product_Code__c,
          new Map<String, Integer>()
        );
      }
      ownershipSortOrderMap.get(config.Product_Code__c)
        .put(
          config.Ownership_Type__c,
          config.Sort_Order__c.intValue() ?? DEFAULT_SORT_ORDER
        );
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

      Boolean isActive = (uiConfig != null &&
        uiConfig.Is_Active__c != null)
        ? uiConfig.Is_Active__c
        : true;

      if (!isActive && uiConfig != null) {
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

  private static List<Map<String, Object>> sortAndFormatResponse(
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts,
    Map<String, Integer> tileSortOrderMap,
    Map<String, Map<String, Integer>> ownershipSortOrderMap,
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap
  ) {
    List<Map<String, Object>> sortedGroups = new List<Map<String, Object>>();

    for (String productCode : groupedAccounts.keySet()) {
      FinancialAccountUIConfiguration__mdt uiConfig = uiConfigMap.get(
        productCode
      );

      Boolean isActive = (uiConfig != null &&
        uiConfig.Is_Active__c != null)
        ? uiConfig.Is_Active__c
        : true;
      if (!isActive && uiConfig != null) {
        continue;
      }

      Integer tileSortOrder = tileSortOrderMap.containsKey(productCode)
        ? tileSortOrderMap.get(productCode)
        : DEFAULT_SORT_ORDER;
      List<UnifiedFinancialAccountModel.AccountList> accounts = groupedAccounts.get(
        productCode
      );

      accounts.sort(
        new compositeComparator(
          productCode,
          tileSortOrder,
          ownershipSortOrderMap
        )
      );

      sortedGroups.add(
        prepareUIResponse(productCode, tileSortOrder, uiConfig, accounts)
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
      'productNameTitle' => uiConfig != null ? uiConfig.Product_Name__c : '',
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

  private class CompositeComparator implements System.Comparator<UnifiedFinancialAccountModel.AccountList> {
    private String prodCode;
    private Integer tileSortOrder;
    private Map<String, Map<String, Integer>> productOwnershipOrderMap;

    /**
     * @description Comparator for sorting financial accounts based on product ownership order and tile sort order.
     * @param prodCode product code used to fetch ownership order map
     * @param tileSortOrder integer representing the sort order at the tile level
     * @param productOwnershipOrderMap a map containing ownership order for each product code
     */
    public CompositeComparator(
      String prodCode,
      Integer tileSortOrder,
      Map<String, Map<String, Integer>> productOwnershipOrderMap
    ) {
      this.prodCode = prodCode;
      this.tileSortOrder = tileSortOrder;
      this.productOwnershipOrderMap = productOwnershipOrderMap;
    }

    /**
     * @description Compares two financial account lists based on ownership order and tile sort order for sorting purposes.
     * @param firstFinAcc first financial account list to compare
     * @param secondFinAcc second financial account list to compare
     * @return a negative integer, zero, or a positive integer as the first list is less than, equal to, or greater than the second list, based on sort order
     */
    public Integer compare(
      UnifiedFinancialAccountModel.AccountList firstFinAcc,
      UnifiedFinancialAccountModel.AccountList secondFinAcc
    ) {
      Map<String, Integer> ownMap = productOwnershipOrderMap.get(prodCode);
      Integer orderA = (ownMap != null &&
        ownMap.containsKey(firstFinAcc.finserv_ownership))
        ? ownMap.get(firstFinAcc.finserv_ownership)
        : 999;
      Integer orderB = (ownMap != null &&
        ownMap.containsKey(secondFinAcc.finserv_ownership))
        ? ownMap.get(secondFinAcc.finserv_ownership)
        : 999;
      return (tileSortOrder * 1000 + orderA) -
        ((tileSortOrder * 1000) + orderB);
    }
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
