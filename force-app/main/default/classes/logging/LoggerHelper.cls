/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @group Logging
 * @description  Helper class for {@link Logger}
 */
public with sharing class LoggerHelper {
  @TestVisible
  private static final List<LogEventBuilder> LOG_ENTRIES_BUFFER = new List<LogEventBuilder>();
  private static final String TRACE_ID = UniqueIdUtil.getTraceId();
  private static final LoggingLevel DEFAULT_LOGGING_LEVEL = LoggingLevel.ERROR;

  /**
   * @description The default save method in custom setting
   * @return The default save method
   */
  @TestVisible
  public static Logger.SaveMethod transactionSaveMethod {
    get {
      if (transactionSaveMethod == null) {
        transactionSaveMethod = getDefaultSaveMethod();
      }
      return transactionSaveMethod;
    }
    set;
  }

  /**
   * @description Returns the default save method
   * @return The default save method
   */
  private static Logger.SaveMethod getDefaultSaveMethod() {
    Logger.SaveMethod defaultSaveMethod;

    String saveMethodName = LoggingSettingsController.getDefaultSaveMethod()
      ?.toUpperCase();
    switch on saveMethodName {
      when 'QUEUEABLE' {
        defaultSaveMethod = Logger.SaveMethod.QUEUEABLE;
      }
      when else {
        defaultSaveMethod = Logger.SaveMethod.EVENT_BUS;
      }
    }

    return defaultSaveMethod;
  }

  /**
   * @description Returns the default user's logging level
   * @return The default user's logging level
   */
  @TestVisible
  private static LoggingLevel userLoggingLevel {
    get {
      if (userLoggingLevel == null) {
        userLoggingLevel = getLoggingLevel(
          LoggingSettingsController.getDefaultLoggingLevel()
        );
      }
      return userLoggingLevel;
    }
    set;
  }

  /**
   * @description Converts a string to an instance of LoggingLevel
   * @param  loggingLevelName The string name of an Apex logging level
   * @return                  The matching instance of LoggingLevel (or a default value if a match is not found)
   */
  @TestVisible
  public static LoggingLevel getLoggingLevel(String loggingLevelName) {
    if (loggingLevelName != null) {
      loggingLevelName = loggingLevelName.trim().toUpperCase();
    }

    switch on loggingLevelName {
      when 'ERROR' {
        return LoggingLevel.ERROR;
      }
      when 'INFO' {
        return LoggingLevel.INFO;
      }
      when 'DEBUG' {
        return LoggingLevel.DEBUG;
      }
      when else {
        return DEFAULT_LOGGING_LEVEL;
      }
    }
  }

  /**
   * @description Returns a builder instance for a log entry
   * @param loggingLevel the logging level of the log entry
   * @return A new builder instance for a entry
   */
  public static LogEventBuilder newEntry(LoggingLevel loggingLevel) {
    return newEntry(loggingLevel, isEnabled(loggingLevel));
  }

  /**
   * @description Returns a builder instance for a log entry
   * @param loggingLevel the logging level of the log entry
   * @param shouldSave if the log entry should be saved. This is based on if loggging is enabled for the user in custom setting
   * @return A new builder instance for a entry
   */
  private static LogEventBuilder newEntry(
    LoggingLevel loggingLevel,
    Boolean shouldSave
  ) {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel, shouldSave);
    if (builder.shouldSave() == true) {
      LOG_ENTRIES_BUFFER.add(builder);
    }

    return builder;
  }

  /**
   * @description Indicates if logging for the specified logging level is enabled for the current user, based on the custom setting LoggingSettings__c
   * @param  loggingLevel - The logging level to check
   * @return If logging for the specified logging level is enabled for the current user
   */
  private static Boolean isEnabled(LoggingLevel loggingLevel) {
    return meetsUserLoggingLevel(loggingLevel);
  }

  /**
   * @description Indicates if the specified logging level is enabled for the current user, based on the custom setting LoggingSettings__c
   * @param logEntryLoggingLevel the logging level to check.
   * @return Boolean
   */
  public static Boolean meetsUserLoggingLevel(
    LoggingLevel logEntryLoggingLevel
  ) {
    return userLoggingLevel.ordinal() <= logEntryLoggingLevel.ordinal();
  }

  // Transaction control methods
  /**
   * @description Returns the number of entries that have been generated but not yet saved
   * @return Integer
   */
  public static Integer getBufferSize() {
    return LOG_ENTRIES_BUFFER.size();
  }

  /**
   * @description Discards any entries that have been generated but not yet saved
   */
  public static void flushBuffer() {
    LOG_ENTRIES_BUFFER.clear();
  }

  /**
   * @description Saves any entries in Logger's buffer, using the specified save method for only this call.
   *   All subsequent calls to saveLog() will use the transaction save method.
   * @param  saveMethod The enum value of Logger.SaveMethod to use for this specific save action.
   */
  public static void saveLog(Logger.SaveMethod saveMethod) {
    if (LOG_ENTRIES_BUFFER.isEmpty()) {
      return;
    }

    List<LogEvent__e> logEvents = new List<LogEvent__e>();
    for (LogEventBuilder logEventBuilder : LOG_ENTRIES_BUFFER) {
      if (logEventBuilder.shouldSave()) {
        LogEvent__e logEvent = LogEventBuilder.getLogEvent();
        logEvent.TraceId__c = LoggerHelper.TRACE_ID;
        logEvents.add(logEvent);
      }
    }

    switch on saveMethod {
      when EVENT_BUS {
        PlatformEventUtils.publishEvents(logEvents);
      }
      when QUEUEABLE {
        System.enqueueJob(new QueueableSaver(logEvents));
      }
    }

    flushBuffer();
  }
}
