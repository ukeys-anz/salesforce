/**
 * @author Prahlad Bhadani
 * @since 10/2025
 * @description This class provide SOQL and DML helper for class related to CacheFinancialAccountQueryBase.
 */
public with sharing class CacheFinancialAccountQueryBaseRepository {
  private static final String CUSTOMER_LENDING_GROUP = 'Customer Lending Group';
  private static final String SUSPENDED = 'Suspended';
  private static final String CLOSED = 'Closed';
  private static final String OCV_DELETED = 'OCV Deleted';
  private static final String SOURCE_SYSTEM_CACHE = 'CACHE';

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
        AND FinServ__RelatedAccount__r.Source_System_Name__c = :SOURCE_SYSTEM_CACHE //CACHE customer
        AND FinServ__FinancialAccount__r.RecordType.DeveloperName = :recordTypeName
        AND FinServ__Active__c = TRUE
        AND FinServ__FinancialAccount__r.Product_Type__c IN :productTypes
        AND Role_Type__c IN :roleTypes.keyset()
        AND FinServ__EndDate__c = NULL
        AND (FinServ__FinancialAccount__r.FinServ__Status__c NOT IN (
          :SUSPENDED,
          :CLOSED
        )
        OR (FinServ__FinancialAccount__r.FinServ__Status__c IN (
          :SUSPENDED,
          :CLOSED
        )
        AND (FinServ__FinancialAccount__r.FinServ__CloseDate__c = NULL
        OR FinServ__FinancialAccount__r.FinServ__CloseDate__c >= LAST_N_MONTHS:18)))
        AND FinServ__FinancialAccount__r.System_Record_Status__c != :OCV_DELETED
      WITH USER_MODE
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
      WHERE
        FinServ__FinancialAccount__r.Account_Key__c = :accountKey
        AND FinServ__RelatedAccount__r.Source_System_Name__c = :SOURCE_SYSTEM_CACHE //CACHE customer
      WITH USER_MODE
    ];
  }
}
