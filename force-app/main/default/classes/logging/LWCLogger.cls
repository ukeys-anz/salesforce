/**
 * @description       : Controller class for the LWC logger component to provide logger setting details and save the log entries
 * @author            : Prakash B
 * @group             : Logging
 * @last modified on  : 11-15-2022
 **/
public without sharing class LWCLogger {
  /**
   * @description Provides data to the frontend about `LoggerSettings__c` & server-supported logging details
   * @return   return The instance of `LWCLoggerSettings` for the current user
   */
  @AuraEnabled(cacheable=true)
  public static LWCLoggerSettings getSettings() {
    return new LWCLoggerSettings();
  }

  /**
   * @description saveComponentLogEntries Saves log entries created via lwc or aura components
   * @param  componentLogEntries The list of `ComponentLogEntry` objects to save via `Logger`
   * @param  saveMethodName      String name of the instance of Logger.SaveMethod to use when saving.
   *                             When null, the value of `Logger.getSaveMethod()` will be used.
   */
  @AuraEnabled
  public static void saveComponentLogEntries(
    List<ComponentLogEntry> componentLogEntries,
    String saveMethodName
  ) {
    try {
      Logger.SaveMethod saveMethod = LoggerHelper.transactionSaveMethod;
      for (ComponentLogEntry componentLogEntry : componentLogEntries) {
        LoggingLevel entryLoggingLevel = LoggerHelper.getLoggingLevel(
          componentLogEntry.loggingLevel
        );
        LogEventBuilder logEventBuilder = LoggerHelper.newEntry(
            entryLoggingLevel
          )
          .setMessage(componentLogEntry.message);

        if (componentLogEntry.recordId != null) {
          logEventBuilder.setRecord(componentLogEntry.recordId);
        }
        if (componentLogEntry.record != null) {
          logEventBuilder.setRecord(componentLogEntry.record);
        }

        logEventBuilder.getLogEvent()
          .StartTime__c = componentLogEntry.timestamp;
        logEventBuilder.getLogEvent()
          .BrowserName__c = componentLogEntry.browserName;
        logEventBuilder.getLogEvent()
          .ComponentName__c = componentLogEntry.componentName;

        setComponentErrorDetails(logEventBuilder, componentLogEntry.error);
        setStackTraceDetails(logEventBuilder, componentLogEntry.stack);
      }
      if (String.isNotBlank(saveMethodName)) {
        saveMethod = Logger.SaveMethod.valueOf(saveMethodName);
      }
      Logger.saveLog(saveMethod);
    } catch (Exception apexException) {
      String errorMessage =
        apexException.getMessage() +
        '\n' +
        apexException.getStackTraceString();
      AuraHandledException auraException = new AuraHandledException(
        errorMessage
      );
      auraException.setMessage(errorMessage);
      throw auraException;
    }
  }

  private static void setComponentErrorDetails(
    logEventBuilder logEventBuilder,
    ComponentError componentError
  ) {
    if (componentError == null) {
      return;
    }

    logEventBuilder.getLogEvent().ExceptionMessage__c = componentError.message;
    logEventBuilder.getLogEvent().ExceptionType__c = componentError.type;
  }

  private static void setStackTraceDetails(
    logEventBuilder logEventBuilder,
    String stackTraceString
  ) {
    String originLocation;
    if (String.isNotBlank(stackTraceString)) {
      originLocation = getOriginLocation(stackTraceString);
    }
    logEventBuilder.getLogEvent().Origin__c = originLocation;
    logEventBuilder.getLogEvent().StackTrace__c = truncateFieldValue(
      Schema.LogEvent__e.StackTrace__c,
      stackTraceString
    );
  }

  private static String getOriginLocation(String stackTraceString) {
    String originLocation;

    String loggerComponentReferenceToIgnore = '/c/logger.js';
    String lwcModuleContent = '/n/modules/';
    Boolean parentComponentFound = false;

    List<String> stackTraceLines = new List<String>();
    for (String currentStackTraceLine : stackTraceString.split('\n')) {
      if (currentStackTraceLine.contains(loggerComponentReferenceToIgnore)) {
        continue;
      } else if (
        parentComponentFound == false &&
        currentStackTraceLine.contains(lwcModuleContent)
      ) {
        parentComponentFound = true;
      }

      if (parentComponentFound == true) {
        stackTraceLines.add(currentStackTraceLine);
      }
    }

    stackTraceString = String.join(stackTraceLines, '\n');
    if (String.isNotBlank(stackTraceString)) {
      String componentContent = lwcModuleContent;
      String componentName;
      String componentFunction;
      for (String currentStackTraceLine : stackTraceString.split('\n')) {
        if (currentStackTraceLine.trim().startsWith('at eval')) {
          continue;
        }

        componentName = currentStackTraceLine.substringAfterLast(
            componentContent
          )
          .substringBefore('.js');
        componentFunction = currentStackTraceLine.substringBefore('@');
        break;
      }
      originLocation = componentName + '.' + componentFunction;
    }

    return originLocation;
  }

  private static String truncateFieldValue(
    Schema.SObjectField field,
    String value
  ) {
    Integer fieldMaxLength = field.getDescribe().getLength();
    if (String.isBlank(value) || value.length() <= fieldMaxLength) {
      return value;
    }

    return value.left(fieldMaxLength);
  }
}
