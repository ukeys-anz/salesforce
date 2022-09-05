/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @description Helper class for {@link LogEventBuilder}
 */

@SuppressWarnings(
  'PMD.ApexCRUDViolation'
) // PMD.ApexCRUDViolation - Currently using PermissionUtils to check CRUD and PMD does not accept this. Ignored in class until this rule is ignored in PMD settings.
public with sharing class LogEventBuilderHelper {
  private static final List<String> IGNORED_CLASSES = LogEventBuilderHelper.getIgnoredClasses();
  @TestVisible
  private static Boolean mockBatch = false;
  @TestVisible
  private static Boolean mockFuture = false;
  @TestVisible
  private static Boolean mockQueueable = false;
  @TestVisible
  private static Boolean mockSchedulable = false;
  @TestVisible
  private static Boolean mockTrigger = false;

  /**
   * @description Returns the current user, including parent fields for profile and user role
   * @return String - The current user's record
   */
  @TestVisible
  public static final User CACHED_USER = queryUser();

  /**
   * @description Returns the current org's `Organization` record
   * @return The current org's `Organization` record
   */
  @TestVisible
  public static final Organization CACHED_ORGANIZATION = queryOrganization();

  /**
   * @description Returns the the organization environment type
   * @return String - The organization environment type
   */
  @TestVisible
  public static final String CACHED_ORGANIZATION_ENVIRONMENT_TYPE = getOrganizationEnvironmentType();

  /**
   * @description Returns the organization environment type
   * @return String The organization environment type
   */
  private static String getOrganizationEnvironmentType() {
    String orgEnvironmentType;
    if (
      CACHED_ORGANIZATION.IsSandbox == true &&
      CACHED_ORGANIZATION.TrialExpirationDate != null
    ) {
      orgEnvironmentType = 'Scratch Org';
    } else if (CACHED_ORGANIZATION.IsSandbox == true) {
      orgEnvironmentType = 'Sandbox';
    } else {
      orgEnvironmentType = 'Production';
    }
    return orgEnvironmentType;
  }

  /**
   * @description Returns the org's current API version
   * @return String The org's current API version
   */
  public static String getApiVersion() {
    // Small hack to determine the org's current API version (since Apex doesn't natively provide it)
    // Expected JSON: {"attributes":{"type":"User","url":"/services/data/v53.0/sobjects/User/005J000000AugnYIAR"}
    String userJson = JSON.serialize(new User(Id = UserInfo.getUserId()));
    return userJson.substringAfter('/data/').substringBefore('/sobjects/User');
  }

  /**
   * @description Returns the current organization
   * @return Organization - The current organization
   */
  private static Organization queryOrganization() {
    if (PermissionUtils.canQuery('Organization')) {
      return [
        SELECT
          Id,
          Name,
          InstanceName,
          IsSandbox,
          NamespacePrefix,
          OrganizationType,
          TrialExpirationDate
        FROM Organization
      ];
    }
    return null;
  }

  /**
   * @description Returns the current user
   * @return User The current user
   */
  private static User queryUser() {
    if (PermissionUtils.canQuery('User')) {
      return [
        SELECT
          Id,
          Profile.Name,
          Profile.UserLicenseId,
          Profile.UserLicense.LicenseDefinitionKey,
          Profile.UserLicense.Name,
          Username,
          UserRole.Name
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
    }
    return null;
  }

  /**
   * @description Returns the calling context
   * @return String The calling context
   */
  public static String getTransactionContext() {
    if (isBatchRunning()) {
      return 'Batch';
    }
    if (isFutureRunning()) {
      return 'Future';
    }
    if (isQueuableRunning()) {
      return 'Queueable';
    }
    if (isScheduledRunning()) {
      return 'Schedulable';
    }
    if (isTriggerRunning()) {
      return 'Trigger';
    }
    return 'Synchronous Apex';
  }

  /**
   * @description Returns a list of classes to be ingnored  in the stack trace
   * @return The list of classes to be ignored in the stack trace
   */
  private static List<String> getIgnoredClasses() {
    return new List<String>{
      DatabaseResultHelper.class.getName(),
      LogEventBuilder.class.getName(),
      LogEventBuilderTest.class.getName(),
      LogEventBuilderHelper.class.getName(),
      Logger.class.getName(),
      LoggerTest.class.getName(),
      LoggerHelper.class.getName(),
      LoggerHelperTest.class.getName(),
      LoggingSettingsController.class.getName(),
      LoggingSettingsControllerTest.class.getName()
      // More classes will be added as the logging epic progresses
    };
  }

  /**
   * @description Checks if a stack trace is valid
   * @param stackTraceString  The Apex stack trace string to validate
   * @return If the stack trace is valid
   */
  public static Boolean isValidStackTrace(String stackTraceString) {
    if (String.isBlank(stackTraceString) || stackTraceString == '()') {
      return false;
    }

    return true;
  }

  /**
   * @description Filters ignored classes from stack trace string
   * @param stackTraceString  The stack trace string to be filtered
   * @return A list of stack trace lines exluding ignored classes
   */
  public static List<String> filterStackTraceLines(String stackTraceString) {
    List<String> stackTraceLines = stackTraceString.split('\n');
    Integer ignoreIndex = getIgnoredStacktraceIndex(stackTraceLines);

    for (Integer i = 0; i <= ignoreIndex; i++) {
      stackTraceLines.remove(0);
    }
    return stackTraceLines;
  }

  /**
   * @description Checks for stack trace lines with ignored classes and keep track of the index so we can remove these lines later
   * @param stackTraceLines  The stack trace lines to check
   * @return Index of the lines we need to remove
   */
  private static Integer getIgnoredStacktraceIndex(
    List<String> stackTraceLines
  ) {
    Integer ignoreIndex;
    for (Integer i = 0; i < stackTraceLines.size(); i++) {
      Boolean ignoreLine = false;
      for (String ignoredClass : IGNORED_CLASSES) {
        if (
          stackTraceLines[i].contains('.' + ignoredClass + '.') &&
          !Test.isRunningTest()
        ) {
          ignoreLine = true;
          ignoreIndex = i;
        }
      }
      if (!ignoreLine) {
        break;
      }
    }
    return ignoreIndex;
  }

  /**
   * @description Gets the origin location from the filtered stack trace string
   * @param filteredStackTraceString The stack trace string that has been filtered to exluded ignored classes
   * @return The origin location
   */
  public static String getOriginLocation(String filteredStackTraceString) {
    String originLocation;
    if (isValidStackTrace(filteredStackTraceString)) {
      originLocation = filteredStackTraceString;
      originLocation = originLocation.contains(':')
        ? originLocation.substringBefore(':')
        : originLocation;
      originLocation = originLocation.startsWith('Class.')
        ? originLocation.substringAfter('Class.')
        : originLocation;
    }
    return originLocation;
  }

  /**
   * @description Truncates a string to fit a field's length
   * @param field The field into which the value must fit
   * @param value The value to be truncated to fit in the field
   * @return The truncated value
   */
  public static String truncateFieldValue(
    Schema.SObjectField field,
    String value
  ) {
    Integer fieldMaxLength = field.getDescribe().getLength();
    return value?.left(fieldMaxLength);
  }

  /**
   * @description Checks if batch is running
   * @return If batch is running
   */
  private static Boolean isBatchRunning() {
    return System.isBatch() || (Test.isRunningTest() && mockBatch);
  }

  /**
   * @description Checks if a future job is running
   * @return If a future job is running
   */
  private static Boolean isFutureRunning() {
    return System.isFuture() || (Test.isRunningTest() && mockFuture);
  }

  /**
   * @description Checks if a queueable job is running
   * @return If a queueable job is running
   */
  private static Boolean isQueuableRunning() {
    return System.isQueueable() || (Test.isRunningTest() && mockQueueable);
  }

  /**
   * @description Checks if a schedulead job is running
   * @return If a scheduled job is running
   */
  private static Boolean isScheduledRunning() {
    return System.isScheduled() || (Test.isRunningTest() && mockSchedulable);
  }

  /**
   * @description Checks if a trigger is running
   * @return If a trigger is running
   */
  private static Boolean isTriggerRunning() {
    return Trigger.isExecuting || (Test.isRunningTest() && mockTrigger);
  }
}
