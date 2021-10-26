/**
 *
 * @author Jasmine Nguyen
 * @since Oct 2021
 * @description Utils class for utitlies related to Task object
 */

public with sharing class TaskUtils {
  /**
   * @description Returns the RecordTypeId Developer name passed through
   * @param developerName String - The developer name of the Record Type you wish to query.
   * @return Id Returns the RecordTypeId
   */
  public static Id getTaskRecordTypeIdByDeveloperName(String developerName) {
    if (String.isNotBlank(developerName)) {
      return Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
        .get(developerName)
        .getRecordTypeId();
    }

    return null;
  }
}
