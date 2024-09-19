/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRCaseActions.
 * @runTests IDRTaskActionsTest
 */
public with sharing class IDRTaskActionsRepository {
  /**
   * @description Query cases to get the ownerId
   * @param caseIds case Ids in current context
   * @return list of cases
   */
  public List<Case> queryCases(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, OwnerId
      FROM Case
      WHERE Id IN :caseIds
    ];
  }
  /**
   * @description Quality Assessments for validating QA Compliance Task
   * @param assessmentIds Quality Assessmnet Ids in current context
   * @return list of Quality Assessments
   */
  public List<Quality_Assessment__c> queryQualityAssessments(
    Set<Id> assessmentIds
  ) {
    if (assessmentIds.isEmpty()) {
      return new List<Quality_Assessment__c>();
    }
    return [
      SELECT
        Id,
        Team_Manager_Response__c,
        Team_Manager_Comments__c,
        Case_Manager__c,
        Case_Manager__r.Name,
        Related_Case__r.CaseNumber__c
      FROM Quality_Assessment__c
      WHERE Id IN :assessmentIds
      WITH SECURITY_ENFORCED
    ];
  }
}
