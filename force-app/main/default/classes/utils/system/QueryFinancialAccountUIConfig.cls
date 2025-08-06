/**
 * @author Nilesh
 * @since March 2025
 * @description Holds Cached Financial Account UI Config Data
 */
public with sharing class QueryFinancialAccountUIConfig {
  public static Map<String, FinancialAccountUIConfiguration__mdt> configByProductCode = new Map<String, FinancialAccountUIConfiguration__mdt>();

  public static Map<String, FinancialAccountUIConfiguration__mdt> configByDeveloperName = new Map<String, FinancialAccountUIConfiguration__mdt>();

  static {
    List<FinancialAccountUIConfiguration__mdt> allConfig = [
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
        FinancialAccountConfiguration__r.Icon__c,
        FinancialAccountConfiguration__r.Transaction_Title__c,
        Include_In_Total_Financial_Position__c
      FROM FinancialAccountUIConfiguration__mdt
      WITH USER_MODE
    ];

    for (FinancialAccountUIConfiguration__mdt config : allConfig) {
      configByProductCode.put(config.Product_Code__c, config);
      configByDeveloperName.put(config.DeveloperName, config);
    }
  }

  /**
   * @description Returns SEt of product codes from Financial Account UI config data.
   * @param developerName Name of the Financial Account UI config record
   * @return Product set of all config data.
   */
  public static FinancialAccountUIConfiguration__mdt getByDeveloperName(
    String developerName
  ) {
    return configByDeveloperName.get(developerName);
  }

  /**
   * @description Returns SEt of product codes from Financial ACcount UI config data.
   * @param productCode field of Financial Account UI config record
   * @return Product set of all config data.
   */
  public static FinancialAccountUIConfiguration__mdt getByProductCode(
    String productCode
  ) {
    return configByProductCode.get(productCode);
  }
}
