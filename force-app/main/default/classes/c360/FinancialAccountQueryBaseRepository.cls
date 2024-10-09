/**
 * @author Ayushi Gupta
 * @since 06/2024
 * @description This class provide SOQL and DML helper for class related to FinancialAccountQueryBase.
 */
public with sharing class FinancialAccountQueryBaseRepository {
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
    List<FinServ__FinancialAccountRole__c> faRoles = [
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
        FinServ__FinancialAccount__r.Product_Name_Display__c
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
    return faRoles;
  }

  /**
   * @description Retrieves financial account by account key (customerId + '-' accountNumber)
   * @param accountKey Account Key
   * @return List< FinServ_FinancialAccountRole__c>
   */
  public List<FinServ__FinancialAccountRole__c> getFinancialAccountsWithAcctNum(
    String accountKey
  ) {
    List<FinServ__FinancialAccountRole__c> faRoles = [
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
        FinServ__FinancialAccount__r.Product_Name_Display__c
      FROM FinServ__FinancialAccountRole__c
      WHERE FinServ__FinancialAccount__r.Account_Key__c = :accountKey
    ];
    return faRoles;
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
    List<FinServ__FinancialAccountRole__c> relatedCustomers = new List<FinServ__FinancialAccountRole__c>{
      [
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
      ]
    };
    return relatedCustomers;
  }

  /**
   * @description get industry record
   * @param  industryCode
   * @return Industry__c
   */
  public Industry__c getIndustryCodeAndDescription(String industryCode) {
    List<Industry__c> result;
    result = [
      SELECT Name, Code__c
      FROM Industry__c
      WHERE Code__c = :industryCode
      LIMIT 1
    ];
    return result.isEmpty() ? null : result[0];
  }

  /**
   * @description get formatted financial account numbers
   * @param  accountNumbers List of account numbers
   * @return List<FinServ__FinancialAccount__c>
   */
  public List<FinServ__FinancialAccount__c> getformattedFinancialAccounts(
    List<String> accountNumbers
  ) {
    return [
      SELECT Account_Number__c, FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__FinancialAccountNumber__c IN :accountNumbers
      WITH SECURITY_ENFORCED
    ];
  }
}
