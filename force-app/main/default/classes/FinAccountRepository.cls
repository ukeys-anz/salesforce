/**
 * @author Pragya Awasthi
 * @since 02/2025
 * @description Provides SOQL for FinAccountController
 */
public with sharing class FinAccountRepository {
  /**
   * @description return financial account based on recordId
   * @param recordId Financial account record id
   * @return FinServ__FinancialAccount__c financial account
   */
  public FinServ__FinancialAccount__c getFinAccountDetails(String recordId) {
    if (recordId == null) {
      return new FinServ__FinancialAccount__c();
    }
    return [
      SELECT
        Account_Key__c,
        Product_Code_Display__c,
        FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccount__c
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description return External account details based on externalId
   * @param externalId External Id of the Financial Account
   * @param objName External Object (Account)
   * @return SObject
   */
  public SObject getExternalAccountDetails(String externalId, String objName) {
    if (String.isBlank(externalId) || String.isBlank(objName)) {
      return null;
    }
    String recordQuery =
      'SELECT Id FROM ' +
      objName +
      ' WHERE ExternalId = :externalId WITH USER_MODE LIMIT 1';

    return database.query(recordQuery) ?? null;
  }
}
