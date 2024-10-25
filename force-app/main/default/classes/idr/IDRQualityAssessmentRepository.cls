/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRQualityAssessmentActions.
 * @runTests QualityAssessmentActionsTest
 */
public with sharing class IDRQualityAssessmentRepository {
  /**
   * @description get Cases with Completed Evaluation field to be updated
   * @param caseIds set of all case ids coming from Trigger Context
   * @return List Of Cases
   */
  public List<Case> getCases(Set<Id> caseIds) {
    return [
      SELECT Id, IDR_Completed_Evaluations__c
      FROM Case
      WHERE Id IN :caseIds
    ];
  }

  /**
   * @description Get all Quality Assessments which are not shared with the current user
   * @param caseIds set of all case ids
   * @param records records in current Trigger
   * @return List Of Quality Assessments
   */
  public List<Quality_Assessment__c> getQualityAssessments(
    Set<Id> caseIds,
    List<Quality_Assessment__c> records
  ) {
    QualityAssessmentsRetriever qaRt = new QualityAssessmentsRetriever();
    List<Quality_Assessment__c> assessments = qaRt.retrieveQualityAssessments(
      caseIds,
      records
    );
    return assessments;
  }

  /**
   * @description Wrapper class for QualityAssessments
   */
  private without sharing class QualityAssessmentsRetriever {
    /**
     * @description Get all Quality Assessments which are not currently shared with the current user
     * @param caseIds set of all case ids we need
     * @param records records in current Trigger
     * @return List Of Quality Assessments
     */
    private List<Quality_Assessment__c> retrieveQualityAssessments(
      Set<Id> caseIds,
      List<Quality_Assessment__c> records
    ) {
      return [
        SELECT
          Id,
          Related_Case__c,
          Related_Case__r.IDR_Completed_Evaluations__c,
          Status__c,
          Evaluation_Type__c
        FROM Quality_Assessment__c
        WHERE
          Related_Case__c IN :caseIds
          AND ID NOT IN :records
          AND Status__c = :IDRConstants.STATUS_COMPLETE
      ];
    }
  }
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
    ];
  }
}
