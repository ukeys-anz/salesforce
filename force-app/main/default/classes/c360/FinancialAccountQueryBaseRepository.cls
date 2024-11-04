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
    if (
      !PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') ||
      customerIds.isEmpty() ||
      String.isBlank(recordTypeName) ||
      productTypes.isEmpty() ||
      roleTypes.isEmpty()
    ) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
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
    if (
      !PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') ||
      String.isBlank(accountKey)
    ) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
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
        FinServ__FinancialAccount__r.Product_Name_Display__c,
        FinServ__FinancialAccount__r.Sub_product_Code_Display__c
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
    if (
      !PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') ||
      String.isBlank(accountKey) ||
      roleTypes.isEmpty()
    ) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    List<FinServ__FinancialAccountRole__c> relatedCustomers = [
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
    return relatedCustomers;
  }

  /**
   * @description get industry record
   * @param  industryCode
   * @return Industry__c
   */
  public Industry__c getIndustryCodeAndDescription(String industryCode) {
    if (
      !PermissionUtils.canQuery('Industry__c') || String.isBlank(industryCode)
    ) {
      return new Industry__c();
    }
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
   * @description get Customer record
   * @param  externalIdValue
   * @param recordTypeName
   * @return List<Account>
   */
  public List<Account> getCustomerUsingExternalIdAndRtName(
    String externalIdValue,
    String recordTypeName
  ) {
    if (
      !PermissionUtils.canQuery('Account') ||
      String.isBlank(externalIdValue) ||
      String.isBlank(recordTypeName)
    ) {
      return new List<Account>();
    }
    List<Account> result = new List<Account>();
    result = [
      SELECT Id, Name, External_Id__c
      FROM Account
      WHERE
        External_Id__c = :externalIdValue
        AND RecordType.DeveloperName = :recordTypeName
      LIMIT 1
    ];
    return result;
  }

  /**
   * @description get Customer record
   * @param  customerId
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getCustomerAAR(
    String customerId
  ) {
    if (
      !PermissionUtils.canQuery('FinServ__AccountAccountRelation__c') ||
      String.isBlank(customerId)
    ) {
      return new List<FinServ__AccountAccountRelation__c>();
    }
    List<FinServ__AccountAccountRelation__c> result = new List<FinServ__AccountAccountRelation__c>();
    result = [
      SELECT Id, FinServ__RelatedAccount__r.External_Id__c
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__r.External_Id__c = :customerId
        AND FinServ__Active__c = TRUE
    ];
    return result;
  }

  /**
   * @description get industry records bsed on codes
   * @param  industryCodesSet set of industryCodes
   * @return List<Industry__c> list of industry codes
   */
  public List<Industry__c> getIndustry(Set<String> industryCodesSet) {
    if (!Schema.sObjectType.Industry__c.isQueryable()) {
      return new List<Industry__c>();
    }

    return [
      SELECT Id, Name, Code__c
      FROM Industry__c
      WHERE Code__c IN :industryCodesSet
    ];
  }

  /**
   * @description get Customer record
   * @param  externalIdValue
   * @return List<Account>
   */
  public List<Account> getCustomerUsingExternalId(String externalIdValue) {
    if (
      !PermissionUtils.canQuery('Account') || String.isBlank(externalIdValue)
    ) {
      return new List<Account>();
    }
    List<Account> result;
    result = [
      SELECT Id, Name, External_Id__c
      FROM Account
      WHERE External_Id__c = :externalIdValue
    ];
    return result;
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
    if (
      !PermissionUtils.canQuery('Account') ||
      String.isBlank(externalIdValue) ||
      String.isBlank(recordTypeName)
    ) {
      return new List<Account>();
    }
    List<Account> result = new List<Account>();
    result = [
      SELECT Id, Name, External_Id__c
      FROM Account
      WHERE
        External_Id__c = :externalIdValue
        AND RecordType.DeveloperName = :recordTypeName
      LIMIT 1
    ];
    return result;
  }

  /**
   * @description get Customer record
   * @param  customerId
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getCustomerAAR(
    String customerId
  ) {
    if (
      !PermissionUtils.canQuery('FinServ__AccountAccountRelation__c') ||
      String.isBlank(customerId)
    ) {
      return new List<FinServ__AccountAccountRelation__c>();
    }
    List<FinServ__AccountAccountRelation__c> result = new List<FinServ__AccountAccountRelation__c>();
    result = [
      SELECT Id, FinServ__RelatedAccount__r.External_Id__c
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__r.External_Id__c = :customerId
        AND FinServ__Active__c = TRUE
    ];
    return result;
  }

  /**
   * @description get industry records bsed on codes
   * @param  industryCodesSet set of industryCodes
   * @return List<Industry__c> list of industry codes
   */
  public List<Industry__c> getIndustry(Set<String> industryCodesSet) {
    if (!Schema.sObjectType.Industry__c.isQueryable()) {
      return new List<Industry__c>();
    }

    return [
      SELECT Id, Name, Code__c
      FROM Industry__c
      WHERE Code__c IN :industryCodesSet
    ];
  }
}
