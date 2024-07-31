/**
 * @author Kopal Goswami
 * @since 01/2024
 * @description This is used to Update the Task record when a ResidentialLoanApplication is updated.
 */

public with sharing class CoachNudgeTaskAction {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final CoachNudgeRepository COACH_NUDGE_REPOSITORY = (CoachNudgeRepository) Lib_InstanceProvider.forType(
    CoachNudgeRepository.class
  );

  /**
   * @description check whether the RLA related to Task is updated with CANCELLED status and then Update the Task  STATUS to EXPIRE and SUBSTATUS to "*Customer cancelled"
   * @param newRlaRecords  Residential Loan application records from trigger on insert/update
   * @param  oldRlaRecords  Holds records information before update
   */
  public static void processCancelledRLARecords(
    List<ResidentialLoanApplication> newRlaRecords,
    Map<Id, ResidentialLoanApplication> oldRlaRecords
  ) {
    try {
      Set<Id> rlaRecordIds = filterRlaAndReturnCancelledStatusRecords(
        newRlaRecords,
        oldRlaRecords
      );

      List<Task> masterTaskList = COACH_NUDGE_REPOSITORY.queryTaskWithRLA(
        rlaRecordIds
      );

      List<Task> taskRecordsToBeUpdated = prepareTaskWithFieldsUpdate(
        masterTaskList
      );

      DML_REPOSITORY.updateRecords(
        taskRecordsToBeUpdated,
        DmlRepository.ALLOW_PARTIAL,
        DmlRepository.SYSTEM_MODE
      );
    } catch (Exception objException) {
      Logger.error('Error in CoachNudgeTaskAction ', objException);
      Logger.saveLog();
    }
  }

  /**
   * @description To filter out the RLA records with Cancelled status
   * @param newRlaRecords Residential Loan application records from trigger on update
   * @param oldRlaRecords Holds records information before update
   * @return Residential Loan Application records with Cancelled status to process
   */
  @TestVisible
  private static Set<Id> filterRlaAndReturnCancelledStatusRecords(
    List<ResidentialLoanApplication> newRlaRecords,
    Map<Id, ResidentialLoanApplication> oldRlaRecords
  ) {
    Set<Id> rlaRecordIds = new Set<Id>();
    for (ResidentialLoanApplication rlaRecord : newRlaRecords) {
      if (
        (RecordComparisonUtil.fieldWasChanged(
          rlaRecord,
          oldRlaRecords.get(rlaRecord.Id),
          ResidentialLoanApplication.Status
        )) && (rlaRecord.Status == GetHelpConstants.RLA_STATUS_CANCELLED)
      ) {
        rlaRecordIds.add(rlaRecord.Id);
      }
    }
    return rlaRecordIds;
  }

  /**
   * @description prepareTaskWithFieldsUpdate prepare task record's field value which needs to be updated
   * @param masterTaskList master list of Task with all the related detail
   * @return List<Task>  task records with status value as expired and sub status field value as Customer Cancelled.
   */
  @TestVisible
  private static List<Task> prepareTaskWithFieldsUpdate(
    List<Task> masterTaskList
  ) {
    if (masterTaskList.isEmpty()) {
      return new List<Task>();
    }
    List<Task> taskRecordsToBeUpdated = new List<Task>();
    for (Task taskRecord : masterTaskList) {
      taskRecord.Status = GetHelpTaskActions.TASK_STATUS_EXPIRED;
      taskRecord.Sub_Status__c = GetHelpTaskActions.TASK_SUB_STATUS_CUSTOMER_CANCELLED;
      taskRecordsToBeUpdated.add(taskRecord);
    }
    return taskRecordsToBeUpdated;
  }
}
