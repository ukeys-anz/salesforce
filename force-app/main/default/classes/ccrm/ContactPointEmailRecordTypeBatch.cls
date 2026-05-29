/**
 * @author       : Kritika Sharma
 * @since        : April 2026
 * @description  : ContactPointEmailRecordTypeBatch is a batch class to update ContactPointEmail records
 * missing a RecordTypeId to the 'Individual' Record Type.
 */
public class ContactPointEmailRecordTypeBatch implements Database.Batchable<SObject>, Database.Stateful {
  private Id individualRecordTypeId;

  /**
   * @description Constructor to initialize individualRecordTypeId for ContactPointEmail
   */
  public ContactPointEmailRecordTypeBatch() {
    individualRecordTypeId = Schema.SObjectType.ContactPointEmail
      .getRecordTypeInfosByDeveloperName()
      .get('Individual')
      .getRecordTypeId();
  }

  /**
   * @description Get all ContactPointEmail records where RecordTypeId is missing
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope of ContactPointEmail records
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id
        FROM ContactPointEmail
        WHERE
          RecordTypeId = NULL
          AND (ParentId != NULL
          OR Customer_Name__c != NULL)
        ORDER BY ParentId, Customer_Name__c
      ]
    );
  }

  /**
   * @description Assigns Individual RecordTypeId and performs a partial update
   * @param bc Database.BatchableContext
   * @param scope List of ContactPointEmail records
   */
  public void execute(
    Database.BatchableContext bc,
    List<ContactPointEmail> scope
  ) {
    for (ContactPointEmail cpe : scope) {
      cpe.RecordTypeId = individualRecordTypeId;
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
