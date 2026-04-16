/**
 * @author Hrushikesh
 * @since 10/2024
 * @description DisputesCaseActions class is to handle all the actions related to disputes
 */
public with sharing class DisputesCaseActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final IDOpsQueryRepository QUERY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );

  public static final Set<String> TASK_STATUSES = new Set<String>{
    'Not Started',
    'Pending'
  };

  public static final String CASE_CLOSURE_ERR_MSG = 'This case has outstanding merchant evidence to review. Please review the evidence before attempting to close the case and action the associated task.';
  /**
   * @description Create a External Case Status when dispute is inserted.
   * @param records List of Case records from Trigger.new
   * @param statusMappingMetadataDevName metadat record dev name
   */
  public static void createExternalCaseStatuses(
    List<Case> records,
    String statusMappingMetadataDevName
  ) {
    List<External_Case_Status__c> externalCaseStatuses = new List<External_Case_Status__c>();

    External_Case_Status_Mapping__mdt statusMappingMetadata = External_Case_Status_Mapping__mdt.getInstance(
      statusMappingMetadataDevName
    );

    for (Case record : records) {
      External_Case_Status__c externalCaseStatus = GetHelpCaseActions.populateExternalCaseStatuses(
        record,
        statusMappingMetadata
      );
      externalCaseStatuses.add(externalCaseStatus);
    }
    /**
     * Reason for using withoutSharing()
     * In Case of Suspected Fraud and Submitted__c is equal to False, we need to create External Case Status in system mode as the owner of the case will be changed to a queue which will cause the record level access issue for the running user. Hence inserting the records in system mode without sharing to avoid any access issue.
     * For other dispute reasons, we can insert the records in user mode as there won't be any record level access issue for the running user.
     */
    DML_REPOSITORY.doInsert(
      externalCaseStatuses,
      new DmlConfig().systemMode().withoutSharing()
    );
  }

  /**
   * @description check if open task is associated to the case, throw validation error if open task found
   * @param records List of Case records from Trigger.new
   */
  public static void checkForOpenTask(List<Case> records) {
    List<Case> closedCases = ListUtil.filter(records)
      .changedTo(Case.Status, 'Closed')
      .toList();

    Set<Id> caseIds = ListUtil.getIds(closedCases, Case.Id);

    List<Task> tasksList = QUERY.getTaskAssociatedToCase(caseIds);

    List<Task> filteredTasks = ListUtil.filter(tasksList)
      .equals(Task.Status, TASK_STATUSES)
      .equals(Task.Subject, 'Card - Merchant Evident Received')
      .toList();

    Set<Id> caseIdsWithOpenTask = ListUtil.getIds(filteredTasks, Task.WhatId);

    List<Case> errorCases = ListUtil.filter(closedCases)
      .equals(Case.Id, caseIdsWithOpenTask)
      .toList();

    ListUtil.addError(errorCases, CASE_CLOSURE_ERR_MSG);
  }
}
