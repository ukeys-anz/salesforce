/**
 * @since 03/2025
 * @description This class provides SOQL helpers for class related GetCustomerInformation.
 * @runTests GetCustomerInformationTest
 */
public with sharing class GetCustomerInformationRepo {
  /**
   * @description REPO to Fetch Financial Accounts Releated to the Customer
   * @param accId ID of the Customer
   * @param ocvId ocvId of the Customer
   * @param roleTypes roletypes for financial roles
   * @return List<FinServ__FinancialAccountRole__c> return the list of Financial Accounts Roles
   */

  public List<FinServ__FinancialAccountRole__c> getFinancialAccounts(
    Id accId,
    String ocvId,
    Set<String> roleTypes
  ) {
    if (String.isBlank(accId) || String.isBlank(ocvId)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    return [
      SELECT
        Id,
        FinServ__FinancialAccount__r.Account_Key__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountType__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        (FinServ__RelatedAccount__c = :accId
        OR FinServ__RelatedAccount__r.OCV_ID__c = :ocvId)
        AND Role_Type__c IN :roleTypes
      WITH USER_MODE
    ];
  }
}
