/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @description Builder class for  `LogEvent__e` platform events and normalises the data into `Log__c`, `LogEntry__c` and `SecureLogEntry__c` records
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessivePublicCount')
public without sharing class LogEventBuilder {
  @TestVisible
  private static final String API_VERSION = LogEventBuilderHelper.getApiVersion();

  private final LogEvent__e logEvent;
  private final LoggingLevel entryLoggingLevel;
  private Boolean shouldSave = false;

  /**
   * @description Used by `Logger` to instantiate a new instance of `LogEventBuilder`
   * @param  entryLoggingLevel The `LoggingLevel` enum to use for the builder's instance of `LogEvent__e`
   * @param  shouldSave        Determines if the builder's instance of `LogEvent__e` should be saved
   */
  public LogEventBuilder(LoggingLevel entryLoggingLevel, Boolean shouldSave) {
    this.entryLoggingLevel = entryLoggingLevel;
    this.shouldSave = shouldSave;

    if (this.shouldSave == false) {
      return;
    }

    this.logEvent = new LogEvent__e();
    setTransactionDetails();
    setUsedLimits();
    setUserDetails();

    DmlException stackTraceException = new DmlException();
    this.parseStackTrace(stackTraceException.getStackTraceString());
  }

  /**
   * @description Returns the `LogEvent__e` record for this instance of LogEventBuilder
   * @return The `LogEvent__e` record
   */
  public LogEvent__e getLogEvent() {
    if (this.shouldSave == true) {
      return this.logEvent;
    }

    return null;
  }

  /**
   * @description Sets the log entry event's message field
   * @param  message The string to use to set the entry's message field
   * @return         The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setMessage(String message) {
    // To help with debugging unit tests, always run System.debug statement in a test context
    if (
      (this.shouldSave == true || System.Test.isRunningTest() == true) &&
      this.logEvent != null
    ) {
      String truncatedMessage = LogEventBuilderHelper.truncateFieldValue(
        Schema.LogEvent__e.LogMessage__c,
        message
      );
      this.logEvent.LogMessage__c = truncatedMessage;
    }
    return this;
  }

  /**
   * @description Sets the log entry event's exception fields
   * @param  apexException The instance of an `Exception` to use.
   * @return               The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setExceptionDetails(Exception apexException) {
    if (this.shouldSave == false || apexException == null) {
      return this;
    }

    this.logEvent.ExceptionMessage__c = apexException.getMessage();
    this.logEvent.ExceptionType__c = apexException.getTypeName();

    return this;
  }

  // DML-result builder methods.
  /**
   * @description Sets the log entry event's database operation result fields
   * @param  saveResult The instance of `Database.SaveResult` to log
   * @return            The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(Database.SaveResult saveResult) {
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      saveResult
    };
    this.setDatabaseResult(saveResults);

    return this.setRecord(saveResult.getId());
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  saveResults The list of `Database.SaveResult` instances to log
   * @return             The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    List<Database.SaveResult> saveResults
  ) {
    if (this.shouldSave == false || saveResults == null) {
      return this;
    }

    String saveResultsWithError = DatabaseResultHelper.getSaveResultError(
      saveResults
    );
    this.logEvent.DatabaseResult__c = LogEventBuilderHelper.truncateFieldValue(
      Schema.LogEvent__e.DatabaseResult__c,
      saveResultsWithError
    );

    return this;
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  deleteResult The instance of `Database.DeleteResult` to log
   * @return              The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(Database.DeleteResult deleteResult) {
    List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>{
      deleteResult
    };
    this.setDatabaseResult(deleteResults);

    return this.setRecord(deleteResult.getId());
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  deleteResults The list of `Database.DeleteResult` instances to log
   * @return               The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    List<Database.DeleteResult> deleteResults
  ) {
    if (this.shouldSave == false || deleteResults == null) {
      return this;
    }

    String deleteResultsWithError = DatabaseResultHelper.getDeleteResultError(
      deleteResults
    );
    this.logEvent.DatabaseResult__c = LogEventBuilderHelper.truncateFieldValue(
      Schema.LogEvent__e.DatabaseResult__c,
      deleteResultsWithError
    );

    return this;
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  mergeResult The instance of `Database.MergeResult` to log
   * @return              The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(Database.MergeResult mergeResult) {
    List<Database.MergeResult> mergeResults = new List<Database.MergeResult>{
      mergeResult
    };
    this.setDatabaseResult(mergeResults);

    return this.setRecord(mergeResult.getId());
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  mergeResults The list of `Database.MergeResult` instances to log
   * @return               The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    List<Database.MergeResult> mergeResults
  ) {
    if (this.shouldSave == false || mergeResults == null) {
      return this;
    }

    String mergeResultsWithError = DatabaseResultHelper.getMergeResultError(
      mergeResults
    );
    this.logEvent.DatabaseResult__c = LogEventBuilderHelper.truncateFieldValue(
      Schema.LogEvent__e.DatabaseResult__c,
      mergeResultsWithError
    );

    return this;
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  upsertResult The instance of `Database.UpsertResult` to log
   * @return              The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(Database.UpsertResult upsertResult) {
    List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>{
      upsertResult
    };
    this.setDatabaseResult(upsertResults);
    return this.setRecord(upsertResult.getId());
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  upsertResults The list of `Database.UpsertResult` instances to log
   * @return               The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    List<Database.UpsertResult> upsertResults
  ) {
    if (this.shouldSave == false || upsertResults == null) {
      return this;
    }

    String upsertResultsWithError = DatabaseResultHelper.getUpsertResultError(
      upsertResults
    );
    this.logEvent.DatabaseResult__c = LogEventBuilderHelper.truncateFieldValue(
      Schema.LogEvent__e.DatabaseResult__c,
      upsertResultsWithError
    );

    return this;
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  undeleteResult The instance of `Database.UpsertResult` to log
   * @return              The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    Database.UndeleteResult undeleteResult
  ) {
    List<Database.UndeleteResult> undeleteResults = new List<Database.UndeleteResult>{
      undeleteResult
    };
    this.setDatabaseResult(undeleteResults);

    return this.setRecord(undeleteResult.getId());
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  undeleteResults The list of `Database.UndeleteResult` instances to log
   * @return               The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    List<Database.UndeleteResult> undeleteResults
  ) {
    if (this.shouldSave == false || undeleteResults == null) {
      return this;
    }

    String undeleteResultsWithError = DatabaseResultHelper.getUndeleteResultError(
      undeleteResults
    );
    this.logEvent.DatabaseResult__c = LogEventBuilderHelper.truncateFieldValue(
      Schema.LogEvent__e.DatabaseResult__c,
      undeleteResultsWithError
    );

    return this;
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  emptyRecycleBinResult The instance of `Database.EmptyRecycleBinResult` to log
   * @return              The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    Database.EmptyRecycleBinResult emptyRecycleBinResult
  ) {
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResults = new List<Database.EmptyRecycleBinResult>{
      emptyRecycleBinResult
    };
    this.setDatabaseResult(emptyRecycleBinResults);

    return this.setRecord(emptyRecycleBinResult.getId());
  }

  /**
   * @description Sets the log entry event's database operation result fields
   * @param  emptyRecycleBinResults The list of `Database.EmptyRecycleBinResult` instances to log
   * @return               The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setDatabaseResult(
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResults
  ) {
    if (this.shouldSave == false || emptyRecycleBinResults == null) {
      return this;
    }

    String emptyRecycleBinResultsWithError = DatabaseResultHelper.getEmptyRecycleBinResultError(
      emptyRecycleBinResults
    );
    this.logEvent.DatabaseResult__c = LogEventBuilderHelper.truncateFieldValue(
      Schema.LogEvent__e.DatabaseResult__c,
      emptyRecycleBinResultsWithError
    );

    return this;
  }

  /**
   * @description Sets the log entry event's record fields
   * @param  recordId The ID of the SObject record related to the entry
   * @return          The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setRecord(Id recordId) {
    if (this.shouldSave == false || String.isBlank(recordId)) {
      return this;
    }

    this.logEvent.RecordId__c = recordId;
    this.logEvent.RecordObjectName__c = recordId.getSObjectType()
      .getDescribe()
      .getName();
    return this;
  }

  /**
   * @description Sets the log entry event's record fields
   * @param  record The `SObject` record related to the entry. The JSON of the record is automatically added to the entry
   * @return        The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setRecord(SObject record) {
    if (this.shouldSave == false || record == null) {
      return this;
    }
    this.logEvent.RecordId__c = record.Id;
    if(LoggingSettingsController.isSecureLogEnabled() == true){
      this.logEvent.RecordsJson__c = JSON.serializePretty(record);
    }
    this.logEvent.RecordObjectName__c = record.getSObjectType() == null
      ? 'Unknown'
      : record.getSObjectType().getDescribe().getName();
    return this;
  }

  /**
   * @description Sets the log entry event's record fields
   * @param  records The list of `SObject` records related to the entry. The JSON of the list is automatically added to the entry
   * @return         The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setRecord(List<SObject> records) {
    if (this.shouldSave == false || records == null || records.size() == 0) {
      return this;
    }

    // First, try to use the list's SObject Type - if the list is null or an instance of List<SObject>, then try to use the first record's SObject Type
    Schema.SObjectType sobjectType = records?.getSObjectType() == null
      ? records.get(0)?.getSObjectType()
      : records?.getSObjectType();

    // If the first object doesn't work, then just log as is a generic SObject
    this.logEvent.RecordObjectName__c = sobjectType != null
      ? sobjectType.getDescribe().getName()
      : 'Unknown';

    if(LoggingSettingsController.isSecureLogEnabled() == true){
      this.logEvent.RecordsJson__c = JSON.serializePretty(records);
    }
    String recordIds = '';
    for (SObject record : records) {
      recordIds += record.Id + '\n';
    }
    this.logEvent.RecordId__c = recordIds;

    return this;
  }

  /**
   * @description Parses the provided stack trace and sets the log entry's origin & stack trace fields
   * @param stackTraceString The Apex stack trace string to parse
   * @return The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder parseStackTrace(String stackTraceString) {
    if (
      this.shouldSave == false ||
      !LogEventBuilderHelper.isValidStackTrace(stackTraceString)
    ) {
      return this;
    }

    List<String> stackTraceLines = LogEventBuilderHelper.filterStackTraceLines(
      stackTraceString
    );

    // In a managed package, we can end up with an invalid (unhelpful) stack trace, so only store when valid
    String filteredStackTraceString = String.join(stackTraceLines, '\n');
    this.logEvent.StackTrace__c = LogEventBuilderHelper.truncateFieldValue(
      Schema.LogEvent__e.StackTrace__c,
      filteredStackTraceString
    );

    String originLocation = LogEventBuilderHelper.getOriginLocation(
      filteredStackTraceString
    );
    this.logEvent.ApexClassName__c = originLocation.substringBefore('.');
    this.logEvent.ApexMethodName__c = originLocation.substringAfter('.');

    return this;
  }

  /**
   * @description Sets the payload on log event
   * @param payload The payload to be store on secure log entry
   * @return The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setPayload(String payload) {
    if (
      this.shouldSave == true &&
      LoggingSettingsController.isSecureLogEnabled() == true
    ) {
      this.logEvent.Payload__c = payload;
    }
    return this;
  }

  /**
   * @description Sets the lwc component name on log event
   * @param cmpName The component name
   * @return The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setComponentName(String cmpName) {
    if (this.shouldSave == true) {
      this.logEvent.ComponentName__c = cmpName;
    }
    return this;
  }

  /**
   * @description Sets the browser name on log event
   * @param browserName The browser name
   * @return The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setBrowserName(String browserName) {
    if (this.shouldSave == true) {
      this.logEvent.BrowserName__c = browserName;
    }
    return this;
  }

  /**
   * @description Sets the span Id on log event
   * @param spanId The span Id for each log entry or secure log entry
   * @return The same instance of `LogEventBuilder`, useful for chaining methods
   */
  public LogEventBuilder setSpanId(String spanId) {
    if (this.shouldSave == true) {
      this.logEvent.SpanId__c = spanId;
    }
    return this;
  }

  /**
   * @description Set transaction details on log event
   */
  private void setTransactionDetails() {
    this.logEvent.APIVersion__c = API_VERSION;
    this.logEvent.EnvironmentType__c = LogEventBuilderHelper.CACHED_ORGANIZATION_ENVIRONMENT_TYPE;
    this.logEvent.InstanceName__c = LogEventBuilderHelper.CACHED_ORGANIZATION.InstanceName;
    this.logEvent.LoggingLevel__c = entryLoggingLevel.NAME();
    this.logEvent.Origin__c = 'Apex';
    this.logEvent.StartTime__c = System.now();
    this.logEvent.TransactionContext__c = LogEventBuilderHelper.getTransactionContext();
    this.logEvent.SpanId__c = UniqueIdUtil.getSpanId();
  }

  /**
   * @description Set used governor limits
   */
  private void setUsedLimits() {
    this.logEvent.UsedCallouts__c = Limits.getCallouts();
    this.logEvent.UsedCPUTime__c = Limits.getCpuTime();
    this.logEvent.UsedDMLStatements__c = Limits.getDmlStatements();
    this.logEvent.UsedFutureCalls__c = Limits.getFutureCalls();
    this.logEvent.UsedHeapSize__c = Limits.getHeapSize();
    this.logEvent.UsedQueueableJobs__c = Limits.getQueueableJobs();
    this.logEvent.UsedSOQLQueries__c = Limits.getQueries();
  }

  /**
   * @description Set user details on log event
   */
  private void setUserDetails() {
    this.logEvent.UserProfile__c = LogEventBuilderHelper.CACHED_USER.Profile.Name;
    this.logEvent.UserRole__c = LogEventBuilderHelper.CACHED_USER.UserRole
      ?.Name;
    this.logEvent.UserId__c = LogEventBuilderHelper.CACHED_USER.Id;
  }

  /**
   * @description Determines if this instance of `LogEventBuilder` should be saved the next time that `Logger.saveLog()` is called
   * @return A boolean set to true if the log entries should be saved.
   */
  public Boolean shouldSave() {
    return this.shouldSave;
  }
}
