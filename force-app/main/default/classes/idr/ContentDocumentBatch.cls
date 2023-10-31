/**
 * @author Greg Shaw (shawg2)
 * @since 10/2023
 * @description Process all LogEntry records that record deletion of ContentDocumentLink records and delete the unlinked file.
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class ContentDocumentBatch implements Database.Batchable<sObject>, Database.Stateful {
  /**
   * @description Return a QueryLocator for 'logFileDelete' LogEntry__c records
   * @param bc BatchableContext ignored
   *
   * @return All Closed Cases
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    if (!Schema.ContentDocument.getSObjectType().getDescribe().isDeletable()) {
      Logger.error(
        'User: ' +
        UserInfo.getUserName() +
        ' doesn\'t have sufficient permission to run this process'
      );
      Logger.saveLog();
      // Return an empty query locator
      return Database.getQueryLocator(
        'SELECT Id ' +
        'FROM LogEntry__c ' +
        'WHERE Id = NULL'
      );
    }
    return Database.getQueryLocator(
      'SELECT Id, Name, CreatedDate, ApexClassName__c, ApexMethodName__c, ExceptionMessage__c, LogMessage__c, RecordId__c' +
      ' FROM LogEntry__c' +
      ' WHERE ApexClassName__c = \'ContentDocumentLinkTriggerHandler\'' +
      ' AND ApexMethodName__c = \'logFileDelete\'' +
      ' AND LogMessage__c LIKE \'Doc Deleted%\''
    );
  }

  /**
   * @description Process a batch of LogEntries. Find all ContentDocument Ids from deleted ContentDocumentLink records.
   * @param param1 BatchableContext ignored
   * @param lstLogEntries List of LogEntry__c for scope
   */
  public void execute(
    Database.BatchableContext param1,
    List<LogEntry__c> lstLogEntries
  ) {
    Set<Id> stDocumentIds = new Set<Id>();
    String strContentDocumentPrefix = Schema.ContentDocument.getSObjectType()
      .getDescribe()
      .getKeyPrefix();
    Integer nStart;
    for (LogEntry__c oLogEntry : lstLogEntries) {
      if (oLogEntry.RecordId__c.startsWith(strContentDocumentPrefix)) {
        stDocumentIds.add(oLogEntry.RecordId__c);
      } else if (
        (nStart = oLogEntry.LogMessage__c.indexOf(
          ', ' + strContentDocumentPrefix
        )) != -1
      ) {
        stDocumentIds.add(
          oLogEntry.LogMessage__c.substring(nStart + 2, nStart + 20)
        );
      }
    }
    List<ContentDocument> lstContentDocuments = [
      SELECT Id
      FROM ContentDocument
      WHERE Id IN :stDocumentIds
    ];
    delete lstContentDocuments;
  }
  /**
   * @description To execute any post processing steps
   * @param bc BatchableContext ignored
   */
  public void finish(Database.BatchableContext bc) {
  }
}
