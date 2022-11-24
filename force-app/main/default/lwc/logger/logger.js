import { LightningElement, api, wire } from "lwc";
import { newLogEntry } from "./logEventBuilder";
import getSettings from "@salesforce/apex/LWCLogger.getSettings";
import saveComponentLogEntries from "@salesforce/apex/LWCLogger.saveComponentLogEntries";
import { handleErrorShowToast } from "c/utils";

export default class Logger extends LightningElement {
  componentLogEntries = [];
  settings;
  @wire(getSettings)
  wiredSettings({ error, data }) {
    if (data) {
      this.settings = data;
    } else if (error) {
      handleErrorShowToast(
        this,
        "Failed to retrieve logging settings",
        error,
        "",
        "pester"
      );
    }
  }

  /**
   * @description Returns information about the current user's settings, stored in `LoggerSettings__c`
   * @return {ComponentLogger.ComponentLoggerSettings} The current user's instance of the Apex class `ComponentLogger.ComponentLoggerSettings`
   */
  @api
  getUserSettings() {
    return this.settings;
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.ERROR`
   * @param {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The new entry's instance of `LogEntryEventBuilder`, useful for chaining methods
   */
  @api
  error(message) {
    return this._newEntry("ERROR", message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.WARN`
   * @param {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The new entry's instance of `LogEntryEventBuilder`, useful for chaining methods
   */
  @api
  warn(message) {
    return this._newEntry("WARN", message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.INFO`
   * @param {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The new entry's instance of `LogEntryEventBuilder`, useful for chaining methods
   */
  @api
  info(message) {
    return this._newEntry("INFO", message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.DEBUG`
   * @param {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The new entry's instance of `LogEntryEventBuilder`, useful for chaining methods
   */
  @api
  debug(message) {
    return this._newEntry("DEBUG", message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.FINE`
   * @param {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The new entry's instance of `LogEntryEventBuilder`, useful for chaining methods
   */
  @api
  fine(message) {
    return this._newEntry("FINE", message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.FINER`
   * @param {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The new entry's instance of `LogEntryEventBuilder`, useful for chaining methods
   */
  @api
  finer(message) {
    return this._newEntry("FINER", message);
  }

  /**
   * @description Creates a new log entry with logging level == `LoggingLevel.FINEST`
   * @param {String} message The string to use to set the entry's message field
   * @return {LogEntryBuilder} The new entry's instance of `LogEntryEventBuilder`, useful for chaining methods
   */
  @api
  finest(message) {
    return this._newEntry("FINEST", message);
  }

  /**
   * @description Returns the number of entries that have been generated but not yet saved
   * @return {Integer} The buffer's current size
   */
  @api
  getBufferSize() {
    return this.componentLogEntries.length;
  }

  /**
   * @description Discards any entries that have been generated but not yet saved
   */
  @api
  flushBuffer() {
    this.componentLogEntries = [];
  }

  /**
   * @description Saves any entries in Logger's buffer, using the specified save method for only this call.
   *              All subsequent calls to saveLog() will use the transaction save method.
   * @param  {String} saveMethod The enum value of Logger.SaveMethod to use for this specific save action.
   */
  @api
  saveLog(saveMethodName) {
    if (this.getBufferSize() > 0) {
      if (
        !saveMethodName &&
        this.settings &&
        this.settings.defaultSaveMethodName
      ) {
        saveMethodName = this.settings.defaultSaveMethodName;
      }
      saveComponentLogEntries({
        componentLogEntries: this.componentLogEntries,
        saveMethodName: saveMethodName
      })
        .then(this.flushBuffer())
        .catch((error) => {
          handleErrorShowToast(
            this,
            "Failed to retrieve logging settings",
            error,
            "",
            "pester"
          );
        });
    }
  }

  _meetsUserLoggingLevel(logEntryLoggingLevel) {
    let logEntryLoggingLevelOrdinal = this.settings.supportedLoggingLevels[
      logEntryLoggingLevel
    ];
    return (
      this.settings &&
      this.settings.userLoggingLevel.ordinal <= logEntryLoggingLevelOrdinal
    );
  }

  _newEntry(loggingLevel, message) {
    const shouldSave = this._meetsUserLoggingLevel(loggingLevel);
    let userAgent = navigator.userAgent;
    let browserName;

    if (userAgent.match(/chrome|chromium|crios/i)) {
      browserName = "Chrome";
    } else if (userAgent.match(/firefox|fxios/i)) {
      browserName = "Firefox";
    } else if (userAgent.match(/safari/i)) {
      browserName = "Safari";
    } else if (userAgent.match(/opr\//i)) {
      browserName = "Opera";
    } else if (userAgent.match(/edg/i)) {
      browserName = "Edge";
    } else {
      browserName = "No browser detected";
    }
    const logEntryBuilder = newLogEntry(
      loggingLevel,
      this.template.host.localName,
      browserName
    ).setMessage(message);

    if (shouldSave === true) {
      this.componentLogEntries.push(logEntryBuilder);
    }
    return logEntryBuilder;
  }
}
