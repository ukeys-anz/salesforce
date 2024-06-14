/**
 *
 * @author Nilesh
 * @since 12th June 2024
 * @description Utility class for consuming generic methods on Financial Account
 */
public with sharing class FinancialAccountUtil {
  /**
   * @description builds a list of finaccnumbers from the financial account roles for the customer sent from the UI
   * Account_Number__c (formula field) = FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
   * @param customerRecordPrimaryOwnerId customer id receive from the UI
   * @return List<String> list of the financial account numbers
   */
  public static List<String> getAllAccountNumberFromFAR(
    Id customerRecordPrimaryOwnerId
  ) {
    List<String> financialAccountNumbers = new List<String>();

    for (FinServ__FinancialAccountRole__c finAccRole : [
      SELECT Account_Number__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__c = :customerRecordPrimaryOwnerId
        AND FinServ__Active__c = TRUE
    ]) {
      financialAccountNumbers.add(finAccRole.Account_Number__c);
    }
    return financialAccountNumbers;
  }
}
