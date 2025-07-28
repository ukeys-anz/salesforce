/**
 * @author Ayushi Gupta
 * @since 05/2025
 * @description This class provide SOQL,DML and mocking helper for class related to A-Z.
 */
public with sharing class CommercialA2ZReviewRepository {
  /**
   * @description to get A2Z records associated to Individual customer
   * @name getA2ZRecordsAssociatedWithIndividualCustomers
   * @param accountIds set of account ids
   * @return List<A_Z_Review__c>
   */
  public List<A_Z_Review__c> getA2ZRecordsAssociatedWithIndividualCustomers(
    Set<Id> accountIds
  ) {
    if (accountIds.isEmpty()) {
      return new List<A_Z_Review__c>();
    }
    return [
      SELECT Id, Customer__r.RecordTypeId
      FROM A_Z_Review__c
      WHERE
        Customer__c IN :accountIds
        AND Customer__r.RecordTypeId = :RTAccount.personAccount
      WITH USER_MODE
    ];
  }
}
