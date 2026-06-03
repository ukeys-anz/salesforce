/**
 * @author Ayushi Gupta
 * @since 06/2024
 * @description This class provide SOQL and DML helper for class related to FinancialAccountQueryBase.
 */
public with sharing class FinancialAccountQueryBaseRepository {
  private static final String CUSTOMER_LENDING_GROUP = 'Customer Lending Group';
  private static final String SUSPENDED = 'Suspended';
  private static final String CLOSED = 'Closed';
  private static final String OCV_DELETED = 'OCV Deleted';

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
        FinServ__FinancialAccount__r.Sub_product_Code_Display__c,
        FinServ__FinancialAccount__r.Suncorp_Bank_Move__c,
        FinServ__FinancialAccount__r.Suncorp_Bank_Identifier__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__r.External_Id__c IN :customerIds
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
        FinServ__FinancialAccount__r.Sub_product_Code_Display__c,
        FinServ__FinancialAccount__r.Suncorp_Bank_Move__c,
        FinServ__FinancialAccount__r.Suncorp_Bank_Identifier__c
      FROM FinServ__FinancialAccountRole__c
      WHERE FinServ__FinancialAccount__r.Account_Key__c = :accountKey
      WITH USER_MODE
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
      WITH USER_MODE
    ];
  }

  /**
   * @description get industry record
   * @param  industryCode
   * @return Industry__c
   */
  public Industry__c getIndustryCodeAndDescription(String industryCode) {
    return [
      SELECT Name, Code__c
      FROM Industry__c
      WHERE Code__c = :industryCode
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description get Customer record
   * @param  externalIdValue
   * @return List<Account>
   */
  public List<Account> getCustomerUsingExternalId(Set<String> externalIdValue) {
    if (externalIdValue.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Name, External_Id__c, Source_System_Name__c
      FROM Account
      WHERE External_Id__c IN :externalIdValue
      WITH USER_MODE
    ];
  }

  /**
   * @description get Customer record
   * @param  externalIdValue
   * @param recordTypeName
   * @return List<Account>
   */
  public List<Account> getCustomerUsingExternalIdAndRtName(
    String externalIdValue,
    String recordTypeName
  ) {
    if (String.isBlank(externalIdValue) || String.isBlank(recordTypeName)) {
      return new List<Account>();
    }
    return [
      SELECT Id, Name, External_Id__c
      FROM Account
      WHERE
        External_Id__c = :externalIdValue
        AND RecordType.DeveloperName = :recordTypeName
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description get customers related to a CLG customer
   * @param  clgCustomerId
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getCLGRelatedCustomers(
    String clgCustomerId
  ) {
    if (String.isBlank(clgCustomerId)) {
      return new List<FinServ__AccountAccountRelation__c>();
    }
    Set<Id> recordTypeIds = new Set<Id>{
      RTAccount.businessAccount,
      RTAccount.personAccount
    };

    return [
      SELECT Id, FinServ__RelatedAccount__r.External_Id__c
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__r.External_Id__c = :clgCustomerId
        AND FinServ__Active__c = TRUE
        AND FinServ__Role__r.Name = :CUSTOMER_LENDING_GROUP
        AND FinServ__RelatedAccount__r.RecordTypeId IN :recordTypeIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get industry records bsed on codes
   * @param  industryCodesSet set of industryCodes
   * @return List<Industry__c> list of industry codes
   */
  public List<Industry__c> getIndustry(Set<String> industryCodesSet) {
    return [
      SELECT Id, Name, Code__c
      FROM Industry__c
      WHERE Code__c IN :industryCodesSet
      WITH USER_MODE
    ];
  }
}
