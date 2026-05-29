/**
 * @author       : Kritika Sharma
 * @since        : April 2026
 * @description  : ContactPointPhoneRecordTypeBatch updates ContactPointPhone records
 * missing a RecordTypeId to the 'Individual' Record Type.
 */
public class ContactPointPhoneRecordTypeBatch implements Database.Batchable<SObject>, Database.Stateful {
  /**
   * @description Queries ContactPointPhone records where RecordTypeId is null.
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id
        FROM ContactPointPhone
        WHERE
          RecordTypeId = NULL
          AND (ParentId != NULL
          OR Customer_Name__c != NULL)
        ORDER BY ParentId, Customer_Name__c
      ]
    );
  }

  /**
   * @description Updates records in the current batch scope and logs results.
   * @param bc Database.BatchableContext
   * @param scope List of ContactPointPhone records
   */
  public void execute(
    Database.BatchableContext bc,
    List<ContactPointPhone> scope
  ) {
    Id individualRecordTypeId = RTContactPointPhone.individual;

    for (ContactPointPhone cpp : scope) {
      cpp.RecordTypeId = individualRecordTypeId;
    }

    Database.SaveResult[] results = Database.update(scope, false);

    for (Integer i = 0; i < results.size(); i++) {
      if (!results[i].isSuccess()) {
        String errorDetails = String.join(results[i].getErrors(), ', ');
        Logger.error(
          'FAILURE: Record ID ' + scope[i].Id + ' | Errors: ' + errorDetails
        );
      }
    }
    Logger.saveLog();
  }
  /**
   * @description finish method
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
  }
}
