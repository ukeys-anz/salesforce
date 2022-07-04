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
  'PMD.ExcessiveParameterList, PMD.ExcessivePublicCount, PMD.CyclomaticComplexity'
)
public without sharing class Lib_SystemLog {
  public enum Severity {
    TRACE,
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    FATAL
  }

  private Map<Severity, Integer> severityMap = new Map<Severity, Integer>{
    Severity.TRACE => 1,
    Severity.DEBUG => 5,
    Severity.INFO => 9,
    Severity.WARNING => 13,
    Severity.ERROR => 17,
    Severity.FATAL => 21
  };

  public static BigObjectHelper bigObjectHelper = new BigObjectHelper();

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
   * @description The Big object log records
   */
  public List<Traced_Application_Log__b> logList { get; private set; }

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
    this.logList = new Traced_Application_Log__b[0];
    this.processName = processName;
    this.functionName = functionName;
    this.batchId = batchId;
  }

  /**
   * @description The method is used to create a single log record in Traced_Application_Log__b object
   * @param processName Process name used to generate the log.
   * @param functionName Function name used to generate the log.
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   * @return Boolean success message for test to verify since big object cannot be tested
   */
  public static Boolean createSingleLog(
    String processName,
    String functionName,
    String errorNo,
    String errorDescription,
    Severity severity
  ) {
    lib_SystemLog sfLog = new lib_SystemLog(processName, functionName);
    sfLog.addMessage(errorNo, errorDescription, severity);
    sfLog.insertLog();
    return true;
  }

  /**
   * @description The method is used to create a single log record in Traced_Application_Log__b object in async mode
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
   * @description The method is used to generate a record to log list at trace level.
   * @param message Information message
   */
  public void trace(String message) {
    addMessage('', message, Severity.TRACE);
  }

  /**
   * @description The method is used to generate a record with an existing Trace Id to log list at trace level.
   * @param message Information message
   * @param traceId Trace Id from a previous related log.
   */
  public void trace(String message, String traceId) {
    addMessage('', message, Severity.TRACE, traceId);
  }

  /**
   * @description The method is used to generate a record to log list at debug level.
   * @param message Information message
   */
  public void debug(String message) {
    addMessage('', message, Severity.DEBUG);
  }

  /**
   * @description The method is used to generate a record with an existing Trace Id to log list at debug level.
   * @param message Information message
   * @param traceId Trace Id from a previous related log.
   */
  public void debug(String message, String traceId) {
    addMessage('', message, Severity.DEBUG, traceId);
  }

  /**
   * @description The method is used to generate a record to log list at info level.
   * @param message Information message
   */
  public void info(String message) {
    addMessage('', message, Severity.INFO);
  }

  /**
   * @description The method is used to generate a record with an existing Trace Id to log list at info level.
   * @param message Information message
   * @param traceId Trace Id from a previous related log.
   */
  public void info(String message, String traceId) {
    addMessage('', message, Severity.INFO, traceId);
  }

  /**
   * @description The method is used to generate a record to log list at warn level.
   * @param message Information message
   */
  public void warning(String message) {
    addMessage('', message, Severity.WARNING);
  }

  /**
   * @description The method is used to generate a record with an existing Trace Id to log list at warn level.
   * @param message Information message
   * @param traceId Trace Id from a previous related log.
   */
  public void warning(String message, String traceId) {
    addMessage('', message, Severity.WARNING, traceId);
  }

  /**
   * @description The method is used to generate a record to log list at error level.
   * @param message Information message
   */
  public void error(String message) {
    error('', message);
  }

  /**
   * @description The method is used to generate a record to log list at error level.
   * @param errorNo Error code used to create the log record.
   * @param message Information message
   */
  public void error(String errorNo, String message) {
    addMessage(errorNo, message, Severity.ERROR);
  }

  /**
   * @description The method is used to generate a record with an existing Trace Id to log list at error level.
   * @param errorNo Error code used to create the log record.
   * @param message Information message
   * @param traceId Trace Id from a previous related log.
   */
  public void error(String errorNo, String message, String traceId) {
    addMessage(errorNo, message, Severity.ERROR, traceId);
  }

  /**
   * @description The method is used to generate a record to log list at fatal level.
   * @param message Information message
   */
  public void fatal(String message) {
    fatal('', message);
  }

  /**
   * @description The method is used to generate a record to log list at fatal level.
   @param errorNo Error code used to create the log record.
   * @param message Information message
   */
  public void fatal(String errorNo, String message) {
    addMessage(errorNo, message, Severity.FATAL);
  }

  /**
   * @description The method is used to generate a record with an existing Trace Id to log list at fatal level.
   * @param errorNo Error code used to create the log record.
   * @param message Information message
   * @param traceId Trace Id from a previous related log.
   */
  public void fatal(String errorNo, String message, String traceId) {
    addMessage(errorNo, message, Severity.FATAL, traceId);
  }

  /**
   * @description  The method addMessage is used to add a record to log list. We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   */
  public void addMessage(
    String errorNo,
    String errorDescription,
    Severity severity
  ) {
    addMessage(errorNo, errorDescription, severity, UniqueIdUtil.getTraceId());
  }

  /**
   * @description  The method addMessage is used to add a record with existing Tace Id to log list. We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   * @param traceId Trace Id from a previous related log.
   */
  public void addMessage(
    String errorNo,
    String errorDescription,
    Severity severity,
    String traceId
  ) {
    Traced_Application_Log__b curLog = new Traced_Application_Log__b();
    curLog.Timestamp__c = DateTime.Now();
    curLog.Trace_Id__c = traceId;
    curLog.Span_Id__c = UniqueIdUtil.getParentId();
    curLog.Severity_Text__c = severity.name();
    curLog.Severity_Number__c = severityMap.get(severity);
    Map<String, String> resourceMap = new Map<String, String>();
    resourceMap.put('Process', processName);
    resourceMap.put('Function', functionName);
    resourceMap.put('BatchId', batchId);
    curLog.Resource__c = JSON.serialize(resourceMap);

    Map<String, String> bodyMap = new Map<String, String>();
    bodyMap.put('Message', errorDescription);
    if (errorNo != '' && errorNo != null) {
      bodyMap.put('ErrorNo', errorNo);
    }

    curLog.Body__c = JSON.serialize(bodyMap);

    this.logList.add(curLog);
  }

  /**
   * @description  The method addMessageWithRequestResponse is used to add a record to log list which is specifically for request response integration pattern
   * which logs request body and response body. We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   * @param endpoint The endpoint used to make the request.
   * @param httpMethod The HTTP method used to make the request.
   * @param statusCode The HTTP status code of the response.
   * @param request Request body in the request response integration pattern
   * @param response Response body in the request response integration pattern
   */
  public void addMessageWithRequestResponse(
    String errorNo,
    String errorDescription,
    Severity severity,
    String endpoint,
    string httpMethod,
    Integer statusCode,
    String request,
    String response
  ) {
    addMessageWithRequestResponse(
      errorNo,
      errorDescription,
      severity,
      endpoint,
      httpMethod,
      statusCode,
      request,
      response,
      UniqueIdUtil.getTraceId()
    );
  }

  /**
   * @description  The method addMessageWithRequestResponse is used to add a record with existing Tace Id to log list which is specifically for request response integration pattern
   * which logs request body and response body. We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   * @param endpoint The endpoint used to make the request.
   * @param httpMethod The HTTP method used to make the request.
   * @param statusCode The HTTP status code of the response.
   * @param request Request body in the request response integration pattern
   * @param response Response body in the request response integration pattern
   * @param traceId Trace Id from a previous related log.
   */
  public void addMessageWithRequestResponse(
    String errorNo,
    String errorDescription,
    Severity severity,
    String endpoint,
    string httpMethod,
    Integer statusCode,
    String request,
    String response,
    String traceId
  ) {
    Traced_Application_Log__b curLog = new Traced_Application_Log__b();
    curLog.Timestamp__c = DateTime.Now();
    curLog.Trace_Id__c = traceId;
    curLog.Span_Id__c = UniqueIdUtil.getParentId();
    curLog.Severity_Text__c = severity.name();
    curLog.Severity_Number__c = severityMap.get(severity);

    Map<String, String> attributesMap = new Map<String, String>();
    if (endpoint != null) {
      attributesMap.put('Endpoint', endpoint);
    }
    if (httpMethod != null) {
      attributesMap.put('HTTPMethod', httpMethod);
    }
    if (statusCode != null) {
      attributesMap.put('StatusCode', String.valueOf(statusCode));
    }
    curLog.Attributes__c = JSON.serialize(attributesMap);

    Map<String, String> resourceMap = new Map<String, String>();
    resourceMap.put('Process', processName);
    resourceMap.put('Function', functionName);
    resourceMap.put('BatchId', batchId);
    curLog.Resource__c = JSON.serialize(resourceMap);

    Map<String, String> bodyMap = new Map<String, String>();
    bodyMap.put('Message', errorDescription);
    if (request != null) {
      bodyMap.put('Request', request);
    }
    if (response != null) {
      bodyMap.put('Response', response);
    }
    if (errorNo != '' && errorNo != null) {
      bodyMap.put('ErrorNo', errorNo);
    }

    curLog.Body__c = JSON.serialize(bodyMap);

    this.logList.add(curLog);
  }

  /**
   * @description  The method addObjectMessage is used to add a record to log list which is specific for an Object
   * We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object
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
    addObjectMessage(
      objectName,
      recordId,
      errorNo,
      errorDescription,
      severity,
      UniqueIdUtil.getTraceId()
    );
  }

  /**
   * @description  The method addObjectMessage is used to add a record with existing Tace Id to log list which is specific for an Object
   * We can add multiple logs by calling this method and at the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object
   * @param objectName The name of the object used to create the log record.
   * @param recordId The record Id of the record of a Object to be logged.
   * @param errorNo Error code used to create the log record.
   * @param errorDescription Error description used to create the log record.
   * @param severity Error Severity used to create the log record.
   * @param traceId Trace Id from a previous related log.
   */
  public void addObjectMessage(
    String objectName,
    String recordId,
    String errorNo,
    String errorDescription,
    Severity severity,
    String traceId
  ) {
    Traced_Application_Log__b curLog = new Traced_Application_Log__b();
    curLog.Timestamp__c = DateTime.Now();
    curLog.Trace_Id__c = traceId;
    curLog.Span_Id__c = UniqueIdUtil.getParentId();
    curLog.Severity_Text__c = severity.name();
    curLog.Severity_Number__c = severityMap.get(severity);
    Map<String, String> resourceMap = new Map<String, String>();
    resourceMap.put('Process', processName);
    resourceMap.put('Function', functionName);
    resourceMap.put('BatchId', batchId);
    curLog.Resource__c = JSON.serialize(resourceMap);

    Map<String, String> bodyMap = new Map<String, String>();
    bodyMap.put('Message', errorDescription);
    bodyMap.put('objectName', objectName);
    bodyMap.put('recordId', recordId);
    if (errorNo != '' && errorNo != null) {
      bodyMap.put('ErrorNo', errorNo);
    }

    curLog.Body__c = JSON.serialize(bodyMap);

    this.logList.add(curLog);
  }

  /**
   * @description  The method addDatabaseSaveResult is used for for creating logs when permorfing DML operations insert or update
   * The save results are checked to see if its successful and if there are any failures we add to the log list. At the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object. If an error is found, a boolean is returned so users can easily identify and throw errors
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
    return addDatabaseSaveResult(
      objectName,
      results,
      records,
      UniqueIdUtil.getTraceId()
    );
  }

  /**
   * @description  The method addDatabaseSaveResult is used for for creating logs with existing Tace Id when permorfing DML operations insert or update
   * The save results are checked to see if its successful and if there are any failures we add to the log list. At the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object. If an error is found, a boolean is returned so users can easily identify and throw errors
   * @param objectName The name of the object used to create the log record.
   * @param results List of save results which will be evaluated for logging.
   * @param records actual records which are used for DML insert/update.
   * @param traceId Trace Id from a previous related log.
   * @return Boolean
   */
  public Boolean addDatabaseSaveResult(
    String objectName,
    List<Database.SaveResult> results,
    List<SObject> records,
    String traceId
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
            Severity.ERROR,
            traceId
          );
        }
      }
    }

    return hasError;
  }

  /**
   * @description  The method addDatabaseUpsertResult is used for for creating logs when permorfing DML operation upsert
   * The upsert results are checked to see if its successful and if there are any failures we add to the log list. At the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object. If an error is found, a boolean is returned so users can easily identify and throw errors
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
   * The trigger {@link Lib_ApplicationLoggingEvents} will listen to these events and inserts the data to Traced_Application_Log__b object
   */
  public void publishEvent() {
    List<Application_Logging__e> logEvents = new List<Application_Logging__e>();
    logEvents.add(new Application_Logging__e(sfLog__c = JSON.serialize(this)));

    // Call method to publish events
    List<Database.SaveResult> results = EventBus.publish(logEvents);
    if (results.size() > 0) {
      this.logList = new Traced_Application_Log__b[0];
    }
  }

  /**
   * @description The method logAPIError is used for creating a platform event for Async logging
   * specifically for api calls using request response integration patterns.
   * The trigger {@link Lib_ApplicationLoggingEvents} will listen to these events and inserts the data to Traced_Application_Log__b object
   * The caller should call {@link insertLog()} method
   * @param processName Process name used to generate the log.
   * @param functionName Name of the funtion to generate the log.
   * @param errorDescription Error description used to create the log record.
   * @param errorNo Error code used to create the log record.
   * @param request Request body in the request response integration pattern
   * @param response Response body in the request response integration pattern
   * @param endpoint The endpoint used to make the request.
   * @param httpMethod The HTTP method used to make the request.
   * @param statusCode The HTTP status code of the response.
   * @return Boolean success message for test to verify since big object cannot be tested
   */
  public static Boolean logAPIError(
    String processName,
    String functionName,
    String errorDescription,
    String errorNo,
    String request,
    String response,
    String endpoint,
    String httpMethod,
    Integer statusCode
  ) {
    lib_SystemLog sfLog = new lib_SystemLog(processName, functionName, null);
    sfLog.addMessageWithRequestResponse(
      errorNo,
      errorDescription,
      lib_systemLog.Severity.ERROR,
      endpoint,
      httpMethod,
      statusCode,
      request,
      response
    );
    sfLog.publishEvent();
    return true;
  }

  /**
   *  @description  The method insertLog is used creating/inserting log records in Traced_Application_Log__b object.
   */
  public void insertLog() {
    if (
      !logList.isEmpty() &&
      Traced_Application_Log__b.sObjectType.getDescribe().isCreateable()
    ) {
      if (!Test.isRunningTest()) {
        bigObjectHelper.insertBigObject(logList, 'Traced_Application_Log__b');
      }
    }
    this.logList = new Traced_Application_Log__b[0];
  }

  /**
   *  @description  The method insertLog is used creating/inserting log records in Traced_Application_Log__b object asynchronously.
   */
  public void insertLogAsync() {
    String logStr = JSON.serialize(this);
    Lib_SystemLog.insertLogStaticAsync(logStr);
    this.logList = new Traced_Application_Log__b[0];
  }

  /**
   *  @description This is the helper future method to insert logs asynchronously
   *  @param logStr json string of log information to be stored
   */
  @future
  public static void insertLogStaticAsync(String logStr) {
    lib_SystemLog sfLog = (lib_SystemLog) JSON.deserialize(
      logStr,
      lib_SystemLog.class
    );
    List<Traced_Application_Log__b> applicationLogs = sfLog.logList;

    if (!Test.isRunningTest()) {
      bigObjectHelper.insertBigObject(
        applicationLogs,
        'Traced_Application_Log__b'
      );
    }
  }
}
