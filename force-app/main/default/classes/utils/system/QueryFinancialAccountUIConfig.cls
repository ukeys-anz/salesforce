/**
 * @author Nilesh
 * @since March 2025
 * @description Holds Cached Financial Account UI Config Data
 */
public with sharing class QueryFinancialAccountUIConfig {
  @TestVisible
  private static List<FinancialAccountUIConfiguration__mdt> allConfigs = new List<FinancialAccountUIConfiguration__mdt>();
  @TestVisible
  private static Set<String> productCodesIncludedInTotalPosition = new Set<String>();
  @TestVisible
  private static Set<String> allProductCodes = new Set<String>();

  static {
    allConfigs = [
      SELECT
        DeveloperName,
        Product_Code__c,
        Ownership_Type__c,
        Show_Goals__c,
        Sort_Order__c,
        Account_Type__c,
        Balance_Title__c,
        Section_Header_Title__c,
        Is_Active__c,
        Include_In_Total_Financial_Position__c
      FROM FinancialAccountUIConfiguration__mdt
    ];

    for (FinancialAccountUIConfiguration__mdt config : allConfigs) {
      allProductCodes.add(config.Product_Code__c);

      if (
        config.Is_Active__c == true &&
        config.Include_In_Total_Financial_Position__c == true
      ) {
        productCodesIncludedInTotalPosition.add(config.Product_Code__c);
      }
    }
  }

  /**
   * @description Returns Financial ACcount UI config data from Metadata.
   * @return UI config records.
   */
  public static List<FinancialAccountUIConfiguration__mdt> getAllConfigs() {
    return allConfigs;
  }

  /**
   * @description Returns SEt of product codes eligibel to include in total  from Financial ACcount UI config data.
   * @return Product set of eligible product codes.
   */
  public static Set<String> getProductCodesIncludedInTotalPosition() {
    return productCodesIncludedInTotalPosition;
  }

  /**
   * @description Returns SEt of product codes from Financial ACcount UI config data.
   * @return Product set of all config data.
   */
  public static Set<String> getAllProductCodes() {
    return allProductCodes;
  }
}
