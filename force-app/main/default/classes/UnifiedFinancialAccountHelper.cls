/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description UnifiedFinancialAccountHelper groups and sort the financial accounts
 */
public with sharing class UnifiedFinancialAccountHelper {
  private static final FinancialAccountRepository FINANCIAL_ACCOUNT_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );

  /**
   * @description Groups financial accounts based on product code .
   * @param finAccounts list of financial accounts received from fabric or database.
   * @return map of product code and list of financial accounts associated with that product code.
   */
  public static Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupByProductCode(
    List<UnifiedFinancialAccountModel.AccountList> finAccounts
  ) {
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = new Map<String, List<UnifiedFinancialAccountModel.AccountList>>();

    for (UnifiedFinancialAccountModel.AccountList finAccount : finAccounts) {
      String productCode = finAccount.product_details.marketing_code;

      if (!groupedAccounts.containsKey(productCode)) {
        groupedAccounts.put(
          productCode,
          new List<UnifiedFinancialAccountModel.AccountList>()
        );
      }
      groupedAccounts.get(productCode).add(finAccount);
    }

    return groupedAccounts;
  }

  /**
   * @description update financial accounts with metata values and sort the records on tile / account level
   * @param groupedAccounts map of product code and list of financial accounts associated with that product code.
   * @return  updated financial accounts with metadata values and sorted based on sort order
   */
  public static Map<String, Object> processMetadataAndBuildResponse(
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts
  ) {
    Set<String> productCodes = groupedAccounts.keySet();
    List<FinancialAccountUIConfiguration__mdt> metadataList = FINANCIAL_ACCOUNT_REPOSITORY.fetchMetadataForProductCodes(
      productCodes
    );

    Map<String, Integer> productTileSortOrderMap = new Map<String, Integer>();
    Map<String, Map<String, Integer>> productOwnershipOrderMap = new Map<String, Map<String, Integer>>();

    determineSortOrder(
      productTileSortOrderMap,
      productOwnershipOrderMap,
      metadataList
    );

    Map<String, FinancialAccountUIConfiguration__mdt> metadataMap = buildMetadataMap(
      metadataList
    );

    List<Map<String, Object>> sortedGroups = buildSortedGroups(
      groupedAccounts,
      productTileSortOrderMap,
      productOwnershipOrderMap,
      metadataMap
    );

    sortedGroups.sort(new TileComparator());

    return new Map<String, Object>{ 'groupedAccounts' => sortedGroups };
  }

  private static void determineSortOrder(
    Map<String, Integer> productTileSortOrderMap,
    Map<String, Map<String, Integer>> productOwnershipOrderMap,
    List<FinancialAccountUIConfiguration__mdt> metadataList
  ) {
    for (FinancialAccountUIConfiguration__mdt meta : metadataList) {
      if (!meta.Is_Active__c) {
        continue;
      }
      String prodCode = meta.Product_Code__c;

      Integer sortOrder = (meta.Sort_Order__c != null)
        ? meta.Sort_Order__c.intValue()
        : 999;

      if (
        !productTileSortOrderMap.containsKey(prodCode) ||
        sortOrder < productTileSortOrderMap.get(prodCode)
      ) {
        productTileSortOrderMap.put(prodCode, sortOrder);
      }

      if (!productOwnershipOrderMap.containsKey(prodCode)) {
        productOwnershipOrderMap.put(prodCode, new Map<String, Integer>());
      }
      productOwnershipOrderMap.get(prodCode)
        .put(meta.Ownership_Type__c, sortOrder);
    }
  }

  private static List<Map<String, Object>> buildSortedGroups(
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts,
    Map<String, Integer> productTileSortOrderMap,
    Map<String, Map<String, Integer>> productOwnershipOrderMap,
    Map<String, FinancialAccountUIConfiguration__mdt> metadataMap
  ) {
    List<Map<String, Object>> sortedGroups = new List<Map<String, Object>>();

    for (String prodCode : groupedAccounts.keySet()) {
      Integer tileSortOrder = productTileSortOrderMap.containsKey(prodCode)
        ? productTileSortOrderMap.get(prodCode)
        : 999;
      List<UnifiedFinancialAccountModel.AccountList> accounts = groupedAccounts.get(
        prodCode
      );
      accounts.sort(
        new CompositeComparator(
          prodCode,
          tileSortOrder,
          productOwnershipOrderMap
        )
      );

      FinancialAccountUIConfiguration__mdt meta = metadataMap.containsKey(
          prodCode
        )
        ? metadataMap.get(prodCode)
        : null;

      Map<String, Object> groupData = populateFinAccountNodesFromMetadata(
        prodCode,
        tileSortOrder,
        meta,
        accounts
      );
      sortedGroups.add(groupData);
    }
    return sortedGroups;
  }

  private static Map<String, Object> populateFinAccountNodesFromMetadata(
    String prodCode,
    Integer tileSortOrder,
    FinancialAccountUIConfiguration__mdt meta,
    List<UnifiedFinancialAccountModel.AccountList> accounts
  ) {
    Map<String, Object> mapOfNodesAndMetada = new Map<String, Object>();
    mapOfNodesAndMetada.put('productCode', prodCode);
    mapOfNodesAndMetada.put('sortOrder', tileSortOrder);
    mapOfNodesAndMetada.put(
      'accountType',
      meta != null ? meta.Account_Type__c : 'Non Savings'
    );
    mapOfNodesAndMetada.put('label', 'test label');
    mapOfNodesAndMetada.put('accounts', accounts);
    mapOfNodesAndMetada.put(
      'balanceTitle',
      meta != null ? meta.Balance_Title__c : ''
    );
    mapOfNodesAndMetada.put(
      'productNameTitle',
      meta != null ? meta.Product_Name__c : ''
    );
    mapOfNodesAndMetada.put(
      'sectionHeaderTitle',
      meta != null ? meta.Section_Header_Title__c : ''
    );
    mapOfNodesAndMetada.put(
      'isActive',
      meta != null ? meta.Is_Active__c : false
    );
    mapOfNodesAndMetada.put(
      'isSaving',
      meta != null ? (meta.Account_Type__c == 'Savings') ? true : false : false
    );
    mapOfNodesAndMetada.put(
      'isOthers',
      meta != null
        ? meta.Account_Type__c == 'Non Savings' ? true : false
        : false
    );
    mapOfNodesAndMetada.put(
      'isHomeLoan',
      meta != null ? meta.Account_Type__c == 'Loan' ? true : false : false
    );
    return mapOfNodesAndMetada;
  }

  private static Map<String, FinancialAccountUIConfiguration__mdt> buildMetadataMap(
    List<FinancialAccountUIConfiguration__mdt> metadataList
  ) {
    Map<String, FinancialAccountUIConfiguration__mdt> metadataMap = new Map<String, FinancialAccountUIConfiguration__mdt>();
    for (FinancialAccountUIConfiguration__mdt meta : metadataList) {
      metadataMap.put(meta.Product_Code__c, meta);
    }
    return metadataMap;
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
