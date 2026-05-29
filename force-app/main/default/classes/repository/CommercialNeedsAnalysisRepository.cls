/**
 * @author       : Mildeep Singh
 * @since        : Aug 2025
 * @description  : This is the Repository class for CommercialNeedsAnalysisTrigger
 **/
public with sharing class CommercialNeedsAnalysisRepository {
  /**
   * @description : Used to get customer records for opportunity attached to needs_analysis__c
   * @name : getCustomerRecordUsingOpportunity
   * @param oppIdsFromNArecords Set of Ids of Opportunity from Needs Analysis
   * @return List<Opportunity>
   */
  public List<Opportunity> getCustomerRecordUsingOpportunity(
    Set<Id> oppIdsFromNArecords
  ) {
    if (oppIdsFromNArecords.isEmpty()) {
      return new List<Opportunity>();
    }
    return [
      SELECT AccountId, CLG__c
      FROM Opportunity
      WHERE Id IN :oppIdsFromNArecords
      WITH USER_MODE
    ];
  }
}
