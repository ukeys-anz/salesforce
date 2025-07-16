/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description FinancialAccountControllerAction groups and sort the financial accounts
 */
public with sharing class FinancialAccountControllerAction {
  private static final Integer DEFAULT_SORT_ORDER = 999;
  private static final String ORIGIN = 'PRODUCT_ORIGIN_ARC';
  private static final String DEFAULT_ICON = 'custom:custom51';
  /**
   * @description Groups financial accounts based on product code .
   * @param finAccounts list of financial accounts received from fabric or database.
   * @return map of product code and list of financial accounts associated with that product code.
   */
  public static List<UnifiedFinancialAccountModel> processFinancialAccounts(
    List<UnifiedFinancialAccountModel.AccountList> finAccounts
  ) {
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = groupAccounts(
      finAccounts
    );

    return prepareFinalUIResponse(groupedAccounts);
  }

  @TestVisible
  private static Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupAccounts(
    List<UnifiedFinancialAccountModel.AccountList> finAccounts
  ) {
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = new Map<String, List<UnifiedFinancialAccountModel.AccountList>>();

    for (UnifiedFinancialAccountModel.AccountList account : finAccounts) {
      String productCode;

      if (account?.product_details?.origin == ORIGIN) {
        productCode = account.product_details.sub_product_code;
      } else {
        productCode = account.product_details.marketing_code;
      }

      FinancialAccountUIConfiguration__mdt uiConfig = QueryFinancialAccountUIConfig.configByProductCode.get(
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
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts
  ) {
    List<UnifiedFinancialAccountModel> groupedByProductCode = new List<UnifiedFinancialAccountModel>();

    for (String productCode : groupedAccounts.keySet()) {
      FinancialAccountUIConfiguration__mdt uiConfig = QueryFinancialAccountUIConfig.configByProductCode.get(
        productCode
      );

      UnifiedFinancialAccountModel uiModelUpdate = new UnifiedFinancialAccountModel(
        groupedAccounts.get(productCode)
      );

      uiModelUpdate.productCode = productCode;
      uiModelUpdate.sortOrder = uiConfig?.Sort_Order__c ?? DEFAULT_SORT_ORDER;
      uiModelUpdate.icon = uiConfig?.Icon__c ?? DEFAULT_ICON;
      uiModelUpdate.accountType = uiConfig?.Account_Type__c ?? 'Non Savings';
      uiModelUpdate.balanceTitle = uiConfig?.Balance_Title__c ?? '';
      uiModelUpdate.sectionHeaderTitle = uiConfig?.Section_Header_Title__c ??
        '';
      uiModelUpdate.isSaving = uiConfig?.Account_Type__c == 'Savings';
      uiModelUpdate.isOthers =
        uiConfig == null ||
        uiConfig?.Account_Type__c == 'Non Savings';
      uiModelUpdate.isHomeLoan = uiConfig?.Account_Type__c == 'Loan';
      uiModelUpdate.accounts = groupedAccounts.get(productCode);

      groupedByProductCode.add(uiModelUpdate);
    }

    return groupedByProductCode;
  }
}
