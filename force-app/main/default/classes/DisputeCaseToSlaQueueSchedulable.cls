/**
 * @author Tan Phan
 * @since 04/2024
 * @description Scheduling the assignment of Dispute Cases to the SLA Queue.
 * @runTests DisputeExternalCaseStatusActionsTest
 */
public with sharing class DisputeCaseToSlaQueueSchedulable implements Schedulable {
  /**
   * @description Executes the scheduled job to assign Dispute Cases to the SLA Queue.
   * It queries the External Case Statuses that are within the SLA time frame,
   * and enqueues an asynchronous job to perform the assignment.
   * @param sc The context information for the scheduled job.
   */
  public void execute(SchedulableContext sc) {
    List<External_Case_Status__c> caseStatuses = DisputeExternalCaseStatusActions.queryCaseStatusesInSla();

    if (!caseStatuses.isEmpty()) {
      Set<Id> parentCaseIds = DisputeExternalCaseStatusActions.getParentCaseIds(
        caseStatuses
      );
      DisputeExternalCaseStatusActions.assignCaseToSlaQueueAsync(parentCaseIds);
    }
  }
}
