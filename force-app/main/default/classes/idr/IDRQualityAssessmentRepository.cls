/**
 * @since 07/2024
 * @description This class provides SOQL and DML helpers for classes related IDRQualityAssessmentActions.
 * @runTests QualityAssessmentActionsTest
 */
public with sharing class IDRQualityAssessmentRepository {
  /**
   * @description Get Quality Assessment Share records
   * @param qaIds set of Quality Assessment Ids
   * @param stUserIds set of Users
   * @return `List<Quality_Assessment__Share>` of Quality Assessment Share records
   */
  public List<Quality_Assessment__Share> getQAShareRecords(
    Set<Id> qaIds,
    Set<Id> stUserIds
  ) {
    if (stUserIds.isEmpty()) {
      return new List<Quality_Assessment__Share>();
    }
    return [
      SELECT Id, UserOrGroupId, ParentId
      FROM Quality_Assessment__Share
      WHERE
        ParentId IN :qaIds
        AND UserOrGroupId IN :stUserIds
        AND RowCause = 'Manual'
      WITH USER_MODE
    ];
  }
  /**
   * @description Get Quality Assessments
   * @param assessmentIds Set of Quality Assessment Ids
   * @param correctActionRecords Set of Correct Action Records
   * @return `List<Quality_Assessment__c>` return list of Quality Assessments
   */
  public List<Quality_Assessment__c> getQualityAssessments(
    Set<Id> assessmentIds,
    Set<Id> correctActionRecords
  ) {
    if (assessmentIds.isEmpty() && correctActionRecords.isEmpty()) {
      return new List<Quality_Assessment__c>();
    }
    return [
      SELECT
        Id,
        OwnerId,
        TeamManager__c,
        TeamManager__r.Name,
        Case_Manager__c,
        Case_Manager__r.Name,
        Related_Case__r.CaseNumber__c
      FROM Quality_Assessment__c
      WHERE
        (Id IN :assessmentIds
        AND TeamManager__c != NULL
        AND Case_Manager__c != NULL)
        OR (Id IN :correctActionRecords
        AND TeamManager__c != NULL)
      WITH USER_MODE
    ];
  }
  /**
   * @description Get Open Tasks for Quality Assessments
   * @param qualityAssessmentIds Set of Quality Assessment Ids
   * @return `List<Task>` return list of Tasks
   */
  public List<Task> getOpenTask(Set<Id> qualityAssessmentIds) {
    if (qualityAssessmentIds.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT Id, Status, Subject
      FROM Task
      WHERE
        Status = :IDRConstants.OPEN_STATUS
        AND WhatId IN :qualityAssessmentIds
      WITH USER_MODE
    ];
  }
}
