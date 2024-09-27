/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @group Logging
 * @description  The main class for logging, from which engineers will call functions to create logs
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.ExcessiveClassLength'
)
public with sharing class Logger {
  private static final LogEventBuilder EMPTY = new LogEventBuilder(null, false);

  // ERROR logging level methods
  /**
   * @description Enum used to control Severity values
   */
  public enum Severity {
    CRITICAL,
    HIGH,
    MEDIUM,
    LOW
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param deleteResult The instance of `Database.DeleteResult` to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.DeleteResult deleteResult
  ) {
    return error(message, deleteResult, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param deleteResult The instance of `Database.DeleteResult` to log
   * @param severity     The severity of an error log message
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.DeleteResult deleteResult,
    Severity severity
  ) {
    if (deleteResult.isSuccess()) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(deleteResult)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message     The string to use to set the entry's message field
   * @param mergeResult The instance of `Database.MergeResult` to log
   * @return            The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.MergeResult mergeResult
  ) {
    return error(message, mergeResult, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message     The string to use to set the entry's message field
   * @param mergeResult The instance of `Database.MergeResult` to log
   * @param severity    The severity of an error log message
   * @return            The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.MergeResult mergeResult,
    Severity severity
  ) {
    if (mergeResult.isSuccess()) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(mergeResult)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message    The string to use to set the entry's message field
   * @param saveResult The instance of `Database.SaveResult` to log
   * @return           The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.SaveResult saveResult
  ) {
    return error(message, saveResult, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message    The string to use to set the entry's message field
   * @param saveResult The instance of `Database.SaveResult` to log
   * @param severity   The severity of an error log message
   * @return           The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.SaveResult saveResult,
    Severity severity
  ) {
    if (saveResult.isSuccess()) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(saveResult)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message        The string to use to set the entry's message field
   * @param undeleteResult The instance of `Database.UndeleteResult` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.UndeleteResult undeleteResult
  ) {
    return error(message, undeleteResult, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message        The string to use to set the entry's message field
   * @param undeleteResult The instance of `Database.UndeleteResult` to log
   * @param severity       The severity of an error log message
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.UndeleteResult undeleteResult,
    Severity severity
  ) {
    if (undeleteResult.isSuccess()) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(undeleteResult)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param upsertResult The instance of `Database.UpsertResult` to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.UpsertResult upsertResult
  ) {
    return error(message, upsertResult, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param upsertResult The instance of `Database.UpsertResult` to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.UpsertResult upsertResult,
    Severity severity
  ) {
    if (upsertResult.isSuccess()) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(upsertResult)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param emptyRecycleBinResult The instance of `Database.EmptyRecycleBinResult` to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.EmptyRecycleBinResult emptyRecycleBinResult
  ) {
    return error(message, emptyRecycleBinResult, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param emptyRecycleBinResult The instance of `Database.EmptyRecycleBinResult` to log
   * @param severity     The severity of an error log message
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Database.EmptyRecycleBinResult emptyRecycleBinResult,
    Severity severity
  ) {
    return error()
      .setDatabaseResult(emptyRecycleBinResult)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param deleteResults The list of `Database.DeleteResult` instances to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.DeleteResult> deleteResults
  ) {
    return error(message, deleteResults, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param deleteResults The list of `Database.DeleteResult` instances to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.DeleteResult> deleteResults,
    Severity severity
  ) {
    if (
      String.isBlank(DatabaseResultHelper.getDeleteResultError(deleteResults))
    ) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(deleteResults)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param mergeResults The list of `Database.MergeResult` instances to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.MergeResult> mergeResults
  ) {
    return error(message, mergeResults, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message      The string to use to set the entry's message field
   * @param mergeResults The list of `Database.MergeResult` instances to log
   * @param severity     The severity of an error log message
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.MergeResult> mergeResults,
    Severity severity
  ) {
    if (
      String.isBlank(DatabaseResultHelper.getMergeResultError(mergeResults))
    ) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(mergeResults)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message     The string to use to set the entry's message field
   * @param saveResults The list of `Database.SaveResult` instances to log
   * @return            The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.SaveResult> saveResults
  ) {
    return error(message, saveResults, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message     The string to use to set the entry's message field
   * @param saveResults The list of `Database.SaveResult` instances to log
   * @param severity    The severity of an error log message
   * @return            The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.SaveResult> saveResults,
    Severity severity
  ) {
    if (String.isBlank(DatabaseResultHelper.getSaveResultError(saveResults))) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(saveResults)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message         The string to use to set the entry's message field
   * @param undeleteResults The list of `Database.UndeleteResult` instances to log
   * @return                The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.UndeleteResult> undeleteResults
  ) {
    return error(message, undeleteResults, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message         The string to use to set the entry's message field
   * @param undeleteResults The list of `Database.UndeleteResult` instances to log
   * @param severity        The severity of an error log message
   * @return                The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.UndeleteResult> undeleteResults,
    Severity severity
  ) {
    if (
      String.isBlank(
        DatabaseResultHelper.getUndeleteResultError(undeleteResults)
      )
    ) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(undeleteResults)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param upsertResults The list of `Database.UpsertResult` instances to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.UpsertResult> upsertResults
  ) {
    return error(message, upsertResults, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param upsertResults The list of `Database.UpsertResult` instances to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.UpsertResult> upsertResults,
    Severity severity
  ) {
    if (
      String.isBlank(DatabaseResultHelper.getUpsertResultError(upsertResults))
    ) {
      return EMPTY;
    }
    return error()
      .setDatabaseResult(upsertResults)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param emptyRecycleBinResults The list of `Database.EmptyRecycleBinResult` instances to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResults
  ) {
    return error(message, emptyRecycleBinResults, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param emptyRecycleBinResults The list of `Database.EmptyRecycleBinResult` instances to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResults,
    Severity severity
  ) {
    return error()
      .setDatabaseResult(emptyRecycleBinResults)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param apexException The instance of `Exception` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(String message, Exception apexException) {
    return error(message, apexException, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param apexException The instance of `Exception` to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Exception apexException,
    Severity severity
  ) {
    return error()
      .setExceptionDetails(apexException)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param recordId      The record ID of an `SObject` to log
   * @param apexException The instance of `Exception` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Id recordId,
    Exception apexException
  ) {
    return error(message, recordId, apexException, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param recordId      The record ID of an `SObject` to log
   * @param apexException The instance of `Exception` to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Id recordId,
    Exception apexException,
    Severity severity
  ) {
    return error()
      .setRecord(recordId)
      .setExceptionDetails(apexException)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @param recordId The record ID of an `SObject` to log
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(String message, Id recordId) {
    return error(message, recordId, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @param recordId The record ID of an `SObject` to log
   * @param severity The severity of an error log message
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    Id recordId,
    Severity severity
  ) {
    return error()
      .setRecord(recordId)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param record        The `SObject` record to log
   * @param apexException The instance of `Exception` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    SObject record,
    Exception apexException
  ) {
    return error(message, record, apexException, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The string to use to set the entry's message field
   * @param record        The `SObject` record to log
   * @param apexException The instance of `Exception` to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    SObject record,
    Exception apexException,
    Severity severity
  ) {
    return error()
      .setRecord(record)
      .setExceptionDetails(apexException)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The instance of `LogMessage` to use to set the entry's message field
   * @param records       The list of `SObject` records to log
   * @param apexException The instance of `Exception` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<SObject> records,
    Exception apexException
  ) {
    return error(message, records, apexException, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message       The instance of `LogMessage` to use to set the entry's message field
   * @param records       The list of `SObject` records to log
   * @param apexException The instance of `Exception` to log
   * @param severity      The severity of an error log message
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<SObject> records,
    Exception apexException,
    Severity severity
  ) {
    return error()
      .setRecord(records)
      .setExceptionDetails(apexException)
      .setMessage(message)
      .setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @param record   The `SObject` record to log
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(String message, SObject record) {
    return error(message, record, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @param record   The `SObject` record to log
   * @param severity The severity of an error log message
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    SObject record,
    Severity severity
  ) {
    return error().setRecord(record).setMessage(message).setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @param records  The list of `SObject` records to log
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(String message, List<SObject> records) {
    return error(message, records, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @param records  The list of `SObject` records to log
   * @param severity The severity of an error log message
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(
    String message,
    List<SObject> records,
    Severity severity
  ) {
    return error().setRecord(records).setMessage(message).setSeverity(severity);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(String message) {
    return error(message, Severity.MEDIUM);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param message  The string to use to set the entry's message field
   * @param severity The severity of an error log message
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder error(String message, Severity severity) {
    return error().setMessage(message).setSeverity(severity);
  }

  // INFO logging methods
  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message   The string to use to set the entry's message field
   * @param  deleteResult The instance of `Database.DeleteResult` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    Database.DeleteResult deleteResult
  ) {
    return info().setDatabaseResult(deleteResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message     The string to use to set the entry's message field
   * @param  mergeResult The instance of `Database.MergeResult` to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    Database.MergeResult mergeResult
  ) {
    return info().setDatabaseResult(mergeResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message    The string to use to set the entry's message field
   * @param  saveResult The instance of `Database.SaveResult` to log
   * @return            The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    Database.SaveResult saveResult
  ) {
    return info().setDatabaseResult(saveResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message        The string to use to set the entry's message field
   * @param  undeleteResult The instance of `Database.UndeleteResult` to log
   * @return                The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    Database.UndeleteResult undeleteResult
  ) {
    return info().setDatabaseResult(undeleteResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message      The string to use to set the entry's message field
   * @param  upsertResult The instance of `Database.UpsertResult` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    Database.UpsertResult upsertResult
  ) {
    return info().setDatabaseResult(upsertResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message      The string to use to set the entry's message field
   * @param  emptyRecycleBinResult The instance of `Database.EmptyRecycleBinResult` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    Database.EmptyRecycleBinResult emptyRecycleBinResult
  ) {
    return info().setDatabaseResult(emptyRecycleBinResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message       The string to use to set the entry's message field
   * @param  deleteResults The list of `Database.DeleteResult` instances to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    List<Database.DeleteResult> deleteResults
  ) {
    return info().setDatabaseResult(deleteResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message      The string to use to set the entry's message field
   * @param  mergeResults The list of `Database.MergeResult` instances to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    List<Database.MergeResult> mergeResults
  ) {
    return info().setDatabaseResult(mergeResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message     The string to use to set the entry's message field
   * @param  saveResults The list of `Database.SaveResult` instances to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    List<Database.SaveResult> saveResults
  ) {
    return info().setDatabaseResult(saveResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message         The string to use to set the entry's message field
   * @param  undeleteResults The list of `Database.UndeleteResult` instances to log
   * @return                 The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    List<Database.UndeleteResult> undeleteResults
  ) {
    return info().setDatabaseResult(undeleteResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message       The string to use to set the entry's message field
   * @param  upsertResults The list of `Database.UpsertResult` instances to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    List<Database.UpsertResult> upsertResults
  ) {
    return info().setDatabaseResult(upsertResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message       The string to use to set the entry's message field
   * @param  emptyRecycleBinResults The list of `Database.EmptyRecycleBinResult` instances to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    List<Database.EmptyRecycleBinResult> emptyRecycleBinResults
  ) {
    return info().setDatabaseResult(emptyRecycleBinResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message       The string to use to set the entry's message field
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(String message, Exception apexException) {
    return info().setExceptionDetails(apexException).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message       The string to use to set the entry's message field
   * @param  recordId      The record ID of an `SObject` to log
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    Id recordId,
    Exception apexException
  ) {
    return info()
      .setRecord(recordId)
      .setExceptionDetails(apexException)
      .setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message  The string to use to set the entry's message field
   * @param  recordId The record ID of an `SObject` to log
   * @return          The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(String message, Id recordId) {
    return info().setRecord(recordId).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message       The string to use to set the entry's message field
   * @param  record        The `SObject` record to log
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    SObject record,
    Exception apexException
  ) {
    return info()
      .setRecord(record)
      .setExceptionDetails(apexException)
      .setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message    The instance of `LogMessage` to use to set the entry's message field
   * @param  records       The list of `SObject` records to log
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(
    String message,
    List<SObject> records,
    Exception apexException
  ) {
    return info()
      .setRecord(records)
      .setExceptionDetails(apexException)
      .setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message The string to use to set the entry's message field
   * @param  record  The `SObject` record to log
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(String message, SObject record) {
    return info().setRecord(record).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message The string to use to set the entry's message field
   * @param  records The list of `SObject` records to log
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(String message, List<SObject> records) {
    return info().setRecord(records).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param  message The string to use to set the entry's message field
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder info(String message) {
    return info().setMessage(message);
  }

  // DEBUG log level methods
  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message   The string to use to set the entry's message field
   * @param  deleteResult The instance of `Database.DeleteResult` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    Database.DeleteResult deleteResult
  ) {
    return debug().setDatabaseResult(deleteResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message     The string to use to set the entry's message field
   * @param  mergeResult The instance of `Database.MergeResult` to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    Database.MergeResult mergeResult
  ) {
    return debug().setDatabaseResult(mergeResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message    The string to use to set the entry's message field
   * @param  saveResult The instance of `Database.SaveResult` to log
   * @return            The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    Database.SaveResult saveResult
  ) {
    return debug().setDatabaseResult(saveResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message        The string to use to set the entry's message field
   * @param  undeleteResult The instance of `Database.UndeleteResult` to log
   * @return                The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    Database.UndeleteResult undeleteResult
  ) {
    return debug().setDatabaseResult(undeleteResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message      The string to use to set the entry's message field
   * @param  upsertResult The instance of `Database.UpsertResult` to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    Database.UpsertResult upsertResult
  ) {
    return debug().setDatabaseResult(upsertResult).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message       The string to use to set the entry's message field
   * @param  deleteResults The list of `Database.DeleteResult` instances to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    List<Database.DeleteResult> deleteResults
  ) {
    return debug().setDatabaseResult(deleteResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message      The string to use to set the entry's message field
   * @param  mergeResults The list of `Database.MergeResult` instances to log
   * @return              The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    List<Database.MergeResult> mergeResults
  ) {
    return debug().setDatabaseResult(mergeResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message     The string to use to set the entry's message field
   * @param  saveResults The list of `Database.SaveResult` instances to log
   * @return             The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    List<Database.SaveResult> saveResults
  ) {
    return debug().setDatabaseResult(saveResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message         The string to use to set the entry's message field
   * @param  undeleteResults The list of `Database.UndeleteResult` instances to log
   * @return                 The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    List<Database.UndeleteResult> undeleteResults
  ) {
    return debug().setDatabaseResult(undeleteResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message       The string to use to set the entry's message field
   * @param  upsertResults The list of `Database.UpsertResult` instances to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    List<Database.UpsertResult> upsertResults
  ) {
    return debug().setDatabaseResult(upsertResults).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message       The string to use to set the entry's message field
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(String message, Exception apexException) {
    return debug().setExceptionDetails(apexException).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message       The string to use to set the entry's message field
   * @param  recordId      The record ID of an `SObject` to log
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    Id recordId,
    Exception apexException
  ) {
    return debug()
      .setRecord(recordId)
      .setExceptionDetails(apexException)
      .setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message  The string to use to set the entry's message field
   * @param  recordId The record ID of an `SObject` to log
   * @return          The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(String message, Id recordId) {
    return debug().setRecord(recordId).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message       The string to use to set the entry's message field
   * @param  record        The `SObject` record to log
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    SObject record,
    Exception apexException
  ) {
    return debug()
      .setRecord(record)
      .setExceptionDetails(apexException)
      .setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param  message    The instance of `LogMessage` to use to set the entry's message field
   * @param  records       The list of `SObject` records to log
   * @param  apexException The instance of `Exception` to log
   * @return               The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(
    String message,
    List<SObject> records,
    Exception apexException
  ) {
    return debug()
      .setRecord(records)
      .setExceptionDetails(apexException)
      .setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message The string to use to set the entry's message field
   * @param  record  The `SObject` record to log
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(String message, SObject record) {
    return debug().setRecord(record).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message The string to use to set the entry's message field
   * @param  records The list of `SObject` records to log
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(String message, List<SObject> records) {
    return debug().setRecord(records).setMessage(message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param  message The string to use to set the entry's message field
   * @return         The new entry's instance of `LogEventBuilder`, useful for chaining methods
   */
  public static LogEventBuilder debug(String message) {
    return debug().setMessage(message);
  }

  /**
   * @description Returns a builder instance for error log entry
   * @return A new builder instance for error log entry
   */
  private static LogEventBuilder error() {
    return LoggerHelper.newEntry(LoggingLevel.ERROR);
  }

  /**
   * @description Returns a builder instance for info log entry
   * @return A new builder instance for info log entry
   */
  private static LogEventBuilder info() {
    return LoggerHelper.newEntry(LoggingLevel.INFO);
  }

  /**
   * @description Returns a builder instance for debug log entry
   * @return A new builder instance for debug log entry
   */
  private static LogEventBuilder debug() {
    return LoggerHelper.newEntry(LoggingLevel.DEBUG);
  }

  /**
   * @description Enum used to control how LogEvent__e records are inserted
   */
  public enum SaveMethod {
    EVENT_BUS,
    QUEUEABLE,
    IMMEDIATE
  }

  /**
   * @description Saves any entries in Logger's buffer. By default, entries are saved via Apex's EventBus.
   * @param saveMethod The enum value of Logger.SaveMethod to use for this specific save action.
   */
  public static void saveLog(SaveMethod saveMethod) {
    LoggerHelper.saveLog(saveMethod);
  }

  /**
   * @description Saves any entries in Logger's buffer. By default, entries are saved via Apex's EventBus.
   */
  @InvocableMethod(
    Category='Logging'
    Label='Save Log'
    Description='Saves any log entries that have been generated'
  )
  public static void saveLog() {
    LoggerHelper.saveLog(LoggerHelper.transactionSaveMethod);
  }

  /**
   * @description checks the logger buffer for any errors
   * @return a boolean indicating whether buffer contains any errors
   */
  public static boolean hasError() {
    return LoggerHelper.hasError();
  }
}
