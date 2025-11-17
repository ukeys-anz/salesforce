/**
 * @author Greg Shaw
 * @since 09/2023
 * @description Quality Assessment task related actions for CMOS
 * @runTests IDRQualityAssessmentTaskActionsTest
 */
public with sharing class IDRQualityAssessmentTaskActions {
  static final IDRQualityAssessmentRepository QA_REPOSITORY = (IDRQualityAssessmentRepository) Lib_InstanceProvider.forType(
    IDRQualityAssessmentRepository.class
  );
  static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  static final Set<String> ALLOWED_RECORD_TYPES = new Set<String>{
    RTQualityAssessment.idrCQQualityId,
    RTQualityAssessment.idrReviewAssessmentId
  };
  static final String CORRECTIVE_ACTIONS_ATTESTATION_SUBJECT =
    IDRConstants.TASK_QA_FEEDBACK_SUBJECT + ' {0} Completed for {1}';
  /**
   * @description For all Assessments going from Completed to Pending set their Compliance Tasks to Expired.
   * @param newList new Trigger Values
   * @param oldMap old Trigger Values
   */
  public static void checkOnReversionFromComplete(
    List<Quality_Assessment__c> newList,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> filterRecords = getValidAssessmentRecords(
      newList,
      oldMap
    );

    Set<Id> filteredCaseManagerIds = ListUtil.getIds(
      filterRecords,
      Quality_Assessment__c.Case_Manager__c
    );

    Set<Id> caseManagerIds = new Set<Id>();
    caseManagerIds.addAll(filteredCaseManagerIds);
    caseManagerIds.addAll(getCQTeamManagerIds(filterRecords));
    caseManagerIds.addAll(getTeamManagerIds(filterRecords));

    Set<Id> qaIds = ListUtil.getIds(filterRecords, Quality_Assessment__c.Id);
    List<Task> taskRecords = QA_REPOSITORY.getOpenTask(qaIds);
    List<Task> filterTaskRecords = filterTask(taskRecords);

    ListUtil.setField(
      filterTaskRecords,
      Task.Status,
      IDRConstants.TASK_STATUS_EXPIRED
    );
    DML_REPOSITORY.doUpdate(filterTaskRecords);

    List<Quality_Assessment__Share> qaShareRecords = QA_REPOSITORY.getQAShareRecords(
      qaIds,
      caseManagerIds
    );

    DML_REPOSITORY.doDelete(qaShareRecords, new DMLConfig().withoutSharing());
  }
  /**
   * @description Filters the given list of Task records.
   * @param taskRecords List of Task records.
   * @return `List<Task>` Filtered Task records.
   */
  static List<Task> filterTask(List<Task> taskRecords) {
    List<Task> filteredTask = new List<Task>();
    for (Task record : taskRecords) {
      if (
        !record.Subject.startsWith(IDRConstants.TASK_QA_COMPLIANCE_SUBJECT) &&
        !record.Subject.startsWith(IDRConstants.TASK_TM_ATTESTATION_SUBJECT) &&
        !record.Subject.startsWith(IDRConstants.TASK_QA_FEEDBACK_SUBJECT)
      ) {
        continue;
      }
      filteredTask.add(record);
    }
    return filteredTask;
  }
  /**
   * @description Filters the given list of Quality Assessment records where record type is Call_Letter_Review_Assessment and owner is not equal to Team manager.
   * @param qaRecords List of Quality Assessment records.
   * @return `Set<Id>` Filtered Team Managers Ids.
   */
  static Set<Id> getTeamManagerIds(List<Quality_Assessment__c> qaRecords) {
    List<Quality_Assessment__c> filteredRecords = ListUtil.filter(qaRecords)
      .equals(
        Quality_Assessment__c.RecordTypeId,
        RTQualityAssessment.idrReviewAssessmentId
      )
      .notEqualsToField(
        Quality_Assessment__c.OwnerId,
        Quality_Assessment__c.TeamManager__c
      )
      .toList();
    return ListUtil.getIds(
      filteredRecords,
      Quality_Assessment__c.TeamManager__c
    );
  }
  /**
   * @description Filters the given list of Quality Assessment records where record type is C_Q_Assessment.
   * @param qaRecords List of Quality Assessment records.
   * @return `Set<Id>` Filtered Team Managers Ids.
   */
  static Set<Id> getCQTeamManagerIds(List<Quality_Assessment__c> qaRecords) {
    List<Quality_Assessment__c> filteredRecords = ListUtil.filter(qaRecords)
      .equals(
        Quality_Assessment__c.RecordTypeId,
        RTQualityAssessment.idrCQQualityId
      )
      .toList();
    return ListUtil.getIds(
      filteredRecords,
      Quality_Assessment__c.TeamManager__c
    );
  }
  /**
   * @description Filters the given list of Quality Assessment records where record type is C_Q_Assessment or Call_Letter_Review_Assessment and status is changed from Completed to Pending or Withdrawn.
   * @param newList new Trigger Values
   * @param oldMap old Trigger Values
   * @return `List<Quality_Assessment__c>` Filtered Quality Assessment records.
   */
  static List<Quality_Assessment__c> getValidAssessmentRecords(
    List<Quality_Assessment__c> newList,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Set<String> allowedStatus = new Set<String>{
      QualityAssessmentActions.STATUS_PENDING,
      QualityAssessmentActions.STATUS_WITHDRAWN
    };
    return ListUtil.filter(newList, oldMap)
      .equals(Quality_Assessment__c.RecordTypeId, ALLOWED_RECORD_TYPES)
      .equals(Quality_Assessment__c.Status__c, allowedStatus)
      .oldEquals(
        Quality_Assessment__c.Status__c,
        QualityAssessmentActions.STATUS_COMPLETE
      )
      .toList();
  }
  /**
   * @description To create Compliance Tasks if Quality Assessment record's status is changed to Completed
   * @param newList new Trigger values
   * @param oldMap old Trigger values
   */
  public static void createComplianceTasks(
    List<Quality_Assessment__c> newList,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> filteredRecords = getCompletedCQAssessments(
      newList,
      oldMap
    );

    Set<Id> filteredRecordsIds = ListUtil.getIds(
      filteredRecords,
      Quality_Assessment__c.Id
    );

    List<Quality_Assessment__c> completedCQAssessments = QA_REPOSITORY.getQualityAssessments(
      filteredRecordsIds
    );
    List<Task> taskRecords = new List<Task>();
    taskRecords.addAll(prepareStandardTask(completedCQAssessments));
    taskRecords.addAll(prepareFeedbackTask(completedCQAssessments));
    DML_REPOSITORY.doInsert(taskRecords, new DmlConfig().systemMode());
  }
  /**
   * @description To prepare a Task for all the QA records updated
   * @param qaRecords List of Quality Assessment object
   * @return `List<Task>` List of Feedback Tasks.
   */
  static List<Task> prepareFeedbackTask(List<Quality_Assessment__c> qaRecords) {
    List<Quality_Assessment__c> filteredRecords = ListUtil.filter(qaRecords)
      .notEquals(Quality_Assessment__c.Corrective_actions_for_TM_CM__c, null)
      .toList();
    List<Task> taskRecords = new List<Task>();
    for (Quality_Assessment__c record : filteredRecords) {
      List<Object> parameters = new List<Object>{
        record.Name,
        record.Case_Manager__r.Name
      };
      String formatted = String.format(
        CORRECTIVE_ACTIONS_ATTESTATION_SUBJECT,
        parameters
      );
      taskRecords.add(
        getTask(record, IDRConstants.TASK_QA_FEEDBACK_DESCRIPTION, formatted)
      );
    }
    return taskRecords;
  }
  /**
   * @description To filter QA records where record type is C_Q_Assessment and status is changed to complete and the Corrective actions for TM/CM is not null
   * @param newList List of Quality Assessment object
   * @param oldMap old Trigger Values
   * @return `List<Quality_Assessment__c>` List of Feedback Tasks.
   */
  static List<Quality_Assessment__c> getCompletedCQAssessments(
    List<Quality_Assessment__c> newList,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    return ListUtil.filter(newList, oldMap)
      .equals(
        Quality_Assessment__c.RecordTypeId,
        RTQualityAssessment.idrCQQualityId
      )
      .anyChangedTo(
        new Set<SObjectField>{ Quality_Assessment__c.Status__c },
        QualityAssessmentActions.STATUS_COMPLETE
      )
      .notEquals(
        Quality_Assessment__c.Evaluation_Type__c,
        IDRConstants.QA_FRONTLINE_ASSESSMENT
      )
      .toList();
  }
  /**
   * @description method to create a Task for all the QA records updated
   * @param qaRecords List of Quality Assessment object
   * @return `List<Task>` List of Feedback Tasks.
   */
  static List<Task> prepareStandardTask(List<Quality_Assessment__c> qaRecords) {
    List<Task> taskRecords = new List<Task>();
    String subject =
      IDRConstants.TASK_QA_COMPLIANCE_SUBJECT + ' {0} : CMOS Case {1}';
    for (Quality_Assessment__c record : qaRecords) {
      List<Object> parameters = new List<Object>{
        record.Case_Manager__r.Name,
        record.Related_Case__r.CaseNumber__c
      };
      String formatted = String.format(subject, parameters);
      taskRecords.add(
        getTask(record, IDRConstants.TASK_QA_COMPLIANCE_DESCRIPTION, formatted)
      );
    }
    return taskRecords;
  }
  /**
   * @description To feed data into Task record.
   * @param record Quality Assessment Object
   * @param description Description of the task
   * @param subject Subject of the task
   * @return `Task` object
   */
  public static Task getTask(
    Quality_Assessment__c record,
    String description,
    String subject
  ) {
    return new Task(
      RecordTypeId = RTTask.complianceTask,
      OwnerId = record.TeamManager__c,
      WhatId = record.Id,
      Subject = subject,
      Description = description ?? '',
      ActivityDate = Date.today().addDays(7),
      Status = IDRConstants.TASK_STATUS_OPEN,
      Priority = IDRConstants.TASK_PRIORITY_NORMAL
    );
  }
  /**
   * @description To create a Quality Assessment Share record for the Team Manager.
   * @param newList new Trigger values
   * @param oldMap old Trigger values
   */
  public static void createQAShareRecord(
    List<Quality_Assessment__c> newList,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> filteredRecords = filterQAShareRecords(
      newList,
      oldMap
    );
    List<Quality_Assessment__Share> shareRecords = new List<Quality_Assessment__Share>();
    for (Quality_Assessment__c record : filteredRecords) {
      shareRecords.add(prepareQAShareRecord(record));
    }
    // Quality_Assessment__Share record for CaseManager__c is created after a calculated delay.
    // It is therefore handled by Quality_Assessment_CMOS.flow and not here.
    DML_REPOSITORY.doInsert(shareRecords, new DmlConfig().withoutSharing());
  }
  /**
   * @description Prepare QA share record
   * @param record Quality Assessment record
   * @return `Quality_Assessment__Share` Quality Assessment Share record
   */
  static Quality_Assessment__Share prepareQAShareRecord(
    Quality_Assessment__c record
  ) {
    Map<Id, String> recordAccess = new Map<Id, String>{
      RTQualityAssessment.idrCQQualityId => 'Edit',
      RTQualityAssessment.idrReviewAssessmentId => 'Read'
    };
    return new Quality_Assessment__Share(
      AccessLevel = recordAccess.get(record.RecordTypeId),
      ParentId = record.Id,
      UserOrGroupId = record.TeamManager__c
    );
  }
  /**
   * @description Filters the given list of Quality Assessment records where record type is C_Q_Assessment or Call_Letter_Review_Assessment and status is changed to Completed
   * and the Corrective actions for TM/CM is not null and Evaluation Type is not Frontline Assessment.
   * @param newList new Trigger values
   * @param oldMap old Trigger values
   * @return `List<Quality_Assessment__c>` Quality Assessment Share record
   */
  static List<Quality_Assessment__c> filterQAShareRecords(
    List<Quality_Assessment__c> newList,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    return ListUtil.filter(newList, oldMap)
      .anyChangedTo(
        new Set<SObjectField>{ Quality_Assessment__c.Status__c },
        QualityAssessmentActions.STATUS_COMPLETE
      )
      .notEquals(
        Quality_Assessment__c.Evaluation_Type__c,
        IDRConstants.QA_FRONTLINE_ASSESSMENT
      )
      .notEqualsToField(
        Quality_Assessment__c.OwnerId,
        Quality_Assessment__c.TeamManager__c
      )
      .toList();
  }
  /**
   * @description To create Compliance Tasks if Quality Assessment record's status is changed to Completed and the Evaluation Type is Final Letter Review Assessment
   * @param newList new Trigger values
   * @param oldMap old Trigger values
   */
  public static void createFinalLetterReviewTask(
    List<Quality_Assessment__c> newList,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> filteredRecords = ListUtil.filter(
        newList,
        oldMap
      )
      .equals(
        Quality_Assessment__c.RecordTypeId,
        RTQualityAssessment.idrReviewAssessmentId
      )
      .anyChangedTo(
        new Set<SObjectField>{ Quality_Assessment__c.Status__c },
        QualityAssessmentActions.STATUS_COMPLETE
      )
      .equals(
        Quality_Assessment__c.Evaluation_Type__c,
        IDRConstants.QA_FINAL_LETTER_REVIEW_ASSESSMENT
      )
      .toList();
    List<Task> taskRecords = new List<Task>();
    taskRecords.addAll(prepareCMTask(filteredRecords));
    taskRecords.addAll(prepareTLTask(filteredRecords));
    DML_REPOSITORY.doInsert(taskRecords, new DmlConfig().systemMode());
  }
  /**
   * @description To prepare a Task for all the QA records where the Corrective actions for CM is not null.
   * @param records List of Quality Assessment objects
   * @return `List<Task>` List of Compliance Tasks.
   */
  static List<Task> prepareCMTask(List<Quality_Assessment__c> records) {
    List<Quality_Assessment__c> filteredRecords = ListUtil.filter(records)
      .isNotNull(Quality_Assessment__c.Corrective_actions_required_CM__c)
      .toList();
    List<Quality_Assessment__c> qaRecords = QA_REPOSITORY.getQualityAssessments(
      ListUtil.getIds(filteredRecords, Quality_Assessment__c.Id)
    );
    List<Task> taskRecords = new List<Task>();
    for (Quality_Assessment__c record : qaRecords) {
      List<Object> parameters = new List<Object>{
        record.Name,
        record.Case_Manager__r.Name
      };
      String formatted = String.format(
        CORRECTIVE_ACTIONS_ATTESTATION_SUBJECT,
        parameters
      );
      Task task = getTask(
        record,
        IDRConstants.TASK_QA_COMPLIANCE_DESCRIPTION,
        formatted
      );
      task.OwnerId = record.Case_Manager__c;
      taskRecords.add(task);
    }
    return taskRecords;
  }
  /**
   * @description To prepare a Task for all the QA records where the Corrective actions for TL is not null.
   * @param records List of Quality Assessment objects
   * @return `List<Task>` List of Compliance Tasks.
   */
  static List<Task> prepareTLTask(List<Quality_Assessment__c> records) {
    List<Quality_Assessment__c> filteredRecords = ListUtil.filter(records)
      .isNotNull(Quality_Assessment__c.Corrective_actions_required_TL__c)
      .toList();
    List<Quality_Assessment__c> qaRecords = QA_REPOSITORY.getQualityAssessments(
      ListUtil.getIds(filteredRecords, Quality_Assessment__c.Id)
    );
    List<Task> taskRecords = new List<Task>();
    for (Quality_Assessment__c record : qaRecords) {
      List<Object> parameters = new List<Object>{
        record.Name,
        record.Case_Manager__r.Name
      };
      String formatted = String.format(
        CORRECTIVE_ACTIONS_ATTESTATION_SUBJECT,
        parameters
      );
      taskRecords.add(
        getTask(record, IDRConstants.TASK_QA_COMPLIANCE_DESCRIPTION, formatted)
      );
    }
    return taskRecords;
  }
}
