/**
 * @author Nakul Kumar
 * @since June 2022
 * @description Batch class to delete `Log__c`, `LogEntry__c` and `SecureLogEntry__c` records
 */

public with sharing class LoggingRecordsPurgeBatch implements Database.Batchable<sObject>, Database.Stateful {
  private static final String NO_DELETE_ACCESS_EXCEPTION_MESSAGE = 'User does not have access to delete logs';
  private Integer batchSize = 200;

  @TestVisible
  private static LogsPurgingSettings__c logPurgingSettings {
    get {
      if (logPurgingSettings == null) {
        logPurgingSettings = LogsPurgingSettings__c.getOrgDefaults();
      }
      return logPurgingSettings;
    }
    set;
  }

  /**
   * executionOrder determines which of the 4 Logger object is to be deleted in this run
   */
  private Integer executionOrder;
  private Schema.SObjectType targetSObject;
  private Integer totalProcessedRecords;

  /**
   * @description Default Constructor, sets up instance variables of LoggingRecordsPurgerBatch class.
   */
  public LoggingRecordsPurgeBatch() {
    this.totalProcessedRecords = 0;
    this.executionOrder = 4;
  }

  /**
   * @description Required by the Database.Batchable interface.  Collects the records /
   * objects passed in to the batch instance and returns a Databae.QueryLocator reference representing
   * the current iteration.
   * @param batchableContext contains the context of the batch job
   * @return an instance of the Database.QueryLocator class
   * @throws NoAccessException when there is no delete access to Logs
   */
  public Database.QueryLocator start(
    Database.BatchableContext batchableContext
  ) {
    if (Schema.Log__c.SObjectType.getDescribe().isDeletable() == false) {
      NoAccessException noDeleteAccessException = new NoAccessException();
      noDeleteAccessException.setMessage(NO_DELETE_ACCESS_EXCEPTION_MESSAGE);
      Logger.error(
        'Exception occurred when deleting logs',
        noDeleteAccessException
      );
      Logger.saveLog();
      throw noDeleteAccessException;
    }
    this.targetSObject = this.getTargetSObject(this.executionOrder);
    return this.getQueryLocator(this.targetSObject);
  }

  /**
   * @description Required by the Database.Batchable interface, this method executes the logic for purging
   * log records.
   * @param batchableContext - The context of the current batch job.
   * @param loggingRecords - The log records to purge.
   */
  public void execute(
    Database.BatchableContext batchableContext,
    List<sObject> loggingRecords
  ) {
    try {
      if (loggingRecords.isEmpty() == false) {
        this.totalProcessedRecords += loggingRecords.size();
        List<Database.DeleteResult> deleteResults = Database.delete(
          loggingRecords,
          false
        );
        Logger.info(
          'Daily Logs Purging - ' +
          this.totalProcessedRecords +
          ' of ' +
          this.targetSObject +
          ' records have been deleted.',
          deleteResults
        );
        List<Database.EmptyRecycleBinResult> emptyRecycleBinResults = Database.emptyRecycleBin(
          loggingRecords
        );
        Logger.info(
          'Daily Logs Purging - ' +
          this.totalProcessedRecords +
          ' of ' +
          this.targetSObject +
          ' records have been emptied from recycle bin.',
          emptyRecycleBinResults
        );
      }
    } catch (Exception e) {
      Logger.error('Daily Logs Purging Failed To Executed', e);
      throw e;
    } finally {
      Logger.saveLog();
    }
  }

  /**
   * @description Required by the Database.Batchable interface.  This method runs after all batch jobs are complete.
   * @param batchableContext - The context of the batch jobs
   */
  public void finish(Database.BatchableContext batchableContext) {
    this.executionOrder -= 1;
    //To be used to log the event of running the batch job
    Id batchJobId = batchableContext.getJobId();
    if (this.executionOrder != 0) {
      batchJobId = Database.executeBatch(this, this.batchSize);
    }
  }

  /**
   * @description Determines which of the 3 Logger objects (SecureLogEntry__c, LogEntry__c or Log__c) should be deleted next.
   *              Records for each SObject type are deleted in separate instances of the LogBatchPurger job,
   *              starting with the object, SecureLogEntry__c. This helps to avoid running into DML limits that occurred
   *              when this job tried to delete records in multiple SObject types within 1 job
   * @param executionOrder Based on this parameter it is determined which object is to be deleted.
   * @return The instance of Schema.SObjectType for the object to be deleted
   */
  private Schema.SObjectType getTargetSObject(Integer executionOrder) {
    Map<Integer, Schema.SObjectType> targetSObjectMap = new Map<Integer, Schema.SObjectType>{
      1 => Schema.Log__c.SObjectType,
      2 => Schema.LogEntry__c.SObjectType,
      3 => Schema.SecureLogEntry__c.SObjectType,
      4 => Schema.LoggingSettings__c.SObjectType
    };
    return targetSObjectMap.get(executionOrder);
  }

  /**
   * @description Queries the list of records of to be deleted object i.e., SecureLogEntry__c, LogEntry__c or Log__c.
   * @param sobjectType Based on this parameter it is determined which object is to be queried.
   * @return The instance of Database.QueryLocator for the lowest-level Logger object
   */
  private Database.QueryLocator getQueryLocator(
    Schema.SObjectType sobjectType
  ) {
    Integer logRetentionDuration = Integer.valueOf(
      logPurgingSettings.LogsRetentionDays__c
    );
    DateTime dateToPurge = Date.today().addDays(-logRetentionDuration);
    Map<String, String> queryMap = new Map<String, String>{
      'LoggingSettings__c' => 'SELECT Id FROM LoggingSettings__c WHERE SecureLogEnabled__c = TRUE',
      'SecureLogEntry__c' => 'SELECT Id FROM SecureLogEntry__c',
      'LogEntry__c' => 'SELECT Id FROM LogEntry__c Where CreatedDate <=: dateToPurge',
      'Log__c' => 'SELECT Id FROM Log__c Where CreatedDate <=: dateToPurge'
    };
    String queryStr = queryMap.get(String.valueOf(sobjectType));
    return Database.getQueryLocator(queryStr);
  }
}
