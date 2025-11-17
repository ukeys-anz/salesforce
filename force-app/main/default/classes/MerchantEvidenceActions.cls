/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 11-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class MerchantEvidenceActions {
  private static final Set<String> TASK_STATUSES = new Set<String>{
    'Not Started',
    'Pending'
  };

  private static final IDOpsQueryRepository QUERY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description creating task records
   * @param externalStatusRecords External Cases records
   */
  public static void createTaskRecords(
    List<External_Case_Status__c> externalStatusRecords
  ) {
    Set<Id> caseIds = ListUtil.getIds(
      externalStatusRecords,
      External_Case_Status__c.Case__c
    );

    Set<Id> existingCaseIdWithOpenTasks = getOpenTasks(caseIds);

    caseIds.removeAll(existingCaseIdWithOpenTasks);

    List<Case> cardCases = getValidCardCases(caseIds);

    performTaskCreation(cardCases);
  }

  /**
   * @description performing operation to get open task records
   * @param caseIds Set of Case ID's
   * @return Set<Id> set of case Ids
   */
  @TestVisible
  private static Set<Id> getOpenTasks(Set<Id> caseIds) {
    List<Task> tasksList = QUERY.getTaskAssociatedToCase(caseIds);

    List<Task> filteredTasks = ListUtil.filter(tasksList)
      .equals(Task.Status, TASK_STATUSES)
      .equals(Task.Subject, 'Card - Merchant Evident Received')
      .toList();

    Set<Id> whatIds = ListUtil.getIds(filteredTasks, Task.WhatId);

    return whatIds;
  }

  /**
   * @description performing operation to get filterd Cases records
   * @param caseIdExternalRecords caseIdExternalRecords
   * @return List<Case> validCardCases
   */
  @TestVisible
  private static List<Case> getValidCardCases(Set<Id> caseIdExternalRecords) {
    List<Case> caseRecords = QUERY.getCaseRecordUsingExternalCases(
      caseIdExternalRecords
    );
    List<Case> cardCases = ListUtil.filter(caseRecords)
      .equals(Case.RecordTypeId, RTCase.cardDispute)
      .toList();
    return cardCases;
  }

  /**
   * @description performing task creation operation
   * @param cardCases List of  Cases
   */
  @TestVisible
  private static void performTaskCreation(List<Case> cardCases) {
    List<Task> taskRecordsToBeCreated = new List<Task>();
    for (Case caseObj : cardCases) {
      Task task = new Task();
      task.WhatId = caseObj.Id;
      task.Subject = 'Card - Merchant Evident Received';
      task.ActivityDate = System.today().addDays(10);
      task.Status = 'Not Started';
      task.Priority = 'Normal';
      task.Description = 'Please Review Merchant Evidence for Personal Information';
      task.OwnerId = QueryQueue.get('Card_Dispute_Merchant_Evidence_Review').Id;
      task.RecordTypeId = RTTask.merchantEvidentReceivedRT;
      taskRecordsToBeCreated.add(task);
    }

    DML_REPOSITORY.doInsert(taskRecordsToBeCreated);
  }
}
