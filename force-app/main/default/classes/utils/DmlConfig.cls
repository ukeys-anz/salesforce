/**
 * @description A class that represents the configuration options for DML operations.
 * @author Tan Phan
 * @since 08/2024
 * @group Util
 */
public inherited sharing class DmlConfig {
  /**
   * @description The severity level for log message.
   */
  public Logger.Severity optSeverity = Logger.Severity.MEDIUM;

  /**
   * @description The access level.
   */
  public AccessLevel optAccess = AccessLevel.USER_MODE;

  /**
   * @description Determines whether to execute DML operations in `without sharing` context.
   */
  public Boolean withoutSharing = false;

  /**
   * @description The DML options for database operations.
   */
  public Database.DmlOptions dmlOptions = new Database.DmlOptions();

  /**
   * @description The error message to log in case of an error.
   */
  public String errorLog = '';

  /**
   * @description Determine whether to perform empty recycle bin after `doDelete`.
   */
  public Boolean hardDelete = false;

  /**
   * @description Gets the value indicating whether all records must succeed.
   */
  public Boolean allOrNone {
    get {
      return this.dmlOptions.OptAllOrNone;
    }
  }

  /**
   * @description Initializes a new instance of the DmlConfig class.
   */
  public DmlConfig() {
    this.dmlOptions.optAllOrNone = true;
  }

  /**
   * @description Sets the severity level to `HIGH` for log message on error.
   * @return The current instance of the DmlConfig class.
   */
  public DmlConfig severityHigh() {
    this.optSeverity = Logger.Severity.HIGH;
    return this;
  }

  /**
   * @description Sets the severity level to `CRITICAL` for log message on error.
   * @return The current instance of the DmlConfig class.
   */
  public DmlConfig severityCrit() {
    this.optSeverity = Logger.Severity.CRITICAL;
    return this;
  }

  /**
   * @description Sets the allOrNone option to `false`.
   * @return The current instance of the DmlConfig class.
   */
  public DmlConfig allowPartial() {
    this.dmlOptions.optAllOrNone = false;
    return this;
  }

  /**
   * @description Sets the access level to `SYSTEM_MODE`.
   * @return The current instance of the DmlConfig class.
   */
  public DmlConfig systemMode() {
    this.optAccess = AccessLevel.SYSTEM_MODE;
    return this;
  }

  /**
   * @description Sets the withoutSharing option to `true`.
   * @return The current instance of the DmlConfig class.
   */
  public DmlConfig withoutSharing() {
    this.withoutSharing = true;
    this.optAccess = AccessLevel.SYSTEM_MODE;
    return this;
  }

  /**
   * @description Sets the error message to log in case of an error.
   * @param message The error message to log.
   * @return The current instance of the DmlConfig class.
   */
  public DmlConfig errorLog(String message) {
    this.errorLog = message;
    return this;
  }

  /**
   * @description Sets the configuration to perform empty recycle bin after `doDelete`.
   * @return The updated DmlConfig instance.
   */
  public DmlConfig hardDelete() {
    this.hardDelete = true;
    return this;
  }
}
