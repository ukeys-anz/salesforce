/**
 * @description       : A DTO object used for passing `LoggerSettings__c` details to lightning components
 * @author            : Prakash B
 * @group             : Logging
 * @last modified on  : 11-15-2022
 **/

public class LWCLoggerSettings {
  /**
   * @description Indicates the save method that will be used by default if no other save method is specified, based on `LoggerSettings__c.DefaultSaveMethod__c`
   */
  @AuraEnabled
  public String defaultSaveMethodName { get; set; }

  /**
   * @description A map of the supported `LoggingLevel` enum values
   */
  @AuraEnabled
  public Map<String, Integer> supportedLoggingLevels { get; set; }

  /**
   * @description The configured `LoggingLevel` for the current user, based on `LoggerSettings__c.LoggingLevel__c`
   */
  @AuraEnabled
  public ComponentLoggingLevel userLoggingLevel { get; set; }

  /**
   * @description Constructor for the LWCLoggerSettings class
   */

  public LWCLoggerSettings() {
    this.defaultSaveMethodName = LoggingSettingsController.getDefaultSaveMethod();
    this.supportedLoggingLevels = getSupportedLoggingLevels();
    this.userLoggingLevel = getUserLoggingLevel();
  }

  /**
   * @description Returns the list of supported logging levels
   * @return Map<String,Integer> Map of logging level names and their ordinal values
   */

  private Map<String, Integer> getSupportedLoggingLevels() {
    return new Map<String, Integer>{
      LoggingLevel.ERROR.name() => LoggingLevel.ERROR.ordinal(),
      LoggingLevel.WARN.name() => LoggingLevel.WARN.ordinal(),
      LoggingLevel.INFO.name() => LoggingLevel.INFO.ordinal(),
      LoggingLevel.DEBUG.name() => LoggingLevel.DEBUG.ordinal(),
      LoggingLevel.FINE.name() => LoggingLevel.FINE.ordinal(),
      LoggingLevel.FINER.name() => LoggingLevel.FINER.ordinal(),
      LoggingLevel.FINEST.name() => LoggingLevel.FINEST.ordinal()
    };
  }

  /**
   * @description Returns the user logging level
   * @return ComponentLoggingLevel Class ComponentLoggingLevel based on the user logging level settings
   */

  private ComponentLoggingLevel getUserLoggingLevel() {
    String usrSetting = LoggingSettingsController.getDefaultLoggingLevel();
    return new ComponentLoggingLevel(LoggerHelper.getLoggingLevel(usrSetting));
  }
}
