/**
 *
 * @author
 * @since 2019
 * @group Logging
 * @description This class handle Exception log and can be use for trigger batch or anything in the code that need to handle proper errors
 * @example
 * Database.SaveResult[] results = Database.update(contactToUpdate, false);
 *
 * lib_systemLog log = new lib_systemLog('ContactService','Contact','upgradeContact');
 *
 * log.addDatabaseSaveResult(results, 'Contact', contactToUpdate);
 * @group Library
 */
@SuppressWarnings(
  'PMD.ExcessiveParameterList, PMD.ExcessivePublicCount, PMD.ApexCRUDViolation'
)
public without sharing class Lib_SystemLog {
  public enum Severity {
    INFO,
    WARNING,
    ERROR,
    FATAL
  }
  /**
   * @description The function name which is being logged.
   */
  private String functionName { get; set; }
  /**
   * @description The Process Name name which is being logged.
   */
  private String processName { get; set; }
  /**
   * @description The batchId.
   */
  private String batchId { get; set; }
  /**
   * @description The error Code.
   */
  private String errorCode { get; private set; }
  /**
   * @description The log records
   */
  public List<Application_Log__c> log { get; private set; }

  /**
   * @description This generates the unique ID as the error identifier
   * @return `String` which is error Identifier
   */
  private static String generateLogGuid() {
    return EncodingUtil.convertToHex(
      Crypto.generateDigest(
        'MD5',
        Blob.valueOf(DateTime.now().getTime().format())
      )
    );
  }

  /**
   * @description Constructor
   * @param proccessName Process name used to generate the log
   */
  public Lib_SystemLog(String proccessName) {
    this(proccessName, null, null);
  }

  /**
   * @description Constructor
   * @param processName Process name used to generate the log
   * @param functionName Name of the funtion to generate the log
   */
  public Lib_SystemLog(String processName, String functionName) {
    this(processName, functionName, null);
  }

  /**
   * @description Constructor
   * @param processName Process name used to generate the log.
   * @param functionName Name of the funtion to generate the log.
   * @param batchId BatchId for generating the log.
   */
  public Lib_SystemLog(
    String processName,
    String functionName,
    String batchId
  ) {
    this(processName, functionName, batchId, generateLogGuid());
  }

  /**
   * @description Constructor
   * @param processName Process name used to generate the log.
   * @param functionName Name of the funtion to generate the log.
   * @param batchId BatchId for generating the log.
   * @param errorIdentifier Error Identifier for the log.
   */
  public Lib_SystemLog(
    String processName,
    String functionName,
    String batchId,
    String errorIdentifier
  ) {
    this.log = new Application_Log__c[0];
    this.processName = processName;
    this.functionName = functionName;
    this.batchId = batchId;
    this.errorCode = errorIdentifier;
  }
  /**
   * @description The method is used to create a single log record in Application_Log__c object
   * @param processName Process name used to generate the log.
   * @param functionName Function name used to generate the log.
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   */
  public static void createSingleLog(
    String processName,
    String functionName,
    String errorNo,
    String errorDescription,
    Severity severity
  ) {
    lib_SystemLog sfLog = new lib_SystemLog(processName, functionName);
    sfLog.addMessage(errorNo, errorDescription, severity);
    sfLog.insertLog();
  }

  /**
   * @description The method is used to create a single log record in Application_Log__c object in async mode
   * @param processName Process name used to generate the log.
   * @param functionName Function name used to generate the log.
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   */
  @future
  public static void createSingleLogAsync(
    String processName,
    String functionName,
    String errorNo,
    String errorDescription
  ) {
    createSingleLog(
      processName,
      functionName,
      errorNo,
      errorDescription,
      Lib_SystemLog.Severity.ERROR
    );
  }

  /**
   * @description  The method addMessage is used to add a record to log list. We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Application_Log__c object
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   */
  public void addMessage(
    String errorNo,
    String errorDescription,
    Severity severity
  ) {
    this.add(
      new Application_Log__c(
        Process_Name__c = processName,
        Batch_Id__c = batchId,
        Function_Name__c = functionName,
        Error_No__c = errorNo,
        Error_Description__c = errorDescription,
        Severity__c = severity.name(),
        Error_Code__c = errorCode
      )
    );
  }

  /**
   * @description  The method addMessageWithRequestResponse is used to add a record to log list which is specifically for request response integration pattern
   * which logs request body and response body. We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Application_Log__c object
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   * @param request Request body in the request response integration pattern
   * @param response Response body in the request response integration pattern
   */
  public void addMessageWithRequestResponse(
    String errorNo,
    String errorDescription,
    Severity severity,
    String request,
    String response
  ) {
    this.add(
      new Application_Log__c(
        Process_Name__c = processName,
        Batch_Id__c = batchId,
        Function_Name__c = functionName,
        Error_No__c = errorNo,
        Error_Description__c = errorDescription,
        Severity__c = severity.name(),
        Error_Code__c = errorCode,
        Request_Body__c = request,
        Response_Body__c = response
      )
    );
  }

  /**
   * @description  The method addObjectMessage is used to add a record to log list which is specific for an Object
   * We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Application_Log__c object
   * @param objectName The name of the object used to create the log record.
   * @param recordId The record Id of the record of a Object to be logged.
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   */
  public void addObjectMessage(
    String objectName,
    String recordId,
    String errorNo,
    String errorDescription,
    Severity severity
  ) {
    this.add(
      new Application_Log__c(
        Process_Name__c = processName,
        Record_ID__c = recordId,
        Object_Name__c = objectName,
        Batch_Id__c = batchId,
        Function_Name__c = functionName,
        Error_No__c = errorNo,
        Error_Description__c = errorDescription,
        Severity__c = severity.name(),
        Error_Code__c = errorCode
      )
    );
  }

  /**
   * @description  The method addDatabaseSaveResult is used for for creating logs when permorfing DML operations insert or update
   * The save results are checked to see if its successful and if there are any failures we add to the log list. At the end the caller should call {@link insertLog()} method
   * to create record/records in Application_Log__c object. If an error is found, a boolean is returned so users can easily identify and throw errors
   * @param objectName The name of the object used to create the log record.
   * @param results List of save results which will be evaluated for logging.
   * @param records actual records which are used for DML insert/update.
   * @return Boolean
   */
  public Boolean addDatabaseSaveResult(
    String objectName,
    List<Database.SaveResult> results,
    List<SObject> records
  ) {
    Boolean hasError = false;
    for (Integer i = 0; i < records.size(); i++) {
      Database.SaveResult sr = results[i];
      SObject rec = records[i];
      if (!sr.isSuccess()) {
        hasError = true;
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          String errNo = String.valueof(err.getStatusCode());
          if (errNo.length() > 50) {
            errNo = errNo.substring(0, 50);
          }
          this.addObjectMessage(
            objectName,
            rec.Id,
            errNo,
            'Id=' +
            rec.Id +
            ',Message:' +
            err.getMessage() +
            'Fields:' +
            err.getFields(),
            Severity.ERROR
          );
        }
      }
    }

    return hasError;
  }

  /**
   * @description  The method addDatabaseUpsertResult is used for for creating logs when permorfing DML operation upsert
   * The upsert results are checked to see if its successful and if there are any failures we add to the log list. At the end the caller should call {@link insertLog()} method
   * to create record/records in Application_Log__c object. If an error is found, a boolean is returned so users can easily identify and throw errors
   * @param objectName The name of the object used to create the log record.
   * @param results List of upsert results which will be evaluated for logging.
   * @param records actual records which are used for DML insert/update.
   * @return Boolean
   */
  public Boolean addDatabaseUpsertResult(
    String objectName,
    List<Database.UpsertResult> results,
    List<SObject> records
  ) {
    Boolean hasError = false;
    for (Integer i = 0; i < records.size(); i++) {
      Database.UpsertResult sr = results[i];
      SObject rec = records[i];
      if (!sr.isSuccess()) {
        hasError = true;
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          String errNo = String.valueof(err.getStatusCode());
          if (errNo.length() > 50) {
            errNo = errNo.substring(0, 50);
          }
          this.addObjectMessage(
            objectName,
            rec.Id,
            errNo,
            'Id=' +
            rec.Id +
            ',Message:' +
            err.getMessage() +
            'Fields:' +
            err.getFields(),
            Severity.ERROR
          );
        }
      }
    }

    return hasError;
  }

  /**
   * @description  The method publishEvent is used for creating a platform event for Async logging
   * The Lib_SystemLog object needs to be created with required fields  before calling this method
   * The information used to create the object is serialized as JSON and published as platform event.
   * The trigger {@link Lib_ApplicationLoggingEvents} will listen to these events and inserts the data to Application_Log__c object
   */
  public void publishEvent() {
    List<Application_Logging__e> logEvents = new List<Application_Logging__e>();
    logEvents.add(new Application_Logging__e(sfLog__c = JSON.serialize(this)));

    // Call method to publish events
    List<Database.SaveResult> results = EventBus.publish(logEvents);
  }

  /**
   * @description The method logAPIError is used for creating a platform event for Async logging
   * specifically for api calls using request response integration patterns.
   * The trigger {@link Lib_ApplicationLoggingEvents} will listen to these events and inserts the data to Application_Log__c object
   * The caller should call {@link insertLog()} method
   * @param processName Process name used to generate the log.
   * @param functionName Name of the funtion to generate the log.
   * @param errorDescription Error description used to create the log record.
   * @param errorNo Error code used to create the log record.
   * @param errorIdentifier Error Identifier for the log.
   * @param request Request body in the request response integration pattern
   * @param response Response body in the request response integration pattern
   */
  public static void logAPIError(
    String processName,
    String functionName,
    String errorDescription,
    String errorNo,
    String errorIdentifier,
    String request,
    String response
  ) {
    lib_SystemLog sfLog = new lib_SystemLog(
      processName,
      functionName,
      null,
      errorIdentifier
    );
    sfLog.addMessageWithRequestResponse(
      errorNo,
      errorDescription,
      lib_systemLog.Severity.ERROR,
      request,
      response
    );
    sfLog.publishEvent();
  }

  /**
   * @description  The method add is used for adding Application_Log__c to list of Application_Log__c logs.
   * The caller should call {@link Lib_SystemLog.insertLog} method
   * @param exc record object to be added to the list of log records to be inserted
   */
  public void add(Application_Log__c exc) {
    log.add(exc);
  }

  /**
   *  @description  The method insertLog is used creating/inserting log records in Application_Log__c object.
   */
  public void insertLog() {
    if (!log.isEmpty()) {
      insert log;
    }
  }

  /**
   * @description  The method getLogErrorCode is used retrun the Error_Code__c value of the first object in the list
   * @return `String` retrun the Error_Code__c value of the first object in the list
   */
  public String getLogErrorCode() {
    if (!log.isEmpty() && log[0].Error_Code__c != null) {
      return log[0].Error_Code__c;
    }
    return null;
  }
}
