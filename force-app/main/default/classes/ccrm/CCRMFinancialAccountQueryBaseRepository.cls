/**
 * @author Ayushi Gupta
 * @since 06/2024
 * @description This class provide SOQL and DML helper for class related to CCRMFinancialAccountQueryBase.
 */
public class CCRMFinancialAccountQueryBaseRepository {
  /**
   * @description Retrieves list of financial accounts related to a customer via
   *                        financial account role relationship (FAR)
   * @param customerIds the customer external Ids
   * @param recordTypeName record type name
   * @param productTypes types of products
   * @param roleTypes map of types of roles
   * @return List<FinServ__FinancialAccountRole__c> list of financial account roles
   */
  public List<FinServ__FinancialAccountRole__c> getFinancialAccountsWithCustomerId(
    Set<String> customerIds,
    String recordTypeName,
    Set<String> productTypes,
    Map<String, String> roleTypes
  ) {
    if (
      !Schema.sObjectType.FinServ__FinancialAccountRole__c.isQueryable() ||
      !Schema.sObjectType.FinServ__FinancialAccount__c.isQueryable()
    ) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    if (
      customerIds.isEmpty() ||
      String.isBlank(recordTypeName) ||
      productTypes.isEmpty() ||
      roleTypes.isEmpty()
    ) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    return [
      SELECT
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.Account_Key__c,
        FinServ__FinancialAccount__r.Name,
        FinServ__FinancialAccount__r.FinServ__Status__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        FinServ__FinancialAccount__r.Account_Number__c,
        FinServ__FinancialAccount__r.Product_Type__c,
        FinServ__FinancialAccount__r.Product_SubCode__c,
        FinServ__FinancialAccount__r.Source_System_Status_Display__c,
        FinServ__RelatedAccount__r.External_Id__c,
        Role_Type__c,
        FinServ__FinancialAccount__r.Product_Code_Display__c,
        FinServ__FinancialAccount__r.Product_Name_Display__c,
        FinServ__FinancialAccount__r.Sub_product_Code_Display__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__r.External_Id__c IN :customerIds
        AND FinServ__FinancialAccount__r.RecordType.DeveloperName = :recordTypeName
        AND FinServ__Active__c = TRUE
        AND FinServ__FinancialAccount__r.Product_Type__c IN :productTypes
        AND Role_Type__c IN :roleTypes.keyset()
        AND FinServ__EndDate__c = NULL
      ORDER BY FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
    ];
  }

  /**
   * @description Retrieves financial account by account key (customerId + '-' accountNumber)
   * @param accountKey Account Key
   * @return List< FinServ_FinancialAccountRole__c>
   */
  public List<FinServ__FinancialAccountRole__c> getFinancialAccountsWithAcctNum(
    String accountKey
  ) {
    if (!Schema.sObjectType.FinServ__FinancialAccountRole__c.isQueryable()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    if (String.isBlank(accountKey)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    return [
      SELECT
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.Account_Key__c,
        FinServ__FinancialAccount__r.Name,
        FinServ__FinancialAccount__r.FinServ__Status__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        FinServ__FinancialAccount__r.Account_Number__c,
        FinServ__FinancialAccount__r.Product_Type__c,
        FinServ__FinancialAccount__r.Product_SubCode__c,
        FinServ__FinancialAccount__r.Source_System_Status_Display__c,
        FinServ__RelatedAccount__r.External_Id__c,
        Role_Type__c,
        FinServ__FinancialAccount__r.Product_Code_Display__c,
        FinServ__FinancialAccount__r.Product_Name_Display__c,
        FinServ__FinancialAccount__r.Sub_product_Code_Display__c
      FROM FinServ__FinancialAccountRole__c
      WHERE FinServ__FinancialAccount__r.Account_Key__c = :accountKey
    ];
  }

  /**
   * @description get related customers of a particular account
   * @param  accountKey Account Key
   * @param roleTypes role types
   * @return List< FinServ_FinancialAccountRole__c>
   */
  public List<FinServ__FinancialAccountRole__c> getRelatedCustomers(
    String accountKey,
    Set<String> roleTypes
  ) {
    if (!Schema.sObjectType.FinServ__FinancialAccountRole__c.isQueryable()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    if (String.isBlank(accountKey) || roleTypes.isEmpty()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    return [
      SELECT
        FinServ__RelatedAccount__r.External_Id__c,
        FinServ__FinancialAccount__r.Product_Type__c,
        Role_Type__c,
        FinServ__FinancialAccount__r.Account_Key__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__FinancialAccount__r.Account_Key__c = :accountKey
        AND FinServ__Active__c = TRUE
        AND FinServ__EndDate__c = NULL
    ];
  }

  /**
   * @description get industry record
   * @param  industryCode
   * @return List<Industry__c>
   */
  public List<Industry__c> getIndustryCodeAndDescription(String industryCode) {
    if (!Schema.sObjectType.Industry__c.isQueryable()) {
      return new List<Industry__c>();
    }
    if (String.isBlank(industryCode)) {
      return new List<Industry__c>();
    }
    return [
      SELECT Name, Code__c
      FROM Industry__c
      WHERE Code__c = :industryCode
      LIMIT 1
    ];
  }
}
