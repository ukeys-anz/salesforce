/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRQualityAssessmentActions.
 * @runTests QualityAssessmentActionsTest
 */
public with sharing class IDRQualityAssessmentRepository {
  /**
   * @description Get Quality Assessments Share records
   * @param mpId2PendingAssessments Map Id to Quality Assessments
   * @param stUserIds set of Users
   * @return list of Quality Assessment Share records
   */
  public List<Quality_Assessment__Share> getQAShareRecords(
    Map<Id, Quality_Assessment__c> mpId2PendingAssessments,
    Set<Id> stUserIds
  ) {
    if (stUserIds.isEmpty()) {
      return new List<Quality_Assessment__Share>();
    }
    return [
      SELECT Id, UserOrGroupId, ParentId
      FROM Quality_Assessment__Share
      WHERE
        ParentId IN :mpId2PendingAssessments.keySet()
        AND UserOrGroupId IN :stUserIds
      WITH SECURITY_ENFORCED
    ];
  }
}