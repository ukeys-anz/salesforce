/**
 * @author Hrushikesh
 * @since 12/2025
 * @description ProcessRecordsInChunksQueueable Class handles the procesing of records in chunks.
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class ProcessRecordsInChunksQueueable implements Queueable {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  public enum DMLOperation {
    DML_INSERT,
    DML_UPDATE,
    DML_DELETE
  }

  private List<SObject> masterRecords;
  private List<Id> masterIds;
  private String queryTemplate;
  private Integer batchSize;
  private DMLOperation operation;
  private Integer totalRecordsToProcess;
  private Integer totalProcessedSoFar;

  private static final Integer DEFAULT_BATCH_SIZE = 50;
  private static final Integer MAX_BATCH_SIZE = 200;
  private static final Integer MIN_BATCH_SIZE = 1;

  /**
   * @description Constructor for processing a list of SObjects
   * @param records List of SObjects to process
   * @param batchSize Number of records to process per execution
   * @param operation DML operation to perform (INSERT, UPDATE, DELETE)
   */
  public ProcessRecordsInChunksQueueable(
    List<SObject> records,
    Integer batchSize,
    DMLOperation operation
  ) {
    this.masterRecords = records != null ? records : new List<SObject>();
    this.batchSize = validateBatchSize(batchSize);
    this.operation = operation;
    this.totalRecordsToProcess = this.masterRecords.size();
    this.totalProcessedSoFar = 0;
  }

  /**
   * @description Constructor for processing a list of IDs with a query
   * @param ids List of record IDs to process
   * @param queryTemplate SOQL query with :recordIds bind variable placeholder
   * @param batchSize Number of records to process per execution
   * @param operation DML operation to perform
   */
  public ProcessRecordsInChunksQueueable(
    List<Id> ids,
    String queryTemplate,
    Integer batchSize,
    DMLOperation operation
  ) {
    this.masterIds = ids != null ? ids : new List<Id>();
    this.queryTemplate = queryTemplate;
    this.batchSize = validateBatchSize(batchSize);
    this.operation = operation;
    this.totalRecordsToProcess = this.masterIds.size();
    this.totalProcessedSoFar = 0;
  }

  /**
   * @description Constructor for DELETE operation using IDs only (no query needed)
   * @param ids List of record IDs to delete
   * @param batchSize Number of records to process per execution
   * @param operation DML operation (typically DELETE)
   */
  public ProcessRecordsInChunksQueueable(
    List<Id> ids,
    Integer batchSize,
    DMLOperation operation
  ) {
    this.masterIds = ids != null ? ids : new List<Id>();
    this.batchSize = validateBatchSize(batchSize);
    this.operation = operation;
    this.totalRecordsToProcess = this.masterIds.size();
    this.totalProcessedSoFar = 0;
  }

  /**
   * @description Private constructor used for chaining jobs with preserved state
   * @param records List of SObjects to process
   * @param ids List of record IDs to process
   * @param queryTemplate SOQL query with :recordIds bind variable placeholder
   * @param batchSize Number of records to process per execution
   * @param operation DML operation (typically DELETE)
   * @param totalRecordsToProcess List of record to process
   * @param totalProcessedSoFar Total records processed so far
   */
  private ProcessRecordsInChunksQueueable(
    List<SObject> records,
    List<Id> ids,
    String queryTemplate,
    Integer batchSize,
    DMLOperation operation,
    Integer totalRecordsToProcess,
    Integer totalProcessedSoFar
  ) {
    this.masterRecords = records;
    this.masterIds = ids;
    this.queryTemplate = queryTemplate;
    this.batchSize = batchSize;
    this.operation = operation;
    this.totalRecordsToProcess = totalRecordsToProcess;
    this.totalProcessedSoFar = totalProcessedSoFar;
  }

  /**
   * @description Main execution method called by the Queueable framework
   * @param context QueueableContext provided by the system
   */
  public void execute(QueueableContext context) {
    if (hasRecordsToProcess()) {
      processRecordsBatch();
    }
    if (hasIdsToProcess()) {
      processIdsBatch();
    }
  }

  /**
   * @description Processes a batch from the SObject list
   */
  private void processRecordsBatch() {
    Integer recordsRemaining = masterRecords.size();
    Integer currentBatchSize = Math.min(batchSize, recordsRemaining);

    // Extract current batch
    List<SObject> currentBatch = new List<SObject>();
    for (Integer i = 0; i < currentBatchSize; i++) {
      currentBatch.add(masterRecords[i]);
    }

    executeDML(currentBatch);

    // Update progress
    totalProcessedSoFar += currentBatchSize;

    // Prepare remaining records for next batch
    List<SObject> remainingRecords = new List<SObject>();
    for (Integer i = currentBatchSize; i < masterRecords.size(); i++) {
      remainingRecords.add(masterRecords[i]);
    }

    // Chain next job if more records exist
    chainNextJob(remainingRecords, null);
  }

  /**
   * @description Processes a batch from the ID list
   */
  private void processIdsBatch() {
    Integer idsRemaining = masterIds.size();
    Integer currentBatchSize = Math.min(batchSize, idsRemaining);

    // Extract current batch of IDs
    List<Id> currentBatchIds = new List<Id>();
    for (Integer i = 0; i < currentBatchSize; i++) {
      currentBatchIds.add(masterIds[i]);
    }

    // Get SObjects for DML
    List<SObject> currentBatch = getSObjectsFromIds(currentBatchIds);

    executeDML(currentBatch);

    // Update progress
    totalProcessedSoFar += currentBatchSize;

    // Prepare remaining IDs for next batch
    List<Id> remainingIds = new List<Id>();
    for (Integer i = currentBatchSize; i < masterIds.size(); i++) {
      remainingIds.add(masterIds[i]);
    }

    // Chain next job if more IDs exist
    chainNextJob(null, remainingIds);
  }

  /**
   * @description Chains the next queueable job if there are remaining records
   * @param remainingRecords Remaining SObjects (null if using IDs)
   * @param remainingIds Remaining IDs (null if using SObjects)
   */
  private void chainNextJob(
    List<SObject> remainingRecords,
    List<Id> remainingIds
  ) {
    Boolean hasMoreRecords = (remainingRecords != null &&
    !remainingRecords.isEmpty());
    Boolean hasMoreIds = (remainingIds != null && !remainingIds.isEmpty());

    if (!hasMoreRecords && !hasMoreIds) {
      return;
    }

    if (Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
      return;
    }

    // Create and enqueue next job with preserved state
    ProcessRecordsInChunksQueueable nextJob = new ProcessRecordsInChunksQueueable(
      remainingRecords,
      remainingIds,
      this.queryTemplate,
      this.batchSize,
      this.operation,
      this.totalRecordsToProcess,
      this.totalProcessedSoFar
    );

    System.enqueueJob(nextJob);
  }

  /**
   * @description Validates and normalizes batch size
   * @param size of the batch passed
   * @return size of batch
   */
  private Integer validateBatchSize(Integer size) {
    if (size == null || size < MIN_BATCH_SIZE) {
      return DEFAULT_BATCH_SIZE;
    }
    if (size > MAX_BATCH_SIZE) {
      return MAX_BATCH_SIZE;
    }
    return size;
  }

  /**
   * @description checks if more records are available to process
   * @return true if more records are available to process
   */
  private Boolean hasRecordsToProcess() {
    return masterRecords != null && !masterRecords.isEmpty();
  }

  /**
   * @description checks if more Ids are available to process
   * @return true if more Ids are available to process
   */
  private Boolean hasIdsToProcess() {
    return masterIds != null && !masterIds.isEmpty();
  }

  /**
   * @description Executes the configured DML operation
   * @param records List of SObjects to process
   */
  private void executeDML(List<SObject> records) {
    try {
      switch on operation {
        when DML_INSERT {
          DML_REPOSITORY.doInsert(records);
        }
        when DML_UPDATE {
          DML_REPOSITORY.doUpdate(records);
        }
        when DML_DELETE {
          DML_REPOSITORY.doDelete(records);
        }
      }
    } catch (DmlException e) {
      Logger.error('ProcessRecordsInChunksQueueable ' + e.getMessage(), e);
      Logger.saveLog();
    }
  }

  /**
   * @description Converts IDs to SObjects, either by querying or creating instances
   * @param ids List of record IDs
   * @return List of SObjects
   */
  private List<SObject> getSObjectsFromIds(List<Id> ids) {
    if (ids == null || ids.isEmpty()) {
      return new List<SObject>();
    }

    // For DELETE or when no query provided, create SObject instances from IDs
    if (operation == DMLOperation.DML_DELETE || String.isBlank(queryTemplate)) {
      List<SObject> records = new List<SObject>();
      for (Id recordId : ids) {
        SObjectType sObjType = recordId.getSObjectType();
        records.add(sObjType.newSObject(recordId));
      }
      return records;
    }

    // For UPDATE/INSERT with query, fetch records
    // The query should use :recordIds as the bind variable
    Set<Id> recordIds = new Set<Id>(ids);
    return Database.query(queryTemplate);
  }
}
