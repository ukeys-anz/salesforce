/**
 * @author MLCRM Developer
 * @since 08/2024
 * @description This class provide SOQL and DML helper for class related to CCRMA2ZReviewActionHelper.
 */

public with sharing class A2ZReviewRepository {
  private static final Id AZ_REVIEW_RT_ID = QueryRT.of(
      A_Z_Review__c.SObjectType
    )
    .getId('Commercial_A_Z_Review');
  /**
   * @description query list of ccrmA2ZReview flterd by related Lead Id
   * @param setOfLeadIds
   * @return List<A_Z_Review__c>
   **/
  public List<A_Z_Review__c> fetchReviewsByLead(Set<ID> setOfLeadIds) {
    if (setOfLeadIds == null || setOfLeadIds.isEmpty()) {
      return new List<A_Z_Review__c>();
    }
    return [
      SELECT
        Id,
        Name,
        Customer__c,
        Lead__c,
        Opportunity__c,
        Opportunity__r.AccountId,
        Lead__r.FinServ__RelatedAccount__c
      FROM A_Z_Review__c
      WHERE RecordTypeId = :AZ_REVIEW_RT_ID AND Lead__c IN :setOfLeadIds
      WITH USER_MODE
    ];
  }
}
