/**
 * @author Ayushi Gupta
 * @since 05/2025
 * @description This class provide SOQL,DML and mocking helper for class related to A-Z.
 */
public with sharing class CommercialA2ZReviewRepository {
  private static final String CLG = 'Customer Lending Group';
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

  /**
   * @description get the Opportunity Data based on Set Of OppIds where Account is not null
   * @param setOfOppIds
   * @return List<Opportunity>
   **/
  public List<Opportunity> getOpportunities(Set<Id> setOfOppIds) {
    if (setOfOppIds.isEmpty()) {
      return new List<Opportunity>();
    }
    return [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE
        AccountId != NULL
        AND Id IN :setOfOppIds
        AND RecordTypeId = :CCRMConstants.CCRM_OPP_RT_ID
      WITH USER_MODE
    ];
  }

  /**
   * @description get the Lead Data based on Set Of LeadIds where Related Account is not null
   * @param setOfLeadIds
   * @return List<Lead>
   **/
  public List<Lead> getLeads(Set<ID> setOfLeadIds) {
    if (setOfLeadIds.isEmpty()) {
      return new List<Lead>();
    }
    return [
      SELECT Id, FinServ__RelatedAccount__c
      FROM Lead
      WHERE
        FinServ__RelatedAccount__c != NULL
        AND Id IN :setOfLeadIds
        AND RecordTypeId = :CCRMConstants.CCRM_LEAD_RT_ID
      WITH USER_MODE
    ];
  }
}
