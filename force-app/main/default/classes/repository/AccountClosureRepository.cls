/**
 * @author Kopal Goswami
 * @since 11/2024
 * @description  AccountClosureRepository is the repository class for Account Closure Case Actions.
 */
public with sharing class AccountClosureRepository {
  /**
   * @description Get list of FinancialAccount Roles linked to the financial account
   * @param finAccountValue Financial account  number to be closed
   * @return List<FinServ__FinancialAccountRole__c> list of Financial account roles
   */
  public List<FinServ__FinancialAccountRole__c> queryFinancialAccountRoles(
    String finAccountValue
  ) {
    if (String.isBlank(finAccountValue)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }

    return [
      SELECT FinServ__RelatedAccount__r.OCV_ID__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c = :finAccountValue
        AND FinServ__Active__c = TRUE
      WITH USER_MODE
    ];
  }
}
