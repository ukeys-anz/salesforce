/**
 * @author Victor Wang
 * @since 08/2021
 * @description QualityAssessmentTaskActions class is to handle Quality Assessment task related actions
 */
public with sharing class QualityAssessmentTaskActions {
  public static final String TASK_SUBJECT_COMPLIANCE_REVIEW = 'Compliance Review';
  public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
  public static final String TASK_PRIORITY_HIGH = 'High';

  /**
   * @description method to create Compliance Task if Quality Assessment record's sub status is changed to Compliance Review
   * @param records new Trigger values
   * @param oldMap old Trigger values
   */
  public static void createComplianceTasks(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Set<Id> breachedQAIds = new Set<Id>();

    for (Quality_Assessment__c record : records) {
      Quality_Assessment__c oldRecord = oldMap?.get(record.Id);

      if (isBreachedQA(record, oldRecord)) {
        breachedQAIds.add(record.Id);
      }
    }

    List<Task> complianceTasks = initComplianceTasks(breachedQAIds);

    insertComplianceTasks(complianceTasks);
  }

  /**
   * @description method to determine if a QA is breached or not
   * @param record current Quality Assessment record
   * @param oldRecord old copy of Quality Assessment record
   * @return Boolean
   */
  @testVisible
  private static Boolean isBreachedQA(
    Quality_Assessment__c record,
    Quality_Assessment__c oldRecord
  ) {
    if (oldRecord == null) {
      return record.Status__c == QualityAssessmentActions.STATUS_REFERRED &&
        record.Sub_Status__c ==
        QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW;
    } else {
      return oldRecord.Status__c != QualityAssessmentActions.STATUS_REFERRED &&
        oldRecord.Sub_Status__c !=
        QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW &&
        record.Status__c == QualityAssessmentActions.STATUS_REFERRED &&
        record.Sub_Status__c ==
        QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW;
    }
  }

  /**
   * @description method to initialize new Compliance tasks for a list of Quality Assessment
   * @param recordIds breached Quality Assessment record ids
   * @return List<Task> a list of tasks to insert
   */
  private static List<Task> initComplianceTasks(Set<Id> recordIds) {
    if (recordIds == null || recordIds.size() == 0) {
      return null;
    }

    Group complianceTaskQueue = CommonUtil.getQueueByName('Compliance_Tasks');

    List<Task> tasksToInsert = new List<Task>();

    try {
      if (Quality_Assessment__c.SObjectType.getDescribe().isAccessible()) {
        for (Quality_Assessment__c record : [
          SELECT
            Id,
            Customer__c,
            Customer__r.PersonContactId,
            Interaction_Owner__c,
            Interaction_Owner__r.Name
          FROM Quality_Assessment__c
          WHERE Id IN :recordIds
        ]) {
          tasksToInsert.add(
            new Task(
              RecordTypeId = GetHelpConstants.TASK_COMPLIANCE_RT_ID,
              WhatId = record.Id,
              WhoId = record.Customer__r?.PersonContactId,
              OwnerId = complianceTaskQueue.Id,
              ActivityDate = Date.today().addDays(5),
              Subject = TASK_SUBJECT_COMPLIANCE_REVIEW,
              Priority = TASK_PRIORITY_HIGH,
              Status = TASK_STATUS_NOT_STARTED,
              Interaction_Owner__c = record.Interaction_Owner__r?.Name
            )
          );
        }
      }
    } catch (System.QueryException e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();

      return null;
    }

    return tasksToInsert;
  }

  /**
   * @description method to insert Compliance Tasks
   * @param records task records to insert
   */
  private static void insertComplianceTasks(List<Task> records) {
    if (records == null || records.size() == 0) {
      return;
    }

    List<Database.SaveResult> results = Database.insert(records, false);

    Logger.error('', results);
    Logger.saveLog();
  }
}
