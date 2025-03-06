/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description FinancialAccountControllerAction groups and sort the financial accounts
 */
public with sharing class FinancialAccountControllerAction {
  private static final Integer DEFAULT_SORT_ORDER = 999;

  /**
   * @description Groups financial accounts based on product code .
   * @param finAccounts list of financial accounts received from fabric or database.
   * @return map of product code and list of financial accounts associated with that product code.
   */
  public static List<UnifiedFinancialAccountModel> processFinancialAccounts(
    List<UnifiedFinancialAccountModel.AccountList> finAccounts
  ) {
    List<FinancialAccountUIConfiguration__mdt> uiConfigDetails = QueryFinancialAccountUIConfig.getAllConfigs();

    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap = (Map<String, FinancialAccountUIConfiguration__mdt>) ListUtil.mapBy(
      uiConfigDetails,
      FinancialAccountUIConfiguration__mdt.Product_Code__c
    );

    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = groupAccounts(
      finAccounts,
      uiConfigMap
    );

    return prepareFinalUIResponse(groupedAccounts, uiConfigMap);
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
  private static List<UnifiedFinancialAccountModel> prepareFinalUIResponse(
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts,
    Map<String, FinancialAccountUIConfiguration__mdt> uiConfigMap
  ) {
    List<UnifiedFinancialAccountModel> groupedByProductCode = new List<UnifiedFinancialAccountModel>();

    for (String productCode : groupedAccounts.keySet()) {
      FinancialAccountUIConfiguration__mdt uiConfig = uiConfigMap.get(
        productCode
      );

      groupedByProductCode.add(
        prepareUIResponse(
          productCode,
          uiConfig,
          groupedAccounts.get(productCode)
        )
      );
    }

    return groupedByProductCode;
  }

  private static UnifiedFinancialAccountModel prepareUIResponse(
    String productCode,
    FinancialAccountUIConfiguration__mdt uiConfig,
    List<UnifiedFinancialAccountModel.AccountList> accounts
  ) {
    UnifiedFinancialAccountModel modelUpateForEachProductGroup = new UnifiedFinancialAccountModel(
      accounts
    );
    modelUpateForEachProductGroup.productCode = productCode;
    modelUpateForEachProductGroup.sortOrder = uiConfig?.Sort_Order__c ??
      DEFAULT_SORT_ORDER;
    modelUpateForEachProductGroup.accountType = uiConfig?.Account_Type__c ??
      'Non Savings';
    modelUpateForEachProductGroup.balanceTitle = uiConfig?.Balance_Title__c ??
      '';
    modelUpateForEachProductGroup.sectionHeaderTitle = uiConfig
      ?.Section_Header_Title__c ?? '';
    modelUpateForEachProductGroup.isSaving =
      uiConfig?.Account_Type__c == 'Savings';
    modelUpateForEachProductGroup.isOthers =
      uiConfig == null ||
      uiConfig?.Account_Type__c == 'Non Savings';
    modelUpateForEachProductGroup.isHomeLoan =
      uiConfig?.Account_Type__c == 'Loan';
    modelUpateForEachProductGroup.accounts = accounts;

    return modelUpateForEachProductGroup;
  }
}
