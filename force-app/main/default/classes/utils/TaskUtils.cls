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

  /**
   * @description Creates instance of Task from metadata record
   * @param metadataRecord metadata record
   * @return objTask Task instance
   */
  public static Task generateTaskFromMetadata(
    Task_Creation_Mapping__mdt metadataRecord
  ) {
    if (metadataRecord == null) {
      throw new IllegalArgumentException('Metadata record cannot be null');
    }
    Task objTask = new Task(
      OwnerId = QueryQueue.get(metadataRecord.Owner__c).Id,
      Subject = metadataRecord.Subject__c,
      Status = metadataRecord.Status__c,
      Type = metadataRecord.Type__c,
      Priority = metadataRecord.Priority__c,
      Coach_Action__c = metadataRecord.Coach_Action__c,
      RecordTypeId = QueryRT.of(Task.SObjectType)
        .getId(metadataRecord.RecordType_DeveloperName__c)
    );

    return objTask;
  }
}
