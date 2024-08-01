/**
 * @author CMOS
 * @since  03/2024
 * @description IDRCaseActionsHelper is class to handle all the IDR (Internal Dispute Resolution) Actions
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCaseActionsHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final IDRCaseActionsRepository CASE_REPOSITORY = (IDRCaseActionsRepository) Lib_InstanceProvider.forType(
    IDRCaseActionsRepository.class
  );
  /**
   * @description Populate modified date when the picklist value is updated
   * @param record  from the trigger
   * @param oldCaserecord Old Record from the trigger
   * @return DateTime returning DateTime value
   */
  public static DateTime populateHardshipUpdateDate(
    Case record,
    Case oldCaserecord
  ) {
    if (
      record.IDR_Is_Hardship_Resolution_Letter_Sent__c ==
      oldCaserecord.IDR_Is_Hardship_Resolution_Letter_Sent__c
    ) {
      return record.IDR_Hardship_Response_updated_on__c;
    }
    return DateTime.now();
  }

  /**
   * @description populateOldOwnerID(record, oldRecord) method handles the following
   * 1. Assigns old owner to Previous Case Owner
   * 2. Assigns the date/time to Date Case Allocated to CM.
   * @param record from the trigger
   * @param oldRecord old Value of the trigger record.
   * @return Id
   */
  public static Id populateOldOwnerID(Case record, Case oldRecord) {
    ID oldOwner = oldRecord.OwnerId;
    if (record.OwnerId == oldOwner) {
      return record.Previous_Case_Owner__c;
    }
    if (oldOwner.getSObjectType() == Group.SObjectType) {
      return null;
    }
    return oldOwner;
  }

  /**
   * @description populateDateCaseAllocatedToCM(record, oldRecord) method handles the following
   * 1. Assigns old owner to Previous Case Owner
   * 2. Assigns the date/time to Date Case Allocated to CM.
   * @param record from the trigger
   * @param oldRecord old Value of the trigger record.
   * @return DateTime
   */
  public static DateTime populateDateCaseAllocatedToCM(
    Case record,
    Case oldRecord
  ) {
    ID newOwner = record.OwnerId;
    if (newOwner == oldRecord.OwnerId) {
      return record.Date_Case_allocated_to_CM__c;
    }
    if (newOwner.getSObjectType() == User.SObjectType) {
      return DateTime.now();
    }
    return null;
  }
  /**
   * @description Populate Date/time Registration Response Provided when AFCA Registration Response Provided is checked
   * @param oldRecord old Record of pre-update cases supplied from the trigger as well
   * @param newRecord new Record of cases from the trigger
   * @return DateTime
   */
  public static DateTime populateAfcaRegistrationResponseDate(
    Case oldRecord,
    Case newRecord
  ) {
    if (
      oldRecord.IDR_AFCA_Registration_Response_Provided__c ==
      newRecord.IDR_AFCA_Registration_Response_Provided__c
    ) {
      return newRecord.Date_time_Registration_Response_Provided__c;
    }

    if (!newRecord.IDR_AFCA_Registration_Response_Provided__c) {
      return newRecord.Date_time_Registration_Response_Provided__c;
    }
    return DateTime.now();
  }

  /**
   * @description Updates related PEND task to Completed
   * @param records case list in current context
   * @param oldMap old map of the cases in current context
   */
  public static void updateTaskStatustoCompleted(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Map<Id, Case> caseIds = identifyCaseStatusChange(records, oldMap);

    List<Task> lstTasks = (List<Task>) CASE_REPOSITORY.queryPendTasks(
      caseIds.keyset()
    );

    lstTasks = setTaskstatustoCompleted(lstTasks);

    DML_REPOSITORY.updateRecords(
      lstTasks,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }
  /**
   * @description To identify and return the cases that match the criteria of case status change
   * @param records case Ids in current context
   * @param oldMap old map of the cases in current context
   * @return Map of caseIds
   */
  @TestVisible
  private static Map<Id, Case> identifyCaseStatusChange(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Map<Id, Case> caseMap = new Map<Id, Case>();
    Set<String> newCaseStatus = new Set<String>{
      IDRConstants.REOPENED_STATUS,
      IDRConstants.ESCALATED_STATUS
    };
    for (Case c : records) {
      Case oldRec = oldMap.get(c.Id);

      if (
        oldRec.Status == IDRConstants.ON_HOLD_STATUS &&
        newCaseStatus.contains(c.Status)
      ) {
        caseMap.put(c.Id, c);
      }
    }

    return caseMap;
  }
  /**
   * @description Sets the status of the task to Completed
   * @param lstTasks List of tasks
   * @return list of tasks to be updated
   */
  @TestVisible
  private static List<Task> setTaskstatustoCompleted(List<Task> lstTasks) {
    List<Task> tasksToUpdate = new List<Task>();
    for (Task oTask : lstTasks) {
      oTask.Status = IDRConstants.TASK_STATUS_COMPLETED;
      taskstoUpdate.add(oTask);
    }
    return tasksToUpdate;
  }
}
