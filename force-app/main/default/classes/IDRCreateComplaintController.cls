/**
 * @author Laxmi
 * @date October 2022
 * @description Fetches the Products for which N/A option is applicable for Account/Policy number.
 */
public with sharing class IDRCreateComplaintController {
  /**
   * @description method to get Products from soql query
   * @return Map<Id, Product2> returns map of Products with its Id
   */
  @AuraEnabled
  public static List<Id> fetchRequiredProducts() {
    Map<Id, Product2> productMap = new Map<Id, Product2>(
      [
        SELECT Id, IDR_Allow_Account_Policy_Number__c
        FROM Product2
        WHERE IDR_Allow_Account_Policy_Number__c = TRUE
      ]
    );
    return new List<Id>(productMap.keySet());
  }
}
