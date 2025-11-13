/**
 * @author Hrushikesh
 * @since 10/2025
 * @description Action class for Case Management- Assisted Transfer.
 */
public with sharing class AssistedTransferActions {
  public static final String CASE_DEFAULT_SUBJECT = 'Assisted Transfer';
  private static final String ON_HOLD_CASE_STATUS = 'On Hold';
  public static final String CASE_STATUS_CLOSED = 'Closed';
  public static final String AWAITING_SUPPORT_COACH_ACTION_SUB_STATUS = 'Awaiting Support Coach Action';

  private static final AssistedTransferRepository ASSISTED_TRANSFER_REPO = (AssistedTransferRepository) Lib_InstanceProvider.forType(
    AssistedTransferRepository.class
  );

  /**
   * @description populate related Subject on Case records
   * @param records Case records that are inserted
   */
  public static void setSubject(List<Case> records) {
    ListUtil.setField(records, Case.Subject, CASE_DEFAULT_SUBJECT);
  }

  /**
   * @description Get a list of account Ids related to entitlement enabled cases
   * @param caseList a list of cases that we need to get account ids from
   */
  public static void updateEntitlementOnCase(List<Case> caseList) {
    List<Case> eligibleRecords = ListUtil.filter(caseList)
      .isNotNull(Case.AccountId)
      .toList();

    Set<Id> accountIds = ListUtil.getIds(eligibleRecords, Case.AccountId);

    Map<Id, Entitlement> entMap = (Map<Id, Entitlement>) ListUtil.mapBy(
      ASSISTED_TRANSFER_REPO.getEntitlements(
        accountIds,
        GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
      ),
      Case.AccountId
    );
    for (Case caseRecord : eligibleRecords) {
      if (entMap.containsKey(caseRecord.AccountId)) {
        caseRecord.EntitlementId = entMap.get(caseRecord.AccountId).Id;
      }
    }
  }

  /**
   * @description Marks the IsStopped field base on Status.
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void markSLAStatus(List<Case> records, Map<Id, Case> oldMap) {
    List<Case> onHoldCases = ListUtil.filter(records, oldMap)
      .changed(Case.Status)
      .toList();
    for (Case caseRecord : onHoldCases) {
      caseRecord.IsStopped = (caseRecord.Status == ON_HOLD_CASE_STATUS);
    }
  }

  /**
   * @description close the milestone once status of Case is closed
   * @param records Case records that are updated
   * @param oldMap old map of Case records
   */
  public static void completeMilestone(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> eligibleRecordsForClosure = ListUtil.filter(records, oldMap)
      .changedTo(Case.Status, CASE_STATUS_CLOSED)
      .toList();

    Map<Id, Case> caseMap = new Map<Id, Case>(eligibleRecordsForClosure);

    MilestoneUtils.completeMilestone(
      new List<Id>(caseMap.keySet()),
      CaseGroupCaseConstants.RESOLUTION_TIME_MILESTONE,
      System.now()
    );
  }

  /**
   * @description updates owner of Case to their Manager if SLA Status is breached
   * @param records Case records that are updated
   * @param oldMap old map of Case records
   */
  public static void updateOwnerOnSubStatusChange(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Id supportCoachQueue = QueryQueue.supportCoachQueue.Id;
    List<Case> eligibleRecordsForEscalation = ListUtil.filter(records, oldMap)
      .changed(Case.Sub_Status__c)
      .equals(Case.Sub_Status__c, AWAITING_SUPPORT_COACH_ACTION_SUB_STATUS)
      .toList();

    ListUtil.setField(
      eligibleRecordsForEscalation,
      Case.OwnerId,
      supportCoachQueue
    );
  }
}
