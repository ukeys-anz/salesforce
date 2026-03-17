/**
 * @author Tan Phan
 * @since 05/2024
 * @description This class provides SOQL and DML helpers for classes related DisputeExternalCaseStatus.
 * @runTests DisputeExternalCaseStatusActionsTest
 */
public with sharing class DisputeExternalCaseStatusRepository {
  /**
   * @description Retrieves custom metadata PegaExternalCaseStatuses__mdt records.
   * @return A list of PegaExternalCaseStatuses__mdt records
   */
  public List<PegaExternalCaseStatuses__mdt> queryMappings() {
    if (!Schema.SObjectType.PegaExternalCaseStatuses__mdt.isQueryable()) {
      return new List<PegaExternalCaseStatuses__mdt>();
    }
    return [
      SELECT
        MasterLabel,
        DisputeReason__c,
        DisputeStatus__c,
        ExternalStatus__c,
        QueueName__c,
        RecordType__c,
        SLADaysInStatus__c,
        SLAQueueName__c
      FROM PegaExternalCaseStatuses__mdt
    ];
  }

  /**
   * @description Queries the External_Case_Status__c records based on the provided query and bind map.
   * @param query The SOQL query string.
   * @param bindMap The map of bind variables used in the query.
   * @return A list of External_Case_Status__c records that match the query.
   */
  public List<External_Case_Status__c> queryCaseStatuses(
    String query,
    Map<String, Object> bindMap
  ) {
    return Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
  }

  /**
   * @description Retrieves a list of Case records with their latest External Case Statuses.
   * @param caseIds A set of Case record IDs to query.
   * @return A list of Case records with their latest External Case Statuses.
   */
  public List<Case> queryCasesWithLatestStatus(Set<Id> caseIds) {
    return [
      SELECT
        Id,
        Dispute_Reason__c,
        OwnerId,
        Status,
        RecordType.DeveloperName,
        (
          SELECT External_Status__c, Status_TimeStamp__c
          FROM External_Case_Statuses__r
          ORDER BY Status_TimeStamp__c DESC, Name DESC
          LIMIT 1
        )
      FROM Case
      WHERE Id IN :caseIds
    ];
  }

  /**
   * @description getRelatedCasesByCaseId is to query case Id based on relatedCaseIds
   * @param relatedCaseIds Set of related Case ids to be queried
   * @return A list of Case records
   */
  public List<Case> getRelatedCasesByCaseId(Set<Id> relatedCaseIds) {
    // Check if relatedCaseIds is null or empty
    if (relatedCaseIds == null || relatedCaseIds.isEmpty()) {
      return new List<Case>(); // Return empty list if no IDs are provided
    }

    // Perform the SOQL query to retrieve the related cases
    return [
      SELECT
        Id,
        CaseNumber,
        Dispute_Reason__c,
        RecordTypeId,
        Account.OCV_ID__c,
        Transaction_UUID__c,
        OCV_ID__c,
        LastModifiedDate,
        AccountId,
        Account.Source_System_Name__c,
        Account.Source_System_ID__c,
        Account.PersonEmail,
        Account.PersonMobilePhone,
        Account.FirstName,
        Account.LastName
      FROM Case
      WHERE Id IN :relatedCaseIds
    ];
  }

  /**
   * @description getRelatedUsersByUserId is to query User list based on relatedUserIds
   * @param relatedUserIds Set of related User ids to be queried
   * @return A list of users related to Case records
   */
  public List<User> getRelatedUsersByUserId(Set<Id> relatedUserIds) {
    // Check if relatedCaseIds is not null and not empty
    if (relatedUserIds == null || relatedUserIds.isEmpty()) {
      return new List<User>();
    }

    return [SELECT Id, Email, UserName FROM User WHERE Id IN :relatedUserIds];
  }
}
