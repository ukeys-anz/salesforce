/**
 * @author Tan Phan
 * @since 04/2024
 * @description This class provides methods to update the status and owner of related cases based on the latest external case status.
 * @runTests DisputeExternalCaseStatusActionsTest
 */
public with sharing class DisputeExternalCaseStatusActions {
  private static Map<String, PegaExternalCaseStatuses__mdt> statusMappings {
    private get {
      if (statusMappings != null) {
        return statusMappings;
      }
      statusMappings = new Map<String, PegaExternalCaseStatuses__mdt>();
      if (!Schema.SObjectType.PegaExternalCaseStatuses__mdt.isQueryable()) {
        return statusMappings;
      }
      for (PegaExternalCaseStatuses__mdt mapping : [
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
      ]) {
        if (String.isBlank(mapping.DisputeReason__c)) {
          statusMappings.put(
            mapping.RecordType__c + mapping.ExternalStatus__c,
            mapping
          );
        } else {
          for (String disputeReason : mapping.DisputeReason__c.split(';')) {
            statusMappings.put(
              mapping.RecordType__c +
                mapping.ExternalStatus__c +
                disputeReason.trim(),
              mapping
            );
          }
        }
      }
      return statusMappings;
    }
    private set;
  }

  /**
   * @description Updates the status and owner of related cases based on the latest external case status.
   * @param caseStatuses The list of external case statuses.
   */
  public static void updateRelatedCasesStatusAndOwner(
    List<External_Case_Status__c> caseStatuses
  ) {
    List<Case> casesToUpdate = new List<Case>();
    for (Case caseWithStatuses : queryRelatedCases(caseStatuses)) {
      Case updatedCase = setCaseStatusAndOwner(caseWithStatuses);
      if (updatedCase != null) {
        casesToUpdate.add(updatedCase);
      }
    }
    if (!casesToUpdate.isEmpty()) {
      DMLUtil.updateRecords(
        casesToUpdate,
        !DMLUtil.ALL_OR_NOTHING,
        DMLUtil.USER_MODE
      );
    }
  }

  /**
   * @description Retrieves the related cases with their associated external case statuses.
   * @param caseStatuses The list of external case statuses.
   * @return The list of cases with their associated external case statuses.
   */
  private static List<Case> queryRelatedCases(
    List<External_Case_Status__c> caseStatuses
  ) {
    return queryCasesWithLatestStatus(getParentCaseIds(caseStatuses));
  }

  /**
   * @description Returns a set of parent case IDs based on the provided list of External_Case_Status__c records.
   *
   * @param caseStatuses The list of External_Case_Status__c records.
   * @return A set of parent case IDs.
   */
  public static Set<Id> getParentCaseIds(
    List<External_Case_Status__c> caseStatuses
  ) {
    Set<Id> caseIds = new Set<Id>();
    for (External_Case_Status__c caseStatus : caseStatuses) {
      if (caseStatus.Case__c != null) {
        caseIds.add(caseStatus.Case__c);
      }
    }
    return caseIds;
  }

  /**
   * @description Retrieves a list of Case records with their latest External Case Statuses.
   * @param caseIds A set of Case record IDs to query.
   * @return A list of Case records with their latest External Case Statuses.
   */
  public static List<Case> queryCasesWithLatestStatus(Set<Id> caseIds) {
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
      WITH USER_MODE
    ];
  }

  /**
   * @description Sets the status and owner of the given case based on the provided case status.
   * @param theCase The case for which to set the status and owner.
   * @return new instance of the case record to be updated
   */
  public static Case setCaseStatusAndOwner(Case theCase) {
    PegaExternalCaseStatuses__mdt mapping = getMapping(theCase);
    if (mapping == null) {
      return null;
    }
    Group queue = CommonUtil.getQueueByName(mapping.QueueName__c);
    if (queue == null) {
      return null;
    }
    if (
      theCase.Status == mapping.DisputeStatus__c &&
      theCase.OwnerId == queue.Id
    ) {
      return null;
    }
    return new Case(
      Id = theCase.Id,
      Status = mapping.DisputeStatus__c,
      OwnerId = queue.Id
    );
  }

  /**
   * @description Retrieves the mapping for a given Case and External_Case_Status__c.
   * @param theCase The Case object for which the mapping is being retrieved.
   * @return The PegaExternalCaseStatuses__mdt mapping for the given Case and External_Case_Status__c.
   */
  @testVisible
  private static PegaExternalCaseStatuses__mdt getMapping(Case theCase) {
    if (theCase.External_Case_Statuses__r.isEmpty()) {
      return null;
    }
    External_Case_Status__c caseStatus = theCase.External_Case_Statuses__r[0];
    String key =
      theCase.RecordType.DeveloperName + caseStatus.External_Status__c;
    String keyWithReason = key + theCase.Dispute_Reason__c;

    return statusMappings.containsKey(keyWithReason)
      ? statusMappings.get(keyWithReason)
      : statusMappings.get(key);
  }

  /**
   * @description Queries the External Case Statuses that are within the SLA time frame.
   * It retrieves the necessary information from the PegaExternalCaseStatuses__mdt custom metadata type,
   * and constructs a dynamic SOQL query to fetch the relevant External Case Status records.
   * @return A list of External Case Status records that are within the SLA time frame.
   */
  public static List<External_Case_Status__c> queryCaseStatusesInSla() {
    Set<String> statusesToCheckSla = new Set<String>();
    Set<String> caseStatusesToCheckSla = new Set<String>();
    Set<String> recordTypesToCheckSla = new Set<String>();
    Set<Integer> slaDays = new Set<Integer>();

    for (PegaExternalCaseStatuses__mdt mapping : statusMappings.values()) {
      if (mapping.SLADaysInStatus__c != null) {
        statusesToCheckSla.add(mapping.ExternalStatus__c);
        caseStatusesToCheckSla.add(mapping.DisputeStatus__c);
        recordTypesToCheckSla.add(mapping.RecordType__c);
        slaDays.add((Integer) mapping.SLADaysInStatus__c);
        slaDays.add((Integer) mapping.SLADaysInStatus__c * 2);
      }
    }
    if (statusesToCheckSla.isEmpty()) {
      return new List<External_Case_Status__c>();
    }
    List<External_Case_Status__c> caseStatuses = Database.query(
      'SELECT Case__c ' +
        'FROM External_Case_Status__c ' +
        'WHERE External_Status__c IN :statusesToCheckSla ' +
        ' AND Case__r.Status IN :caseStatusesToCheckSla' +
        ' AND Case__r.RecordType.DeveloperName IN :recordTypesToCheckSla' +
        ' AND Status_TimeStamp__c IN (N_DAYS_AGO:' +
        String.join(new List<Integer>(slaDays), ',N_DAYS_AGO:') +
        ') LIMIT 1000',
      AccessLevel.USER_MODE
    );

    return caseStatuses;
  }

  /**
   * @description Executes asynchronously to assign cases to the SLA queue based on their status and SLA days.
   * @param caseIds A set of Case Ids representing the cases to be processed.
   */
  @future
  public static void assignCaseToSlaQueueAsync(Set<Id> caseIds) {
    List<Case> casesToUpdate = new List<Case>();
    for (Case theCase : queryCasesWithLatestStatus(caseIds)) {
      PegaExternalCaseStatuses__mdt mapping = getMapping(theCase);
      if (
        mapping == null ||
        mapping.SLADaysInStatus__c == null ||
        mapping.SLADaysInStatus__c == 0 ||
        mapping.SLAQueueName__c == null
      ) {
        continue;
      }
      Group slaQueue = CommonUtil.getQueueByName(mapping.SLAQueueName__c);
      if (slaQueue == null || theCase.OwnerId == slaQueue.Id) {
        continue;
      }
      Integer slaDays = (Integer) mapping.SLADaysInStatus__c;
      Integer caseDays = theCase.External_Case_Statuses__r[0]
        .Status_TimeStamp__c.date()
        .daysBetween(Date.today());
      if (caseDays == slaDays || caseDays == slaDays * 2) {
        casesToUpdate.add(new Case(Id = theCase.Id, OwnerId = slaQueue.Id));
      }
    }
    if (!casesToUpdate.isEmpty()) {
      DMLUtil.updateRecords(
        casesToUpdate,
        !DMLUtil.ALL_OR_NOTHING,
        DMLUtil.USER_MODE
      );
    }
  }
}
