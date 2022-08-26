/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @description Controller class for LoggingSettings custom settings, checking if certain log settings are enabled
 */

public with sharing class LoggingSettingsController {
  private static LoggingSettings__c userSettings = getUserSettings();

  /**
   * @description Returns the specified user's instance of `LoggingSettings__c`
   * @return LoggingSettings__c The specified user's instance of the custom settings
   */
  private static LoggingSettings__c getUserSettings() {
    // Only load the current user's settings once - this allows the instance to be modified in memory (as well as upserted if any changes should be persisted)
    if (userSettings == null) {
      User currentUser = new User(
        Id = UserInfo.getUserId(),
        ProfileId = UserInfo.getProfileId()
      );
      userSettings = getUserSettings(currentUser);
    }
    return userSettings;
  }

  /**
   * @description Sets the value of userSettings
   * @param usrSettings The user settings to be set
   */
  public static void setUserSettings(LoggingSettings__c usrSettings) {
    userSettings = usrSettings;
  }

  /**
   * @description Returns the specified user's instance of `LoggingSettings__c`
   * @param loggingUser The user record - at a minimum, this record should have the user Id and Profile fields populated
   * @return LoggingSettings__c The specified user's instance of the custom settings
   */
  private static LoggingSettings__c getUserSettings(User loggingUser) {
    LoggingSettings__c loggingUserSettings;
    /**
     * We do not need to check for profile or org level because with getInstance(), the fields returned in the custom setting record are merged based on the 
    lowest level fields that are defined in the hierarchy. And at this point, all the fields are mandatory and have a default value. If we add new fields that might
    have null value then we can refactor to use getValues() and check for profile/org level
     */
    loggingUserSettings = LoggingSettings__c.getInstance(loggingUser.Id);

    return loggingUserSettings;
  }

  /**
   * @description Returns if Secure Log is enabled
   * @return Boolean Is Secure Log enabled
   */
  public static Boolean isSecureLogEnabled() {
    return userSettings.SecureLogEnabled__c;
  }

  /**
   * @description Returns the default logging level
   * @return String The default logging level
   */
  public static String getDefaultLoggingLevel() {
    return userSettings.DefaultLoggingLevel__c;
  }

  /**
   * @description Returns the default save method
   * @return String The default save method
   */
  public static String getDefaultSaveMethod() {
    return userSettings.DefaultSaveMethod__c;
  }
}
