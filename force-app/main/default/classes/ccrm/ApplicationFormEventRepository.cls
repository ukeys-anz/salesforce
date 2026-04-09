/**
 * @description Repository class responsible for retrieving related data
 *              used by ApplicationForm event processing. This includes
 *              fetching Account External IDs and qualifying ApplicationForm
 *              records related to given IDs.
 * @author      Akanksha Kulkarni
 * @date        2025-11-10
 */
public class ApplicationFormEventRepository {
  /**
   * @description Returns a map of Account IDs to their corresponding External_Id__c values
   *              for the Accounts related to the given list of ApplicationForm records.
   * @param applicationForms The list of ApplicationForm records whose related Account External IDs are needed.
   * @return A map of Account Id → External_Id__c values. Returns an empty map if no related Accounts exist.
   *
   */
  public Map<Id, String> getRelatedAccounts(
    List<ApplicationForm> applicationForms
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (ApplicationForm app : applicationForms) {
      Id accountRecId = app.Opportunity?.AccountId != null
        ? app.Opportunity.AccountId
        : app.AccountId;
      accountIds.add(accountRecId);
    }

    Map<Id, String> accountExternalIds = new Map<Id, String>();
    if (!accountIds.isEmpty()) {
      for (Account acc : [
        SELECT Id, External_Id__c
        FROM Account
        WHERE Id IN :accountIds
        WITH USER_MODE
      ]) {
        accountExternalIds.put(acc.Id, acc.External_Id__c);
      }
    }

    return accountExternalIds;
  }

  /**
   * @description Queries and returns a list of ApplicationForm records
   *              associated with the provided ApplicationForm Ids.
   *              Only ApplicationForms meeting these conditions are returned:
   *              - Account.Sync_Status__c is NOT 'Broker Org'
   *              - Assisted_Broker_TPMI_SAO__c is not null
   * @param applicationFormIds The set of ApplicationForm record IDs to query.
   * @return A list of ApplicationForm records matching the criteria.
   */
  public List<ApplicationForm> queryApplicationFormCustomer(
    Set<Id> applicationFormIds
  ) {
    List<ApplicationForm> applicationForms = new List<ApplicationForm>();
    if (applicationFormIds.isEmpty()) {
      return applicationForms;
    }

    applicationForms = [
      SELECT Id, Assisted_Broker_TPMI_SAO__c, Account.Sync_Status__c, AccountId
      FROM ApplicationForm
      WHERE
        Id IN :applicationFormIds
        AND Account.Sync_Status__c EXCLUDES (
          :BrokerConstants.SYNC_STATUS_BROKER_ORG
        )
        AND Assisted_Broker_TPMI_SAO__c != NULL
      WITH USER_MODE
    ];

    return applicationForms;
  }
}
