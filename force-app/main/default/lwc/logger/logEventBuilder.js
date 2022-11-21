const LogEntryBuilder = class {
  /**
   * @description Constructor used to generate each JavaScript-based log entry event
   *              This class is the JavaScript-equivalent of the Apex class `LogEntryBuilder`
   * @param  {String} loggingLevel The `LoggingLevel` enum to use for the builder's instance of `LogEntryEvent__e`
   * @param  {String} componentName Name of the LWC component which calls the logger
   * @param  {String} browserName Browser name to be captured in the logger
   */
  constructor(loggingLevel, componentName, browserName) {
    this.componentName = componentName;
    this.browserName = browserName;
    this.loggingLevel = loggingLevel;
    this.timestamp = new Date().toISOString();
  }

  /**
   * @description Sets the log entry event's message field
   * @param  {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The same instance of `LogEntryBuilder`, useful for chaining methods
   */
  setMessage(message) {
    this.message = message;
    return this;
  }

  /**
   * @description Sets the log entry event's record fields
   * @param  {String} recordId The ID of the SObject record related to the entry
   * @return {LogEntryBuilder} The same instance of `LogEntryBuilder`, useful for chaining methods
   */
  setRecordId(recordId) {
    this.recordId = recordId;
    return this;
  }

  /**
   * @description Sets the log entry event's record fields
   * @param  {Object} record The `SObject` record related to the entry. The JSON of the record is automatically added to the entry
   * @return {LogEntryBuilder} The same instance of `LogEntryBuilder`, useful for chaining methods
   */
  setRecord(record) {
    this.record = record;
    return this;
  }

  /**
   * @description Sets the log entry event's exception fields
   * @param {Error} error The instance of a JavaScript `Error` object to use, or an Apex HTTP error to use
   * @return {LogEntryBuilder} The same instance of `LogEntryBuilder`, useful for chaining methods
   */
  setError(error) {
    this.error = {};
    if (error.body) {
      this.error.message = error.body.message;
      this.error.stack = error.body.stackTrace;
      this.error.type = error.body.exceptionType;
    } else {
      this.error.message = error.message;
      this.error.stack = error.stack;
      this.error.type = "JavaScript." + error.name;
    }
    return this;
  }
};

export function newLogEntry(loggingLevel, componentName, browserName) {
  return new LogEntryBuilder(loggingLevel, componentName, browserName);
}
