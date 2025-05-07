/**
 * @author Batya Aisman Sufrin
 * @since 03/2025
 * @description FalseCustomerProfileCaseRepository is the repository class for False Customer Profile Case Actions.
 */
public with sharing class FalseCustomerProfileCaseRepository {
  /**
   * @description Get list of Accounts By accountId
   * @param accountIds set of account Ids
   * @return List<Account> list of Accounts
   */
  public List<Account> queryAccountsByIds(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }

    return [
      SELECT Id, Name
      FROM Account
      WHERE Id IN :accountIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Get list of Customer Onboarding Applications By COB Ids
   * @param cobIds set of COB Ids
   * @return List<CustomerOnboardingApplication__c> list of Customer Onboarding Applications with PIDs
   */
  public List<CustomerOnboardingApplication__c> queryCobsWithPIDByIds(
    Set<Id> cobIds
  ) {
    if (cobIds.isEmpty()) {
      return new List<CustomerOnboardingApplication__c>();
    }

    return [
      SELECT
        Id,
        (
          SELECT Id, FirstName__c, MiddleNames__c, LastName__c
          FROM COBPrimaryIDDocuments__r
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE Id IN :cobIds
      WITH USER_MODE
    ];
  }
}
